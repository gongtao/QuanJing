//
//  exploreViewController.m
//  Weitu
//
//  Created by sunhu on 14/12/19.
//  Copyright (c) 2014年 SparkingSoft Co., Ltd. All rights reserved.
//

#import "exploreViewController.h"

//
//  OQJCategoryViewCon.m
//  Weitu
//
//  Created by Su on 8/23/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//



#import "OWaterFlowCollectionView.h"
#import "OWaterFlowLayout.h"
#import "XHRefreshControl.h"
#import "OWTImageCell.h"
#import "OWTCategoryManager.h"
#import "OWTCategoryViewCon.h"
#import "OWTSearchViewCon.h"
#import <FontAwesomeKit/FontAwesomeKit.h>

#import "UIView+EasyAutoLayout.h"
#import "SVProgressHUD+WTError.h"
#import <SVPullToRefresh/SVPullToRefresh.h>


#import "WLJWebViewController.h"
#import "UIViewController+WTExt.h"
static NSString* kWaterFlowCellID = @"kWaterFlowCellID";

@interface exploreViewController ()

@property (nonatomic, strong) OWaterFlowLayout* waterFlowLayout;
@property (nonatomic, strong) XHRefreshControl* refreshControl;
@property (nonatomic, strong) UICollectionView* collectionView;
@property (nonatomic, copy) NSArray* categories;
@property (nonatomic, copy)NSArray *seArr;

@property (nonatomic, copy)NSArray *titleArr;
@end

@implementation exploreViewController

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
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];
    
    [self setupNavigationBar];
    [self setupCollectionView];
    //    [self setupRefreshControl];
    //
    //   [self reloadData];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

- (void)setupNavigationBar
{
       self.title = _titleString;
    //
    //    UIImage* searchImage = [[FAKFontAwesome searchIconWithSize:22] imageWithSize:CGSizeMake(22, 22)];
    //    searchImage = [searchImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    //
    //    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:searchImage
    //                                                                              style:UIBarButtonItemStylePlain
    //                                                                             target:self
    //                                                                             action:@selector(search)];
}

- (void)setupCollectionView
{
    _titleArr = @[@"旅游",@"家居",@"汽车",@"美食",@"时尚",@"百科"];
    
    self.title = _titleArr[_titleCount];
    
    UIImage* searchImage = [[FAKFontAwesome searchIconWithSize:22] imageWithSize:CGSizeMake(22, 22)];
    searchImage = [searchImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:searchImage
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(search)];
    
    UIImageView *imageV = [[UIImageView alloc]init];
    
    imageV.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@.jpg",_titleArr[_titleCount]]];
    //    imageV.frame = CGRectMake(0, 0, 320, 1197);
    
    UIScrollView *scrollV = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, 320, self.view.bounds.size.height)];
    [scrollV addSubview:imageV];
    //    scrollV.contentSize =CGSizeMake(320, 1197);
    scrollV.showsHorizontalScrollIndicator = YES;
    
    //
    //    if ( [UIScreen mainScreen].bounds.size.height==2208.000000 ){
    //                    imageV.frame = CGRectMake(0, 64, 320, 1197);
    //                    scrollV.contentSize =CGSizeMake(320, 1197);
    //                            }
    //                else
    //                {
    //    imageV.frame = CGRectMake(0, 0, 320, 456);
    //    scrollV.contentSize =CGSizeMake(320, 456+44+64);
    imageV.frame = CGRectMake(0, 0, 320, 445);
    scrollV.contentSize =CGSizeMake(320, 445+44+64);
    //                }
    //不支持高分辨率
    
    scrollV.delegate =self;
    [self.view addSubview:scrollV];
    scrollV.bounces = NO;
    
    //搜索框的尺寸(20,20) (40,40)  高67
    //标签的尺寸 （20，280/6） 高120 145
    
    //每日一图 高198 336
    //    342 418 496 572 656
    //
    //    700 902
    //
    //
    //    热门搜索
    //    994 1031 1068 1106 1147 1187
    //
    //    宽6
    NSArray *arr20 =@[@"温哥华以北约120公里的惠斯勒乃北美洲最大面积的...",
                     @"今年的圣诞节你想去哪里过，去商场、电影院、还是...",
                     @"每年８月最后一个星期三，在西班牙巴伦西亚地区的...",
                     @"洒红节是印度最盛大的节日之一，源于古人期盼丰收..."];
    NSArray *arr21 =@[@"在比格迪市有一处有着悠久而又丰富历史的充满着魅...",
                      @"在波兰的波兹南市附近有一家明亮时尚而又宽敞的的...",
                      @"肉丸看似默默无语，但在全球美食榜单上却是个大明...",
                      @"东京总是带给我丰富灵感。因为在东京，人们穿着打..."];
    NSArray *arr22 =@[@"温哥华以北约120公里的惠斯勒乃北美洲最大面积的...",
                      @"精湛的工艺和先进技术在德国制造的汽车中代代流传...",
                      @"肉丸看似默默无语，但在全球美食榜单上却是个大明...",
                      @"东京总是带给我丰富灵感。因为在东京，人们穿着打..."];
    NSArray *arr23 =@[@"温哥华以北约120公里的惠斯勒乃北美洲最大面积的...",
                      @"精湛的工艺和先进技术在德国制造的汽车中代代流传...",
                      @"肉丸看似默默无语，但在全球美食榜单上却是个大明...",
                      @"东京总是带给我丰富灵感。因为在东京，人们穿着打..."];
    NSArray *arr24 =@[@"温哥华以北约120公里的惠斯勒乃北美洲最大面积的...",
                      @"精湛的工艺和先进技术在德国制造的汽车中代代流传...",
                      @"肉丸看似默默无语，但在全球美食榜单上却是个大明...",
                      @"东京总是带给我丰富灵感。因为在东京，人们穿着打..."];
    NSArray *arr25 =@[@"温哥华以北约120公里的惠斯勒乃北美洲最大面积的...",
                      @"精湛的工艺和先进技术在德国制造的汽车中代代流传...",
                      @"肉丸看似默默无语，但在全球美食榜单上却是个大明...",
                      @"东京总是带给我丰富灵感。因为在东京，人们穿着打..."];
    NSArray *capArr = @[arr20,arr21,arr22,arr23,arr24,arr25];
    
    for (int i = 0; i<5; i++) {
        UIButton *btn = [[ UIButton alloc]init];
        //        btn.backgroundColor = [UIColor yellowColor];
        if (i==0) {
            btn.frame = CGRectMake(0, 0, 320, 137);
            
        }
        if (i>0) {
            btn.frame = CGRectMake(0, 137+76*(i-1), 320, 76);
            UIView *view2 =[[UIView alloc]initWithFrame:CGRectMake(90, 137+76*(i-1)+2, 230, 76-20)];
            view2.backgroundColor = [UIColor whiteColor];
            [scrollV addSubview:view2];
            
            UILabel *label1 =[[UILabel alloc]init];
            label1.frame=CGRectMake(105, 137+76*(i-1)+2, 205, 76-30);
            label1.text =_titleArray[i];
            
            label1.font = [UIFont  systemFontOfSize:15];
//            label1.backgroundColor = [UIColor yellowColor];
            //        label1.text =arr1[i-7];
            
            [scrollV addSubview:label1];
            
            UILabel *label2 =[[UILabel alloc]init];
            label2.frame =CGRectMake(105, 137+76*(i-1)+40+2*(i-1)+5-10+5-10-10, 205, 76-10);
            
            
            
            label2.font = [UIFont  systemFontOfSize:12];
            
            //            label2.text =arr2[i-7];
            
            
            
            NSAttributedString *attributedString =[[NSAttributedString alloc] initWithString:capArr[_titleCount][i-1] attributes:@{NSForegroundColorAttributeName : [UIColor lightGrayColor],NSKernAttributeName : @(1.3f)}];
            
            [label2 setAttributedText:attributedString];
            
            [label2 setNumberOfLines:3];
            [scrollV addSubview:label2];

            
        }
        btn.tag =i;
        //            btn.tintColor = [UIColor rColor];
        //        [btn se forState:UIControlStateSelected];
        
        [btn addTarget:self action:@selector(btnclick:) forControlEvents:UIControlEventTouchUpInside];
        
        [scrollV addSubview:btn];
    }
}

- (void)btnclick:(UIButton *)button
{
    WLJWebViewController *evc = [[WLJWebViewController alloc]init];
    evc.urlString =_sortArr[button.tag];
    evc.titleS =_titleArray[button.tag];
    [self.navigationController pushViewController:evc animated:YES];
    [evc substituteNavigationBarBackItem];
    
    
    
    
    
    
    //    OWTSearchResultsViewCon* searchResultsViewCon = [[OWTSearchResultsViewCon alloc] initWithNibName:nil bundle:nil];
    //    //
    //    [searchResultsViewCon setKeyword:keyword ];
    //    [self.navigationController pushViewController:searchResultsViewCon animated:YES];
    
}


//- (void)setupRefreshControl
//{
//    _refreshControl = [[XHRefreshControl alloc] initWithScrollView:_collectionView delegate:self];
//}
//
//
//
//- (void)viewWillDisappear:(BOOL)animated
//{
//    [super viewWillDisappear:animated];
//}
//
//- (void)viewDidAppear:(BOOL)animated
//{
//    [super viewDidAppear:animated];
//    [self refreshIfNeeded];
//}
//
- (void)search
{
    OWTSearchViewCon* searchViewCon = [[OWTSearchViewCon alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:searchViewCon animated:YES];
}
//


@end
