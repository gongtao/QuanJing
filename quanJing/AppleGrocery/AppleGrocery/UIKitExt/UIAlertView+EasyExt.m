//
//  UIAlertView+EasyExt.m
//  Lego
//
//  Created by Bing SU on 6/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UIAlertView+EasyExt.h"

@implementation UIAlertView (EasyExt)

+ (void)simpleAlertOKWithMessage:(NSString *)message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:message
                                                    message:nil
                                                   delegate:nil 
                                          cancelButtonTitle:@"确定"
                                          otherButtonTitles:nil];
    [alert show];
}

@end
