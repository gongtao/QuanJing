//
//  QJSearchWord+CoreDataProperties.h
//  Weitu
//
//  Created by QJ on 15/10/26.
//  Copyright © 2015年 SparkingSoft Co., Ltd. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "QJSearchWord.h"

NS_ASSUME_NONNULL_BEGIN

@interface QJSearchWord (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString * detailed;
@property (nullable, nonatomic, retain) NSString * word;

@end

NS_ASSUME_NONNULL_END
