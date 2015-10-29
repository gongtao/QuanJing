//
//  OWTUserSharedAssetsViewCon.m
//  Weitu
//
//  Created by Su on 6/14/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import "OWTUserSharedAssetsViewCon.h"
#import "OWTAssetFlowViewCon.h"
#import "OWTUser.h"
#import "OWTUserManager.h"
#import "OWTAssetViewCon.h"
#import "SVProgressHUD+WTError.h"
#import "UIView+EasyAutoLayout.h"
#import "UIViewController+WTExt.h"
#import "QJInterfaceManager.h"

@interface OWTUserSharedAssetsViewCon ()
{
}

@property (nonatomic, strong) OWTAssetFlowViewCon* assetViewCon;
@property (nonatomic, strong) UIBarButtonItem* numBarItem;
@property (nonatomic, strong)NSMutableOrderedSet *imageAssets;


@end

@implementation OWTUserSharedAssetsViewCon

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
    if (self.user1 != nil && self.user1.likeAmount != nil )
    {
        return _imageAssets;
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
   
    self.navigationItem.rightBarButtonItem = _numBarItem;
    
    __weak OWTUserSharedAssetsViewCon* wself = self;
    
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
        OWTAssetViewCon* assetViewCon = [[OWTAssetViewCon alloc] initWithAsset:asset];
        [wself.navigationController pushViewController:assetViewCon animated:YES];
    };
    
    /*// 用户收藏图片列表
     - (void)requestUserCollectImageList:(NSUInteger)pageNum
     pageSize:(NSUInteger)pageSize
     finished:(nullable void (^)(NSArray * imageObjectArray, BOOL isLastPage, NSArray * resultArray, NSError * error))finished;
     */
//    _assetViewCon.refreshDataFunc = ^(void (^refreshDoneFunc)())
//    {
//        QJInterfaceManager *fm = [QJInterfaceManager sharedManager];
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//            [fm requestUserCollectImageList:userID  pageNum:1 pageSize:60  currentImageId:nil finished:^(NSArray * albumObjectArray, BOOL isLastPage,NSArray * resultArray, NSError * error){
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    if (error == nil) {
//                        if (albumObjectArray != nil){
//                            [wself.imageAssets removeAllObjects];
//                            [wself.imageAssets addObjectsFromArray:albumObjectArray];
//                        }
//                        if (refreshDoneFunc != nil){
//                            refreshDoneFunc();
//                        }
//                        NSLog(@"获取相册成功,照片熟量 %ld",wself.imageAssets.count);
//                    }else{
//                        [SVProgressHUD showErrorWithStatus:@"获取相册失败"];
//                        NSLog(@"获取相册失败");
//                        if (refreshDoneFunc != nil)
//                            refreshDoneFunc();
//                    }
//                });
//            }];
//            
//        });
//
//    };
    
//    _assetViewCon.loadMoreDataFunc = ^(void (^loadMoreDoneFunc)())
//    {
//        OWTUserManager* um = GetUserManager();
//        [um loadMoreUserSharedAssets:wself.user
//                               count:50
//                             success:^{
//                                 if (loadMoreDoneFunc != nil)
//                                 {
//                                     loadMoreDoneFunc();
//                                 }
//                                   wself.numBarItem.title = [NSString stringWithFormat:@"%ld", _lightbox];
//                             }
//                             failure:^(NSError* error) {
//                                 [SVProgressHUD showError:error];
//                                 if (loadMoreDoneFunc != nil)
//                                 {
//                                     loadMoreDoneFunc();
//                                 }
//                             }];
//    };;
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
    [_assetViewCon manualRefresh];

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
    
    _numBarItem.title = [NSString stringWithFormat:@"%ld", _lightbox];
}

- (void)refreshUserSharedAssetsIfNeeded
{
    if (_user1 == nil)
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

- (void)setUser1:(QJUser*)user
{
    _user1 = user;

    self.navigationItem.title = [NSString stringWithFormat:@"%@收藏的照片", _user1.collectAmount];
}

@end
