//
//  OWTSMSAuthCodeVerifyViewCon.h
//  Weitu
//
//  Created by Su on 5/20/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TTTAttributedLabel/TTTAttributedLabel.h>

@interface OWTSMSAuthCodeVerifyViewCon : UIViewController<TTTAttributedLabelDelegate, UITextFieldDelegate>
@property(nonatomic,copy)NSString *cellphone1;
@property (nonatomic, copy) NSString* cellphone;
@property (nonatomic, strong) void (^successFunc)();
@property (nonatomic, strong) void (^cancelBlock) ();
- (void)verifyCode;

@end
