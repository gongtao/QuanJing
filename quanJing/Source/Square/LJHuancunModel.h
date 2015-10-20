//
//  LJHuancunModel.h
//  Weitu
//
//  Created by qj-app on 15/6/25.
//  Copyright (c) 2015年 SparkingSoft Co., Ltd. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface LJHuancunModel : NSManagedObject
@property(nonatomic,strong)NSData *response;
@property(nonatomic,strong)NSString *type;
@property(nonatomic,strong)NSString *userid;
@end
