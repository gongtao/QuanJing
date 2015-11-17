//
//  loginBackView.m
//  Weitu
//
//  Created by qj-app on 15/11/17.
//  Copyright © 2015年 SparkingSoft Co., Ltd. All rights reserved.
//

#import "loginBackView.h"

@interface loginBackView ()

@end

@implementation loginBackView

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIImageView *imageView=[LJUIController createImageViewWithFrame:CGRectMake(0, 64, SCREENWIT, SCREENHEI-64) imageName:@"loginBackImage"];
    [self.view addSubview:imageView];
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
