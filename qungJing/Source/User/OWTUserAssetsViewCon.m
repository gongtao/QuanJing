//
//  OWTUserAssetsViewCon.m
//  Weitu
//
//  Created by Su on 6/14/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import "OWTUserAssetsViewCon.h"
#import "OWTAssetFlowViewCon.h"
#import "OWTUser.h"
#import "OWTUserManager.h"
#import "OWTAssetViewCon.h"
#import "SVProgressHUD+WTError.h"
#import "UIView+EasyAutoLayout.h"
#import "UIViewController+WTExt.h"



@interface OWTUserAssetsViewCon ()


@property (nonatomic, copy) NSMutableOrderedSet* assets;

@end

@implementation OWTUserAssetsViewCon

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
    if (self.user != nil && self.user.assetsInfo != nil && self.user.assetsInfo.assets != nil)
    {
        return self.user.assetsInfo.assets;
    }
    else
    {
        return nil;
    }
}

- (void)setup
{
    _assetViewCon = [[OWTAssetFlowViewCon alloc] initWithNibName:nil bundle:nil];
    [self addChildViewController:_assetViewCon];
    
    __weak OWTUserAssetsViewCon* wself = self;
    
    _assetViewCon.numberOfAssetsFunc = ^
    {
        NSMutableOrderedSet* assets = [wself assets];
        if (assets != nil)
        {
            return (int)assets.count;
        }
        else
        {
            return 0;
        }
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
        OWTAssetViewCon* assetViewCon = [[OWTAssetViewCon alloc] initWithAsset:asset deletionAllowed:YES onDeleteAction:^{ [wself.assetViewCon reloadData]; }];
        [wself.navigationController pushViewController:assetViewCon animated:YES];
    };
    
    _assetViewCon.refreshDataFunc = ^(void (^refreshDoneFunc)())
    {
        OWTUserManager* um = GetUserManager();
        [um refreshUserAssets:wself.user
                      success:^{
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
        OWTUserManager* um = GetUserManager();
        [um loadMoreUserAssets:wself.user
                         count:60
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
    [_assetViewCon reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self refreshUserAssetsIfNeeded];
}

- (void)refreshUserAssetsIfNeeded
{
    if (_user == nil)
    {
        return;
    }
    
    if (_user.assetsInfo != nil && _user.assetsInfo.assets != nil)
    {
        return;
    }
    
    [_assetViewCon manualRefresh];
}

#pragma mark -

- (void)setUser:(OWTUser*)user
{
    _user = user;
    
    if (_user != nil)
    {
        self.navigationItem.title = [NSString stringWithFormat:@"%@的照片", _user.displayName];
        NSInteger photoNum = _user.assetsInfo.publicAssetNum;
        if (_user.isCurrentUser)
        {
            photoNum += _user.assetsInfo.privateAssetNum;
        }
        NSNumber* totalAssetNum = [NSNumber numberWithInteger:photoNum];
        _assetViewCon.totalAssetNum = totalAssetNum;
    }
    else
    {
        self.navigationItem.title = @"";
        _assetViewCon.totalAssetNum = nil;
    }
}

@end
