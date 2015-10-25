//
//  LJImageAndProfileCell.h
//  Weitu
//
//  Created by qj-app on 15/5/19.
//  Copyright (c) 2015年 SparkingSoft Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QuanJingSDK.h"
@interface LJImageAndProfileCell : UITableViewCell <UIScrollViewDelegate>
{
	void (^commentcb)(OWTActivityData *, NSInteger);
}
@property(nonatomic, strong) UIView * backView;
@property (nonatomic, strong) void (^headerImagecb)();
@property(nonatomic, strong) void (^assetImagecb)(OWTAsset *);
@property(nonatomic, assign) NSInteger number;
@property(nonatomic, assign) NSInteger imageNum;
@property(nonatomic, readonly) OWTUser * user;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withViewController:(UIViewController *)viewConctroller withComment:(void (^)(OWTActivityData *, NSInteger))cb;
-(void)customcell:(QJActionObject*)actionModel withImageNumber:(NSInteger)number;
-(NSArray *)getTheAllCellHeight:(NSArray *)actionList;
@end
