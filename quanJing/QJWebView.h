//
//  QJWebView.h
//  Weitu
//
//  Created by QJ on 15/11/12.
//  Copyright © 2015年 SparkingSoft Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol QJWebViewResourceLoadDelegate;

NS_ASSUME_NONNULL_BEGIN

@interface QJWebView : UIWebView

@property (nullable, nonatomic, weak) id <QJWebViewResourceLoadDelegate> resourceLoadDelegate;

@end

@protocol QJWebViewResourceLoadDelegate <NSObject>

- (void)webView:(QJWebView *)webView didLoadResourceCount:(NSUInteger)currentCount totalCount:(NSUInteger)totalCount;

@end

NS_ASSUME_NONNULL_END
