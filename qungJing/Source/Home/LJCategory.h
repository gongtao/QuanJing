//
//  LJCategory.h
//  Weitu
//
//  Created by qj-app on 15/8/19.
//  Copyright (c) 2015年 SparkingSoft Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LJCategory : NSObject
@property (nonatomic, strong) NSString* categoryID;
@property (nonatomic, strong) NSString* categoryName;
@property (nonatomic, assign) NSInteger priority;
@property(nonatomic,strong)NSString *url;
@property (nonatomic, strong) NSString* feedID;
@property (nonatomic,strong)NSString *searchWord;
@property(nonatomic,strong)NSString *count;

@end
