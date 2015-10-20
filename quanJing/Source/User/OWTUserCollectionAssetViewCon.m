//
//  OWTUserSharedAssetsViewCon.m
//  Weitu
//
//  Created by Su on 6/14/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import "OWTUserCollectionAssetViewCon.h"
#import "OWTAssetFlowViewCon.h"
#import "OWTUser.h"
#import "OWTUserManager.h"
#import "OWTAssetViewCon.h"
#import "SVProgressHUD+WTError.h"
#import "UIView+EasyAutoLayout.h"
#import "UIViewController+WTExt.h"

@interface OWTUserCollectionAssetViewCon ()
{
}

@property (nonatomic, strong) OWTAssetFlowViewCon* assetViewCon;
@property (nonatomic, strong) UIBarButtonItem* numBarItem;

@end

@implementation OWTUserCollectionAssetViewCon

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        [self setup];
    }
    return self;
}

- (NSMutableOrderedSet*)assets
{
    if (self.user != nil && self.user.assetsInfo != nil && self.user.assetsInfo.sharedAssets != nil)
    {
        return self.user.assetsInfo.sharedAssets;
    }
    else
    {
        return nil;
    }
}

- (int)assetNum
{
    NSMutableOrderedSet* assets = [self assets];
    if (assets != nil)
    {
        return (int)assets.count;
    }
    else
    {
        return 0;
    }
}

- (void)setup
{
    _assetViewCon = [[OWTAssetFlowViewCon alloc] initWithNibName:nil bundle:nil];
    [self addChildViewController:_assetViewCon];
    
    _numBarItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                   style:UIBarButtonItemStyleBordered
                                                  target:nil
                                                  action:nil];
    //    self.navigationItem.rightBarButtonItem = _numBarItem;
    self.navigationItem.rightBarButtonItem = _numBarItem;
    
    __weak OWTUserCollectionAssetViewCon* wself = self;
    
    _assetViewCon.numberOfAssetsFunc = ^
    {
        return [wself assetNum];
    };
    
    _assetViewCon.assetAtIndexFunc = ^(NSInteger index)
    {
        NSMutableOrderedSet* assets = [wself assets];
        if (assets != nil)
        {
            return (OWTAsset*)[assets objectAtIndex:index];
        }
        else
        {
            return (OWTAsset*)nil;
        }
    };
    
    _assetViewCon.onAssetSelectedFunc = ^(OWTAsset* asset)
    {
        OWTAssetViewCon* assetViewCon = [[OWTAssetViewCon alloc] initWithAsset:asset];
        [wself.navigationController pushViewController:assetViewCon animated:YES];
    };
    
    _assetViewCon.refreshDataFunc = ^(void (^refreshDoneFunc)())
    {
        OWTUserManager* um = GetUserManager();
        [um refreshUserSharedAssets:wself.user
                            success:^{
                                if (refreshDoneFunc != nil)
                                {
                                    refreshDoneFunc();
                                }
                                wself.numBarItem.title = [NSString stringWithFormat:@"%d", (int)[wself assetNum]];
                            }
                            failure:^(NSError* error) {
                                [SVProgressHUD showError:error];
                                if (refreshDoneFunc != nil)
                                {
                                    refreshDoneFunc();
                                }
                            }];
    };
    
    _assetViewCon.loadMoreDataFunc = ^(void (^loadMoreDoneFunc)())
    {
        OWTUserManager* um = GetUserManager();
        [um loadMoreUserSharedAssets:wself.user
                               count:50
                             success:^{
                                 if (loadMoreDoneFunc != nil)
                                 {
                                     loadMoreDoneFunc();
                                 }
                                 wself.numBarItem.title = [NSString stringWithFormat:@"%d", (int)[wself assetNum]];
                             }
                             failure:^(NSError* error) {
                                 [SVProgressHUD showError:error];
                                 if (loadMoreDoneFunc != nil)
                                 {
                                     loadMoreDoneFunc();
                                 }
                             }];
    };;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view addSubview:_assetViewCon.view];
    [_assetViewCon.view easyFillSuperview];
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
    [self refreshUserSharedAssetsIfNeeded];
}

- (void)reloadData
{
    [_assetViewCon reloadData];
    
    _numBarItem.title = [NSString stringWithFormat:@"%d", (int)[self assetNum]];
}

- (void)refreshUserSharedAssetsIfNeeded
{
    if (_user == nil)
    {
        return;
    }
    
    NSMutableOrderedSet* sharedAssets = [self assets];
    if (sharedAssets != nil)
    {
        return;
    }
    
    [_assetViewCon manualRefresh];
}

#pragma mark -

- (void)setUser:(OWTUser*)user
{
    _user = user;
    
    self.navigationItem.title = [NSString stringWithFormat:@"%@收藏的照片", _user.displayName];
}

@end
