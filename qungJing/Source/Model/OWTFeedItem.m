//
//  OWTFeedItem.m
//  Weitu
//
//  Created by Su on 6/27/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import "OWTFeedItem.h"
#import "OWTAssetManager.h"

@implementation OWTFeedItem

- (void)mergeWithData:(OWTFeedItemData*)feedItemData
{
    if (feedItemData == nil)
    {
        return;
    }
    
    if (feedItemData.itemID != nil)
    {
        if (_itemID == nil)
        {
            _itemID = feedItemData.itemID;
        }
        else
        {
            if (![_itemID isEqualToString:feedItemData.itemID])
            {
                AssertTR(!"FeedItemID does not match.");
                return;
            }
        }
    }
    
    if (feedItemData.timestamp != nil)
    {
        _timestamp = feedItemData.timestamp.longLongValue;
    }
    
    if (feedItemData.assetData != nil)
    {
        _asset = [GetAssetManager() registerAssetData:feedItemData.assetData];
    }
}

- (NSComparisonResult)compare:(OWTFeedItem*)rhs
{
    if (rhs.timestamp < _timestamp)
    {
        return NSOrderedAscending;
    }
    else if (_timestamp == rhs.timestamp)
    {
        return [rhs.itemID compare:_itemID];
    }
    else
    {
        return NSOrderedDescending;
    }
}

@end
