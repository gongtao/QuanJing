//
//  OWTAlbumViewCon.m
//  Weitu
//
//  Created by Su on 6/30/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import "OWTAlbumViewCon.h"
#import "OWTAlbum.h"
#import "OWTAssetFlowViewCon.h"

#import "OWTAsset.h"
#import "OWTAssetViewCon.h"

#import "OWTTabBarHider.h"

#import "OWaterFlowCollectionView.h"
#import "OWaterFlowLayout.h"
#import "OWTImageCell.h"

#import "OWTAssetManager.h"
#import "OWTAlbumInfoEditViewCon.h"

#import "UIView+EasyAutoLayout.h"
#import "UIViewController+WTExt.h"
#import "SVProgressHUD+WTError.h"
#import "OWTUserManager.h"

#import <SVPullToRefresh/SVPullToRefresh.h>
#import <SHBarButtonItemBlocks/SHBarButtonItemBlocks.h>

static NSString* kWaterFlowCellID = @"kWaterFlowCellID";

@interface OWTAlbumViewCon ()
{
}

@property (nonatomic, strong) OWTAssetFlowViewCon* assetViewCon;
@property (nonatomic, strong) OWTAlbum* album;

@end

@implementation OWTAlbumViewCon

- (instancetype)initWithAlbum:(OWTAlbum *)album
{
    self = [super initWithNibName:nil bundle:nil];
    if (self)
    {
        _album = album;
    }
    return self;
}

- (void)setupNavigationBar
{
    OWTUserManager* um = GetUserManager();
    if ([um.currentUser.userID isEqualToString:_album.userID])
    {
        UIBarButtonItem* item = [UIBarButtonItem SH_barButtonItemWithTitle:@"编辑"
                                                                     style:UIBarButtonItemStylePlain
                                                                 withBlock:^(UIBarButtonItem* sender) {
                                                                     [self editAlbum];
                                                                 }];
        self.navigationItem.rightBarButtonItem = item;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self setupNavigationBar];

    self.view.backgroundColor = GetThemer().themeColorBackground;

    _assetViewCon = [[OWTAssetFlowViewCon alloc] initWithNibName:nil bundle:nil];
    [self addChildViewController:_assetViewCon];
    [self.view addSubview:_assetViewCon.view];
    [_assetViewCon.view easyFillSuperview];

    __weak OWTAlbumViewCon* wself = self;

    _assetViewCon.numberOfAssetsFunc = ^
    {
        NSMutableOrderedSet* assets = wself.album.assets;
        if (assets != nil)
        {
            return (int)assets.count;
        }
        else
        {
            return 0;
        }
    };
    
//    _assetViewCon.assetAtIndexFunc = ^(NSInteger index)
//    {
//        NSMutableOrderedSet* assets = wself.album.assets;
//        if (assets != nil)
//        {
//            return (OWTAsset*)[assets objectAtIndex:index];
//        }
//        else
//        {
//            return (OWTAsset*)nil;
//        }
//    };
//    
//    _assetViewCon.onAssetSelectedFunc = ^(OWTAsset* asset)
//    {
//        OWTAssetViewCon* assetViewCon = [[OWTAssetViewCon alloc] initWithAsset:asset deletionAllowed:YES onDeleteAction:^{ [wself reloadData]; }];
//        [wself.navigationController pushViewController:assetViewCon animated:YES];
//    };
    
    _assetViewCon.refreshDataFunc = ^(void (^refreshDoneFunc)())
    {
        [wself.album refreshAssetsWithSuccess:^{
            if (refreshDoneFunc != nil)
            {
                refreshDoneFunc();
            }
        }
                                      failure:^(NSError* error) {
                                          [SVProgressHUD showError:error];
                                          if (refreshDoneFunc != nil)
                                          {
                                              refreshDoneFunc();
                                          }
                                      }];
    };
    
    _assetViewCon.loadMoreDataFunc = ^(void (^loadMoreDoneFunc)()) {
        [wself.album loadMoreAssetsCount:50
                                 success:^{
                                     if (loadMoreDoneFunc != nil)
                                     {
                                         loadMoreDoneFunc();
                                     }
                                 }
                                 failure:^(NSError* error) {
                                     [SVProgressHUD showError:error];
                                     if (loadMoreDoneFunc != nil)
                                     {
                                         loadMoreDoneFunc();
                                     }
                                 }];
    };
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self substituteNavigationBarBackItem];
    [self reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self refreshIfNeeded];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
}

#pragma mark - Actions

- (void)editAlbum
{
    OWTAlbumInfoEditViewCon* editViewCon = [[OWTAlbumInfoEditViewCon alloc] initForEditingAlbum:_album];
    editViewCon.doneAction = ^(EWTDoneType doneType) {
        switch (doneType)
        {
            case nWTDoneTypeCancelled:
                [self dismissViewControllerAnimated:YES completion:nil];
                break;
                
            case nWTDoneTypeUpdated:
            {
                self.title = _album.albumName;
                
//                UILabel * label = [[UILabel alloc]initWithFrame:CGRectMake(0, 20, 100, 44)];
//                label.text = [NSString stringWithFormat:@"      %@",_album.albumName];
//             
//                label.font = [UIFont fontWithName:@"Arial-BoldItalicMT" size:24];
//                
//                [label setTextAlignment:NSTextAlignmentCenter];
//                label.textColor = GetThemer().themeTintColor;
//                self.navigationItem.titleView =label;
                
                [self dismissViewControllerAnimated:YES completion:nil];
                break;
            }
                
            case nWTDoneTypeDeleted:
            {
                [self dismissViewControllerAnimated:YES completion:^{
                    if (_onDeleteAction != nil)
                    {
                        _onDeleteAction();
                    }
                }];
                break;
            }
                
            case nWTDoneTypeCreated:
            default:
            {
                AssertTR(false);
                break;
            }
        }
    };
    
    UINavigationController* navCon = [[UINavigationController alloc] initWithRootViewController:editViewCon];
    [self presentViewController:navCon animated:YES completion:nil];
}

- (void)refreshIfNeeded
{
    if (_album.assets == nil || _album.assets.count == 0 || _album.refreshNeeded)
    {
        [_assetViewCon manualRefresh];
    }
}

#pragma mark - Actions

- (void)reloadData
{
    self.title = _album.albumName;
//    UILabel * label = [[UILabel alloc]initWithFrame:CGRectMake(0, 20, 100, 44)];
//    label.text = [NSString stringWithFormat:@"%@",_album.albumName];
//    
//    label.font = [UIFont fontWithName:@"Arial-BoldItalicMT" size:24];
//    
//    [label setTextAlignment:UITextAlignmentCenter];
//    label.textColor = GetThemer().themeTintColor;
//    self.navigationItem.titleView =label;

    [_assetViewCon reloadData];
}

@end
