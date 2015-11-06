//
//  OWTEmailAuthViewCon.h
//  Weitu
//
//  Created by Su on 4/1/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OWTPasswordAuthViewCon : UIViewController <UITextFieldDelegate>

@property (nonatomic, strong) void (^cancelFunc)();
@property (nonatomic, strong) void (^successFunc)();

@end
