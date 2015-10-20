//
//  OWTSMSAuthCodeRequestViewCon.h
//  Weitu
//
//  Created by Su on 5/20/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CTCheckbox.h"
@interface OWTSMSAuthCodeRequestViewCon : UIViewController<UITextFieldDelegate>

@property (nonatomic, readonly) NSString* cellphone;
@property (nonatomic, strong) void (^doneFunc)(NSString* cellphone);
@property (nonatomic, strong)void (^cancelBlock)();

@property (weak, nonatomic) IBOutlet CTCheckbox *checkbox;

@end
