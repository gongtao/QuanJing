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
    [self refresh];
}
#pragma 网络请求部分
-(void)getDataSourceWithDict:(NSDictionary *)dict
{
    RKObjectManager *um=[RKObjectManager sharedManager];
    _user=GetUserManager().currentUser;
    [um getObject:nil path:[NSString stringWithFormat:@"users/%@/likes",_user.userID] parameters:dict success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        NSDictionary *dict=mappingResult.dictionary;
        if (!loadMore) {
            [_assets removeAllObjects];
            [_collectionView headerEndRefreshing];
        }else
        {
            [_collectionView footerEndRefreshing];
        }
        for (OWTAsset *asset in dict[@"assets"]) {
            [_assets addObject:asset];
        }
        [self getCellHeight];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        if (!loadMore) {
            [_collectionView headerEndRefreshing];
        }else
        {
            [_collectionView footerEndRefreshing];
        }
        [SVProgressHUD showErrorWithStatus:@"网络有点慢"];
    }];
    
}
-(void)getDataSourceWithDict1:(NSDictionary *)dict
{
    RKObjectManager *um=[RKObjectManager sharedManager];
    _user=GetUserManager().currentUser;
    [um getObject:nil path:[NSString stringWithFormat:@"users/%@/comment",_user.userID] parameters:dict success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        NSDictionary *dict=mappingResult.dictionary;
        if (!loadMore) {
            [_assets removeAllObjects];
            [_collectionView headerEndRefreshing];
        }else
        {
            [_collectionView footerEndRefreshing];
        }
        for (OWTAsset *asset in dict[@"assets"]) {
            [_assets addObject:asset];
        }
        [SVProgressHUD dismiss];
        [self getCellHeight];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        if (!loadMore) {
            [_collectionView headerEndRefreshing];
        }else
        {
            [_collectionView footerEndRefreshing];
        }

        [SVProgressHUD showErrorWithStatus:@"网络有点慢"];
    }];
    
}
-(void)getCellHeight
{
    [_cellHeights removeAllObjects];
    for (OWTAsset *asset in _assets) {
        OWTImageInfo *imageInfo=asset.imageInfo;
        NSString *str=[NSString stringWithFormat:@"%f",imageInfo.height*(ITEMWIDTH/imageInfo.width)];
        [_cellHeights addObject:str];
        NSLog(@"%@",str);
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


}
-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(LJCollectionViewLayout *)collectionViewLayout heightForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [_cellHeights[indexPath.item] floatValue];
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
    OWTAsset *asset=_assets[indexPath.item];
    OWTImageInfo *imageinfo=asset.imageInfo;
    [cell.imageView setImageWithURL:[NSURL URLWithString:imageinfo.url]];
    cell.touchImagecb=^{
        OWTAsset  *asset1=[[OWTAsset alloc]init];
        [asset1 mergeWithData:(OWTAssetData *)asset];
        OWTAssetViewCon* assetViewCon = [[OWTAssetViewCon alloc] initWithAsset:asset1 deletionAllowed:YES onDeleteAction:^{  }];
        [self.navigationController pushViewController:assetViewCon animated:YES];
    
    };
    
    return cell;
}
#pragma MJRefresh
-(void)refresh
{
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
