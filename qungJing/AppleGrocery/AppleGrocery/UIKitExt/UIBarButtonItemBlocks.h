//
//  UIBarButtonItemBlocks.h
//  Lego
//
//  Created by Bing SU on 6/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^BlockAction)();

@interface UIBarButtonItemBlocks : UIBarButtonItem

- (id)initWithImage:(UIImage *)image style:(UIBarButtonItemStyle)style blockAction:(BlockAction)action;
- (id)initWithImage:(UIImage *)image landscapeImagePhone:(UIImage *)landscapeImagePhone style:(UIBarButtonItemStyle)style blockAction:(BlockAction)action;
- (id)initWithTitle:(NSString *)title style:(UIBarButtonItemStyle)style blockAction:(BlockAction)action;
- (id)initWithBarButtonSystemItem:(UIBarButtonSystemItem)systemItem blockAction:(BlockAction)action;
- (id)initWithCustomView:(UIView *)customView;

@property (nonatomic, copy) BlockAction blockAction;

@end
