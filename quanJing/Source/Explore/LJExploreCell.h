//
//  LJExploreCell.h
//  Weitu
//
//  Created by qj-app on 15/9/1.
//  Copyright (c) 2015年 SparkingSoft Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LJExploreCell : UITableViewCell
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

- (void)customCell:(NSArray *)data withUserInformation:(NSArray *)users withLike:(NSArray *)like withComment:(NSArray *)comment withActivityData:(OWTActivityData *)activityData withImageNumber:(NSInteger)number;
- (NSArray *)getTheAllCellHeight:(NSArray *)data withUserInformation:(NSArray *)users withLike:(NSArray *)like withComment:(NSArray *)comment withActivityData:(NSArray *)activityData;
@end
