//
//  OWTAuthViewCon.h
//  Weitu
//
//  Created by Su on 4/1/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OFullViewNavCon.h"

@interface OWTAuthViewCon : OFullViewNavCon

@property (nonatomic, strong) void (^cancelFunc)();
@property (nonatomic, strong) void (^successFunc)(BOOL isNewUser);
@property(nonatomic, strong)void (^cancelBlock)(void);

@end
