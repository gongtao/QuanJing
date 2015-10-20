//
//  OQJSelectedViewCon.m
//  Weitu
//
//  Created by Su on 8/23/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import "OQJSelectedViewCon1.h"
#import "OWTFeedViewCon.h"
#import "OWTFeedManager.h"
#import "OWTSearchViewCon.h"
#import <UIColor-HexString/UIColor+HexString.h>
#import <QBFlatButton/QBFlatButton.h>
#import <FontAwesomeKit/FontAwesomeKit.h>
#import <AppleGrocery/UIKitExt/OLineView.h>

typedef enum
{
    kQJSelectedWorkingModeLatest,
    kQJSelectedWorkingModeHottest,
} EQJSelectedImageWorkingMode;

@interface OQJSelectedViewCon1 ()
{
    IBOutlet UIView* _buttonsView;
    IBOutlet QBFlatButton* _latestButton;
    IBOutlet QBFlatButton* _hottestButton;
    IBOutlet OLineView* _lineView;

    IBOutlet UIScrollView* _scrollView;

    int _currentPageIndex;
    NSArray* _pageButtons;
    NSArray* _pageViews;
    NSArray* _pageViewCons;
}

@end

@implementation OQJSelectedViewCon1

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
    }
    return self;
}
-(void)viewWillAppear:(BOOL)animated
{

    NSLog(@"");
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _currentPageIndex = -1;
    [self setupNavBar];
//    [self setupButtons];
    [self setupContentView];
}

- (void)setupNavBar
{
    if (_isFashion==YES) {
        self.title=@"时尚";
    }else {
    self.title = @"壁纸";
    }
    UIImage* searchImage = [[FAKFontAwesome searchIconWithSize:22] imageWithSize:CGSizeMake(22, 22)];
    searchImage = [searchImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:searchImage
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(search)];
}

- (void)setupButtons
{
    _buttonsView.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1.0];
    _lineView.lineColor = [UIColor lightGrayColor];
    _lineView.lineWidth = 0.5;
    _lineView.lineShadowColor = nil;
    
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
    OWTFeedManager* fm = GetFeedManager();
    
//    OWTFeedViewCon* latestViewCon = [[OWTFeedViewCon alloc] initWithNibName:nil bundle:nil];
//    [latestViewCon presentFeed:fm.latestUploadFeed animated:NO refresh:NO];

    OWTFeedViewCon* hottestViewCon = [[OWTFeedViewCon alloc] initWithNibName:nil bundle:nil];
    if (_isFashion==YES) {
       [hottestViewCon presentFeed:[fm feedWithID:KWTFeedFashion] animated:NO refresh:NO];
    }else{
        [hottestViewCon presentFeed:[fm feedWithID:kWTFeedWallpaper] animated:NO refresh:NO];}

    _pageViews = @[  hottestViewCon.view ];
    _pageViewCons = @[  hottestViewCon ];
    
    for (UIView* view in _pageViews)
    {
        [_scrollView addSubview:view];
    }
    
    for (UIViewController* viewCon in _pageViewCons)
    {
        [self addChildViewController:viewCon];
    }

    NSLog(@"_pageViews.count %i",_pageViews.count);
    //_scrollView.contentSize = CGSizeMake(_scrollView.bounds.size.width * _pageViews.count, _scrollView.bounds.size.height);
   // [self layoutPageViews];

    [self presentPageAtIndex:0 animated:NO];
}

- (void)viewDidLayoutSubviews
{
    [self layoutPageViews];
}

- (void)search
{
    OWTSearchViewCon* searchViewCon = [[OWTSearchViewCon alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:searchViewCon animated:YES];
}

- (void)layoutPageViews
{
    float x = 0;
    float w = _scrollView.bounds.size.width;
    float h = _scrollView.bounds.size.height;
    if ( [[UIDevice currentDevice].model rangeOfString:@"iPhone"].location !=NSNotFound) {
        for (UIView* view in _pageViews)
        {
            view.frame = CGRectMake(x, 0, w, h);
            x += w;
        }
    }else{
        for (UIView* view in _pageViews)
        {
            view.frame = CGRectMake(x, 64, w, h-64);
            x += w;
        }
    }
    
    
//     if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
//    for (UIView* view in _pageViews)
//    {
//        view.frame = CGRectMake(x, 0, w, h);
//        x += w;
//    }
//     }
//     else{
//         for (UIView* view in _pageViews)
//         {
//             view.frame = CGRectMake(x, 64, w, h-64);
//             x += w;
//         }
//     }
}

- (IBAction)onLatestButtonPressed:(id)sender
{
    [self presentPageAtIndex:0 animated:YES];
}

- (IBAction)onHottestButtonPressed:(id)sender
{
    [self presentPageAtIndex:1 animated:YES];
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
    
    OWTFeedViewCon* feedViewCon = _pageViewCons[_currentPageIndex];
    [feedViewCon manualRefreshIfNeeded];
}

@end
