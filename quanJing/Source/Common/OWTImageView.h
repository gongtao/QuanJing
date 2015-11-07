//
//  OWTImageView.h
//  Weitu
//
//  Created by Su on 4/23/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface OWTImageView : UIImageView

@property (nonatomic, assign) BOOL fadeTransitionEnabled;
@property (nonatomic, assign) BOOL maintainAspectRatio;
@property (nonatomic, strong) UIImage * avatarImage;
@property (nonatomic, strong) UIImage * placeholderImage;

- (void)setup;

- (void)setImageWithImage:(UIImage *)image;
- (void)setImageWithImageAsThumbnail:(UIImage *)image;

- (void)setImageWithInfo:(OWTImageInfo *)imageInfo;
- (void)setImageWithInfoAsThumbnail:(OWTImageInfo *)imageInfo;

- (void)setImageWithInfo:(OWTImageInfo *)imageInfo desiredAspectRatio:(CGFloat)aspectRatio;

- (void)setImageWithURLString:(NSString *)urlString imageSize:(CGSize)imageSize primaryColor:(UIColor *)primaryColor;
- (void)setImageWithURL:(NSURL *)url imageSize:(CGSize)imageSize primaryColor:(UIColor *)primaryColor;

- (void)setImageWithURLString:(NSString *)urlString primaryColorHex:(NSString *)primaryColorHex;
- (void)setImageWithURL:(NSURL *)url primaryColor:(UIColor *)primaryColor;

- (void)clearImageAnimated:(BOOL)animated;
- (void)setImageWithURL:(NSURL *)url completedBlock:(void (^) (BOOL sucess))block;

@end
