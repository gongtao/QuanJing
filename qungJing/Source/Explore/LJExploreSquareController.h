//
//  LJExploreSquareController.h
//  Weitu
//
//  Created by qj-app on 15/9/1.
//  Copyright (c) 2015年 SparkingSoft Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LJExploreSquareController : UIViewController
@property(nonatomic,readonly)OWTFeed *feed;
@property(nonatomic,assign)float height;
@property(nonatomic,readonly)NSMutableArray *heights;
@property(nonatomic,readonly)NSMutableArray *likes;
@property(nonatomic,readonly)NSMutableArray *comment;
@property(nonatomic,copy)NSString *replyid;
@property(nonatomic,copy)NSMutableArray *assets;
- (instancetype)initWithGameId:(NSString *)GameId withTitle:(NSString *)title;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil;
- (void)presentFeed:(OWTFeed*)feed animated:(BOOL)animated refresh:(BOOL)refresh;
-(void)reloadData:(NSInteger)page;
@end
