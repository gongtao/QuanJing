//
//  OWTImageView.m
//  Weitu
//
//  Created by Su on 4/23/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import "OWTImageView.h"
#import "OWTImageInfo.h"
#import <SDWebImage/UIImageView+WebCache.h>

#import <NSLayoutConstraint+ExpressionFormat/NSLayoutConstraint+ExpressionFormat.h>
#import <UIView+Positioning/UIView+Positioning.h>
#import <UIColor-HexString/UIColor+HexString.h>

@interface OWTImageView()

@property (nonatomic, assign) CGSize imageSize;
@property (nonatomic, strong) NSLayoutConstraint* aspectRatioConstraint;

@end

@implementation OWTImageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self setup];
    }
    return self;
}

- (void)setup
{
    _fadeTransitionEnabled = YES;
    _maintainAspectRatio = YES;

    self.contentMode = UIViewContentModeScaleAspectFill;

    self.clipsToBounds = YES;
    self.opaque = YES;
}

- (void)setImageWithImage:(UIImage*)image
{
    [self cancelCurrentImageLoad];

    _imageSize = image.size;
    [self updateAspectRatio];
    self.image = image;
}

- (void)setImageWithImageAsThumbnail:(UIImage*)image
{
    [self cancelCurrentImageLoad];

    _imageSize = [self squaredSizeForImageSize:image.size];
    [self updateAspectRatio];

    self.image = image;
}

- (CGSize)squaredSizeForImageSize:(CGSize)imageSize
{
    CGFloat maxLength = MAX(imageSize.width, imageSize.height);
    return CGSizeMake(maxLength, maxLength);
}

- (CGSize)sizeForImageSize:(CGSize)imageSize aspectRatio:(CGFloat)aspectRatio
{
    CGFloat originalAspectRatio = imageSize.width / imageSize.height;
    if (originalAspectRatio > aspectRatio)
    {
        CGSize newSize;
        newSize.height = imageSize.height;
        newSize.width = newSize.height * aspectRatio;
        return newSize;
    }
    else
    {
        CGSize newSize;
        newSize.width = imageSize.width;
        newSize.height = newSize.width / aspectRatio;
        return newSize;
    }
}

- (void)setImageWithInfo:(OWTImageInfo*)imageInfo
{
    if (imageInfo != nil)
    {
        [self setImageWithURLString:imageInfo.url
                          imageSize:imageInfo.imageSize
                       primaryColor:imageInfo.primaryColor];
    }
    else
    {
        [self clearImageAnimated:NO];
    }
}

- (void)setImageWithInfoAsThumbnail:(OWTImageInfo*)imageInfo
{
    if (imageInfo != nil)
    {
        [self setImageWithURLString:imageInfo.thumbnailURL
                          imageSize:[self squaredSizeForImageSize:imageInfo.imageSize]
                       primaryColor:imageInfo.primaryColor];
    }
    else
    {
        self.backgroundColor = [UIColor lightGrayColor];
        [self clearImageAnimated:YES];
    }
}

- (void)setImageWithInfo:(OWTImageInfo*)imageInfo desiredAspectRatio:(CGFloat)aspectRatio
{
    if (imageInfo != nil)
    {
        [self setImageWithURLString:imageInfo.thumbnailURL
                          imageSize:[self sizeForImageSize:imageInfo.imageSize aspectRatio:aspectRatio]
                       primaryColor:imageInfo.primaryColor];
    }
    else
    {
        self.backgroundColor = [UIColor lightGrayColor];
        [self clearImageAnimated:YES];
    }
}

- (void)setImageWithURLString:(NSString*)urlString imageSize:(CGSize)imageSize primaryColor:(UIColor*)primaryColor
{
    NSURL* url = [NSURL URLWithString:urlString];
    [self setImageWithURL:url imageSize:imageSize primaryColor:primaryColor];
}

- (void)setImageWithURL:(NSURL *)url imageSize:(CGSize)imageSize primaryColor:(UIColor*)primaryColor
{
    _imageSize = imageSize;
    [self updateAspectRatio];
    [self setImageWithURL:url primaryColor:primaryColor];
}

- (void)setImageWithURLString:(NSString*)urlString primaryColorHex:(NSString*)primaryColorHex
{
    UIColor* primaryColor;
    NSURL* url = [NSURL URLWithString:urlString];
    if (primaryColorHex != nil)
    {
        primaryColor = [UIColor colorWithHexString:primaryColorHex];
    }
    else
    {
        primaryColor = [UIColor lightGrayColor];
    }
    [self setImageWithURL:url primaryColor:primaryColor];
}

- (void)setImageWithURL:(NSURL *)url completedBlock:(void (^) (BOOL sucess))block
{
    
    //传入一个头像的URL 调用SDWebImage 去获取用户的头像的image
    [self setImageWithURL:url
         placeholderImage:nil
                  options:SDWebImageRetryFailed
                completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                    if (image != nil )
                    {
                        block(YES);
                    }
                }];

}

- (void)setImageWithURL:(NSURL *)url primaryColor:(UIColor*)primaryColor
{
    self.backgroundColor = primaryColor;

    NSDate* startTime = [NSDate date];
    __weak OWTImageView* wself = self;
    //传入一个头像的URL 调用SDWebImage 去获取用户的头像的image
    [self setImageWithURL:url
         placeholderImage:_placeholderImage
                  options:SDWebImageRetryFailed
                completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                    if (image != nil && wself.fadeTransitionEnabled)
                    {
                        _avatarImage = image;
                        NSDate* now = [NSDate date];
                        NSTimeInterval diff = [now timeIntervalSinceDate:startTime];
                        CATransition *transition = [CATransition animation];
                        transition.type = kCATransitionFade; // there are other types but this is the nicest
                        if (diff > 0.1)
                        {
                            transition.duration = 0.34; // set the duration that you like
                        }
                        else
                        {
                            transition.duration = diff; // set the duration that you like
                        }
                        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                        [wself.layer addAnimation:transition forKey:nil];
                    }
                }];
}

- (void)clearImageAnimated:(BOOL)animated
{
    self.backgroundColor = [UIColor clearColor];
    self.image = nil;
    [self cancelCurrentImageLoad];

    _imageSize = CGSizeMake(0, 0);
    if (_aspectRatioConstraint != nil)
    {
        [self removeConstraint:_aspectRatioConstraint];
        [self setNeedsUpdateConstraints];
    }

    if (_fadeTransitionEnabled && animated)
    {
        CATransition* transition = [CATransition animation];
        transition.type = kCATransitionFade; // there are other types but this is the nicest
        transition.duration = 0.34; // set the duration that you like
        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        [self.layer addAnimation:transition forKey:nil];
    }
}

- (void)updateAspectRatio
{
    if (!_maintainAspectRatio)
    {
        return;
    }

    CGFloat aspectRatio = _imageSize.height / _imageSize.width;

    if (isfinite(aspectRatio))
    {
        if (_aspectRatioConstraint != nil)
        {
            [self removeConstraint:_aspectRatioConstraint];
        }

        _aspectRatioConstraint = [NSLayoutConstraint constraintWithItem:self
                                                              attribute:NSLayoutAttributeHeight
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeWidth
                                                             multiplier:aspectRatio
                                                               constant:0.0f];
        [self addConstraint:_aspectRatioConstraint];
        [self setNeedsUpdateConstraints];
    }
}

@end
