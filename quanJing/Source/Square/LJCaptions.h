//
//  LJCaptions.h
//  Weitu
//
//  Created by qj-app on 15/7/7.
//  Copyright (c) 2015年 SparkingSoft Co., Ltd. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface LJCaptions : NSManagedObject
@property(nonatomic,copy)NSString *caption;
@property(nonatomic,copy)NSString *imageUrl;
@property(nonatomic,copy)NSString *number;
@property(nonatomic,strong)NSData *imageData;
@end
