//
//  OQJSearchView.m
//  Weitu
//
//  Created by QJ on 14-9-1.
//  Copyright (c) 2014年 SparkingSoft Co., Ltd. All rights reserved.
//

#import "OQJSearchView.h"

@interface OQJSearchView ()
@property (nonatomic, strong) UISearchBar* searchBar;
@end

@implementation OQJSearchView

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 260, 44)];
    _searchBar.searchBarStyle = UISearchBarStyleMinimal;
    [_searchBar setPlaceholder:@"搜索"];
    _searchBar.delegate = self;
    _searchBar.translucent = NO;
    [_searchBar setSearchFieldBackgroundImage:[[UIImage imageNamed:@"SearchBarBG"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)]
                                     forState:UIControlStateNormal];
    _searchBar.searchTextPositionAdjustment = UIOffsetMake(4, 1);
    _searchBar.searchFieldBackgroundPositionAdjustment = UIOffsetMake(0, 0);
    [_searchBar setPositionAdjustment:UIOffsetMake(0, 1) forSearchBarIcon:UISearchBarIconSearch];
    
    //[self setupSearchBarActions];
    
    self.navigationItem.titleView = _searchBar;

  //  self.searchBar.cancelButtonHidden = NO;
       [self.searchBar becomeFirstResponder];
    
   
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
