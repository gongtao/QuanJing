//
//  OWTCategory.m
//  Weitu
//
//  Created by Su on 6/27/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import "OWTCategory.h"

@implementation OWTCategory

- (void)mergeWithData:(OWTCategoryData*)categoryData
{
    if (categoryData == nil)
    {
        return;
    }
    
    if (categoryData.categoryID != nil)
    {
        if (_categoryID == nil)
        {
            _categoryID = categoryData.categoryID;
        }
        else
        {
            if (![_categoryID isEqualToString:categoryData.categoryID])
            {
                AssertTR(!"CategoryID does match while merging.");
                return;
            }
        }
    }
    
    if (categoryData.categoryName != nil)
    {
        _categoryName = categoryData.categoryName;
    }
    
    if (categoryData.type != nil)
    {
        _type = categoryData.type;
    }
    
    if (categoryData.searchWords != nil)
    {
        _searchWords = categoryData.searchWords;
    }
    
    if (categoryData.GroupName != nil)
    {
        _GroupName = categoryData.GroupName;
    }
    
    if (categoryData.priority != nil)
    {
        _priority = categoryData.priority.integerValue;
    }
    
    if (categoryData.coverImageInfo != nil)
    {
        _coverImageInfo = categoryData.coverImageInfo;
    }
    
    if (categoryData.feedID != nil)
    {
        _feedID = categoryData.feedID;
    }
}

@end
