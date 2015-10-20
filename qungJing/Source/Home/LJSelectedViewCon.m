//
//  LJSelectedViewCon.m
//  Weitu
//
//  Created by qj-app on 15/8/15.
//  Copyright (c) 2015年 SparkingSoft Co., Ltd. All rights reserved.
//

#import "LJSelectedViewCon.h"
#import "OQJExploreViewConlvyou.h"
#import "OQJExploreViewConlvyouinternational.h"
#import "OWTSearchViewCon.h"
#import <UIColor-HexString/UIColor+HexString.h>
#import <QBFlatButton/QBFlatButton.h>
#import <FontAwesomeKit/FontAwesomeKit.h>
#import <AppleGrocery/UIKitExt/OLineView.h>
#import "OWTTabBarHider.h"
@interface LJSelectedViewCon ()<UIScrollViewDelegate>

@end

@implementation LJSelectedViewCon
{
    UIScrollView *_scrollView;
    UIButton *_gnBtn;
    UIButton *_gwBtn;
    QBFlatButton* _latestButton;
    QBFlatButton* _hottestButton;
    int _currentPageIndex;
    NSArray* _pageButtons;
    NSArray* _pageViews;
    NSArray* _pageViewCons;
    OWTTabBarHider *_tabHider;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _tabHider=[[OWTTabBarHider alloc]init];
    [self setUpAllView];
    [self setupNavBar];
    [self setupContentView];
    [self setupButtons];
}
-(void)viewWillAppear:(BOOL)animated
{
    [_tabHider hideTabBar];

}
- (void)setupNavBar
{
    self.view.backgroundColor = GetThemer().themeColorBackground;
    
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0 , 100, 44)];
    
    //titleLabel.text = @"首页";
    titleLabel.backgroundColor = [UIColor clearColor];  //设置Label背景透明
    titleLabel.font = [UIFont boldSystemFontOfSize:20];  //设置文本字体与大小
    titleLabel.textColor = GetThemer().themeColor;  //设置文本颜色
    titleLabel.textAlignment = UITextAlignmentCenter;
    titleLabel.text = @"旅 游";  //设置标题
    self.navigationItem.titleView = titleLabel;
    
    
    UIImage* searchImage = [[FAKFontAwesome searchIconWithSize:22] imageWithSize:CGSizeMake(22, 22)];
    searchImage = [searchImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:searchImage
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(search)];
}
- (void)search
{
    OWTSearchViewCon* searchViewCon = [[OWTSearchViewCon alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:searchViewCon animated:YES];
}

-(void)setUpAllView
{
    _latestButton=[[QBFlatButton alloc]initWithFrame:CGRectMake(10, 5, SCREENWIT/2-20, 30)];
    _hottestButton=[[QBFlatButton alloc]initWithFrame:CGRectMake(SCREENWIT/2+10, 5, SCREENWIT/2-20, 30)];
    _latestButton.tag=301;
    _latestButton.tag=302;
    [_latestButton setTitle:@"国外" forState:UIControlStateNormal];
    _latestButton.selected=YES;
    [_hottestButton setTitle:@"国内" forState:UIControlStateNormal];
    [_latestButton addTarget:self action:@selector(lyClick1) forControlEvents:UIControlEventTouchUpInside];
    [_hottestButton addTarget:self action:@selector(lyClick2) forControlEvents:UIControlEventTouchUpInside];

//    _gnBtn=[LJUIController createButtonWithFrame:CGRectMake(0, 0, SCREENWIT/2, 50) imageName:nil title:@"国外" target:self action:@selector(lyClick:)];
//    _gwBtn=[LJUIController createButtonWithFrame:CGRectMake(SCREENWIT/2, 0, SCREENWIT/2, 50) imageName:nil title:@"国外" target:self action:@selector(lyClick:)];
    [self.view addSubview:_latestButton];
    [self.view addSubview:_hottestButton];
    _scrollView=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 40, SCREENWIT, SCREENHEI-64-40)];
    _scrollView.delegate=self;
    [self.view addSubview:_scrollView];

}
- (void)setupButtons
{
//    _buttonsView.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1.0];
//    _lineView.lineColor = [UIColor lightGrayColor];
//    _lineView.lineWidth = 0.5;
//    _lineView.lineShadowColor = nil;
    
    _pageButtons = @[ _latestButton, _hottestButton ];
    for (QBFlatButton* button in _pageButtons)
    {
        button.cornerRadius = 1;
        button.borderWidth = 0.5;
        button.height = 0;
        button.depth = 0;
        button.borderColor = [UIColor lightGrayColor];
        button.titleLabel.font = [UIFont boldSystemFontOfSize:15];
        
        [button setSurfaceColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        
        [button setSurfaceColor:[UIColor colorWithHexString:@"ff9800"] forState:UIControlStateSelected];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        
        [button setSurfaceColor:[UIColor colorWithHexString:@"ff9800"] forState:UIControlStateHighlighted];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    }
}

- (void)setupContentView
{
    //    OWTFeedManager* fm = GetFeedManager();
    
    OQJExploreViewConlvyouinternational* latestViewCon = [[OQJExploreViewConlvyouinternational alloc] init];
    
    OQJExploreViewConlvyou* hottestViewCon = [[OQJExploreViewConlvyou alloc] init];
    
    //    OWTFeedManager* fm = GetFeedManager();
    //
    //    OWTFeedViewCon* latestViewCon = [[OWTFeedViewCon alloc] initWithNibName:nil bundle:nil];
    //    [latestViewCon presentFeed:fm.latestUploadFeed animated:NO refresh:NO];
    //
    //    OWTFeedViewCon* hottestViewCon = [[OWTFeedViewCon alloc] initWithNibName:nil bundle:nil];
    //    [hottestViewCon presentFeed:[fm feedWithID:kWTFeedWallpaper] animated:NO refresh:NO];
    _pageViews = @[ latestViewCon.view, hottestViewCon.view ];
    _pageViewCons = @[ latestViewCon, hottestViewCon ];
    
    for (UIView* view in _pageViews)
    {
        [_scrollView addSubview:view];
    }
    
    for (UIViewController* viewCon in _pageViewCons)
    {
        [self addChildViewController:viewCon];
    }
    
    _scrollView.contentSize = CGSizeMake(_scrollView.bounds.size.width * _pageViews.count, _scrollView.bounds.size.height);
    [self layoutPageViews];
    
    [self presentPageAtIndex:0 animated:NO];
}
- (void)layoutPageViews
{
    float x = 0;
    float w = _scrollView.bounds.size.width;
    float h = _scrollView.bounds.size.height;
    for (UIView* view in _pageViews)
    {
        view.frame = CGRectMake(x, 0, w, h);
        x += w;
    }
}
- (void)presentPageAtIndex:(int)pageIndex animated:(BOOL)animated
{
    if (pageIndex == _currentPageIndex)
    {
        return;
    }
    
    if (_currentPageIndex >= 0 && _currentPageIndex < _pageButtons.count)
    {
        QBFlatButton* oldButton = _pageButtons[_currentPageIndex];
        oldButton.selected = NO;
        oldButton.borderWidth = 0.5;
    }
    
    _currentPageIndex = pageIndex;
    
    QBFlatButton* newButton = _pageButtons[_currentPageIndex];
    newButton.selected = YES;
    newButton.borderWidth = 0;
    
    float x = _scrollView.bounds.size.width * (CGFloat)pageIndex;
    [_scrollView setContentOffset:CGPointMake(x, 0) animated:animated];
    
    //    OWTFeedViewCon* feedViewCon = _pageViewCons[_currentPageIndex];
    //    [feedViewCon manualRefreshIfNeeded];
}

-(void)lyClick1
{
[self presentPageAtIndex:0 animated:YES];
}
-(void)lyClick2
{
[self presentPageAtIndex:1 animated:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
