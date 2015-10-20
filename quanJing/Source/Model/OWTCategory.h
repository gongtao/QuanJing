//
//  OWTCategory.h
//  Weitu
//
//  Created by Su on 6/27/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import "OWTCategoryData.h"

@interface OWTCategory : NSObject

@property (nonatomic, strong) NSString* categoryID;
@property (nonatomic, strong) NSString* categoryName;
@property (nonatomic, strong) NSString* type;
@property (nonatomic, strong) NSString* searchWords;

@property (nonatomic, assign) NSInteger priority;
@property (nonatomic, strong) OWTImageInfo* coverImageInfo;
@property (nonatomic, strong) NSString* feedID;


//dutu
@property (nonatomic, strong) NSString* IsMultiLevel;
@property (nonatomic, strong) NSString* GroupName;
@property (nonatomic, assign) NSInteger UserID;

- (void)mergeWithData:(OWTCategoryData*)categoryData;

@end
