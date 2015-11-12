//
//  QJWebProgressView.h
//  Weitu
//
//  Created by QJ on 15/11/12.
//  Copyright © 2015年 SparkingSoft Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MCWeakProxy : NSProxy

/**
 Target object.
 
 All selectors called on receiver will be redirected to this instance.
 */
@property (nonatomic, weak) id target;

/**
 Return a new weak proxy with given target.
 
 @param target  The target object
 */
+ (instancetype)weakProxyWithTarget:(id)target;

@end

@interface QJWebProgressView : UIView

@property (nonatomic, assign) double progress;

@property (nonatomic, copy) void (^finished)(void);

- (void)setProgress:(float)progress animated:(BOOL)animated;

@end
