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
@interface OWTSMSAuthCodeVerifyViewCon ()
{
   

    __weak IBOutlet UIView *backView;
    IBOutlet UITextField* _verificationCodeTextField;
    
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
    [self startResendTimer];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self stopResendTimer];
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

- (void)resendTimerCheck
{
    if (_resendTimeLeft > 0)
    {
        [_timeBtn setTitle:[NSString stringWithFormat:@"%d秒后重发", (int)_resendTimeLeft]
                       forState:UIControlStateNormal];
        [_timeBtn setTitle:[NSString stringWithFormat:@"%d秒后重发", (int)_resendTimeLeft]
                       forState:UIControlStateDisabled];
    }
    else
    {
        [_timeBtn setTitle:@"重发"
                       forState:UIControlStateNormal];
        [_timeBtn setTitle:@"重发"
                       forState:UIControlStateDisabled];
        [self stopResendTimer];
    }
}

- (void)startResendTimer
{
    [self stopResendTimer];
    
    _resendTimeLeft = 60;
    [self resendTimerCheck];
    
    _timeBtn.enabled = NO;
    
    _resendTimer = [NSTimer scheduledTimerWithTimeInterval:1
                                                     block:^{
                                                         _resendTimeLeft -= 1;
                                                         [self resendTimerCheck];
                                                     }
                                                   repeats:YES];
}

- (void)stopResendTimer
{
    if (_timeBtn != nil)
    {
        [_resendTimer invalidate];
        _resendTimer = nil;
    }
    _timeBtn.enabled = YES;
}

- (IBAction)reRequestAuthCode:(id)sender
{
    OWTAuthManager* am = GetAuthManager();
    [SVProgressHUD showWithStatus:NSLocalizedString(@"PLEASE_WAIT", @"Please wait.")
                         maskType:SVProgressHUDMaskTypeBlack];
    
    [am authWithSMSCellphone:_cellphone
                     success:^{
                         [SVProgressHUD dismiss];
                         [self startResendTimer];
                     }
                     failure:^(NSError* error) {
                         if (error == nil)
                         {
                             return;
                         }
                         
//                         [SVProgressHUD showError:error];
                     }];
}

#pragma mark - Code Verification Related

- (void)verifyCode
{
    [self verifyCode:nil];
}
- (IBAction)reSendClick:(id)sender {
    OWTAuthManager* am = GetAuthManager();
    [SVProgressHUD showWithStatus:NSLocalizedString(@"PLEASE_WAIT", @"Please wait.")
                         maskType:SVProgressHUDMaskTypeBlack];
    
    [am authWithSMSCellphone:_cellphone
                     success:^{
                         [SVProgressHUD dismiss];
                         [self startResendTimer];
                     }
                     failure:^(NSError* error) {
                         if (error == nil)
                         {
                             return;
                         }
                         
                         //                         [SVProgressHUD showError:error];
                     }];

}

- (IBAction)verifyCode:(id)sender
{
    if (![self hasValidVerificationCode])
    {
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"SMSAUTH_PLEASE_INPUT_VERIFICATION_CODE", @"Please input 6 digits verification code.")];
        [_verificationCodeTextField becomeFirstResponder];
        return;
    }
    
    NSString* verificationCode = _verificationCodeTextField.text;
    
    OWTAuthManager* am = GetAuthManager();
    [SVProgressHUD showWithStatus:NSLocalizedString(@"PLEASE_WAIT", @"Please wait.")
                         maskType:SVProgressHUDMaskTypeBlack];
    
    [am authWithSMSCellphone:_cellphone
            verificationCode:verificationCode
                     success:^{
                         [SVProgressHUD dismiss];

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
                                                   
//                                                   [SVProgressHUD showError:error];
                                               }];
                     }
                     failure:^(NSError* error) {
                         if (error == nil)
                         {
                             return;
                         }

//                         [SVProgressHUD showError:error];
                     }];
}
- (IBAction)back:(id)sender {
  //  OWTLoginRegisterSelectionViewCon *rsv = [[OWTLoginRegisterSelectionViewCon alloc]init];
  //  [self.navigationController popViewControllerAnimated:YES];
  ///  [self.navigationController popToViewController:rsv animated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
    _cancelBlock();
    NSLog(@"cancle clicked");
}

- (BOOL)hasValidVerificationCode
{
    NSString* verificationCode = _verificationCodeTextField.text;
    return [verificationCode isValidNumberOfDigitNum:6];
}
- (IBAction)loginClick:(id)sender {
    if (![self hasValidVerificationCode])
    {
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"SMSAUTH_PLEASE_INPUT_VERIFICATION_CODE", @"Please input 6 digits verification code.")];
        [_verificationCodeTextField becomeFirstResponder];
        return;
    }
    
    NSString* verificationCode = _verificationCodeTextField.text;
    
    OWTAuthManager* am = GetAuthManager();
    [SVProgressHUD showWithStatus:NSLocalizedString(@"PLEASE_WAIT", @"Please wait.")
                         maskType:SVProgressHUDMaskTypeBlack];
    
    [am authWithSMSCellphone:_cellphone1
            verificationCode:verificationCode
                     success:^{
                         [SVProgressHUD dismiss];
                         
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
                                                   
                                                   //                                                   [SVProgressHUD showError:error];
                                               }];
                     }
                     failure:^(NSError* error) {
                         if (error == nil)
                         {
                             return;
                         }
                         
                         //                         [SVProgressHUD showError:error];
                     }];

}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == _verificationCodeTextField)
    {
        [self verifyCode:self];
    }
    
    return YES;
}
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

@end
