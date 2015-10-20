//
//  OQJNavCon.m
//  Weitu
//
//  Created by Su on 8/26/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import "OQJNavCon.h"
#import "RRConst.h"
#import "UIColor+HexString.h"
@interface OQJNavCon ()

@end

@implementation OQJNavCon

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationBar.translucent = NO;
    self.navigationBar.tintAdjustmentMode = UIViewTintAdjustmentModeNormal;
    self.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIColor colorWithHexString:@"f6f6f6"] forKey:UITextAttributeTextColor];
    
    
}

-(void)viewWillAppear:(BOOL)animated
{
    if (GetThemer().ifCommentPop) {
        GetThemer().ifCommentPop = false;
        return;
    }
    
    if (_ifCustomColor) {

        self.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIColor colorWithHexString:@"f6f6f6"] forKey:UITextAttributeTextColor];
        self.navigationBar.barTintColor = [UIColor colorWithHexString:@"#2b2b2b"];
        UIApplication *application = [UIApplication sharedApplication];
        [application setStatusBarStyle:UIStatusBarStyleLightContent];
    }else{
        self.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIColor colorWithHexString:@"f6f6f6"] forKey:UITextAttributeTextColor];
        self.navigationBar.barTintColor =[UIColor blackColor];
        UIApplication *application = [UIApplication sharedApplication];
        [application setStatusBarStyle:UIStatusBarStyleLightContent];

    }
}
@end
