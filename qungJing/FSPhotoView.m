//
//  FSPhotoView.m
//  FSPhotoView
//
//  Created by Stephen Jin on 7/26/13.
//  Copyright (c) 2013 Stephen Jin. All rights reserved.
//

#import "FSPhotoView.h"
#import "SDWebImageManager.h"

#import <ALAssetsLibrary-CustomPhotoAlbum/ALAssetsLibrary+CustomPhotoAlbum.h>
@interface FSPhotoView () <UIScrollViewDelegate> {
    BOOL    _disableAutoLayout;
    UIViewContentMode ivContentMode;
}
@property (nonatomic, retain) UIImageView       *imageView;
@property (nonatomic, assign) CGRect            senderFrame;
@property (nonatomic, assign) CGRect            clipsFrame;
@property (nonatomic, assign) CGFloat           offscreenY;
@property (copy)              DisappearBlcok    block;


@property (nonatomic, retain)NSString       *imageUrl;

- (void)displayImage:(UIImage *)newImage withSenderView:(UIImageView*)senderView;
@end

@implementation FSPhotoView

+ (FSPhotoView *)showImageWithSenderViewWithUrl:(NSString*)url
{
    UIImageView *senderView = [[UIImageView alloc]init];
    [senderView setImageWithURL:[NSURL URLWithString:url]];
    
    if (nil == senderView.image) return nil;
    return [FSPhotoView showImageWithSenderView:senderView completion:nil withUrl:url];

}

+ (FSPhotoView *)showImageWithSenderView:(UIImageView*)senderView;
{
    if (nil == senderView.image) return nil;
    return [FSPhotoView showImageWithSenderView:senderView completion:nil];
}

+ (FSPhotoView *)showImageWithSenderView:(UIImageView*)senderView completion:(DisappearBlcok)completed withUrl:(NSString *)url;
{
    if (nil == senderView.image) return nil;
    
    // Deal with staus bar.
    CGRect rect = [UIScreen mainScreen].bounds;
    
    if (![UIApplication sharedApplication].statusBarHidden)
    {
        rect.size.height = [UIScreen mainScreen].bounds.size.height-20.f;
        rect.origin.y += [UIApplication sharedApplication].statusBarHidden?0:20.f;
    }
    
    FSPhotoView *photoView = [[FSPhotoView alloc] initWithFrame:rect andCompleteBlock:completed withUrl:url];
    if (photoView)
    {
        [[UIApplication sharedApplication].keyWindow addSubview:photoView];
        [photoView displayImage:senderView.image withSenderView:senderView];
    }
    
    return [photoView autorelease];
}

- (id)initWithFrame:(CGRect)frame andCompleteBlock:(DisappearBlcok)block withUrl:(NSString *)url
{
    self = [super initWithFrame:frame];
    _imageUrl =url;
    if (self) {
        // Initialization code
        self.block = block;
        [self setDelegate:self];
        [self setMaximumZoomScale:2.f];
        [self setShowsHorizontalScrollIndicator:NO];
        [self setShowsVerticalScrollIndicator:NO];
        [self loadSubviewsWithFrame:frame];
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(removePhotoView)];
        [singleTap setNumberOfTapsRequired:1];
        [self addGestureRecognizer:singleTap];
        [singleTap release];
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(zoomToLocation:)];
        [doubleTap setNumberOfTapsRequired:2];
        [self addGestureRecognizer:doubleTap];
        [singleTap requireGestureRecognizerToFail:doubleTap];
        [doubleTap release];
        
        UILongPressGestureRecognizer *longPress =
        [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                      action:@selector(saveImagewithUrl:)];
        //代理
        longPress.delegate = self;
        longPress.minimumPressDuration = 1.0;
        //将长按手势添加到需要实现长按操作的视图里
        [self addGestureRecognizer:longPress];
        [longPress release];
    }
    return self;
}

- (void)loadSubviewsWithFrame:(CGRect)frame
{
    self.imageView = [[[UIImageView alloc] initWithFrame:frame] autorelease];
    [self addSubview:self.imageView];
}

#pragma mark - Display Functions
- (void)displayImage:(UIImage *)newImage withSenderView:(UIImageView*)senderView
{
    CGSize  frameSize = self.frame.size;
    CGSize  imageSize = newImage.size;
    CGFloat xScale = frameSize.width  / imageSize.width;    // the scale needed to perfectly fit the image width-wise
    CGFloat yScale = frameSize.height / imageSize.height;   // the scale needed to perfectly fit the image height-wise
    CGFloat minScale = MIN(xScale, yScale);                 // use minimum of these to allow the image to become fully visible
    CGRect  photoImageViewFrame;
    
    if (xScale > 1 && yScale > 1)
    {
        photoImageViewFrame.origin = CGPointZero;
        photoImageViewFrame.size.height = newImage.size.height*minScale;
        photoImageViewFrame.size.width = newImage.size.width*minScale;
        [self imageView].frame = photoImageViewFrame;
        self.contentSize = photoImageViewFrame.size;
        [self imageView].image = newImage;
        minScale = 1;
    }
    else
    {
        photoImageViewFrame.origin = CGPointZero;
        photoImageViewFrame.size = newImage.size;
        [self imageView].frame = photoImageViewFrame;
        self.contentSize = photoImageViewFrame.size;
        [self imageView].image = newImage;
    }
    
    self.maximumZoomScale = 2.f*minScale;//maxScale;
    self.minimumZoomScale = minScale;
    self.zoomScale = minScale;

    _disableAutoLayout = NO;
    [self layoutIfNeeded];  // call layoutSubviews
    
    [self configAnimationDisplay:senderView];
}

//Image in PhotoView cannot be zoom in without this function. 
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

- (BOOL)isZoomed
{
    return !([self zoomScale] == [self minimumZoomScale]);
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    if (_disableAutoLayout) return;

    // Center the image as it becomes smaller than the size of the screen
    CGSize boundsSize = [self bounds].size;
    CGRect frameToCenter = [self imageView].frame;
    
    // Horizontally
    if (frameToCenter.size.width < boundsSize.width)
    {
        frameToCenter.origin.x = floorf((boundsSize.width - frameToCenter.size.width) / 2.0);
	}
    else
    {
        frameToCenter.origin.x = 0;
	}
    
    // Vertically
    if (frameToCenter.size.height < boundsSize.height)
    {
        frameToCenter.origin.y = floorf((boundsSize.height - frameToCenter.size.height) / 2.0);
	}
    else
    {
        frameToCenter.origin.y = 0;
	}
    
	// Center
	if (!CGRectEqualToRect([self imageView].frame, frameToCenter))
    {
        [self imageView].frame = frameToCenter;
    }
}

- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center
{
    CGRect zoomRect;
    
    zoomRect.size.height = self.frame.size.height / scale;
    zoomRect.size.width  = self.frame.size.width  / scale;
    zoomRect.origin.x = center.x/self.zoomScale - (zoomRect.size.width  /2.0 );
    zoomRect.origin.y = center.y/self.zoomScale - (zoomRect.size.height /2.0 );
    
    zoomRect.origin.x -= (self.bounds.size.width - self.imageView.frame.size.width)/2/self.zoomScale;
    
    if (center.y < self.bounds.size.height/2 && self.imageView.frame.size.height < self.imageView.frame.size.width)
    {
        zoomRect.origin.y -= (self.bounds.size.height - self.imageView.frame.size.height)/self.zoomScale ;
    }
    else
    {
        zoomRect.origin.y -= (self.bounds.size.height - self.imageView.frame.size.height)/2/self.zoomScale;
    }
    return zoomRect;
}

#pragma mark - Config Animation Methods
- (void)normalModeShowWithSenderView:(UIView*)senderView
{
    UIImageView *oriImageView = (UIImageView *)senderView;
    CGRect curFrame = [self imageView].frame;

    CGRect oriFrame     = [oriImageView.superview convertRect:oriImageView.frame toView:self];
    self.senderFrame    = oriFrame;
    [[self imageView] setFrame:oriFrame];
    
    if (oriFrame.origin.y<44)
    {
        _disableAutoLayout = YES;
        
        self.offscreenY = (oriFrame.origin.y<0)?(fabs(oriFrame.origin.y)+44):(44-oriFrame.origin.y);
        [[self imageView] setFrame:CGRectMake(oriFrame.origin.x, -self.offscreenY, oriFrame.size.width, oriFrame.size.height)];
        
        oriFrame.origin.y = 44.f;
        oriFrame.size.height -= self.offscreenY;

        CGRect clipRect = oriFrame;
        clipRect.origin.x = 0.f;
        clipRect.size.width = 320.f;
        UIView *clipsView = [[[UIView alloc] initWithFrame:clipRect] autorelease];
        [clipsView setClipsToBounds:YES];
        [clipsView setBackgroundColor:[UIColor clearColor]];
        [[self imageView] removeFromSuperview];
        [clipsView addSubview:self.imageView];
        [self addSubview:clipsView];
        
        [self setBackgroundColor:[UIColor clearColor]];
        [UIView animateWithDuration:.3f delay:.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [self setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.95f]];
            [clipsView setFrame:curFrame];
            [self.imageView setFrame:CGRectMake((320-curFrame.size.width)/2, 0, curFrame.size.width, curFrame.size.height)];
        } completion:^(BOOL finished) {
            _disableAutoLayout = NO;
            [self.imageView removeFromSuperview];
            [self.imageView setFrame:curFrame];
            [clipsView removeFromSuperview];
            [self addSubview:self.imageView];
        }];
    }
    else
    {
        [self setBackgroundColor:[UIColor clearColor]];
        [UIView animateWithDuration:.3f delay:.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [self setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.95f]];
            [[self imageView] setFrame:curFrame];
        } completion:^(BOOL finished) {}];
    }
}

- (void)configAnimationDisplay:(UIImageView *)senderView
{
    if (nil == senderView) return;
    
    self.offscreenY = 0.f;
    
    switch (senderView.contentMode) {
        case UIViewContentModeScaleAspectFit:
            ivContentMode = UIViewContentModeScaleAspectFit;
            [self aspectFillModeShowWithSenderView:senderView];
            break;
        case UIViewContentModeScaleAspectFill:
            ivContentMode = UIViewContentModeScaleAspectFill;
            [self aspectFillModeShowWithSenderView:senderView];
            break;
        default:
            ivContentMode = UIViewContentModeScaleToFill;
            [self normalModeShowWithSenderView:senderView];
            break;
    }
}

- (void)aspectFillModeShowWithSenderView:(UIView*)senderView
{
    UIImageView *oriImageView = (UIImageView *)senderView;
    CGRect curFrame = [self imageView].frame;
    
    _disableAutoLayout = YES;
    
    CGRect clipFrame = [senderView.superview convertRect:senderView.frame toView:self];
    
    if (clipFrame.origin.y<44)
    {
        self.offscreenY = (clipFrame.origin.y<0)?(fabs(clipFrame.origin.y)+44):(44-clipFrame.origin.y);
        clipFrame.origin.y = 44.f;
        clipFrame.size.height -= self.offscreenY;
    }
    self.clipsFrame = clipFrame;
    
    UIView *clipsView = [[[UIView alloc] initWithFrame:clipFrame] autorelease];
    [clipsView setClipsToBounds:YES];
    [[self imageView] removeFromSuperview];
    [clipsView addSubview:self.imageView];
    [self addSubview:clipsView];
        
    CGRect convertRect = senderView.frame;
    CGFloat hImageRate = oriImageView.image.size.height/oriImageView.image.size.width;
    CGFloat hViewRate = oriImageView.frame.size.height/oriImageView.frame.size.width;

    if ( (ivContentMode == UIViewContentModeScaleAspectFill && hImageRate > hViewRate) ||
         (ivContentMode == UIViewContentModeScaleAspectFit  && hImageRate < hViewRate) )
    {
        convertRect.size.height = oriImageView.image.size.height*senderView.frame.size.width/oriImageView.image.size.width;
        convertRect.origin.y = senderView.frame.origin.y - (convertRect.size.height-senderView.frame.size.height)*0.5f;
    }
    else
    {
        convertRect.size.width = oriImageView.image.size.width*senderView.frame.size.height/oriImageView.image.size.height;
        convertRect.origin.x = senderView.frame.origin.x - (convertRect.size.width-senderView.frame.size.width)*0.5f;
    }
    
    CGRect oriFrame = [senderView.superview convertRect:convertRect toView:clipsView];
    self.senderFrame = oriFrame;
    [[self imageView] setFrame:oriFrame];
    
    [self setBackgroundColor:[UIColor clearColor]];
    [UIView animateWithDuration:.3f delay:.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [self setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.95f]];
        [clipsView setFrame:curFrame];
        [self.imageView setFrame:CGRectMake(0, 0, curFrame.size.width, curFrame.size.height)];
    } completion:^(BOOL finished) {
        _disableAutoLayout = NO;
        [self.imageView removeFromSuperview];
        [self.imageView setFrame:curFrame];
        [clipsView removeFromSuperview];
        [self addSubview:self.imageView];
    }];
}

#pragma mark - PhotoView Clicked Methods
- (void)zoomToLocation:(UITapGestureRecognizer *)tapGes
{
    if ([self isZoomed])
    {
        [self setZoomScale:self.minimumZoomScale animated:YES];
    }
    else
    {
        CGRect zoomRect = [self zoomRectForScale:self.maximumZoomScale withCenter:[tapGes locationInView:self]];
        [self zoomToRect:zoomRect animated:YES];
    }
}

-(void)saveImagewithUrl:(NSString *)url
{
//    NSLog(@"dddddddddddddddddddd");
    url =_imageUrl;
        [SVProgressHUD showWithStatus:@"保存图片中..." maskType:SVProgressHUDMaskTypeBlack];
        
        SDWebImageManager* manager = [SDWebImageManager sharedManager];
        NSURL* url1 = [NSURL URLWithString:url];
        [manager downloadWithURL:url1
                         options:SDWebImageHighPriority
                        progress:nil
                       completed:^(UIImage* image, NSError* error, SDImageCacheType cacheType, BOOL finished){
                           if (image != nil)
                           {
                               ALAssetsLibrary* assetsLibrary = [[ALAssetsLibrary alloc] init];
                               [assetsLibrary saveImage:image
                                                toAlbum:@"全景"
                                             completion:^(NSURL* assetURL, NSError* error){
                                                 [SVProgressHUD showSuccessWithStatus:@"保存成功"];
                                             }
                                                failure:^(NSError* error){
                                                    [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"保存失败: %@", error.localizedDescription]];
                                                }];
                           }
                           else
                           {
                               [SVProgressHUD showSuccessWithStatus:@"无法下载图片，请稍后再试。"];
                           }
                       }];
    

}

- (void)removePhotoView
{
    _disableAutoLayout = YES;

    if (ivContentMode != UIViewContentModeScaleToFill)
    {
        UIView *clipView = [[[UIView alloc] initWithFrame:[self imageView].frame] autorelease];
        [clipView setClipsToBounds:YES];
        [self.imageView removeFromSuperview];
        [self.imageView setFrame:CGRectMake(0, 0, CGRectGetWidth([self imageView].frame), CGRectGetHeight([self imageView].frame))];
        [clipView addSubview:self.imageView];
        [self addSubview:clipView];
        
        [UIView animateWithDuration:0.3f animations:^{
            [clipView setFrame:self.clipsFrame];
            if ([self isZoomed])
            {
                [self setContentOffset:CGPointMake(0.f, 0.f)];
            }
            [[self imageView] setFrame:self.senderFrame];
        }];
        
        [UIView animateWithDuration:0.5f animations:^{
            [self setBackgroundColor:[UIColor clearColor]];
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
            if (_block) _block(YES);
        }];
    }
    else
    {
        if (self.offscreenY != 0)
        {
            UIView *clipView = [[[UIView alloc] initWithFrame:[self imageView].frame] autorelease];
            [clipView setClipsToBounds:YES];
            [self.imageView removeFromSuperview];
            [self.imageView setFrame:CGRectMake(0, 0, CGRectGetWidth([self imageView].frame), CGRectGetHeight([self imageView].frame))];
            [clipView addSubview:self.imageView];
            [self addSubview:clipView];
            
            CGRect clipOriFrame = self.imageView.frame;
            clipOriFrame.origin.y = 44.f;
            clipOriFrame.size.height -= self.offscreenY;
            
            [UIView animateWithDuration:0.3f animations:^{
                [clipView setFrame:clipOriFrame];
                if ([self isZoomed])
                {
                    [self setContentOffset:CGPointMake(0.f, 0.f)];
                }
                [[self imageView] setFrame:CGRectMake(self.senderFrame.origin.x, -self.offscreenY, self.senderFrame.size.width, self.senderFrame.size.height)];
            }];
            
            [UIView animateWithDuration:.5f animations:^{
                [self setBackgroundColor:[UIColor clearColor]];
            } completion:^(BOOL finished) {
                [self removeFromSuperview];
                if (_block) _block(YES);
            }];
        }
        else
        {
            [UIView animateWithDuration:0.3f animations:^{
                if ([self isZoomed])
                {
                    [self setContentOffset:CGPointMake(0.f, 0.f)];
                }
                [[self imageView] setFrame:self.senderFrame];
            }];
            
            [UIView animateWithDuration:.5f animations:^{
                [self setBackgroundColor:[UIColor clearColor]];
            } completion:^(BOOL finished) {
                [self removeFromSuperview];
                if (_block) _block(YES);
            }];
        }
    }
}
//- (void)downloadAsset
//{
//    [SVProgressHUD showWithStatus:@"保存图片中..." maskType:SVProgressHUDMaskTypeBlack];
//    
//    SDWebImageManager* manager = [SDWebImageManager sharedManager];
//    NSURL* url = [NSURL URLWithString:self.asset.imageInfo.url];
//    [manager downloadWithURL:url
//                     options:SDWebImageHighPriority
//                    progress:nil
//                   completed:^(UIImage* image, NSError* error, SDImageCacheType cacheType, BOOL finished){
//                       if (image != nil)
//                       {
//                           ALAssetsLibrary* assetsLibrary = [[ALAssetsLibrary alloc] init];
//                           [assetsLibrary saveImage:image
//                                            toAlbum:@"全景"
//                                         completion:^(NSURL* assetURL, NSError* error){
//                                             [SVProgressHUD showSuccessWithStatus:@"保存成功"];
//                                         }
//                                            failure:^(NSError* error){
//                                                [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"保存失败: %@", error.localizedDescription]];
//                                            }];
//                       }
//                       else
//                       {
//                           [SVProgressHUD showSuccessWithStatus:@"无法下载图片，请稍后再试。"];
//                       }
//                   }];
//}
- (void)dealloc
{
    self.imageView = nil;
    [super dealloc];
}

@end
