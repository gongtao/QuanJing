//
//  UIControl+Blocks.h
//  Lego
//
//  Created by Bing SU on 6/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIControl (Blocks)

@property (nonatomic, strong) void (^touchUpInsideAction)();

@end
