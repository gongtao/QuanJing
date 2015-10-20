//
//  DealErrorPageViewController.m
//  Weitu
//
//  Created by denghs on 15/8/3.
//  Copyright (c) 2015年 SparkingSoft Co., Ltd. All rights reserved.
//

#import "DealErrorPageViewController.h"

@interface DealErrorPageViewController ()
@property (strong, nonatomic) IBOutlet UIButton *pressAction;

@end

@implementation DealErrorPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)pressButton:(id)sender {
    
    if (_getRefreshAction) {
        _getRefreshAction();

    }
    NSLog(@"尼玛， 按钮开始了");
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
