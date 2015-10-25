//
//  OWTAuthViewCon.m
//  Weitu
//
//  Created by Su on 4/1/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import "OWTAuthViewCon.h"
#import "OKenBurnsNavCon.h"
#import "OWTLoginRegisterSelectionViewCon.h"
#import "OWTSMSAuthCodeRequestViewCon.h"
#import "OWTSMSAuthCodeVerifyViewCon.h"
#import "OWTPasswordAuthViewCon.h"
#import "UIViewController+WTExt.h"
#import "OWTAuthManager.h"
#import "OWTAccessToken.h"
#import <SIAlertView/SIAlertView.h>
#import "UIColor+HexString.h"
@interface OWTAuthViewCon ()
{
}

@property (nonatomic, assign) BOOL isRegistering;
@property (nonatomic, strong) OWTLoginRegisterSelectionViewCon* loginRegisterSelectionViewCon;
@property (nonatomic, strong) OWTSMSAuthCodeRequestViewCon* smsAuthCodeRequestViewCon;
@property (nonatomic, strong) OWTSMSAuthCodeVerifyViewCon* smsAuthCodeVerifyViewCon;
@property (nonatomic, strong) OWTPasswordAuthViewCon* passwordAuthViewCon;

@end

@implementation OWTAuthViewCon

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self setupLoginRegisterSelectionViewCon];
    [self setupSMSAuthRequestViewCon];
    [self setupSMSAuthCodeVerifyViewCon];
    [self setupPasswordAuthViewCon];
    [self setupBackgroundView];

    [self pushViewCon:_loginRegisterSelectionViewCon animated:NO];
    [self showLoginRegisterViewConAnimated:NO];
}

- (void)setupBackgroundView
{
    self.navigationController.navigationBar.titleTextAttributes=[NSDictionary dictionaryWithObject:[UIColor colorWithHexString:@"f6f6f6"] forKey:UITextAttributeTextColor];
    OKenBurnsNavCon* burnsViewCon = [[OKenBurnsNavCon alloc] initWithNibName:nil bundle:nil];

    NSArray* images = @[
                         [UIImage imageNamed:@"photo_bg_4"],
                         [UIImage imageNamed:@"photo_bg_5"],
                         [UIImage imageNamed:@"photo_bg_3"],
                         [UIImage imageNamed:@"photo_bg_1"] ];

    burnsViewCon.backgroundImages = images;
    [self addChildViewController:burnsViewCon];
    [self.view insertSubview:burnsViewCon.view atIndex:0];
    burnsViewCon.view.frame = self.view.bounds;
}

- (void)setupLoginRegisterSelectionViewCon
{
    __weak OWTAuthViewCon* wself = self;

    _loginRegisterSelectionViewCon = [[OWTLoginRegisterSelectionViewCon alloc] initWithNibName:nil bundle:nil];
 
    _loginRegisterSelectionViewCon.doneWithLoginFunc = ^{
        wself.isRegistering = NO;

        [wself pushViewCon:wself.smsAuthCodeRequestViewCon animated:YES];
        [wself.smsAuthCodeRequestViewCon isLogin:YES];
        [wself showRequestViewConAnimated:YES];
    };
    _loginRegisterSelectionViewCon.doneWithRegisterFunc = ^{
        wself.isRegistering = YES;
        [wself pushViewCon:wself.smsAuthCodeRequestViewCon animated:YES];
        [wself.smsAuthCodeRequestViewCon isLogin:NO];
        [wself showRequestViewConAnimated:YES];
    };
    
    _loginRegisterSelectionViewCon.doneWithPasswordLoginFunc = ^{
        wself.isRegistering = NO;
        [wself pushViewCon:wself.passwordAuthViewCon animated:YES];
        [wself showRequestViewConAnimated:YES];
    };
    _loginRegisterSelectionViewCon.cancelFunc=^{
        if (_cancelFunc) {
            _cancelFunc();
        }
    };
    
}

- (void)setupSMSAuthRequestViewCon
{
    __weak OWTAuthViewCon* wself = self;
    
    _smsAuthCodeRequestViewCon = [[OWTSMSAuthCodeRequestViewCon alloc] initWithNibName:nil bundle:nil];
    _smsAuthCodeRequestViewCon.cancelBlock = ^{
        wself.cancelBlock();
    };
    _smsAuthCodeRequestViewCon.doneFunc = ^(NSString* cellphone,NSString *code) {
        wself.smsAuthCodeVerifyViewCon.cellphone1 = cellphone;
        wself.smsAuthCodeVerifyViewCon.code=code;
        wself.smsAuthCodeVerifyViewCon.cancelBlock = ^{
            wself.cancelBlock();
        };
        [wself pushViewCon:wself.smsAuthCodeVerifyViewCon animated:YES];
        [wself showVerifyViewConAnimated:YES];
    };
}

- (void)setupSMSAuthCodeVerifyViewCon
{
    __weak OWTAuthViewCon* wself = self;

    _smsAuthCodeVerifyViewCon = [[OWTSMSAuthCodeVerifyViewCon alloc] initWithNibName:nil bundle:nil];
    _smsAuthCodeVerifyViewCon.successFunc = ^{
        OWTAccessToken* accessToken = GetAuthManager().accessToken;

        if (wself.successFunc != nil)
        {
            if (wself.isRegistering && !accessToken.isNewUser)
            {
                SIAlertView* alertView = [[SIAlertView alloc] initWithTitle:@"用户已存在" andMessage:@"您的手机号已经注册过，将直接登录。"];
                [alertView addButtonWithTitle:@"确定"
                                         type:SIAlertViewButtonTypeDefault
                                      handler:^(SIAlertView* alertView) {
                                          [alertView dismissAnimated:YES];
                                          wself.successFunc(false);
                                      }];

                alertView.transitionStyle = SIAlertViewTransitionStyleFade;
                [alertView show];
            }
            else
            {
                wself.successFunc(accessToken.isNewUser);
            }
        }
    };
}

- (void)setupPasswordAuthViewCon
{
    __weak OWTAuthViewCon* wself = self;

    _passwordAuthViewCon = [[OWTPasswordAuthViewCon alloc] initWithNibName:nil bundle:nil];
    _passwordAuthViewCon.cancelFunc = ^{
        wself.cancelBlock();
    };
    _passwordAuthViewCon.successFunc = ^{
        if (wself.successFunc != nil)
        {
            wself.successFunc(NO);
        }
    };
}

- (void)showLoginRegisterViewConAnimated:(BOOL)animated
{
    
    UIButton *left=[LJUIController createButtonWithFrame:CGRectMake(0, 0, 10, 17) imageName:@"返回.png" title:nil target:self action:@selector(cancel)];
    UIBarButtonItem *btn1=[[UIBarButtonItem alloc]initWithCustomView:left];
    self.navigationItem.leftBarButtonItem=btn1;
}

- (void)showRequestViewConAnimated:(BOOL)animated
{
    UIButton *left=[LJUIController createButtonWithFrame:CGRectMake(0, 0, 10, 17) imageName:@"返回.png" title:nil target:self action:@selector(popRequestViewCon)];
    UIBarButtonItem *btn1=[[UIBarButtonItem alloc]initWithCustomView:left];
    self.navigationItem.leftBarButtonItem=btn1;
}

- (void)showVerifyViewConAnimated:(BOOL)animated
{
        UIButton *left=[LJUIController createButtonWithFrame:CGRectMake(0, 0, 10, 17) imageName:@"返回.png" title:nil target:self action:@selector(popVerifyViewCon)];
    UIBarButtonItem *btn1=[[UIBarButtonItem alloc]initWithCustomView:left];
    self.navigationItem.leftBarButtonItem=btn1;
}

- (void)popRequestViewCon
{
    [self popViewConAnimated:YES];
    [self showLoginRegisterViewConAnimated:YES];
}

- (void)popVerifyViewCon
{
    [self popVerifyViewConAnimate:YES];
}

- (void)popVerifyViewConAnimate:(BOOL)animated
{
    [self popViewConAnimated:animated];
    [self showRequestViewConAnimated:animated];
}

- (void)cancel
{
    if (_cancelFunc != nil)
    {
        _cancelFunc();
    }
}

@end
