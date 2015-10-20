//
//  LJFavorite.h
//  Weitu
//
//  Created by qj-app on 15/6/4.
//  Copyright (c) 2015年 SparkingSoft Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LJFavorite : UIViewController
@property(nonatomic,copy)NSString *backString1;
@property (nonatomic, strong) void (^doneFunc)();
@property(nonatomic,strong)NSArray *DataArr;
@property(nonatomic,strong)NSMutableArray *hobbies;

@end
