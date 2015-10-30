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

@property (nonatomic, assign)NSInteger currentPage;
@property (nonatomic, strong)QJImageObject *currentAlumbObject;
@property (nonatomic, strong)NSMutableOrderedSet *imageAssets;

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
   if (self.user1 != nil && self.user1.uploadAmount != nil )
    {
        return _imageAssets;
    }
    else
    {
        return nil;
    }
}

- (void)setup
{
    _imageAssets = [[NSMutableOrderedSet alloc]init];
    _currentPage = 1;
    NSNumber *userID = ([_user1.uid integerValue] != [[[QJPassport sharedPassport]currentUser].uid integerValue])? _user1.uid :nil;
    _assetViewCon = [[OWTAssetFlowViewCon alloc] initWithNibName:nil bundle:nil];
    [self addChildViewController:_assetViewCon];
    
    __weak OWTUserAssetsViewCon* wself = self;
    _assetViewCon.numberOfAssetsFunc = ^
    {
        NSMutableOrderedSet* assets = [wself imageAssets];
        if (assets != nil)
        {
            return (int)assets.count;
        }
        else
        {
            return 0;
        }
    };
    
    //带返回参数的block
    _assetViewCon.assetAtIndexFunc = ^(NSInteger index)
    {
        
        NSMutableOrderedSet* assets = [wself assets];
        if (assets != nil)
        {
            if (index >= _imageAssets.count ) {
                return (QJImageObject*)[assets objectAtIndex:_imageAssets.count -1];
            }
            return (QJImageObject*)[assets objectAtIndex:index];
        }
        else
        {
            return (QJImageObject*)nil;
        }
    };
    
    //点击动作
    _assetViewCon.onAssetSelectedFunc = ^(QJImageObject* asset)
    {
        asset.imageType =  [NSNumber numberWithInt:2];
        OWTAssetViewCon* assetViewCon = [[OWTAssetViewCon alloc] initWithAsset:asset deletionAllowed:YES onDeleteAction:^{ [wself.assetViewCon reloadData]; }];
        assetViewCon.user1 = wself.user1;
        [wself.navigationController pushViewController:assetViewCon animated:YES];
    };
    
    _assetViewCon.refreshDataFunc = ^(void (^refreshDoneFunc)())
    {
        QJInterfaceManager *fm = [QJInterfaceManager sharedManager];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [fm requestUserImageList:userID  pageNum:1 pageSize:60  currentImageId:nil finished:^(NSArray * albumObjectArray, BOOL isLastPage,NSArray * resultArray, NSError * error){
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (error == nil) {
                        if (albumObjectArray != nil){
                            [wself.imageAssets removeAllObjects];
                            [wself.imageAssets addObjectsFromArray:albumObjectArray];
                        }
                        if (refreshDoneFunc != nil){
                            refreshDoneFunc();
                        }
                        NSLog(@"获取相册成功,照片熟量 %ld",wself.imageAssets.count);
                    }else{
                        [SVProgressHUD showErrorWithStatus:@"获取相册失败"];
                        NSLog(@"获取相册失败");
                        if (refreshDoneFunc != nil)
                            refreshDoneFunc();
                    }
                });
            }];
            
        });
        
    };
    
    _assetViewCon.loadMoreDataFunc = ^(void (^loadMoreDoneFunc)()) {
        QJInterfaceManager *fm = [QJInterfaceManager sharedManager];
        NSInteger tmp = wself.currentPage+1;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [fm requestUserImageList:userID  pageNum:tmp pageSize:60  currentImageId:nil finished:^(NSArray * albumObjectArray, BOOL isLastPage, NSArray * resultArray, NSError * error){
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (error == nil) {
                        if (albumObjectArray != nil){
                            wself.currentPage++;
                            [wself.imageAssets addObjectsFromArray:albumObjectArray];
                        }
                        if (loadMoreDoneFunc != nil){
                            loadMoreDoneFunc();
                        }
                        NSLog(@"获取相册loadmore成功,照片熟量 %ld",wself.imageAssets.count);
                    }else{
                        [SVProgressHUD showErrorWithStatus:@"获取相册失败"];
                        NSLog(@"获取相册loadmore失败");
                        if (loadMoreDoneFunc != nil)
                            loadMoreDoneFunc();
                    }
                });
            }];
            
        });
    };
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setup];

    [self.view addSubview:_assetViewCon.view];
    [_assetViewCon.view easyFillSuperview];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self substituteNavigationBarBackItem];
    //[_assetViewCon reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self refreshUserAssetsIfNeeded];
}

- (void)refreshUserAssetsIfNeeded
{
    if (_imageAssets.count>0)
    {
        return;
    }

    [_assetViewCon manualRefresh];
}

#pragma mark -

- (void)setUser1:(QJUser*)user
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
