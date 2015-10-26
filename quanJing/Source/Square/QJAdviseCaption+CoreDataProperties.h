//
//  QJAdviseCaption+CoreDataProperties.h
//  Weitu
//
//  Created by QJ on 15/10/26.
//  Copyright © 2015年 SparkingSoft Co., Ltd. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "QJAdviseCaption.h"

NS_ASSUME_NONNULL_BEGIN

@interface QJAdviseCaption (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString * caption;
@property (nullable, nonatomic, retain) NSString * imageUrl;
@property (nullable, nonatomic, retain) NSNumber * number;

@end

NS_ASSUME_NONNULL_END
