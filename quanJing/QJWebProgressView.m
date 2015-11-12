//
//  QJWebProgressView.m
//  Weitu
//
//  Created by QJ on 15/11/12.
//  Copyright © 2015年 SparkingSoft Co., Ltd. All rights reserved.
//

#import "QJWebProgressView.h"

#import "UIColor+HexString.h"

@implementation MCWeakProxy

+ (instancetype)weakProxyWithTarget:(id)target
{
	MCWeakProxy * proxy = [self alloc];
	
	proxy.target = target;
	return proxy;
}

- (BOOL)respondsToSelector:(SEL)sel
{
	return [_target respondsToSelector:sel] || [super respondsToSelector:sel];
}

- (id)forwardingTargetForSelector:(SEL)sel
{
	return _target;
}

@end

@interface QJWebProgressView ()

@property (nonatomic, assign) float fromProgress;
@property (nonatomic, assign) float toProgress;
@property (nonatomic, assign) CFTimeInterval startTime;
@property (nonatomic, strong) CADisplayLink * displayLink;
@property (nonatomic, strong) UIImageView * progressView;

@end

@implementation QJWebProgressView

- (instancetype)init
{
	self = [super init];
	
	if (self)
		[self initializeInterface];
	return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	
	if (self)
		[self initializeInterface];
	return self;
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	CGRect frame = self.bounds;
	frame.size.width = (frame.size.width - 7.0) * self.progress + 11.0;
	_progressView.frame = frame;
}

- (void)initializeInterface
{
	_progress = 0.0;
	_fromProgress = 0.0;
	_toProgress = 0.0;
	
	self.backgroundColor = [UIColor colorWithHexString:@"dedede"];
	
	UIImage * image = [UIImage imageNamed:@"article_webview_progress.png"];
	_progressView = [UIImageView new];
	_progressView.image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 0.0, 0.0, image.size.width)];
	[self addSubview:_progressView];
}

#pragma mark - Property

- (void)setProgress:(double)progress
{
	NSParameterAssert(progress >= 0 && progress <= 1);
	
	// Stop running animation
	if (self.displayLink) {
		self.displayLink.paused = YES;
		[self.displayLink invalidate];
		self.displayLink = nil;
	}
	
	_progress = progress;
	
	[self setNeedsLayout];
}

- (void)setProgress:(float)progress animated:(BOOL)animated
{
	if (animated) {
		if (self.progress == progress)
			return;
			
		if (self.displayLink) {
			// Reuse current display link and manipulate animation params
			self.startTime = CACurrentMediaTime();
			self.fromProgress = self.progress;
			self.toProgress = progress;
		}
		else {
			[self animateToProgress:progress];
		}
	}
	else {
		self.progress = progress;
	}
}

- (void)animateToProgress:(float)progress
{
	self.fromProgress = self.progress;
	self.toProgress = progress;
	self.startTime = CACurrentMediaTime();
	
	self.displayLink = [CADisplayLink displayLinkWithTarget:[MCWeakProxy weakProxyWithTarget:self]
		selector:@selector(animateFrame:)];
	[self.displayLink addToRunLoop:NSRunLoop.mainRunLoop forMode:NSRunLoopCommonModes];
	self.displayLink.paused = NO;
}

- (void)animateFrame:(CADisplayLink *)displayLink
{
	CGFloat d = (displayLink.timestamp - self.startTime) / 0.3;
	
	if (d >= 1.0) {
		// Order is important! Otherwise concurrency will cause errors, because setProgress: will detect an
		// animation in progress and try to stop it by itself.
		if (self.displayLink) {
			self.displayLink.paused = YES;
			[self.displayLink invalidate];
			self.displayLink = nil;
		}
		
		self.progress = self.toProgress;
		
		// 最终结束
		if (self.progress >= 1.0)
			if (self.finished) {
				self.finished();
				self.finished = nil;
			}
			
		return;
	}
	
	_progress = self.fromProgress + d * (self.toProgress - self.fromProgress);
	
	[self setNeedsLayout];
}

@end
