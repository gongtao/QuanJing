//
//  LJFeedWithUserProfileViewCon.h
//  Weitu
//
//  Created by qj-app on 15/5/20.
//  Copyright (c) 2015年 SparkingSoft Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LJFeedWithUserProfileViewCon : UIViewController<UIImagePickerControllerDelegate>

@property(nonatomic,readonly)OWTFeed *feed;
@property(nonatomic,assign)float height;
@property(nonatomic,readonly)NSMutableArray *heights;
@property(nonatomic,readonly)NSMutableArray *likes;
@property(nonatomic,readonly)NSMutableArray *comment;
@property(nonatomic,readonly)NSMutableArray *activeList;
@property(nonatomic,copy)NSString *replyid;
@property(nonatomic,copy)NSMutableArray *assets;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil;
- (void)presentFeed:(OWTFeed*)feed animated:(BOOL)animated refresh:(BOOL)refresh;
-(void)reloadData:(NSInteger)page;
@end
