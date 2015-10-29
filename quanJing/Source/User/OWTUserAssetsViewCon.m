//
//  OWTUserAssetsViewCon.m
//  Weitu
//
//  Created by Su on 6/14/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import "OWTUserAssetsViewCon.h"
#import "OWTAssetFlowViewCon.h"
#import "OWTUserManager.h"
#import "OWTAssetViewCon.h"
#import "SVProgressHUD+WTError.h"
#import "UIView+EasyAutoLayout.h"
#import "UIViewController+WTExt.h"
#import "QJInterfaceManager.h"
#import "QJPassport.h"
#import "QJAlbumObject.h"

@interface OWTUserAssetsViewCon ()

@property (nonatomic, copy) NSMutableOrderedSet* assets;
@property (nonatomic, assign)NSInteger currentPage;
@property (nonatomic, strong)QJAlbumObject *currentAlumbObject;

@end

@implementation OWTUserAssetsViewCon

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
    }
    return self;
}

- (NSMutableOrderedSet*)assets
{
//    if (self.user1 != nil && self.user1.assetsInfo != nil && self.user.assetsInfo.assets != nil)
//    {
//        return self.user1.assetsInfo.assets;
//    }
//    else
//    {
        return nil;
 //   }
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
        [um refreshUserAssets:wself.user1
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
        [um loadMoreUserAssets:wself.user1
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


-(void)getAlbumID:(NSInteger)pageNum
{
    
//    NSNumber *userID = ([_user1.uid integerValue] == [[[QJPassport sharedPassport]currentUser].uid integerValue])? _user1.uid :nil;
    
    //Quesion 一个相册ID会有多个？
    QJInterfaceManager *fm = [QJInterfaceManager sharedManager];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [fm requestUserAlbumList:pageNum  pageSize:60  finished:^(NSArray * albumObjectArray, BOOL isLastPage, NSArray * resultArray, NSError * error){
            dispatch_async(dispatch_get_main_queue(), ^{
                if (error == nil) {
                   _currentAlumbObject = [albumObjectArray firstObject];
                    [self albumID2Assest:_currentAlumbObject];
                    NSLog(@"获取相册ID成功");
                }else{
                    [SVProgressHUD showErrorWithStatus:@"获取相册失败"];
                    NSLog(@"获取相册ID失败");
                }
            });
        }];

    });
}

//通过相册ID获取图片
-(void)albumID2Assest:(QJAlbumObject*)albumObject
{
    QJInterfaceManager *fm = [QJInterfaceManager sharedManager];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [fm requestUserAlbumImageList:albumObject.aid  pageNum:_currentPage pageSize:60  finished:^(NSArray * albumObjectArray, BOOL isLastPage, NSArray * resultArray, NSError * error){
            dispatch_async(dispatch_get_main_queue(), ^{
                if (error == nil) {
                    NSLog(@"获取相册成功end");
                }else{
                    [SVProgressHUD showErrorWithStatus:@"获取相册失败"];
                    NSLog(@"获取相册失败");
                }
            });
        }];
        
    });
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _currentPage = 1;
    [self getAlbumID:_currentPage];
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
    if (_user1 == nil)
    {
        return;
    }
    
    if (_user1.uploadAmount != nil && _user1.uploadAmount != nil)
    {
        return;
    }
    
    [_assetViewCon manualRefresh];
}

#pragma mark -

- (void)setUser:(QJUser*)user
{
    _user1 = user;
    
    if (_user1 != nil)
    {
        
        NSString *indentify = ([user.uid integerValue] == [[[QJPassport sharedPassport]currentUser].uid integerValue])? @"我":user.nickName;
        self.navigationItem.title = [NSString stringWithFormat:@"%@的照片",indentify];
        NSNumber* totalAssetNum = _user1.uploadAmount;
        _assetViewCon.totalAssetNum = totalAssetNum;
    }
    else
    {
        self.navigationItem.title = @"";
        _assetViewCon.totalAssetNum = nil;
    }
}

@end
