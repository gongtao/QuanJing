//
//  OWTLoginRegisterSelectionViewCon.h
//  Weitu
//
//  Created by Su on 5/21/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OWTLoginRegisterSelectionViewCon : UIViewController<UITextViewDelegate>

@property (nonatomic, strong) void (^doneWithLoginFunc)();
@property (nonatomic, strong) void (^doneWithRegisterFunc)();
@property (nonatomic, strong) void (^doneWithPasswordLoginFunc)();
@property(nonatomic,strong)void(^cancelFunc)();
@end
