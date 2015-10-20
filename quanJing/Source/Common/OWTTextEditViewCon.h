//
//  OWTTextEditViewCon.h
//  Weitu
//
//  Created by Su on 4/14/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OWTTextEditViewCon : UIViewController<UITextViewDelegate>

@property (nonatomic, strong) void (^doneFunc)();
@property (nonatomic, strong) NSString* text;

@end
