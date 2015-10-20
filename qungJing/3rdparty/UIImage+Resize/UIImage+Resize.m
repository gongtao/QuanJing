// UIImage+Resize.m
// Created by Trevor Harmon on 8/5/09.
// Free for personal or commercial use, with or without modification.
// No warranty is expressed or implied.

#import "UIImage+Resize.h"


#import "StandardPaths.h"
@implementation UIImage (Resize)

// Returns a copy of this image that is cropped to the given bounds.
// The bounds will be adjusted using CGRectIntegral.
// This method does not ignore the image's imageOrientation setting.
- (UIImage *)croppedImage:(CGRect)bounds {
    CGAffineTransform txTranslate;
    CGAffineTransform txCompound;
    CGRect adjustedBounds;
    BOOL drawTransposed;
    
    switch (self.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            txTranslate = CGAffineTransformMakeTranslation(self.size.width, self.size.height);
//            txCompound = CGAffineTransformRotate(txTranslate, M_PI);
            adjustedBounds = CGRectApplyAffineTransform(bounds, txCompound);
            drawTransposed = NO;
            break;
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            txTranslate = CGAffineTransformMakeTranslation(self.size.height, 0.0);
//            txCompound = CGAffineTransformRotate(txTranslate, M_PI_2);
            adjustedBounds = CGRectApplyAffineTransform(bounds, txCompound);
            drawTransposed = YES;
            break;
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            txTranslate = CGAffineTransformMakeTranslation(0.0, self.size.width);
//            txCompound = CGAffineTransformRotate(txTranslate, M_PI + M_PI_2);
            adjustedBounds = CGRectApplyAffineTransform(bounds, txCompound);
            drawTransposed = YES;
            break;
        default:
            adjustedBounds = bounds;
            drawTransposed = NO;
    }
    
    CGImageRef imageRef = CGImageCreateWithImageInRect([self CGImage], adjustedBounds);
    UIImage *croppedImage;
    if (CGRectEqualToRect(adjustedBounds, bounds))
        croppedImage = [UIImage imageWithCGImage:imageRef scale:self.scale orientation:self.imageOrientation];
    else
        croppedImage = [self resizedImage:imageRef
                                     size:bounds.size
                                transform:[self transformForOrientation:bounds.size]
                           drawTransposed:drawTransposed
                     interpolationQuality:kCGInterpolationHigh];
    CGImageRelease(imageRef);
    return croppedImage;
}

// Returns a copy of this image that is squared to the thumbnail size.
// If transparentBorder is non-zero, a transparent border of the given size will be added around the edges of the thumbnail. (Adding a transparent border of at least one pixel in size has the side-effect of antialiasing the edges of the image when rotating it using Core Animation.)
- (UIImage *)thumbnailImage:(NSInteger)thumbnailSize
       interpolationQuality:(CGInterpolationQuality)quality {
    UIImage *resizedImage = [self resizedImageWithContentMode:UIViewContentModeScaleAspectFill
                                                       bounds:CGSizeMake(thumbnailSize, thumbnailSize)
                                         interpolationQuality:quality];
    
    // Crop out any part of the image that's larger than the thumbnail size
    // The cropped rect must be centered on the resized image
    // Round the origin points so that the size isn't altered when CGRectIntegral is later invoked
    CGRect cropRect = CGRectMake(round((resizedImage.size.width - thumbnailSize) / 2),
                                 round((resizedImage.size.height - thumbnailSize) / 2),
                                 thumbnailSize,
                                 thumbnailSize);
    UIImage *croppedImage = [resizedImage croppedImage:cropRect];
    
    return croppedImage;
}

// Returns a rescaled copy of the image, taking into account its orientation
// The image will be scaled disproportionately if necessary to fit the bounds specified by the parameter
- (UIImage *)resizedImage:(CGSize)newSize interpolationQuality:(CGInterpolationQuality)quality {
    BOOL drawTransposed;
    
    switch (self.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            drawTransposed = YES;
            break;
            
        default:
            drawTransposed = NO;
    }
    
    return [self resizedImage:newSize
                    transform:[self transformForOrientation:newSize]
               drawTransposed:drawTransposed
         interpolationQuality:quality];
}
//
- (UIImage *)resizedImage:(CGSize)newSize
                transform:(CGAffineTransform)transform
           drawTransposed:(BOOL)transpose
     interpolationQuality:(CGInterpolationQuality)quality {
    
    CGFloat screenScale = SP_SCREEN_SCALE();
    
    CGRect newRect = CGRectIntegral(CGRectMake(0, 0, newSize.width, newSize.height));
    CGRect transposedRect = CGRectMake(0, 0, newRect.size.height, newRect.size.width);
    CGImageRef imageRef = self.CGImage;
    
    // Build a context that's the same dimensions as the new size
    CGContextRef bitmap = CGBitmapContextCreate(NULL,
                                                newRect.size.width,
                                                newRect.size.height,
                                                CGImageGetBitsPerComponent(imageRef),
                                                0,
                                                CGImageGetColorSpace(imageRef),
                                                CGImageGetBitmapInfo(imageRef));
    
    if (bitmap == NULL) {
        NSLog(@"Failed context creation - image format is not supported by device. To force creation, try setting colorspace as CGColorSpaceCreateDeviceRGB() and/or bitmapinfo as kCGImageAlphaNone");
    } else {
        
        // Rotate and/or flip the image if required by its orientation
        CGContextConcatCTM(bitmap, transform);
        
        // Set the quality level to use when rescaling
        CGContextSetInterpolationQuality(bitmap, quality);
        
        // Draw into the context; this scales the image
        CGContextDrawImage(bitmap, transpose ? transposedRect : newRect, imageRef);
        
        // Get the resized image from the context and a UIImage
        CGImageRef newImageRef = CGBitmapContextCreateImage(bitmap);
        UIImage *newImage = [UIImage imageWithCGImage:newImageRef scale:screenScale orientation:UIImageOrientationUp];
        
        // Clean up
        CGContextRelease(bitmap);
        CGImageRelease(newImageRef);
        
        return newImage;
    }
    return nil;
}

// Resizes the image according to the given content mode, taking into account the image's orientation
- (UIImage *)resizedImageWithContentMode:(UIViewContentMode)contentMode
                                  bounds:(CGSize)bounds
                    interpolationQuality:(CGInterpolationQuality)quality {
    CGFloat horizontalRatio = bounds.width / self.size.width;
    CGFloat verticalRatio = bounds.height / self.size.height;
    CGFloat ratio;
    
    switch (contentMode) {
        case UIViewContentModeScaleAspectFill:
            ratio = MAX(horizontalRatio, verticalRatio);
            break;
            
        case UIViewContentModeScaleAspectFit:
            ratio = MIN(horizontalRatio, verticalRatio);
            break;

        default:
            DDLogError(@"Unsupported contentMode: %d", contentMode);
            ratio = MIN(horizontalRatio, verticalRatio);
            break;
    }
    
    CGSize newSize = CGSizeMake(self.size.width * ratio, self.size.height * ratio);
    
    return [self resizedImage:newSize interpolationQuality:quality];
}

    //图片旋转
//    - (UIImage *)fixOrientation:(CGSize)newSize interpolationQuality:(CGInterpolationQuality)quality {
//        
//        // No-op if the orientation is already correct
//        if (self.imageOrientation == UIImageOrientationUp)
//            return [self resizedImage:newSize
//                            transform:[self transformForOrientation:newSize]
//                       drawTransposed:NO
//                 interpolationQuality:quality];
//        
//        // We need to calculate the proper transformation to make the image upright.
//        // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
//        CGAffineTransform transform = CGAffineTransformIdentity;
//        
//        switch (self.imageOrientation) {
//            case UIImageOrientationDown:
//            case UIImageOrientationDownMirrored:
//                transform = CGAffineTransformTranslate(transform, self.size.width, self.size.height);
//                transform = CGAffineTransformRotate(transform, M_PI);
//                break;
//                
//            case UIImageOrientationLeft:
//            case UIImageOrientationLeftMirrored:
//                transform = CGAffineTransformTranslate(transform, self.size.width, 0);
//                transform = CGAffineTransformRotate(transform, M_PI_2);
//                break;
//                
//            case UIImageOrientationRight:
//            case UIImageOrientationRightMirrored:
//                transform = CGAffineTransformTranslate(transform, 0, self.size.height);
//                transform = CGAffineTransformRotate(transform, -M_PI_2);
//                break;
//            default:
//                break;
//        }
//        
//        switch (self.imageOrientation) {
//            case UIImageOrientationUpMirrored:
//            case UIImageOrientationDownMirrored:
//                transform = CGAffineTransformTranslate(transform, self.size.width, 0);
//                transform = CGAffineTransformScale(transform, -1, 1);
//                break;
//                
//            case UIImageOrientationLeftMirrored:
//            case UIImageOrientationRightMirrored:
//                transform = CGAffineTransformTranslate(transform, self.size.height, 0);
//                transform = CGAffineTransformScale(transform, -1, 1);
//                break;
//            default:
//                break;
//        }
//        
//        // Now we draw the underlying CGImage into a new context, applying the transform
//        // calculated above.
//        CGContextRef ctx = CGBitmapContextCreate(NULL, self.size.width, self.size.height,
//                                                 CGImageGetBitsPerComponent(self.CGImage), 0,
//                                                 CGImageGetColorSpace(self.CGImage),
//                                                 CGImageGetBitmapInfo(self.CGImage));
//        CGContextConcatCTM(ctx, transform);
//        switch (self.imageOrientation) {
//            case UIImageOrientationLeft:
//            case UIImageOrientationLeftMirrored:
//            case UIImageOrientationRight:
//            case UIImageOrientationRightMirrored:
//                // Grr...
//                CGContextDrawImage(ctx, CGRectMake(0,0,self.size.height,self.size.width), self.CGImage);
//                break;
//                
//            default:
//                CGContextDrawImage(ctx, CGRectMake(0,0,self.size.width,self.size.height), self.CGImage);
//                break;
//        }
//        
//        // And now we just create a new UIImage from the drawing context
//        CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
//        UIImage *img = [UIImage imageWithCGImage:cgimg];
//        CGContextRelease(ctx);
//        CGImageRelease(cgimg);
//        return img;
//    }


#pragma mark -
#pragma mark Private helper methods

// Returns a copy of the image that has been transformed using the given affine transform and scaled to the new size
// The new image's orientation will be UIImageOrientationUp, regardless of the current image's orientation
// If the new size is not integral, it will be rounded up
- (UIImage *)resizedImage:(CGImageRef)imageRef
                     size:(CGSize)newSize
                transform:(CGAffineTransform)transform
           drawTransposed:(BOOL)transpose
     interpolationQuality:(CGInterpolationQuality)quality {
    CGRect newRect;
    if ([self respondsToSelector:@selector(scale)])
        newRect = CGRectIntegral(CGRectMake(0, 0, newSize.width * self.scale, newSize.height * self.scale));
    else
        newRect = CGRectIntegral(CGRectMake(0, 0, newSize.width, newSize.height));
    CGRect transposedRect = CGRectMake(0, 0, newRect.size.height, newRect.size.width);
    //CGImageRef imageRef = self.CGImage;
    
    // Build a context that's the same dimensions as the new size
    CGContextRef bitmap = CGBitmapContextCreate(NULL,
                                                newRect.size.width,
                                                newRect.size.height,
                                                CGImageGetBitsPerComponent(imageRef),
                                                0,
                                                CGImageGetColorSpace(imageRef),
                                                CGImageGetBitmapInfo(imageRef));
    
    // Rotate and/or flip the image if required by its orientation
    CGContextConcatCTM(bitmap, transform);
    
    // Set the quality level to use when rescaling
    CGContextSetInterpolationQuality(bitmap, quality);
    
    // Draw into the context; this scales the image
    CGContextDrawImage(bitmap, transpose ? transposedRect : newRect, imageRef);
    
    // Get the resized image from the context and a UIImage
    CGImageRef newImageRef = CGBitmapContextCreateImage(bitmap);
    UIImage *newImage;
    if ([self respondsToSelector:@selector(scale)] && [UIImage respondsToSelector:@selector(imageWithCGImage:scale:orientation:)]) {
    	newImage = [UIImage imageWithCGImage:newImageRef scale:self.scale orientation:self.imageOrientation];
    } else {
    	newImage = [UIImage imageWithCGImage:newImageRef];
    }

    // Clean up
    CGContextRelease(bitmap);
    CGImageRelease(newImageRef);
    
    return newImage;
}

// Returns an affine transform that takes into account the image orientation when drawing a scaled image
- (CGAffineTransform)transformForOrientation:(CGSize)newSize {
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (self.imageOrientation) {
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
        case UIImageOrientationDown:           // EXIF = 3
        case UIImageOrientationDownMirrored:   // EXIF = 4
            transform = CGAffineTransformTranslate(transform, newSize.width, newSize.height);
//            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:           // EXIF = 6
        case UIImageOrientationLeftMirrored:   // EXIF = 5
            transform = CGAffineTransformTranslate(transform, newSize.width, 0);
//            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:          // EXIF = 8
        case UIImageOrientationRightMirrored:  // EXIF = 7
            transform = CGAffineTransformTranslate(transform, 0, newSize.height);
//            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
    }
    
    switch (self.imageOrientation) {
        case UIImageOrientationUp:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
        case UIImageOrientationDown:
            break;
            
        case UIImageOrientationUpMirrored:     // EXIF = 2
        case UIImageOrientationDownMirrored:   // EXIF = 4
            transform = CGAffineTransformTranslate(transform, newSize.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:   // EXIF = 5
        case UIImageOrientationRightMirrored:  // EXIF = 7
            transform = CGAffineTransformTranslate(transform, newSize.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
    }
    
    return transform;

}

@end