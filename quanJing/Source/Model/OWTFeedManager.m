//
//  OWTFeedManager.m
//  Weitu
//
//  Created by Su on 3/10/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import "OWTFeedManager.h"
#import "OWTDataManager.h"
#import "OWTFeedItemData.h"
#import "OWTFeedInfoData.h"
#import "OWTCategory.h"

NSString* kWTFeedHome           = @"home";
NSString* kWTFeedLatestUpload   = @"latest";
NSString* kWTFeedWallpaper      = @"wallpaper";
NSString* kWTFeedFollowing      = @"following";
NSString* kWTFeedSubscription   = @"subscription";
NSString* kWTFeedSquare         = @"square";
NSString *KWTFeedFashion      =@"22";
NSString* kWTFeedIDDefault      = @"home";

static OWTFeedManager* sSharedSingleton;

@interface OWTFeedManager ()
{
    NSMutableDictionary* _feedsByID;
}

@end

@implementation OWTFeedManager

- (id)init
{
    self = [super init];
    if (self != nil)
    {
        [self setup];
    }
    return self;
}

- (void)setup
{
    _feedsByID = [NSMutableDictionary dictionary];
    [self setupDefaultFeeds];
}

- (void)setupDefaultFeeds
{
    OWTFeedInfo* homeFeedInfo = [[OWTFeedInfo alloc] initWithFeedID:kWTFeedHome
                                                             nameZH:@"美图欣赏"
                                                             nameEN:@"Wonderful Pictures"
                                                     lastUpdateTime:[[NSDate date] timeIntervalSince1970]
                                                         generation:1];
    
    OWTFeed* homeFeed = [[OWTFeed alloc] initWithFeedInfo:homeFeedInfo];
    
    OWTFeedInfo* latestUploadsFeedInfo = [[OWTFeedInfo alloc] initWithFeedID:kWTFeedLatestUpload
                                                                      nameZH:@"最新上传"
                                                                      nameEN:@"Latest Upload"
                                                              lastUpdateTime:[[NSDate date] timeIntervalSince1970]
                                                                  generation:1];
    OWTFeed* latestUploadsFeed = [[OWTFeed alloc] initWithFeedInfo:latestUploadsFeedInfo];
    
    OWTFeedInfo* wallpaperFeedInfo = [[OWTFeedInfo alloc] initWithFeedID:kWTFeedWallpaper
                                                                  nameZH:@"热门壁纸"
                                                                  nameEN:@"Hot wallpapers"
                                                          lastUpdateTime:[[NSDate date] timeIntervalSince1970]
                                                              generation:1];
    OWTFeed* wallpaperFeed = [[OWTFeed alloc] initWithFeedInfo:wallpaperFeedInfo];
    
    OWTFeedInfo* followingFeedInfo = [[OWTFeedInfo alloc] initWithFeedID:kWTFeedFollowing
                                                                  nameZH:@"我的关注"
                                                                  nameEN:@"Following"
                                                          lastUpdateTime:[[NSDate date] timeIntervalSince1970]
                                                              generation:1];
    OWTFeed* followingFeed = [[OWTFeed alloc] initWithFeedInfo:followingFeedInfo];
    
    OWTFeedInfo* subscriptionFeedInfo = [[OWTFeedInfo alloc] initWithFeedID:kWTFeedSubscription
                                                                     nameZH:@"我的订阅"
                                                                     nameEN:@"Subscription"
                                                             lastUpdateTime:[[NSDate date] timeIntervalSince1970]
                                                                 generation:1];
    OWTFeed* subscriptionFeed = [[OWTFeed alloc] initWithFeedInfo:subscriptionFeedInfo];
    
    OWTFeedInfo* squareFeedInfo = [[OWTFeedInfo alloc] initWithFeedID:kWTFeedSquare
                                                               nameZH:@"晒图广场"
                                                               nameEN:@"Picture Square"
                                                       lastUpdateTime:[[NSDate date] timeIntervalSince1970]
                                                           generation:1];
    OWTFeed* squareFeed = [[OWTFeed alloc] initWithFeedInfo:squareFeedInfo];
    OWTFeedInfo *fashionFeedInfo=[[OWTFeedInfo alloc]initWithFeedID:KWTFeedFashion nameZH:nil nameEN:nil lastUpdateTime:[[NSDate date] timeIntervalSince1970] generation:1];
    OWTFeed *fashionFeed=[[OWTFeed alloc]initWithFeedInfo:fashionFeedInfo];
    [self registerFeed:fashionFeed];
    [self registerFeed:homeFeed];
    [self registerFeed:latestUploadsFeed];
    [self registerFeed:wallpaperFeed];
    [self registerFeed:followingFeed];
    [self registerFeed:subscriptionFeed];
    [self registerFeed:squareFeed];
}

- (void)setupResponseDescriptors
{
    OWTDataManager* dm = GetDataManager();
    
    RKResponseDescriptor* responseDescriptor;
    responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:dm.accessTokenMapping
                                                                      method:RKRequestMethodAny
                                                                 pathPattern:nil
                                                                     keyPath:@"accessToken"
                                                                 statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [[RKObjectManager sharedManager] addResponseDescriptor:responseDescriptor];
}

#pragma mark - Actions

- (OWTFeed*)feedWithID:(NSString*)feedID
{
    return [_feedsByID objectForKey:feedID];
}

- (OWTFeed*)feedForCategory:(OWTCategory*)category
{
    NSString* feedID = category.feedID;
    OWTFeed* feed = [_feedsByID objectForKey:feedID];
    if (feed == nil)
    {
        OWTFeedInfo* feedInfo = [[OWTFeedInfo alloc] initWithFeedID:feedID
                                                             nameZH:category.categoryName
                                                             nameEN:category.categoryName
                                                     lastUpdateTime:[[NSDate date] timeIntervalSince1970]
                                                         generation:1];
        feed = [[OWTFeed alloc] initWithFeedInfo:feedInfo];
        [self registerFeed:feed];
    }
    
    return feed;
}


- (OWTFeed*)feedForCategoryData:(OWTCategoryData*)category
{
    NSString* feedID = category.feedID;
    OWTFeed* feed = [_feedsByID objectForKey:feedID];
    if (feed == nil)
    {
        OWTFeedInfo* feedInfo = [[OWTFeedInfo alloc] initWithFeedID:feedID
                                                             nameZH:category.categoryName
                                                             nameEN:category.categoryName
                                                     lastUpdateTime:[[NSDate date] timeIntervalSince1970]
                                                         generation:1];
        feed = [[OWTFeed alloc] initWithFeedInfo:feedInfo];
        [self registerFeed:feed];
    }
    
    return feed;
}

- (OWTFeed*)homeFeed
{
    return [self feedWithID:kWTFeedHome];
}

- (OWTFeed*)latestUploadFeed
{
    return [self feedWithID:kWTFeedLatestUpload];
}

- (void)registerFeed:(OWTFeed*)feed
{
    if (feed.feedID != nil) {
        [_feedsByID setValue:feed forKey:feed.feedID];
    }
}

- (void)refreshFeed:(OWTFeed*)feed
            success:(void (^)(OWTFeed* feed, BOOL hasMutated))successHandler
            failure:(void (^)(OWTFeed* feed, NSError* error))failureHandler
{
    // TODO issue the request
}

- (void)fetchFeedItemsBackwardFromIndex:(NSInteger)startingIndex
                             numToFetch:(NSInteger)numToFetch
                                success:(void (^)(OWTFeed* feed, NSInteger numFetched))successHandler
                                failure:(void (^)(OWTFeed* feed, NSError* error))failureHandler
{
    // TODO issue the request
}

@end
