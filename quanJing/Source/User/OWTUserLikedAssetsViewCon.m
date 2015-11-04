//
//  OWTUserLikedAssetsViewCon.m
//  Weitu
//
//  Created by Su on 6/14/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import "OWTUserLikedAssetsViewCon.h"
#import "OWTAssetFlowViewCon.h"
#import "OWTUser.h"
#import "OWTUserManager.h"
#import "OWTAssetViewCon.h"
#import "SVProgressHUD+WTError.h"
#import "UIView+EasyAutoLayout.h"
#import "UIViewController+WTExt.h"
#import "QJInterfaceManager.h"
#import "QJPassport.h"

#define PageSize 30

@interface OWTUserLikedAssetsViewCon ()
{
}
@property (nonatomic, assign)NSInteger currentPage;

@property (nonatomic, strong) OWTAssetFlowViewCon* assetViewCon;
@property (nonatomic, strong)NSMutableOrderedSet *imageAssets;
@property (nonatomic, strong) UIBarButtonItem* numBarItem;

@end

@implementation OWTUserLikedAssetsViewCon

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
    if (self.user1 != nil && self.user1.collectAmount != nil )
    {
        return _imageAssets;
    }
    else
    {
        return nil;
    }
}

- (instancetype)initWithUser:(QJUser *)user  {
    self =  [super init];
    if (self)
    {
        self.user1 = user;
        
        return self;
    }
    return nil;
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
    _imageAssets = [[NSMutableOrderedSet alloc]init];
    [self addChildViewController:_assetViewCon];
    _currentPage = 1;
    _numBarItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                   style:UIBarButtonItemStyleBordered
                                                  target:nil
                                                  action:nil];
//    self.navigationItem.rightBarButtonItem = _numBarItem;

    __weak OWTUserLikedAssetsViewCon* wself = self;

    _assetViewCon.numberOfAssetsFunc = ^
    {
        return [wself assetNum];
    };
    
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

    
    _assetViewCon.onAssetSelectedFunc = ^(QJImageObject* asset)
    {
        OWTAssetViewCon* assetViewCon = [[OWTAssetViewCon alloc] initWithImageId:asset imageType:asset.imageType];
        assetViewCon.user1 = wself.user1;
        [wself.navigationController pushViewController:assetViewCon animated:YES];
    };
    
    _assetViewCon.refreshDataFunc = ^(void (^refreshDoneFunc)())
    {
        QJInterfaceManager *fm = [QJInterfaceManager sharedManager];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [fm requestUserCollectImageList:wself.user1.uid  pageNum:1 pageSize:PageSize finished:^(NSArray * albumObjectArray, BOOL isLastPage,NSArray * resultArray, NSError * error){
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (error == nil) {
                        if (albumObjectArray != nil){
                            [wself.imageAssets removeAllObjects];
                            [wself.imageAssets addObjectsFromArray:albumObjectArray];
                        }
                        if (refreshDoneFunc != nil){
                            refreshDoneFunc();
                        }
                        NSLog(@"获取相册收藏成功,照片熟量 %ld",wself.imageAssets.count);
                    }else{
                        [SVProgressHUD showErrorWithStatus:@"获取收藏失败"];
                        NSLog(@"获取相册收藏失败");
                        if (refreshDoneFunc != nil)
                            refreshDoneFunc();
                    }
                });
            }];
            
        });
        
    };

    _assetViewCon.loadMoreDataFunc = ^(void (^loadMoreDoneFunc)())
    {
        QJInterfaceManager *fm = [QJInterfaceManager sharedManager];
        if (wself.imageAssets.count/PageSize == 0) {
            if (loadMoreDoneFunc != nil){
                loadMoreDoneFunc();
            }
            return ;
        }
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [fm requestUserCollectImageList:wself.user1.uid  pageNum:wself.imageAssets.count/PageSize+1 pageSize:PageSize  finished:^(NSArray * albumObjectArray, BOOL isLastPage, NSArray * resultArray, NSError * error){
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
    NSString *str = ([_user1.uid integerValue] != [[[QJPassport sharedPassport]currentUser].uid integerValue])?_user1.nickName:@"我";
    self.navigationItem.title = [NSString stringWithFormat:@"%@喜欢的照片", str];
    _assetViewCon.totalAssetNum = _user1.collectAmount;

    [self.view addSubview:_assetViewCon.view];
    [_assetViewCon.view easyFillSuperview];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self substituteNavigationBarBackItem];
//    [self reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self refreshUserLikedAssetsIfNeeded];
}

//- (void)reloadData
//{
//    [_assetViewCon reloadData];
//
//    _numBarItem.title = [NSString stringWithFormat:@"%d", (int)[self assetNum]];
//}

- (void)refreshUserLikedAssetsIfNeeded
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
}

@end
