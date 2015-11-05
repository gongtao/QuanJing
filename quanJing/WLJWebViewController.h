//
//  WLJWebViewController.h
//  Html_Hpple
//
//  Created by 王霖 on 14-5-27.
//  Copyright (c) 2014年 com.wangan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WLJArticle.h"
// #import "ui"
@class FSImageViewerViewController;

@interface WLJWebViewController : UIViewController

@property(strong, nonatomic) FSImageViewerViewController * imageViewController;

@property (nonatomic, strong) NSString * urlString;
@property (nonatomic, strong) WLJArticle * article;

@property (nonatomic, copy) NSString * titleS;
@property (nonatomic, copy) NSString * assetUrl;

@property (nonatomic, copy) NSString * SummaryStr;
@end
