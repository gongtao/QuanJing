//
//  OQJCategoryViewCon.m
//  Weitu
//
//  Created by Su on 8/23/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import "OQJExploreViewConlvyouinternational5.h"
#import "OWTCategory.h"
#import "OWTCategoryData.h"

#import "OWaterFlowCollectionView.h"
#import "OWaterFlowLayout.h"
#import "XHRefreshControl.h"
#import "OWTImageCell.h"
#import "OWTCategoryManagerlvyouinternational.h"
#import "OWTCategoryViewCon.h"
#import "OWTSearchViewCon.h"
#import <FontAwesomeKit/FontAwesomeKit.h>

#import "UIView+EasyAutoLayout.h"
#import "SVProgressHUD+WTError.h"
#import <SVPullToRefresh/SVPullToRefresh.h>

static NSString* kWaterFlowCellID = @"kWaterFlowCellID";

@interface OQJExploreViewConlvyouinternational5 ()

@property (nonatomic, strong) OWaterFlowLayout* waterFlowLayout;
@property (nonatomic, strong) XHRefreshControl* refreshControl;

@property (nonatomic, copy) NSMutableArray* categories;
@property (nonatomic, copy) NSMutableArray* categories1;
@property (nonatomic, copy) NSMutableArray* categories2;
@property (nonatomic, copy) NSMutableArray* categories3;
@property (nonatomic, copy) NSMutableArray* categories4;
@property (nonatomic, copy) NSMutableArray* categories5;
@property (nonatomic, copy) NSMutableArray* categories6;

@end

@implementation OQJExploreViewConlvyouinternational5

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
    }
    return self;
}

- (void)viewDidLoad
{
//    OWTCategoryManagerlvyouinternational *ocm = [[OWTCategoryManagerlvyouinternational alloc ]init];
    //ocm.keyPath =@"categories/app";
    
    [super viewDidLoad];
    
    [self setupNavigationBar];
    [self setupCollectionView];
    [self setupRefreshControl];
    
    [self reloadData];
}

- (void)setupNavigationBar
{
    self.view.backgroundColor = GetThemer().themeColorBackground;
    
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0 , 100, 44)];
    
    //titleLabel.text = @"首页";
    titleLabel.backgroundColor = [UIColor clearColor];  //设置Label背景透明
    titleLabel.font = [UIFont boldSystemFontOfSize:20];  //设置文本字体与大小
    titleLabel.textColor = GetThemer().themeColor;  //设置文本颜色
    titleLabel.textAlignment = UITextAlignmentCenter;
    titleLabel.text = @"应 用";  //设置标题
    self.navigationItem.titleView = titleLabel;
    
    UIImage* searchImage = [[FAKFontAwesome searchIconWithSize:22] imageWithSize:CGSizeMake(22, 22)];
    searchImage = [searchImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:searchImage
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(search)];
}

- (void)setupCollectionView
{
    
    UILabel *label1 = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 320, 60)];
    label1.text = @"南美洲";
    label1.textColor = GetThemer().themeColor;
    label1.font = [UIFont boldSystemFontOfSize:20];  //设置文本字体与大小
    label1.textAlignment = UITextAlignmentCenter;
    

   
    _waterFlowLayout = [[OWaterFlowLayout alloc] init];
    _waterFlowLayout.sectionInset = UIEdgeInsetsMake(66, 0, 6, 0);
    _waterFlowLayout.minimumColumnSpacing = 6;
    _waterFlowLayout.minimumInteritemSpacing = 6;
    _waterFlowLayout.columnCount = 2;
    
    _collectionView = [[OWaterFlowCollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:_waterFlowLayout];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.backgroundColor = GetThemer().themeColorBackground;
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.showsVerticalScrollIndicator = NO;
    _collectionView.alwaysBounceVertical = YES;
    
    [_collectionView registerClass:OWTImageCell.class forCellWithReuseIdentifier:kWaterFlowCellID];
    
    _collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    _collectionView.bounces = NO;
    [self.view addSubview:_collectionView];
    [_collectionView easyFillSuperview];
    [_collectionView addSubview:label1];
}

- (void)setupRefreshControl
{
    _refreshControl = [[XHRefreshControl alloc] initWithScrollView:_collectionView delegate:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self refreshIfNeeded];
}

- (void)search
{
    OWTSearchViewCon* searchViewCon = [[OWTSearchViewCon alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:searchViewCon animated:YES];
}

- (void)refreshIfNeeded
{
    OWTCategoryManagerlvyouinternational* cm = GetCategoryManagerlvyouinternational();
    if (cm.isRefreshNeeded)
    {
        [self manualRefresh];
    }
}

- (void)manualRefresh
{
    [_refreshControl startPullDownRefreshing];
}

- (void)refresh
{
    OWTCategoryManagerlvyouinternational* cm = GetCategoryManagerlvyouinternational();
    [cm refreshCategoriesWithSuccess:^{
        [_refreshControl endPullDownRefreshing];
        [self reloadData];
    }
                             failure:^(NSError* error) {
                                 [_refreshControl endPullDownRefreshing];
                                 [SVProgressHUD showError:error];
                             }];
}

- (void)reloadData
{
    
    //元素
    NSArray *arr= GetCategoryManagerlvyouinternational().categories;
 //   _categories = GetCategoryManagerlvyouinternational().categories;
    _categories = [[NSMutableArray alloc]init];
    _categories1 = [[NSMutableArray alloc]init];
    _categories2 = [[NSMutableArray alloc]init];
    _categories3 = [[NSMutableArray alloc]init];
    _categories4 = [[NSMutableArray alloc]init];
    _categories5 = [[NSMutableArray alloc]init];
    _categories6 = [[NSMutableArray alloc]init];
    for (OWTCategory*oc in arr) {
        if ([oc.GroupName  isEqual:@"亚洲"]) {
            [_categories1 addObject:oc];
        }
//            [_categories addObject:oc];
////        }
//
//        NSLog(@"oc.GroupName =%@",oc.GroupName);
////
        if ([oc.GroupName  isEqual:@"欧洲"]) {
            [_categories2 addObject:oc];
        }

        if ([oc.GroupName  isEqual:@"大洋洲"]) {
            [_categories3 addObject:oc];
        }

        if ([oc.GroupName  isEqual:@"北美洲"]) {
            [_categories4 addObject:oc];
        }

        if ([oc.GroupName  isEqual:@"南美洲"]) {
            [_categories addObject:oc];
        }

        if ([oc.GroupName  isEqual:@"非洲"]) {
            [_categories6 addObject:oc];
        }
//        if ([oc.GroupName  isEqual:@"亚洲"]) {
//            [_categories addObject:oc];
//        }

        
        
  }
    
    NSLog(@"_categories =%@",_categories);
    
    [_collectionView reloadData];
}

#pragma mark - OWaterFlowLayoutDataSource

- (CGSize)collectionView:(UICollectionView*)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath*)indexPath
{
    return CGSizeMake(157, 178);
   
}

#pragma mark - UICollectionViewDataSource methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _categories.count;///修改的
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    OWTImageCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:kWaterFlowCellID forIndexPath:indexPath];
    
    OWTCategory* category = _categories[indexPath.row];//修改的
    [cell setImageWithInfo:category.coverImageInfo];
    
    return cell;
     NSLog(@"55xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx%f",_collectionView.contentSize.height);
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

#pragma mark - UICollectionViewDelegate methods

- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

// called when the user taps on an already-selected item in multi-select mode
- (BOOL)collectionView:(UICollectionView *)collectionView shouldDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    OWTCategory* category = _categories[indexPath.row];
    OWTCategoryViewCon* categoryViewCon = [[OWTCategoryViewCon alloc] initWithCategory:category];
    [self.navigationController pushViewController:categoryViewCon animated:YES];
}

#pragma mark - 3rdparty refresh control

- (void)beginPullDownRefreshing
{
    [self refresh];
}

- (BOOL)keepiOS7NewApiCharacter
{
    return NO;
}

- (XHRefreshViewLayerType)refreshViewLayerType
{
    return XHRefreshViewLayerTypeOnScrollViews;
}

- (BOOL)isPullUpLoadMoreEnabled
{
    return NO;
}

@end
