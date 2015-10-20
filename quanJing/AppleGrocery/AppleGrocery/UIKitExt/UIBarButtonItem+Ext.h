//
//  UIBarButtonItem+Ext.h
//  Weitu
//
//  Created by Su on 3/28/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIBarButtonItem (Ext)

+ (UIBarButtonItem*)barButtonItemWithTitle:(NSString *)theTitle
                                    target:(id)theTarget
                                    action:(SEL)theAction
                   withTitleTextAttributes:(NSDictionary *)textAttributes
                        andBackgroundImage:(UIImage *)theImage;

@end
