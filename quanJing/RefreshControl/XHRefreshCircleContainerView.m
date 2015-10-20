//
// XHRefreshView.m
// MessageDisplayExample
//
// Created by 曾 宪华 on 14-6-6.
// Copyright (c) 2014年 曾宪华 开发团队(http://iyilunba.com ) 本人QQ:543413507 本人QQ群（142557668）. All rights reserved.
//

#import "XHRefreshCircleContainerView.h"

@interface XHRefreshCircleContainerView ()

@end

@implementation XHRefreshCircleContainerView

#pragma mark - Propertys

- (XHCircleView1*)circleView
{
    if (!_circleView)
    {
        CGFloat width = CGRectGetWidth(self.bounds);
        CGFloat height = CGRectGetHeight(self.bounds);
        CGFloat x = (width - kXHRefreshCircleViewHeight) / 2;
        CGFloat y = (height - kXHRefreshCircleViewHeight) / 2;
        CGRect frame = CGRectMake(x, y, kXHRefreshCircleViewHeight, kXHRefreshCircleViewHeight);
        _circleView = [[XHCircleView1 alloc] initWithFrame:frame];
    }
    return _circleView;
}

- (UILabel*)stateLabel
{
    if (!_stateLabel)
    {
        CGRect frame = CGRectMake(CGRectGetMaxX(self.circleView.frame) + 5, self.circleView.center.y - 7, 160, 14);
        _stateLabel = [[UILabel alloc] initWithFrame:frame];
        _stateLabel.backgroundColor = [UIColor clearColor];
        _stateLabel.font = [UIFont systemFontOfSize:14.f];
        _stateLabel.textColor = [UIColor blackColor];
    }
    return _stateLabel;
}

- (UILabel*)timeLabel
{
    if (!_timeLabel)
    {
        CGRect timeLabelFrame = self.stateLabel.frame;
        timeLabelFrame.origin.y += CGRectGetHeight(timeLabelFrame) + 6;
        _timeLabel = [[UILabel alloc] initWithFrame:timeLabelFrame];
        _timeLabel.backgroundColor = [UIColor clearColor];
        _timeLabel.font = [UIFont systemFontOfSize:11.f];
        _timeLabel.textColor = [UIColor colorWithWhite:0.659 alpha:1.000];
    }
    return _timeLabel;
}

#pragma mark - Life Cycle

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // Initialization code
        self.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.circleView];
// [self addSubview:self.stateLabel];
// [self addSubview:self.timeLabel];
    }
    return self;
}

@end