//
//  OWTComment.m
//  Weitu
//
//  Created by Su on 6/27/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import "OWTComment.h"

@implementation OWTComment

- (void)mergeWithData:(OWTCommentData*)commentData
{
    if (commentData == nil)
    {
        return;
    }
    
    if (commentData.commentID != nil)
    {
        if (_commentID == nil)
        {
            _commentID = commentData.commentID;
        }
        else
        {
            if (![_commentID isEqualToString:commentData.commentID])
            {
                AssertTR(false);
                return;
            }
        }
    }
    
    if (commentData.userID != nil)
    {
        _userID = commentData.userID;
    }
    
    if (commentData.content != nil)
    {
        _content = commentData.content;
    }
    
    if (commentData.timestamp != nil)
    {
        _timestamp = commentData.timestamp.longLongValue;
    }
}

@end
