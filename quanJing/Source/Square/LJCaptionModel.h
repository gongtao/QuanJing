//
//  LJCaptionModel.h
//  Weitu
//
//  Created by qj-app on 15/6/10.
//  Copyright (c) 2015年 SparkingSoft Co., Ltd. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface LJCaptionModel : NSManagedObject
@property(nonatomic,copy)NSString *imageUrl;
@property(nonatomic,copy)NSString *caption;
@property(nonatomic,copy)NSString *isSelfInsert;
@end
