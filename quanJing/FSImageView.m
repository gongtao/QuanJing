//  FSImageViewer
//
//  Created by Felix Schulze on 8/26/2013.
//  Copyright 2013 Felix Schulze. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "FSImageView.h"
#import "FSPlaceholderImages.h"
#import "FSImageScrollView.h"

#import "SDWebImageManager.h"
#import <ALAssetsLibrary-CustomPhotoAlbum/ALAssetsLibrary+CustomPhotoAlbum.h>
#import "UMSocial.h"
#import "OWTFont.h"

#import "LJUIController.h"




#define ZOOM_VIEW_TAG 0x101
#define MB_FILE_SIZE 1024*1024

@interface RotateGesture : UIRotationGestureRecognizer {
}
@end

@implementation RotateGesture
- (BOOL)canBePreventedByGestureRecognizer:(UIGestureRecognizer *)gesture {
    return NO;
}

- (BOOL)canPreventGestureRecognizer:(UIGestureRecognizer *)preventedGestureRecognizer {
    return YES;
}
@end

@implementation FSImageView {
    UIActivityIndicatorView *activityView;
    CGFloat beginRadians;
    UIViewController*_viewController;
    UIButton *_selectButton;
    
}

- (id)initWithFrame:(CGRect)frame  withViewcontroller:(UIViewController *)sender{
    if ((self = [super initWithFrame:frame])) {
        _viewController=sender;
        self.backgroundColor = [UIColor whiteColor];
        self.userInteractionEnabled = NO;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.opaque = YES;

        FSImageScrollView *scrollView = [[FSImageScrollView alloc] initWithFrame:self.bounds];
        scrollView.backgroundColor = [UIColor whiteColor];
        scrollView.opaque = YES;
        scrollView.delegate = self;
        [self addSubview:scrollView];
        _scrollView = scrollView;

        UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        imageView.opaque = YES;
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.tag = ZOOM_VIEW_TAG;
        [_scrollView addSubview:imageView];
        _imageView = imageView;

        activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        activityView.frame = CGRectMake((CGRectGetWidth(self.frame) / 2) - 11.0f, CGRectGetHeight(self.frame) / 2, 22.0f, 22.0f);
        activityView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
        [self addSubview:activityView];

        RotateGesture *gesture = [[RotateGesture alloc] initWithTarget:self action:@selector(rotate:)];
        [self addGestureRecognizer:gesture];
        
        UILongPressGestureRecognizer *longpress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(save)];
        [self addGestureRecognizer:longpress];
        
        
        
        
        //
        UIImage* backImage = [[OWTFont circleBackIconWithSize:32] imageWithSize:CGSizeMake(26, 26)];
        backImage = [backImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        
        
        _backButton =[[UIButton alloc]initWithFrame: CGRectMake(0, 495, 50, 50)];
        
        [_backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
        [_backButton setImage:backImage forState:UIControlStateNormal];
        [_backButton setShowsTouchWhenHighlighted:TRUE];
        _backButton.tintColor = [UIColor whiteColor];
        
        
        _downloadButton =[[UIButton alloc]initWithFrame: CGRectMake(180, 500, 50, 50)];
        UIImage* downloadImage = [UIImage imageNamed:@"SignOut-icon"];
        downloadImage = [downloadImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        
        
        [_downloadButton addTarget:self action:@selector(save) forControlEvents:UIControlEventTouchUpInside];
        [_downloadButton setImage:downloadImage forState:UIControlStateNormal];
       
        
        [_downloadButton setShowsTouchWhenHighlighted:TRUE];
        _downloadButton.userInteractionEnabled =YES;
        _downloadButton.tintColor = [UIColor whiteColor];
        
        
        
        _shareButton =[[UIButton alloc]initWithFrame: CGRectMake(280, 510, 22, 22)];
        [_shareButton setBackgroundImage:[UIImage imageNamed:@"大图_07.png"] forState:UIControlStateNormal];
        [_shareButton addTarget:self action:@selector(share) forControlEvents:UIControlEventTouchUpInside];
        _shareButton.backgroundColor = [UIColor clearColor];
        
        [_shareButton setShowsTouchWhenHighlighted:TRUE];
        _shareButton.userInteractionEnabled =YES;
        
       // _label=[[UILabel alloc]initWithFrame:CGRectMake(100, 500, 50,50)];
        
        _label=[LJUIController createLabelWithFrame:CGRectMake(100, 500, 80,50) Font:18 Text:nil];
        _label.textColor=[UIColor whiteColor];
        _label.userInteractionEnabled=YES;
        [self addSubview:_label];
        [self addSubview:_backButton];
        [self addSubview:_shareButton];
        [self addSubview:_downloadButton];
        
        
        

        
    }
    return self;
}
- (FSImageView*)initWithFrame:(CGRect)frame gridItem:(AGIPCGridItem*)item{
    if ((self = [super initWithFrame:frame])) {
        
        _gridItem = item;
        self.backgroundColor = [UIColor whiteColor];
        self.userInteractionEnabled = NO;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.opaque = YES;
        
        FSImageScrollView *scrollView = [[FSImageScrollView alloc] initWithFrame:self.bounds];
        scrollView.backgroundColor = [UIColor whiteColor];
        scrollView.opaque = YES;
        scrollView.delegate = self;
        [self addSubview:scrollView];
        _scrollView = scrollView;
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        imageView.opaque = YES;
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.tag = ZOOM_VIEW_TAG;
        [_scrollView addSubview:imageView];
        _imageView = imageView;
        
        activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        activityView.frame = CGRectMake((CGRectGetWidth(self.frame) / 2) - 11.0f, CGRectGetHeight(self.frame) / 2, 22.0f, 22.0f);
        activityView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
        [self addSubview:activityView];
        
        RotateGesture *gesture = [[RotateGesture alloc] initWithTarget:self action:@selector(rotate:)];
        [self addGestureRecognizer:gesture];
        
        UILongPressGestureRecognizer *longpress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(save)];
        [self addGestureRecognizer:longpress];
        
        //
        UIImage* backImage = [[OWTFont circleBackIconWithSize:32] imageWithSize:CGSizeMake(26, 26)];
        backImage = [backImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        
       _selectButton =[[UIButton alloc]initWithFrame: CGRectMake(SCREENWIT/2-10, SCREENHEI-35, 30, 30)];
        if(!_gridItem.selected){
            [_selectButton setBackgroundImage:[UIImage imageNamed:@"大图1_03_21.png"] forState:UIControlStateNormal];
            _selectButton.selected = NO;
            
        }else{
            [_selectButton setBackgroundImage:[UIImage imageNamed:@"大图1_05.png"] forState:UIControlStateNormal];
            _selectButton.selected = YES;
        }
        [_selectButton addTarget:self action:@selector(selctAction:) forControlEvents:UIControlEventTouchUpInside];
        _selectButton.backgroundColor = [UIColor clearColor];
        
        [_selectButton setShowsTouchWhenHighlighted:TRUE];
        _selectButton.userInteractionEnabled =YES;
        [self addSubview:_selectButton];
    }
    
    return self;
}
-(void)refreshTheSelectedBtn:(BOOL)isSelected
{
    if(!isSelected){
        [_selectButton setBackgroundImage:[UIImage imageNamed:@"大图1_03_21.png"] forState:UIControlStateNormal];
        _selectButton.selected = NO;
        _gridItem.selected=NO;
    }else{
        [_selectButton setBackgroundImage:[UIImage imageNamed:@"大图1_05.png"] forState:UIControlStateNormal];
        _selectButton.selected = YES;
        _gridItem.selected=YES;
    }

}
-(void)selctAction:(UIButton*)sender
{
    if (sender.isSelected) {
        [sender setBackgroundImage:[UIImage imageNamed:@"大图1_03_21.png"] forState:UIControlStateNormal];
        _gridItem.selected = NO;
    }else{
        [sender setBackgroundImage:[UIImage imageNamed:@"大图1_05.png"] forState:UIControlStateNormal];
        _gridItem.selected = YES;
    }
    sender.selected = !sender.isSelected;
    
}

//
- (void)back
{
    if (_showBack != nil)
    {
        _showBack();
    }}
-(void)share
{
    
    
    
    NSURL *url1 =self.image.URL;
   

    //share
    [SVProgressHUD showWithStatus:@"准备图片中..." maskType:SVProgressHUDMaskTypeBlack];
    
    SDWebImageManager* manager = [SDWebImageManager sharedManager];
    
    [manager downloadWithURL:url1
                     options:SDWebImageHighPriority
                    progress:nil
                   completed:^(UIImage* image, NSError* error, SDImageCacheType cacheType, BOOL finished){
                       [SVProgressHUD dismiss];
                       [UMSocialData defaultData].extConfig.wxMessageType = UMSocialWXMessageTypeImage;
                       [UMSocialData defaultData].extConfig.qqData.qqMessageType = UMSocialQQMessageTypeImage;
                       [UMSocialSnsService presentSnsIconSheetView:_viewController
                                                            appKey:nil
                                                         shareText:nil
                                                        shareImage:image
                                                   shareToSnsNames:[NSArray arrayWithObjects:UMShareToSina,UMShareToWechatTimeline,UMShareToWechatSession,UMShareToWechatFavorite,UMShareToQzone,UMShareToQQ,UMShareToSms,nil]
                                                          delegate:nil];

                   }];
    
}

//
- (void)dealloc {
    if (_image) {
        [[FSImageLoader sharedInstance] cancelRequestForUrl:self.image.URL];
    }
}


- (void)layoutSubviews {
    [super layoutSubviews];

    if (_scrollView.zoomScale == 1.0f) {
        [self layoutScrollViewAnimated:YES];
    }

}

- (void)setImage:(id <FSImage>)aImage {

    if (!aImage) {
        return;
    }
    if ([aImage isEqual:_image]) {
        return;
    }
    if (_image != nil) {
        [[FSImageLoader sharedInstance] cancelRequestForUrl:_image.URL];
    }

    _image = aImage;

    if (_image.image) {
        _imageView.image = _image.image;

    }
    else {

        if ([_image.URL isFileURL]) {

            NSError *error = nil;
            NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:[_image.URL path] error:&error];
            NSInteger fileSize = [[attributes objectForKey:NSFileSize] integerValue];

            if (fileSize >= MB_FILE_SIZE) {

                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{

                    UIImage *image = nil;
                    NSData *data = [NSData dataWithContentsOfURL:self.image.URL];
                    if (!data) {
                        [self handleFailedImage];
                    } else {
                        image = [UIImage imageWithData:data];
                    }

                    dispatch_async(dispatch_get_main_queue(), ^{

                        if (image != nil) {
                            [self setupImageViewWithImage:image];
                        }

                    });
                });

            }
            else {
                self.imageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:self.image.URL]];
            }

        }
        else {
            [[FSImageLoader sharedInstance] loadImageForURL:_image.URL image:^(UIImage *image, NSError *error) {
                if (!error) {
                    [self setupImageViewWithImage:image];
                }
                else {
                    [self handleFailedImage];
                }
            }];
        }

    }

    if (_imageView.image) {

        [activityView stopAnimating];
        self.userInteractionEnabled = YES;
        _loading = NO;

        [[NSNotificationCenter defaultCenter] postNotificationName:kFSImageViewerDidFinishedLoadingNotificationKey object:@{
                @"image" : self.image,
                @"failed" : @(NO)
        }];

    } else {
        _loading = YES;
        [activityView startAnimating];
        self.userInteractionEnabled = NO;
    }
    if ([_imageView.image imageOrientation] != UIImageOrientationUp) {
        CGImageRef imgRef = _imageView.image.CGImage;
        _imageView.image = [UIImage imageWithCGImage:imgRef scale:1.0 orientation:UIImageOrientationUp];
    }
    [self layoutScrollViewAnimated:NO];
}

- (void)setupImageViewWithImage:(UIImage *)aImage {
    if (!aImage) {
        return;
    }

    _loading = NO;
    [activityView stopAnimating];
    _imageView.image = aImage;
    [self layoutScrollViewAnimated:NO];

    [[self layer] addAnimation:[self fadeAnimation] forKey:@"opacity"];
    self.userInteractionEnabled = YES;

    [[NSNotificationCenter defaultCenter] postNotificationName:kFSImageViewerDidFinishedLoadingNotificationKey object:@{
            @"image" : self.image,
            @"failed" : @(NO)
    }];
}

- (void)prepareForReuse {
    self.tag = -1;
}

- (void)changeBackgroundColor:(UIColor *)color {
    self.backgroundColor = color;
    self.imageView.backgroundColor = color;
    self.scrollView.backgroundColor = color;
}


- (void)handleFailedImage {

    _imageView.image = FSImageViewerErrorPlaceholderImage;
    _image.failed = YES;
    [self layoutScrollViewAnimated:NO];
    self.userInteractionEnabled = NO;
    [activityView stopAnimating];
    [[NSNotificationCenter defaultCenter] postNotificationName:kFSImageViewerDidFinishedLoadingNotificationKey object:@{
            @"image" : self.image,
            @"failed" : @(YES)
    }];
}

- (void)resetBackgroundColors {
    self.backgroundColor = [UIColor whiteColor];
    self.superview.backgroundColor = self.backgroundColor;
    self.superview.superview.backgroundColor = self.backgroundColor;
}


#pragma mark - Layout

- (void)rotateToOrientation:(UIInterfaceOrientation)orientation {

    if (self.scrollView.zoomScale > 1.0f) {

        CGFloat height, width;
        height = MIN(CGRectGetHeight(self.imageView.frame) + self.imageView.frame.origin.x, CGRectGetHeight(self.bounds));
        width = MIN(CGRectGetWidth(self.imageView.frame) + self.imageView.frame.origin.y, CGRectGetWidth(self.bounds));
        self.scrollView.frame = CGRectMake((self.bounds.size.width / 2) - (width / 2), (self.bounds.size.height / 2) - (height / 2), width, height);

    } else {

        [self layoutScrollViewAnimated:NO];

    }
}

- (void)layoutScrollViewAnimated:(BOOL)animated {

    if (!_imageView.image) {
        return;
    }

    if (animated) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.0001];
    }

    CGFloat hfactor = self.imageView.image.size.width / self.frame.size.width;
    CGFloat vfactor = self.imageView.image.size.height / self.frame.size.height;

    CGFloat factor = MAX(hfactor, vfactor);

    CGFloat newWidth = (int) (self.imageView.image.size.width / factor);
    CGFloat newHeight = (int) (self.imageView.image.size.height / factor);

    CGFloat leftOffset = (int) ((self.frame.size.width - newWidth) / 2);
    CGFloat topOffset = (int) ((self.frame.size.height - newHeight) / 2);

    self.scrollView.frame = CGRectMake(leftOffset, topOffset, newWidth, newHeight);
    self.scrollView.layer.position = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
    self.scrollView.contentSize = CGSizeMake(self.scrollView.bounds.size.width, self.scrollView.bounds.size.height);
    self.scrollView.contentOffset = CGPointMake(0.0f, 0.0f);
    self.imageView.frame = self.scrollView.bounds;
//    if (_islocal==YES) {
        NSLog(@"ss%f",self.imageView.frame.origin.y);
        if (self.scrollView.frame.origin.y+self.imageView.frame.size.height>SCREENHEI-95) {
            CGRect frame=self.imageView.frame;
            
            frame.size.height=SCREENHEI-95-_scrollView.frame.origin.y;
            self.imageView.frame=frame;
        }
//    }
    
//    NSLog(@"%f  %f  %f   %f",self.imageView.frame.origin.x,self.imageView.frame.size.width,self.imageView.frame.origin.y,self.imageView.frame.size.height);
    //NSLog(@"ss%f",self.imageView.frame.size.height+self.imageView.frame.origin.y);
    if (animated) {
        [UIView commitAnimations];
    }
}

#pragma mark - Animation

- (CABasicAnimation *)fadeAnimation {

    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    animation.fromValue = [NSNumber numberWithFloat:0.0f];
    animation.toValue = [NSNumber numberWithFloat:1.0f];
    animation.duration = .3f;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];

    return animation;
}

#pragma mark - UIScrollViewDelegate

- (void)killZoomAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {

    if ([finished boolValue]) {

        [self.scrollView setZoomScale:1.0f animated:NO];
        self.imageView.frame = self.scrollView.bounds;
        [self layoutScrollViewAnimated:NO];

    }

}

- (void)killScrollViewZoom {

    if (!self.scrollView.zoomScale > 1.0f) return;

    if (!self.imageView.image) {
        return;
    }

    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationDidStopSelector:@selector(killZoomAnimationDidStop:finished:context:)];
    [UIView setAnimationDelegate:self];


    CGFloat hfactor = self.imageView.image.size.width / self.frame.size.width;
    CGFloat vfactor = self.imageView.image.size.height / self.frame.size.height;

    CGFloat factor = MAX(hfactor, vfactor);

    CGFloat newWidth = (int) (self.imageView.image.size.width / factor);
    CGFloat newHeight = (int) (self.imageView.image.size.height / factor);

    CGFloat leftOffset = (int) ((self.frame.size.width - newWidth) / 2);
    CGFloat topOffset = (int) ((self.frame.size.height - newHeight) / 2);

    self.scrollView.frame = CGRectMake(leftOffset, topOffset, newWidth, newHeight);
    self.imageView.frame = self.scrollView.bounds;
    //NSLog(@"dd%f",self.imageView.frame.size.height+self.imageView.frame.origin.y);
//    if (_islocal==YES) {
        if (self.scrollView.frame.origin.y+self.imageView.frame.size.height>SCREENHEI-95) {
            CGRect frame=self.imageView.frame;
            
            frame.size.height=SCREENHEI-95-_scrollView.frame.origin.y;
            self.imageView.frame=frame;
        }

//    }
    [UIView commitAnimations];

}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return [self.scrollView viewWithTag:ZOOM_VIEW_TAG];
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale {

    if (scrollView.zoomScale > 1.0f) {

        CGFloat height, width;
        height = MIN(CGRectGetHeight(self.imageView.frame) + self.imageView.frame.origin.x, CGRectGetHeight(self.bounds));
        width = MIN(CGRectGetWidth(self.imageView.frame) + self.imageView.frame.origin.y, CGRectGetWidth(self.bounds));


        if (CGRectGetMaxX(self.imageView.frame) > self.bounds.size.width) {
            width = CGRectGetWidth(self.bounds);
        } else {
            width = CGRectGetMaxX(self.imageView.frame);
        }

        if (CGRectGetMaxY(self.imageView.frame) > self.bounds.size.height) {
            height = CGRectGetHeight(self.bounds);
        } else {
            height = CGRectGetMaxY(self.imageView.frame);
        }

        CGRect frame = self.scrollView.frame;
        self.scrollView.frame = CGRectMake((self.bounds.size.width / 2) - (width / 2), (self.bounds.size.height / 2) - (height / 2), width, height);
        self.scrollView.layer.position = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
        if (!CGRectEqualToRect(frame, self.scrollView.frame)) {

            CGFloat offsetY, offsetX;

            if (frame.origin.y < self.scrollView.frame.origin.y) {
                offsetY = self.scrollView.contentOffset.y - (self.scrollView.frame.origin.y - frame.origin.y);
            } else {
                offsetY = self.scrollView.contentOffset.y - (frame.origin.y - self.scrollView.frame.origin.y);
            }

            if (frame.origin.x < self.scrollView.frame.origin.x) {
                offsetX = self.scrollView.contentOffset.x - (self.scrollView.frame.origin.x - frame.origin.x);
            } else {
                offsetX = self.scrollView.contentOffset.x - (frame.origin.x - self.scrollView.frame.origin.x);
            }

            if (offsetY < 0) offsetY = 0;
            if (offsetX < 0) offsetX = 0;

            self.scrollView.contentOffset = CGPointMake(offsetX, offsetY);
        }

    } else {
        [self layoutScrollViewAnimated:YES];
    }
}

#pragma mark - RotateGesture
-(void)save
{
    if (_identifyVC) {
        NSLog(@"the shi de ");
        return;
    }
    NSURL *url1 =self.image.URL;
    [SVProgressHUD showWithStatus:@"保存图片中..." maskType:SVProgressHUDMaskTypeBlack];
    
    SDWebImageManager* manager = [SDWebImageManager sharedManager];
   
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
                                             [SVProgressHUD showSuccessWithStatus:@"保存成功"];
                                            }];
                       }
                       else
                       {
                           [SVProgressHUD showSuccessWithStatus:@"无法下载图片，请稍后再试。"];
                       }
                   }];
    
    
}

- (void)rotate:(UIRotationGestureRecognizer *)gesture {

    if (gesture.state == UIGestureRecognizerStateBegan) {
        [self.layer removeAllAnimations];
        beginRadians = gesture.rotation;
        self.layer.transform = CATransform3DMakeRotation(beginRadians, 0.0f, 0.0f, 1.0f);

    }
    else if (gesture.state == UIGestureRecognizerStateChanged) {
        self.layer.transform = CATransform3DMakeRotation((beginRadians + gesture.rotation), 0.0f, 0.0f, 1.0f);
    }
    else {
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform"];
        animation.toValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
        animation.duration = 0.3f;
        animation.removedOnCompletion = NO;
        animation.fillMode = kCAFillModeForwards;
        animation.delegate = self;
        [animation setValue:[NSNumber numberWithInt:202] forKey:@"AnimationType"];
        [self.layer addAnimation:animation forKey:@"RotateAnimation"];
    }
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {

    if (flag) {
        if ([[anim valueForKey:@"AnimationType"] integerValue] == 101) {
            [self resetBackgroundColors];
        } else if ([[anim valueForKey:@"AnimationType"] integerValue] == 202) {
            self.layer.transform = CATransform3DIdentity;
        }
    }
}

#pragma mark - Bars

- (void)toggleBars {
    [[NSNotificationCenter defaultCenter] postNotificationName:kFSImageViewerToogleBarsNotificationKey object:nil];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    UITouch *touch = [touches anyObject];

    if (touch.tapCount == 1) {
        [self performSelector:@selector(toggleBars) withObject:nil afterDelay:.2];
    }
}


@end
