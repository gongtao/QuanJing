//
//  OWTAsset.m
//  Weitu
//
//  Created by Su on 6/27/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import "OWTAsset.h"
#import "OWTComment.h"

@implementation OWTAsset
-(void)getFromModel:(QJImageObject *)model
{
    _assetID=model.imageId.stringValue;
    _imageInfo.width=model.width.intValue;
    _imageInfo.height=model.height.intValue;
    _imageInfo.url=model.url;
    _ownerUserID=model.userId.stringValue;
    _imageInfo.primaryColorHex=model.bgcolor;
}
- (void)addComment:(OWTComment*)comment
{
    if (_comments == nil)
    {
        _comments = [NSMutableArray arrayWithObject:comment];
    }
    else
    {
        [_comments addObject:comment];
    }

    _commentNum = _comments.count;

    if (_latestComments == nil)
    {
        _latestComments = [NSMutableArray arrayWithObject:comment];
    }
    else
    {
        [_latestComments addObject:comment];
        if (_latestComments.count > 3)
        {
            [_latestComments removeObjectAtIndex:0];
        }
    }
}

- (NSInteger)likeNum
{
    return _likedUserIDs.count;
}

- (void)markLikedByUser:(NSString*)userID
{
    if (userID == nil || userID.length == 0)
    {
        return;
    }
    
    [_likedUserIDs addObject:userID];
}

- (void)markUnlikedByUser:(NSString*)userID
{
    if (userID == nil || userID.length == 0)
    {
        return;
    }
    
    [_likedUserIDs removeObject:userID];
}

- (BOOL)isLikedByUser:(NSString*)userID
{
    return [_likedUserIDs containsObject:userID];
}

#pragma mark - Data Merge

- (void)mergeWithData:(OWTAssetData*)assetData
{
    if (assetData.assetID != nil)
    {
        if (_assetID == nil)
        {
            _assetID = assetData.assetID;
        }
        else
        {
            if (![_assetID isEqualToString:assetData.assetID])
            {
                DDLogError(@"OWTAsset [%@] merging with wrong object, ID: %@.", _assetID, assetData.assetID);
                return;
            }
        }
    }
    
    if (assetData.caption != nil)
    {
        _caption = assetData.caption;
    }

    
    
    if (assetData.oriPic != nil)
    {
        _oriPic = assetData.oriPic;
    }
    if (assetData.webURL != nil)
    {
        _webURL = assetData.webURL;
    }
    
    
    if (assetData.serial != nil)
    {
        _serial = assetData.serial;
    }

    if (assetData.ownerUserID != nil)
    {
        _ownerUserID = assetData.ownerUserID;
    }
    
    if (assetData.isPrivate != nil)
    {
        _isPrivate = assetData.isPrivate.boolValue;
    }
    
    if (assetData.imageInfo != nil)
    {
        _imageInfo = assetData.imageInfo;
    }

    if (assetData.likedUserNum != nil)
    {
        _likeNum = assetData.likedUserNum.integerValue;
    }

    if (assetData.commentNum != nil)
    {
        _commentNum = assetData.commentNum.integerValue;
    }

    if (assetData.latestCommentDatas != nil)
    {
        _latestComments = [NSMutableArray arrayWithCapacity:assetData.latestCommentDatas.count];
        for (OWTCommentData* commentData in assetData.latestCommentDatas)
        {
            OWTComment* comment = [OWTComment new];
            [comment mergeWithData:commentData];
            [_latestComments addObject:comment];
        }
    }

    if (assetData.likedUserIDs != nil)
    {
        _likedUserIDs = [NSMutableSet setWithArray:assetData.likedUserIDs];
    }
}

- (void)mergeWithRelatedAssets:(NSArray*)relatedAssets
{
    _relatedAssets = [NSOrderedSet orderedSetWithArray:relatedAssets];
}

@end
