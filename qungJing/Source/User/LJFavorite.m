//
//  LJFavorite.m
//  Weitu
//
//  Created by qj-app on 15/6/4.
//  Copyright (c) 2015年 SparkingSoft Co., Ltd. All rights reserved.
//

#import "LJFavorite.h"
#import "LJUIController.h"
#import "UIColor+HexString.h"
@interface LJFavorite ()

@end

@implementation LJFavorite
- (instancetype)init
{
    self = [super init];
    if (self) {
        _hobbies=[[NSMutableArray alloc]init];
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor whiteColor];
    self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIColor colorWithHexString:@"f6f6f6"] forKey:UITextAttributeTextColor];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithHexString:@"#2b2b2b"];
//    UIApplication *application = [UIApplication sharedApplication];
//    [application setStatusBarStyle:UIStatusBarStyleLightContent];

    }
-(void)cancelClick
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)certainClick
{
    _doneFunc();
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)viewWillAppear:(BOOL)animated
{
    [self customUI];
}
-(void)customUI
{
    
    CGFloat wit=SCREENWIT/2;
    CGFloat hei=(SCREENHEI-64)/10;
    for (NSInteger i=0; i<_DataArr.count; i++) {
        int y=i/2;
        int x=i%2;
        UILabel *label=[LJUIController createLabelWithFrame:CGRectMake(30+x*wit, 64+y*hei, 70, hei)Font:17 Text:_DataArr[i]];
        [self.view addSubview:label];
        UIButton *btn=[LJUIController createButtonWithFrame:CGRectMake(110+x*wit, 74+y*hei, 30, 30) imageName:@"4_03-02.png" title:nil target:self action:@selector(btnClick:)];
        [btn setBackgroundImage:[UIImage imageNamed:@"4_03.png"] forState:UIControlStateSelected];
        btn.tag=40+i;
        [self.view addSubview:btn];
        for (NSString *str in _hobbies) {
            if ([str isEqualToString:_DataArr[i]]) {
                btn.selected=YES;
            }
        }
}
    UIImageView *imageView=[LJUIController createImageViewWithFrame:CGRectMake(0, 20, SCREENWIT, 50) imageName:nil];
    imageView.backgroundColor=GetThemer().themeColorBackground;
    UIButton *cancel=[LJUIController createButtonWithFrame:CGRectMake(10, 10, 50, 30) imageName:nil title:@"取消" target:self action:@selector(cancelClick)];
    UIButton *certain=[LJUIController createButtonWithFrame:CGRectMake(SCREENWIT-60, 10, 50, 30) imageName:nil title:@"确定" target:self action:@selector(certainClick)];
    [cancel setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [certain setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];    [imageView addSubview:cancel];
    [imageView addSubview:certain];
    [self.view addSubview:imageView];

}
-(void)viewWillDisappear:(BOOL)animated
{
    for (UIView *view in self.view.subviews) {
        [view removeFromSuperview];
    }

}
-(void)btnClick:(UIButton *)sender
{
    if (sender.selected==NO) {
        sender.selected=YES;
        [_hobbies addObject:_DataArr[sender.tag-40]];
    }else
    {
        sender.selected=NO;
        [_hobbies removeObject:_DataArr[sender.tag-40]];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
