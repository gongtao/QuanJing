//
//  StartViewController.m
//  Weitu
//
//  Created by qj-app on 15/7/23.
//  Copyright (c) 2015年 SparkingSoft Co., Ltd. All rights reserved.
//

#import "StartViewController.h"
#import "OWTMainViewCon.h"
#import "WTCommon.h"
#import "OWTAppDelegate.h"
@interface StartViewController ()<UIScrollViewDelegate>

@end

@implementation StartViewController
{
    UIScrollView *_scroll;
    UIPageControl *_pageControl;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    _scroll=[[UIScrollView alloc]initWithFrame:self.view.bounds];
    _scroll.delegate=self;
    [self.view addSubview:_scroll];
    NSArray* images = @[ @"启动2-1.png",
                         @"启动2-2.png",
                         @"启动2-3.png",
                         @"启动2-4.png"];
    for (NSInteger i=0; i<4; i++) {
        UIImageView *imageView=[LJUIController createImageViewWithFrame:CGRectMake(SCREENWIT*i, 0, SCREENWIT, SCREENHEI) imageName:images[i]];
        if (i==3) {
            UIButton *btn=[LJUIController createButtonWithFrame:CGRectMake(SCREENWIT/2-31, SCREENHEI-120+30+7, 72, 21) imageName:@"_0000_立即体验" title:@"" target:self action:@selector(onBtnClick)];
            btn.titleLabel.font=[UIFont systemFontOfSize:20];
            [btn.layer setCornerRadius:5];
            [imageView addSubview:btn];
        }
        [_scroll addSubview:imageView];
    }
    _scroll.pagingEnabled=YES;
    _scroll.contentSize=CGSizeMake(SCREENWIT*4, SCREENHEI);
    _pageControl=[[UIPageControl alloc]initWithFrame:CGRectMake(SCREENWIT/2-50, SCREENHEI-30-20, 100, 20)];
    _pageControl.numberOfPages=4;
    [self.view addSubview:_pageControl];
}
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    _pageControl.currentPage=scrollView.contentOffset.x/SCREENWIT;

}
-(void)onBtnClick
{
    OWTMainViewCon *mainView=[[OWTMainViewCon alloc]initWithNibName:nil bundle:nil];
    mainView.tabBar.hidden=YES;
    GetAppDelegate().window.rootViewController=mainView;
    [self presentViewController:mainView animated:NO completion:nil];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
