//
//  OQJSearchPageVC.m
//  Weitu
//
//  Created by denghs on 15/9/29.
//  Copyright (c) 2015年 SparkingSoft Co., Ltd. All rights reserved.
//

#import "OQJSearchPageVC.h"
#import "OWTSearchResultsViewCon.h"
#import "LJSearchViewController.h"
#import "OWTTabBarHider.h"

@interface OQJSearchPageVC ()
@property (nonatomic, strong)UISearchBar *searchBar;
@property (nonatomic, strong) OWTTabBarHider* tabBarHider;


@end

@implementation OQJSearchPageVC

- (id)initWithSeachContent:(NSString *)title
{
    self = [super init];
    if (self != nil)
    {
        _tile = title;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _tabBarHider = [[OWTTabBarHider alloc]init];
    [self setUpsearchView];
    OWTSearchResultsViewCon *search = [[OWTSearchResultsViewCon alloc]init];
    [search setKeyword:_tile];
    [self addChildViewController:search];
    [self.view addSubview:search.view];
}

-(void)setUpsearchView
{
    
    _searchBar=[[UISearchBar alloc]initWithFrame:CGRectMake(-20, 0, SCREENWIT-50, 40)];
    _searchBar.delegate=self;
    _searchBar.placeholder=@"搜索";
    [_searchBar setContentMode:UIViewContentModeLeft];
    _searchBar.userInteractionEnabled=YES;
    
    [_searchBar setSearchFieldBackgroundImage:[[UIImage imageNamed:@"_0004_圆角矩形-5"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)]
                                     forState:UIControlStateNormal];
    //_searchBar
    [_searchBar.layer setBorderColor:[UIColor redColor].CGColor];
    UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onSearchTap)];
    [_searchBar addGestureRecognizer:tap];
    
    self.navigationItem.titleView = _searchBar;
    
    [self changeSearchBarBackcolor:_searchBar];
    
    
}
-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    //    [searchBar endEditing:YES];
    LJSearchViewController *lvc=[[LJSearchViewController alloc]init];
    lvc.hidesBottomBarWhenPushed=YES;
    [_tabBarHider hideTabBar];
    [self.navigationController pushViewController:lvc animated:NO];
}

-(void)changeSearchBarBackcolor:(UISearchBar *)mySearchBar
{
    
    UITextField *txfSearchField = [mySearchBar valueForKey:@"_searchField"];
    txfSearchField.clearButtonMode = UITextFieldViewModeNever;
    mySearchBar.text = @"搜索";
    txfSearchField.textColor = [UIColor whiteColor];
    [txfSearchField setValue:[UIFont boldSystemFontOfSize:12] forKeyPath:@"_placeholderLabel.font"];
    
    mySearchBar.barTintColor = [UIColor whiteColor];
    txfSearchField = [[[mySearchBar.subviews firstObject] subviews] lastObject];
    
}

#pragma mark tapAndButton
-(void)onSearchTap
{
    LJSearchViewController *lvc=[[LJSearchViewController alloc]init];
    lvc.hidesBottomBarWhenPushed=YES;
    //[_tabBarHider hideTabBar];
    [self.navigationController pushViewController:lvc animated:NO];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
