//
//  OWTFeedManager.h
//  Weitu
//
//  Created by Su on 3/10/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OWTFeed.h"

extern NSString* kWTFeedIDDefault;
extern NSString* kWTFeedHome;
extern NSString* kWTFeedLatestUpload;
extern NSString* kWTFeedWallpaper;
extern NSString* kWTFeedFollowing;
extern NSString* kWTFeedSubscription;
extern NSString* kWTFeedSquare;
extern NSString* KWTFeedFashion;
@interface OWTFeedManager : NSObject

@property (nonatomic, readonly) OWTFeed* homeFeed;
@property (nonatomic, readonly) OWTFeed* latestUploadFeed;

- (OWTFeed*)feedWithID:(NSString*)feedID;
- (OWTFeed*)feedForCategory:(OWTCategory*)category;
- (OWTFeed*)feedForCategoryData:(OWTCategoryData*)category;

- (void)refreshFeed:(OWTFeed*)feed
               success:(void (^)(OWTFeed* feed, BOOL hasMutated))successHandler
               failure:(void (^)(OWTFeed* feed, NSError* error))failureHandler;

- (void)fetchFeedItemsBackwardFromIndex:(NSInteger)startingIndex
                                numToFetch:(NSInteger)numToFetch
                                   success:(void (^)(OWTFeed* feed, NSInteger numFetched))successHandler
                                   failure:(void (^)(OWTFeed* feed, NSError* error))failureHandler;

@end
