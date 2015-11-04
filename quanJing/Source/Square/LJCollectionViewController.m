//
//  LJCollectionViewController.m
//  Weitu
//
//  Created by qj-app on 15/6/24.
//  Copyright (c) 2015年 SparkingSoft Co., Ltd. All rights reserved.
//

#import "LJCollectionViewController.h"
#import "LJCollectionViewLayout.h"
#import "OWTUser.h"
#import "WTCommon.h"
#import "OWTUserManager.h"
#import "OWTAsset.h"
#import "OWTImageInfo.h"
#import "LJCollectionCell.h"
#import "UIImageView+AFNetworking.h"
#import "OWTAssetViewCon.h"
#import "MJRefresh.h"
#define ITEMWIDTH  (SCREENWIT-15)/2
#define CELL_IDENTIFIER @"waterCell"
@interface LJCollectionViewController ()<MyCollectionViewLayoutDelegete,UICollectionViewDataSource,UICollectionViewDelegate>

@end

@implementation LJCollectionViewController
{
    UICollectionView *_collectionView;
    OWTUser *_user;
    NSMutableArray *_assets;
    NSMutableArray *_cellHeights;
    BOOL loadMore;
    NSInteger page;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    _assets=[[NSMutableArray alloc]init];
    _cellHeights=[[NSMutableArray alloc]init];
    if(_isLike==YES)
    {
        self.title=@"喜欢的图片";
    }else
    {
        self.title=@"评论的图片";
    }
    [self setupCollectionView];
}
#pragma 网络请求部分
-(void)getDataSourceWithDict:(NSDictionary *)dict
{
    QJInterfaceManager *fm=[QJInterfaceManager sharedManager];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [fm requestUserLikeImageList:[QJPassport sharedPassport].currentUser.uid pageNum:1 pageSize:50 finished:^(NSArray * _Nonnull imageObjectArray, BOOL isLastPage, NSArray * _Nonnull resultArray, NSError * _Nonnull error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (error==nil) {
                    if (!loadMore) {
                        [_assets removeAllObjects];
                        [_collectionView headerEndRefreshing];
                    }else
                    {
                        [_collectionView footerEndRefreshing];
                    }
                    [_assets addObjectsFromArray:imageObjectArray];
                    [self getCellHeight];
                    [_collectionView reloadData];
                }
            });
        }];
    });
    

}
-(void)getDataSourceWithDict1:(NSDictionary *)dict
{
    QJInterfaceManager *fm=[QJInterfaceManager sharedManager];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [fm requestUserCommentImageList:page pageSize:50 finished:^(NSArray * _Nonnull imageObjectArray, BOOL isLastPage, NSArray * _Nonnull resultArray, NSError * _Nonnull error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (error==nil) {
                        if (!loadMore) {
                            [_assets removeAllObjects];
                            [_collectionView headerEndRefreshing];
                        }else
                        {
                            [_collectionView footerEndRefreshing];
                        }
                        [_assets addObjectsFromArray:imageObjectArray];
                        [self getCellHeight];
                        [_collectionView reloadData];
                    }
                });
                            }];
    });
    
    
}
-(void)getCellHeight
{
    [_cellHeights removeAllObjects];
    for (QJImageObject *asset in _assets) {
        if (asset.height==nil) {
            return;
        }
        NSString *str=[NSString stringWithFormat:@"%f",asset.height.floatValue*(ITEMWIDTH/asset.width.floatValue)];
        [_cellHeights addObject:str];
        NSLog(@"%@  %@   %@",str,asset.height.stringValue,asset.width.stringValue);
    }
    [_collectionView reloadData];
}
-(void)setupCollectionView
{
    LJCollectionViewLayout *ljout=[[LJCollectionViewLayout alloc]init];
    ljout.sectionInset=UIEdgeInsetsMake(5, 5, 5, 5);
    ljout.delegate=self;
    _collectionView=[[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, SCREENWIT, SCREENHEI+49) collectionViewLayout:ljout];
    _collectionView.autoresizingMask=UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    _collectionView.dataSource=self;
    _collectionView.delegate=self;
    _collectionView.backgroundColor=[UIColor whiteColor];
    [self.view addSubview:_collectionView];
    [_collectionView registerClass:[LJCollectionCell class] forCellWithReuseIdentifier:CELL_IDENTIFIER];
    [_collectionView addHeaderWithTarget:self action:@selector(refreshNew)];
    [_collectionView headerBeginRefreshing];
    [_collectionView addFooterWithTarget:self action:@selector(refreshMore)];
    _collectionView.headerPullToRefreshText = @"";
    _collectionView.headerReleaseToRefreshText = @"";
    _collectionView.headerRefreshingText = @"";
    
    _collectionView.footerPullToRefreshText = @"";
    _collectionView.footerReleaseToRefreshText = @"";
    _collectionView.footerRefreshingText = @"";

}
-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(LJCollectionViewLayout *)collectionViewLayout heightForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (_cellHeights.count>0) {
        return [_cellHeights[indexPath.item] floatValue];
    }else {
        return 50;
    }
}
#pragma mark - UICollectionViewDataSource
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _assets.count;
}
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    LJCollectionCell *cell=(LJCollectionCell *)[collectionView dequeueReusableCellWithReuseIdentifier:CELL_IDENTIFIER forIndexPath:indexPath];
    cell.imageView.frame=cell.bounds;
    QJImageObject *imageModel=_assets[indexPath.item];
    [cell.imageView setImageWithURL:[NSURL URLWithString:[QJInterfaceManager thumbnailUrlFromImageUrl:imageModel.url size:cell.bounds.size]]];
    cell.touchImagecb=^{
        OWTAssetViewCon * assetViewCon = [[OWTAssetViewCon alloc]initWithImageId:imageModel imageType:imageModel.imageType];
        assetViewCon.isSquare = YES;
        assetViewCon.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:assetViewCon animated:NO];
    };
    
    return cell;
}
-(void)refreshNew
{
    page=0;
NSDictionary *dict=@{@"startIndex":@"0",@"count":@"50"};
    loadMore=NO;
    if (_isLike) {
        [self getDataSourceWithDict:dict];
    }else{
        [self getDataSourceWithDict1:dict];
    }

}
-(void)refreshMore
{
    page++;
    if (_cellHeights.count%50==0) {
        NSString *str=[NSString stringWithFormat:@"%d",page];
        NSDictionary *dict=@{@"startIndex":str,@"count":@"50"};
        loadMore=YES;
        if (_isLike) {
            [self getDataSourceWithDict:dict];
        }else{
            [self getDataSourceWithDict1:dict];
        }

    }else
    {
        [_collectionView footerEndRefreshing];
    }
}
@end
