//
//  OWTEmailAuthViewCon.m
//  Weitu
//
//  Created by Su on 4/1/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import "OWTPasswordAuthViewCon.h"
#import "OWTAuthManager.h"
#import "NSString+ContentCheck.h"
#import "SVProgressHUD+WTError.h"
#import "OWTUserManager.h"
#import "OLineView.h"
#import <QBFlatButton/QBFlatButton.h>
#import <FontAwesomeKit/FAKFontAwesome.h>
#import "QuanJingSDK.h"
@interface OWTPasswordAuthViewCon ()
{
    
    __weak IBOutlet UIView *backView;
    __weak IBOutlet UITextField *_passwordTextField;

    __weak IBOutlet UITextField *usernameTextField;
    NSInteger hightRejust;
}

@end

@implementation OWTPasswordAuthViewCon

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
    self.navigationItem.title = @"用户名密码登录";
    UIBarButtonItem* doneItem = [[UIBarButtonItem alloc] initWithTitle:@"登录"
                                                                 style:UIBarButtonItemStyleDone
                                                                target:self
                                                                action:@selector(performAuth:)];
    self.navigationItem.rightBarButtonItem = doneItem;
    
    
   }

- (void)cancel
{
    if (_cancelFunc != nil)
    {
        _cancelFunc();
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(inputKeyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(inputKeyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    _passwordTextField.secureTextEntry = YES;

    
}
-(void)inputKeyboardWillShow:(NSNotification*)notification
{
    CGFloat animationTime = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    [UIView animateWithDuration:animationTime animations:^{
        CGRect keyBoardFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
        if (self.view) {
            NSLog(@"%f",self.view.center.y);
            hightRejust = SCREENHEI==480?25:0;

            backView.center=CGPointMake(backView.center.x, self.view.center.y-keyBoardFrame.size.height+150-hightRejust);
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
        backView.center=CGPointMake(backView.center.x, self.view.center.y+keyBoardFrame.size.height-150);
    }];

}
-(void)viewWillAppear:(BOOL)animated
{
    NSLog(@"dd");
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == usernameTextField)
    {
        [_passwordTextField becomeFirstResponder];
        [_passwordTextField selectAll:self];
    }
    else if (textField == _passwordTextField)
    {
        [self performAuth:self];
    }
    
    return YES;
}

- (IBAction)performAuth:(id)sender
{
//    if (![self hasValidUsernameInput])
//    {
//        [SVProgressHUD showErrorWithStatus:@"用户名或密码错误"];
//        [_usernameTextField becomeFirstResponder];
//        return;
//    }
////    if (self.checkbox.checked==NO )
////    {
////        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"没有同意全景服务条款", @"请输入正确的号码")];
////        [_usernameTextField becomeFirstResponder];
////        return;
////    }
//
//
//    if (![self hasValidPasswordInput])
//    {
//        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"AUTH_PLEASE_INPUT_PASSWORD", @"Please input password.")];
//        [_passwordTextField becomeFirstResponder];
//        return;
//    }

    OWTAuthManager* am = GetAuthManager();

    NSString* username = usernameTextField.text;
    NSString* password = _passwordTextField.text;

    [SVProgressHUD showWithStatus:NSLocalizedString(@"PLEASE_WAIT", @"Please wait.")
                         maskType:SVProgressHUDMaskTypeBlack];
    QJPassport *pt=[QJPassport sharedPassport];
    
    [am authWithUsername:username
             password:password
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
                                            
//                                            [SVProgressHUD showError:error];
                                            
//                                            [SVProgressHUD showErrorWithStatus:@"请输入相册名称"];
                                            
                                            
                                        }];
              }
              failure:^(NSError* error) {
                  [SVProgressHUD dismiss];
                  if (error == nil)
                  {
                      return;
                  }
                
                  //                  [SVProgressHUD showError:error];
//                  [SVProgressHUD showErrorWithStatus:@"请输入相册名称"];
              }];
}
- (IBAction)loginClick:(id)sender {
    OWTAuthManager* am = GetAuthManager();
    
    NSString* username = usernameTextField.text;
    NSString* password = _passwordTextField.text;
    
    [SVProgressHUD showWithStatus:NSLocalizedString(@"PLEASE_WAIT", @"Please wait.")
                         maskType:SVProgressHUDMaskTypeBlack];
//    QJPassport *pt=[QJPassport sharedPassport];
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        
//    });
//    [pt loginUser:username password:password finished:^(NSInteger userId, NSString * _Nonnull ticket, NSError * _Nonnull error) {
//        [SVProgressHUD dismiss];
//        if (error==nil) {
//            OWTUserManager* um = GetUserManager();
//            [um refreshCurrentUserSuccess:^{
//                if (_successFunc != nil)
//                {
//                    _successFunc();
//                }
//            }
//                                  failure:^(NSError* error){
//                                      if (error == nil)
//                                      {
//                                          return;
//                                      }
//                                      
//                                  }];
//
//        }
//        
//    }];
    [am authWithUsername:username
                password:password
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
                                               
                                                                                          }];
                 }
                 failure:^(NSError* error) {
                     [SVProgressHUD dismiss];
                     if (error == nil)
                     {
                         return;
                     }
                     
                     //                  [SVProgressHUD showError:error];
                     //                  [SVProgressHUD showErrorWithStatus:@"请输入相册名称"];
                 }];

}

//- (BOOL)hasValidUsernameInput
//{
//    NSString* username = _usernameTextField.text;
//    return username != nil && username.length > 3;
//}

//- (BOOL)hasValidPasswordInput
//{
//    NSString* password = _passwordTextField.text;
//    return (password != nil && password.length > 0);
//}
- (IBAction)back1:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    _cancelFunc();

}

- (IBAction)shownDetail:(id)sender {UIAlertView *view = [[UIAlertView alloc]init];
    [view initWithTitle:@"全景服务条款" message:@"全景图片网服务条款的确认和接纳        全景图片网的各项电子服务的所有权和运作权归北京全景视觉网络科技有限公司(Panorama Media Limited)。全景图片网提供的服务将完全按照其发布的章程、服务条款和操作规则严格执行。用户必须完全同意所有服务条款并完成注册程序，才能成为全景图片网的正式用户。     服务简介     北京全景视觉网络科技有限公司完全尊重客户的权利，并根据以下规定使用所取得的客户基本资料。 为了完成特许权的交易，并向北京全景视觉网络科技有限公司客户提供服务，我们需要一些基本资料。通常包括（但不仅限于此）：   (1)提供详尽、准确的个人资料。  (2)不断更新注册资料，符合及时、详尽、准确的要求。  我们使用客户的信息完成合作并向世界各地北京全景视觉网络科技有限公司的分公司及合作者透露这些信息与合作细节。互联网的性质也决定了所有数据可在世界各地传递。   另外，我们根据注册单上的电子邮件或通讯地址，向客户提供各种促销资料。客户也可以受到关于特殊促销活动、新产品、服务等一系列信息。当收到不再需要这些资料的通知时，我们就不再寄给客户任何资料。我们不共享客户提供的北京全景视觉网络科技有限公司网站之外的任何信息。如果您认为北京全景视觉网络科技有限公司没有认真完全执行以上规定，或者想从北京全景视觉网络科技有限公司系统中取消注册，请随时与我们联系，我们会做出合理的答复或修改全景图片网不公开用户的姓名、地址、电子邮箱和笔名，除以下情况外：   (1)用户授权全景图片网透露这些信息。   (2)相应的法律及程序要求全景图片网提供用户的个人资料。  如果用户提供的资料包含有不正确的信息，全景图片网保留结束用户使用网络服务资格的权利。    服务条款的修改和服务修订   全景图片网有权在必要时修改服务条款，全景图片网服务条款一旦发生变动，将会在重要页面上提示修改内容。如果不同意所改动的内容，用户可以主动取消获得的网络服务。如果用户继续享用网络服务，则视为接受服务条款的变动。全景图片网保留随时修改或中断服务而不需知照用户的权利。全景图片网行使修改或中断服务的权利，不需对用户或第三方负责。  用户的帐号，密码和安全性   用户一旦注册成功，成为全景图片网的合法用户，将得到一个密码和用户名。   用户将对用户名和密码安全负全部责任。另外，每个用户都要对以其用户名进行的所有活动和事件负全责。您可随时根据指示改变您的密码。   用户若发现任何非法使用用户帐号或存在安全漏洞的情况，请立即通告全景图片网。   有限责任   全景图片网对任何直接、间接、偶然、特殊及继起的损害不负责任，这些损害可能来自：不正当使用网络服务，在网上购买商品或进行同类型服务，在网上进行交易，非法使用网络服务或用户传送的信息有所变动。这些行为都有可能会导致全景图片网的形象受损，所以全景图片网事先提出这种损害的可能性。   对用户信息的存储和限制    全景图片网不对用户所发布信息的删除或储存失败负责。全景图片网有判定用户的行为是否符合全景图片网服务条款的要求和精神的保留权利，如果用户违背了服务条款的规定，全景图片网有中断对其提供网络服务的权利。   保障     用户同意保障和维护全景图片网全体成员的利益，负责支付由用户使用超出服务范围引起的律师费用，违反服务条款的损害补偿费用等。   结束服务    用户或全景图片网可随时根据实际情况中断一项或多项网络服务。全景图片网不需对任何个人或第三方负责而随时中断服务。用户对后来的条款修改有异议，或对全景图片网的服务不满，可以行使如下权利：   (1)停止使用全景图片网的网络服务。   (2)通告全景图片网停止对该用户的服务。   结束用户服务后，用户使用网络服务的权利马上中止。从那时起，用户没有权利，全景图片网也没有义务传送任何未处理的信息或未完成的服务给用户或第三方。    通告     所有发给用户的通告都可通过重要页面的公告或电子邮件或常规的信件传送。服务条款的修改、服务变更、或其它重要事件的通告都会以此形式进行。    网络服务内容的所有权    网站的所有权属于北京全景视觉网络科技有限公司。本网站中的文字说明、设计图案、摄影作品、正片、音乐、插图、各种软件（不仅限于此）都为北京全景视觉网络科技有限公司和其内容提供商所有。   北京全景视觉网络科技有限公司网站中的各个组成部分，包括全部设计、内容（不仅限于此）受版权、道义权、商标权等一系列相关的知识产权法保护。任何人都不可以擅自以任何方式从网站中拷贝或传送图片、文字等所有内容。其使用权只归北京全景视觉网络科技有限公司独家所有。     对于违反合作规定，或非法使用网站内容的行为，北京全景视觉网络科技有限公司要求行为人对所有权的丢失、使用及损坏做出赔偿。"
               delegate:self cancelButtonTitle:@"同意" otherButtonTitles: nil];
    [view show];
}
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}
@end
