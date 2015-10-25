//
//  OWTSMSAuthCodeVerifyViewCon.m
//  Weitu
//
//  Created by Su on 5/20/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import "OWTSMSAuthCodeVerifyViewCon.h"
#import "OWTLicenseViewCon.h"
#import "OWTAuthManager.h"
#import "OWTUserManager.h"
#import "SVProgressHUD+WTError.h"
#import "NSString+ContentCheck.h"
#import <QBFlatButton/QBFlatButton.h>
#import <NSTimer-Blocks/NSTimer+Blocks.h>
#import "OWTLoginRegisterSelectionViewCon.h"
#import "UIColor+HexString.h"
#import "NSTimer+Blocks.h"
#import "QuanJingSDK.h"
@interface OWTSMSAuthCodeVerifyViewCon ()
{
   

    __weak IBOutlet UIView *backView;
    IBOutlet UITextField* _verificationCodeTextField;
    
    __weak IBOutlet UITextField *passwordTextField;
    __weak IBOutlet UIButton *_timeBtn;
    NSTimer* _resendTimer;
    NSTimeInterval _resendTimeLeft;
}

@end

@implementation OWTSMSAuthCodeVerifyViewCon

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
    self.navigationItem.title = NSLocalizedString(@"SMSAUTH_VERIFY_VIEWCON_TITLE", @"SMS Auth");
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(inputKeyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(inputKeyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [_timeBtn setBackgroundColor:[UIColor colorWithHexString:@"#ff2a00"]];

}
-(void)inputKeyboardWillShow:(NSNotification*)notification
{
    CGFloat animationTime = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    [UIView animateWithDuration:animationTime animations:^{
        CGRect keyBoardFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
        if (self.view) {
            NSLog(@"%f",self.view.center.y);
            NSInteger highInjust = SCREENHEI==480?60:0;
            backView.center=CGPointMake(backView.center.x, self.view.center.y-keyBoardFrame.size.height+125-highInjust);
            NSLog(@"%f",self.view.center.y);
        }
    }];
    
}
-(void)inputKeyboardWillHide:(NSNotification*)notification
{
    CGFloat animationTime = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    CGRect frame=[UIScreen mainScreen].bounds;
    [UIView animateWithDuration:animationTime animations:^{
        CGRect keyBoardFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
        backView.center=CGPointMake(backView.center.x, self.view.center.y+keyBoardFrame.size.height-125);
    }];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)setCellphone:(NSString *)cellphone
{
}

- (void)attributedLabel:(TTTAttributedLabel *)label
   didSelectLinkWithURL:(NSURL *)url
{
    OWTLicenseViewCon* licenseViewCon = [[OWTLicenseViewCon alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:licenseViewCon animated:YES];
}



#pragma mark - Code Verification Related

- (IBAction)loginClick:(id)sender {

    if (_verificationCodeTextField.text==nil||passwordTextField.text==nil||![_verificationCodeTextField.text isEqualToString:passwordTextField.text]) {
        [SVProgressHUD showErrorWithStatus:@"密码填写有误"];
        [passwordTextField resignFirstResponder];
        return;
    }
    [SVProgressHUD show];
    QJPassport *pt=[QJPassport sharedPassport];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [pt registerUser:_cellphone1 password:passwordTextField.text code:_code finished:^(NSNumber * _Nonnull userId, NSString * _Nonnull ticket, NSError * _Nonnull error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD dismiss];
                if (error) {
                    [SVProgressHUD showError:error];
                }else {
                    [SVProgressHUD showSuccessWithStatus:@"注册成功"];
                    OWTUserManager* um = GetUserManager();
                    [um refreshCurrentUserSuccess:^{
                        if (_successFunc != nil)
                        {
                            _successFunc();
                        }
                    }
                                          failure:^(NSError* error){
                                              if (error == nil)
                                              {
                                                  return;
                                              }
                                          }];
                    
                }
  
            });
        }];
            });
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

@end
