//
//  OWTAssetCategory.h
//  Weitu
//
//  Created by Su on 5/8/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OWTCategoryData : NSObject

@property (nonatomic, copy) NSString* categoryID;
@property (nonatomic, copy) NSString* categoryName;
@property (nonatomic, copy) NSString* type;
@property (nonatomic, copy) NSString* searchWords;

@property (nonatomic, copy) NSString* GroupName;
@property (nonatomic, copy) NSNumber* priority;
@property (nonatomic, strong) OWTImageInfo* coverImageInfo;
@property (nonatomic, copy) NSString* feedID;

@end
