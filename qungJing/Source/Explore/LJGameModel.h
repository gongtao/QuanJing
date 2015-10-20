//
//  LJGameModel.h
//  Weitu
//
//  Created by qj-app on 15/9/1.
//  Copyright (c) 2015年 SparkingSoft Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LJGameModel : NSObject
@property(nonatomic,copy)NSString *GameId;
@property(nonatomic,copy)NSString *GameName;
@property(nonatomic,copy)NSString *GameTitle;
@property(nonatomic,copy)NSString *GameType;
@property(nonatomic,copy)NSString *State;
@property(nonatomic,copy)NSString *StartTime;
@property(nonatomic,copy)NSString *EndTime;
@property(nonatomic,copy)NSString *IsAPP;
@property(nonatomic,copy)NSString *GameCover;
@property(nonatomic,copy)NSString *Orderno;
@end
