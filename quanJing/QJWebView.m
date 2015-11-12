//
//  QJWebView.m
//  Weitu
//
//  Created by QJ on 15/11/12.
//  Copyright © 2015年 SparkingSoft Co., Ltd. All rights reserved.
//

#import "QJWebView.h"

#import <objc/runtime.h>

@interface UIWebView (WebResourceLoadDelegate)

- (id)webView:(id)view identifierForInitialRequest:(id)initialRequest fromDataSource:(id)dataSource;

- (void)webView:(id)view resource:(id)resource didFailLoadingWithError:(id)error fromDataSource:(id)dataSource;

- (void)webView:(id)view resource:(id)resource didFinishLoadingFromDataSource:(id)dataSource;

@end

@interface QJWebView ()
{
	NSUInteger _currentCount;
	NSUInteger _totalCount;
}

@end

@implementation QJWebView

- (instancetype)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	
	if (self) {
		_currentCount = 0;
		_totalCount = 0;
	}
	return self;
}

#pragma mark - Override

- (void)loadRequest:(NSURLRequest *)request
{
	_currentCount = 0;
	_totalCount = 0;
	[super loadRequest:request];
}

#pragma mark - WebResourceLoadDelegate

- (id)webView:(id)view identifierForInitialRequest:(id)initialRequest fromDataSource:(id)dataSource
{
	_totalCount++;
	return [super webView:view identifierForInitialRequest:initialRequest fromDataSource:dataSource];
}

- (void)webView:(id)view resource:(id)resource didFailLoadingWithError:(id)error fromDataSource:(id)dataSource
{
	[super webView:view resource:resource didFailLoadingWithError:error fromDataSource:dataSource];
	_currentCount++;
	
	if ([self.resourceLoadDelegate respondsToSelector:@selector(webView:didLoadResourceCount:totalCount:)])
		[self.resourceLoadDelegate webView:self didLoadResourceCount:_currentCount totalCount:_totalCount];
}

- (void)webView:(id)view resource:(id)resource didFinishLoadingFromDataSource:(id)dataSource
{
	[super webView:view resource:resource didFinishLoadingFromDataSource:dataSource];
	_currentCount++;
	
	if ([self.resourceLoadDelegate respondsToSelector:@selector(webView:didLoadResourceCount:totalCount:)])
		[self.resourceLoadDelegate webView:self didLoadResourceCount:_currentCount totalCount:_totalCount];
}

@end
