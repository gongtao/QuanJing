//
//  OWTWallpaperPagingViewCon.m
//  Weitu
//
//  Created by Su on 8/28/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//


#import "OWTAssetPagingViewCon.h"
#import "OWTPhotoAssetPageView.h"
#import "OWTFeed.h"
#import "OWTFeedItem.h"
#import "OWTAsset.h"
#import "UIView+EasyAutoLayout.h"
#import "OWTFont.h"
#import <SDWebImage/SDWebImageManager.h>
#import <ALAssetsLibrary-CustomPhotoAlbum/ALAssetsLibrary+CustomPhotoAlbum.h>

#import "NSString+FontAwesome.h"
#import "UITabBarController+NBUAdditions.h"


@interface OWTAssetPagingViewCon ()
{
    IBOutlet NIPagingScrollView* _pagingScrollView;
    IBOutlet UIButton* _backButton;
    IBOutlet UIButton* _downloadButton;
    UIView<NIPagingScrollViewPage>* _lastPage;
    IBOutlet UIButton* _shareButton;
}

@property (nonatomic, strong) OWTFeed* feed;
@property (nonatomic, assign) BOOL isToolbarVisible;

@end

@implementation OWTAssetPagingViewCon

- (id)initWithFeed:(OWTFeed*)feed
{
    self = [super initWithNibName:nil bundle:nil];
    if (self != nil)
    {
        _feed = feed;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.automaticallyAdjustsScrollViewInsets = NO;

    _pagingScrollView.pageMargin = 5;
    _pagingScrollView.delegate = self;
    _pagingScrollView.dataSource = self;
 //   [self setInitialPageIndex:10];
    
    UIImage* backImage = [[OWTFont circleBackIconWithSize:32] imageWithSize:CGSizeMake(26, 26)];
    backImage = [backImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [_backButton setImage:backImage forState:UIControlStateNormal];
    [_backButton setShowsTouchWhenHighlighted:TRUE];

    UIImage* downloadImage = [UIImage imageNamed:@"SignOut-icon"];
    downloadImage = [downloadImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [_downloadButton setImage:downloadImage forState:UIControlStateNormal];
//    [_downloadButton addTarget:self action:@selector(download) forControlEvents:UIControlEventTouchUpInside];
    [_downloadButton setShowsTouchWhenHighlighted:TRUE];
    _downloadButton.userInteractionEnabled =YES;
    
//    UIImage* shareImage = [[UIFont fontWithName:kFontAwesomeFamilyName size:32] imageWithSize:CGSizeMake(26, 26)];
//    shareImage = [shareImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    
    
    [_shareButton setBackgroundImage:[UIImage imageNamed:@"08.png"] forState:UIControlStateNormal];
    [_shareButton addTarget:self action:@selector(share) forControlEvents:UIControlEventTouchUpInside];
    _shareButton.backgroundColor = [UIColor clearColor];
    
    _shareButton.frame =  CGRectMake(0, 0, 10, 10);
    //    _shareButton.backgroundColor = [UIColor redColor];
    [_shareButton setShowsTouchWhenHighlighted:TRUE];
    _shareButton.userInteractionEnabled =YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self reloadData];
}
//
- (IBAction)goBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)share
{
    //分享
    [SVProgressHUD showWithStatus:@"准备图片中..." maskType:SVProgressHUDMaskTypeBlack];
    
    SDWebImageManager* manager = [SDWebImageManager sharedManager];
    OWTAsset* asset = ((OWTFeedItem*)_feed.items[_pagingScrollView.centerPageIndex]).asset;
    NSURL* url = [NSURL URLWithString:asset.imageInfo.url];
    
    [manager downloadWithURL:url
                     options:SDWebImageHighPriority
                    progress:nil
                   completed:^(UIImage* image, NSError* error, SDImageCacheType cacheType, BOOL finished){
                           
                   }];

    }
-(void)download
{
    [SVProgressHUD showWithStatus:@"保存图片中..." maskType:SVProgressHUDMaskTypeBlack];
    
    SDWebImageManager* manager = [SDWebImageManager sharedManager];
    OWTAsset* asset = ((OWTFeedItem*)_feed.items[_pagingScrollView.centerPageIndex]).asset;
    NSURL* url = [NSURL URLWithString:asset.imageInfo.url];
    [manager downloadWithURL:url
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
- (IBAction)download:(id)sender
{
    [SVProgressHUD showWithStatus:@"保存图片中..." maskType:SVProgressHUDMaskTypeBlack];
    
    SDWebImageManager* manager = [SDWebImageManager sharedManager];
    OWTAsset* asset = ((OWTFeedItem*)_feed.items[_pagingScrollView.centerPageIndex]).asset;
    NSURL* url = [NSURL URLWithString:asset.imageInfo.url];
    [manager downloadWithURL:url
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
//界面效果
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
 //
    [[NSNotificationCenter defaultCenter] postNotificationName:kWTHideMainTabBarNotification object:nil];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [self.tabBarController setTabBarHidden:YES animated:animated];
//    UIView<NIPagingScrollViewPage>* currentPage = _pagingScrollView.centerPageView;
//    
//    if (currentPage != _lastPage)
//    {
//        if (_lastPage != nil && [_lastPage isKindOfClass:OWTAssetPageView.class])
//        {
//            OWTAssetPageView* assetPageView = (OWTAssetPageView*)_lastPage;
//            [assetPageView pageDidSlideOut];
//        }
//    }

}




- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kWTShowMainTabBarNotification object:nil];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [self.tabBarController setTabBarHidden:NO animated:animated];
    UIView<NIPagingScrollViewPage>* pageView = _pagingScrollView.centerPageView;
    if (pageView != nil && [pageView isKindOfClass:OWTAssetPageView.class])
    {
        OWTAssetPageView* assetPageView = (OWTAssetPageView*)pageView;
        [assetPageView pageWillSlideOut];
        [assetPageView pageDidSlideOut];
    }
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [_pagingScrollView willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

#pragma mark - Actions

- (void)setInitialPageIndex:(NSInteger)pageIndex
{
    [self moveToPageAtIndex:pageIndex animated:NO];
    NSLog(@"moveToPageAtIndex%d",pageIndex);
}

- (void)moveToPageAtIndex:(NSInteger)pageIndex animated:(BOOL)animated
{
    [_pagingScrollView moveToPageAtIndex:pageIndex animated:animated updateVisiblePagesWhileScrolling:YES];
}

#pragma mark - Data

- (void)reloadData
{
    UIView<NIPagingScrollViewPage>* pageView = _pagingScrollView.centerPageView;
        if (pageView != nil && [pageView isKindOfClass:OWTAssetPageView.class])
    {
                OWTAssetPageView* assetPageView = (OWTAssetPageView*)pageView;
                [assetPageView pageWillSlideOut];
        [assetPageView pageDidSlideOut];
    }
    
    [_pagingScrollView reloadData];
    _pagingScrollView.centerPageIndex=_indexnow;
}

#pragma mark - Paging View Data Source

- (NSInteger)numberOfPagesInPagingScrollView:(NIPagingScrollView *)pagingScrollView
{
    return _feed.items.count;
}

//重点
- (UIView<NIPagingScrollViewPage> *)pagingScrollView:(NIPagingScrollView *)pagingScrollView pageViewForIndex:(NSInteger)pageIndex
{
    NSLog(@"pageindex=%d",pageIndex);
//    if (pageIndex==0) {
//        pageIndex=_indexnow;
//    }
//    
    //设置第一张图片，scrollview的开始
    OWTAsset* asset = ((OWTFeedItem*)_feed.items[pageIndex]).asset;
    OWTPhotoAssetPageView* photoAssetPageView = (OWTPhotoAssetPageView*)[_pagingScrollView dequeueReusablePageWithIdentifier:@"OWTPhotoAssetPageView"];
    if (photoAssetPageView == nil)
    {
       
        
        CGRect bounds = _pagingScrollView.bounds;
        photoAssetPageView = [[OWTPhotoAssetPageView alloc] initWithFrame:bounds];
//        NSLog(@"_pagingScrollView.centerPageIndex =%d",_pagingScrollView.centerPageIndex);
        
        //
//        UIView<NIPagingScrollViewPage>* currentPage = pagingScrollView.centerPageView;
        
    }
    

    photoAssetPageView.pageIndex = pageIndex;
    photoAssetPageView.asset = asset;
    return photoAssetPageView;
}

#pragma mark - Paging View Delegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    DDLogVerbose(@"scrollViewWillBeginDragging");
    UIView* currentPage = _pagingScrollView.centerPageView;
    if (currentPage != nil && [currentPage isKindOfClass:OWTAssetPageView.class])
    {
        OWTAssetPageView* assetPageView = (OWTAssetPageView*)currentPage;
        [assetPageView pageWillBeginSlide];
    }
}

- (void)pagingScrollViewDidScroll:(NIPagingScrollView *)pagingScrollView
{
   
}

- (void)pagingScrollViewWillChangePages:(NIPagingScrollView *)pagingScrollView
{
    DDLogVerbose(@"pagingScrollViewWillChangePages: %ld", (long)_pagingScrollView.centerPageIndex);
    
    UIView<NIPagingScrollViewPage>* currentPage = _pagingScrollView.centerPageView;
    if (currentPage != nil && [currentPage isKindOfClass:OWTAssetPageView.class])
    {
        OWTAssetPageView* assetPageView = (OWTAssetPageView*)currentPage;
        [assetPageView pageWillSlideOut];
    }
    
    _lastPage = _pagingScrollView.centerPageView;
}

- (void)pagingScrollViewDidChangePages:(NIPagingScrollView *)pagingScrollView
{
    DDLogVerbose(@"pagingScrollViewDidChangePages: %ld", (long)_pagingScrollView.centerPageIndex);
    
    UIView<NIPagingScrollViewPage>* currentPage = pagingScrollView.centerPageView;
    if (currentPage != _lastPage)
    {
        if (_lastPage != nil && [_lastPage isKindOfClass:OWTAssetPageView.class])
        {
            OWTAssetPageView* assetPageView = (OWTAssetPageView*)_lastPage;
            [assetPageView pageDidSlideOut];
        }
    }
}

@end
