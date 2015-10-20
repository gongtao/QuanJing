//
//  UIBarButtonItem+Ext.m
//  Weitu
//
//  Created by Su on 3/28/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import "UIBarButtonItem+Ext.h"

@implementation UIBarButtonItem (Ext)

+ (UIBarButtonItem*)barButtonItemWithTitle:(NSString *)theTitle
                                    target:(id)theTarget
                                    action:(SEL)theAction
                   withTitleTextAttributes:(NSDictionary *)textAttributes
                        andBackgroundImage:(UIImage *)theImage
{
    UIBarButtonItem *b = [[UIBarButtonItem alloc] initWithTitle:theTitle style:UIBarButtonItemStylePlain target:theTarget action:theAction];
    [b setTitleTextAttributes:textAttributes forState:UIControlStateNormal];
    [b setBackgroundImage:theImage forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    return b;
}

@end
