//
//  OWTLicenseViewCon.m
//  Weitu
//
//  Created by Su on 4/10/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import "OWTLicenseViewCon.h"
#import "UIViewController+WTExt.h"

@interface OWTLicenseViewCon ()
{
    IBOutlet UIWebView* _webView;
}

@end

@implementation OWTLicenseViewCon

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        [self setup];
    }
    return self;
}

- (void)setup
{
    self.navigationItem.title = @"全景服务条款";
//    UILabel * label = [[UILabel alloc]initWithFrame:CGRectMake(0, 20, 100, 44)];
//    label.text = @"全景服务条款";
//    
//    
//    label.font = [UIFont fontWithName:@"Arial-BoldItalicMT" size:24];
//    
//    [label setTextAlignment:NSTextAlignmentCenter];
//    label.textColor = GetThemer().themeTintColor;
//    self.navigationItem.titleView =label;
    [self substituteNavigationBarBackItem];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    NSString* htmlFile = [[NSBundle mainBundle] pathForResource:@"license" ofType:@"html"];
    NSString* htmlString = [NSString stringWithContentsOfFile:htmlFile encoding:NSUTF8StringEncoding error:nil];
    [_webView loadHTMLString:htmlString baseURL:nil];
}

@end
