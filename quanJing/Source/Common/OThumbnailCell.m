//
//  OThumbnailCell.m
//  Weitu
//
//  Created by Su on 5/31/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import "OThumbnailCell.h"
#import "UIView+EasyAutoLayout.h"
#import "UIImage+Resize.h"
#import "OWTImageView.h"



#import "FSBasicImage.h"
#import "FSBasicImageSource.h"



@interface OThumbnailCell()
{
}

@property (nonatomic, strong) OWTImageView* imageView;


@property (nonatomic, strong) NSArray* thumbImageInfos;
@end

@implementation OThumbnailCell

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
    _generation = 0;

    _imageView = [[OWTImageView alloc] initWithFrame:self.contentView.bounds];
    _imageView.fadeTransitionEnabled = NO;
    [self.contentView addSubview:_imageView];
    [_imageView easyFillSuperview];
}

- (void)prepareForReuse
{
    _generation++;
    [_imageView clearImageAnimated:NO];
}

- (void)setThumbnailWithImage:(UIImage *)image
{
    if (image == nil)
    {
        _imageView.image = nil;
        return;
    }
    
    NSInteger generation = _generation;

#if 0
    CGFloat thumbnailSize = self.bounds.size.width * 2.0;
#endif
    
    __weak OThumbnailCell* wself = self;
    
    dispatch_queue_t dq = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(dq, ^{
#if 0
        UIImage* thumbnailImage = [image thumbnailImage:thumbnailSize
                                   interpolationQuality:kCGInterpolationDefault];
#else
        UIImage* thumbnailImage = image;
#endif
        if (thumbnailImage != nil)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (wself == nil)
                {
                    return;
                }
                
                if (generation == wself.generation)
                {
                    [wself.imageView setImageWithImageAsThumbnail:thumbnailImage];
                    
                    
                    
                    
                    
                    
                    
                    
                    
                }
                else
                {
                    DDLogDebug(@"Generation mismatch, want %ld, got %ld.", (long)generation, (long)wself.generation);
                }
            });
        }
    });
}

//- (void)setThumbnailWithImageInfo:(OWTImageInfo*)imageInfo
//{
//    if (imageInfo == nil)
//    {
//        _imageView.image = nil;
//        return;
//    }
//
//    
//    
//    NSLog(@"eeeeeeeeeeeeeeeeeeeeeeeeeee");
//    [_imageView setImageWithInfoAsThumbnail:imageInfo];
//    
//    
//    _imageView.userInteractionEnabled =YES;
//    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap)];
//    [_imageView addGestureRecognizer:gesture];
//    
//}
//-(void)tap
//{
//    NSLog(@"aaaaaaaaaaaaaaaa");
//}
- (void)setThumbnailWithImageInfo:(NSArray*) thumbImageInfos index:(NSInteger)index
{
    _thumbImageInfos =thumbImageInfos;
    
    
    OWTImageInfo *imageInfo =thumbImageInfos[index];
    
    
    if (imageInfo == nil)
    {
        _imageView.image = nil;
        return;
    }
    
    
    
//    NSLog(@"eeeeeeeeeeeeeeeeeeeeeeeeeee");
    [_imageView setImageWithInfoAsThumbnail:imageInfo];
    
    _imageView.tag=index;
    _imageView.userInteractionEnabled =YES;
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap:)];
    [_imageView addGestureRecognizer:gesture];
    
}
-(void)tap:(UITapGestureRecognizer*)sender
{
//    NSLog(@"lllllllllll%d",sender.view.tag);
    
//    myManage *sharedManager = [myManage sharedManager];
//    
//    
//    sharedManager.dogName = [NSString stringWithFormat:@"%d",sender.view.tag];
    if (_showImage != nil)
    {
        _showImage();
    }
   

}
@end
