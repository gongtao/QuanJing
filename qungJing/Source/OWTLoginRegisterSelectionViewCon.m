//
//  OWTLoginRegisterSelectionViewCon.m
//  Weitu
//
//  Created by Su on 5/21/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import "OWTLoginRegisterSelectionViewCon.h"
#import <QBFlatButton/QBFlatButton.h>

@interface OWTLoginRegisterSelectionViewCon ()
{
    IBOutlet QBFlatButton* _loginButton;
    IBOutlet QBFlatButton* _passwordLoginButton;
}

@end

@implementation OWTLoginRegisterSelectionViewCon

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
    self.navigationItem.title = @"身份验证";
    //给键盘注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(inputKeyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(inputKeyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    NSArray* buttons = @[ _loginButton, _passwordLoginButton];

    for (QBFlatButton* button in buttons)
    {
        button.cornerRadius = 5;
        button.height = 0;
        button.depth = 0;
        button.borderColor = [UIColor clearColor];
//        button.backgroundColor=[UIColor clearColor];
//        [button setSurfaceColor:[UIColor clearColor] forState:UIControlStateNormal];
//        [button setSurfaceColor:[UIColor clearColor] forState:UIControlStateHighlighted];
    }
}
-(void)inputKeyboardWillShow:(NSNotification*)sender
{
    NSLog(@"dd");
}
-(void)inputKeyboardWillHide:(NSNotification*)sender
{

}
- (IBAction)loginButtonPressed:(id)sender
{
    if (_doneWithLoginFunc != nil)
    {
        _doneWithLoginFunc();
    }
}


- (IBAction)passwordLoginButtonPressed:(id)sender
{
    if (_doneWithPasswordLoginFunc != nil)
    {
        _doneWithPasswordLoginFunc();
    }
}
- (IBAction)back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    if (_cancelFunc) {
        _cancelFunc();
    }
}
- (IBAction)forgetTheNumber:(id)sender {

}
- (IBAction)passworLoginButton:(id)sender {
    if (_doneWithRegisterFunc != nil)
    {
        _doneWithRegisterFunc();
    }

}

@end
