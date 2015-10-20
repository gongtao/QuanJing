//
//  OWTActivityManager.m
//  Weitu
//
//  Created by Su on 6/3/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import "OWTActivityManager.h"
#import "OWTServerError.h"
#import "OWTAuthManager.h"
#import "OWTUserManager.h"
#import "OWTAssetManager.h"
#import "OWTActivity.h"
#import "OWTActivityMerger.h"
#import "OWTMergedActivity.h"


static const int kDefaultLoadItemNum = 20;

@interface OWTActivityManager ()
{
    NSMutableArray* _items;
    NSMutableDictionary* _itemsByID;
}

@property (nonatomic, assign) long long maxItemTimestamp;
@property (nonatomic, assign) long long minItemTimestamp;


@end
@implementation OWTActivityManager
//owt翻页


//- (void)fetchFriendsActivitiesSuccess:(void (^)(NSArray* mergedActivities))success
//                              failure:(void (^)(NSError* error))failure

- (void)refreshWithSuccess:(void (^)(NSArray* mergedActivities))success
                   failure:(void (^)(NSError* error))failure with:(NSInteger)page
{
    [self fetchItemsFromID:LONG_LONG_MAX
                      toID:0
                     count:kDefaultLoadItemNum*page
              dropOldItems:YES
                   success:success
                   failure:failure];
}

- (void)loadMoreWithSuccess:(void (^)(NSArray* mergedActivities))success
                    failure:(void (^)(NSError* error))failure
{
    [self fetchItemsFromID:_maxItemTimestamp
                      toID:0
                     count:kDefaultLoadItemNum
              dropOldItems:NO
                   success:success
                   failure:failure];
}

- (void)fetchItemsFromID:(long long)fromItemTimestamp
                    toID:(long long)toItemTimestamp
                   count:(int)count
            dropOldItems:(BOOL)dropOldItems
                 success:(void (^)(NSArray* mergedActivities))success
                 failure:(void (^)(NSError* error))failure
{
    
    OWTAuthManager* am = GetAuthManager();
    if (!am.isAuthenticated)
    {
        if (failure != nil)
        {
            failure(MakeError(kWTErrorAuthFailed));
            return;
        }
    }
    

    RKObjectManager* om = [RKObjectManager sharedManager];
    [om getObject:nil
             path:@"activity/friends1"
       parameters:@{  @"count" : [NSString stringWithFormat:@"%d", count],
                      @"timestamp" : [NSString stringWithFormat:@"%lld", fromItemTimestamp]
                     
                    }
          success:^(RKObjectRequestOperation* o, RKMappingResult* result)    {
              [o logResponse];
              
              NSDictionary* resultObjects = result.dictionary;
              OWTServerError* error = resultObjects[@"error"];
              if (error != nil)
              {
                  if (failure != nil)
                  {
                      failure([error toNSError]);
                  }
                  return;
              }
              
              NSArray* activitieDatas = resultObjects[@"activities"];
              /*
               {
               "activityType" : "upload",
               "friendsOrFans" : "好友",
               "subjectAssetID" : "1126910",
               "subjectUserID" : "",
               "timestamp" : "1419348064",
               "userID" : "302723"
               }
               // */
              //               NSLog(@"kkkkkkkkkkkkkkkkkkk%@",activitieDatas[@"userID"]);
              //                NSLog(@"kkkkkkkkkkkkkkkkkkk%@",activitieDatas[@"userID"]);
              if (activitieDatas == nil)
              {
                  if (failure != nil)
                  {
                      failure(MakeError(kWTErrorGeneral));
                  }
                  
                  
                  return;
              }
              
              
              
              
              
              NSArray* friendUserDatas = resultObjects[@"users"];
              /*
               {
               "Signature" : null,
               "avatarImageInfo" : {
               "height" : "150",
               "primaryColorHex" : "ffffff",
               "smallURL" : "",
               "url" : "http://zonepic.quanjing.com/head%5Cd0/141210-122225-kmrMK6.jpg",
               "width" : "150"
               },
               "nickname" : "张欣",
               "userID" : "904068"
               },
               */
              if (friendUserDatas == nil)
              {
                  if (failure != nil)
                  {
                      failure(MakeError(kWTErrorGeneral));
                  }
                  return;
              }
              
              OWTUserManager* um = GetUserManager();
              for (OWTUserData* userData in friendUserDatas)
              {
                  [um registerUserData:userData];
              }
              
              NSArray* assetDatas = resultObjects[@"assets"];
              /*              {
               "assetID" : "1117233",
               "caption" : "",
               "commentNum" : 0,
               "createTime" : 1412000653,
               "imageInfo" : {
               "height" : 393,
               "primaryColorHex" : "eeeeee",
               "smallURL" : "http://zonepic.quanjing.com/photo/i0/140929/140929-022419-Aed7km.jpg",
               "url" : "http://zonepic.quanjing.com/photo/s0/140929/140929-022419-Aed7km.jpg",
               "width" : 640
               },
               "keywords" : "",
               "latestComments" : [],
               "likedUserIDs" : [],
               "oriPic" : "",
               "ownerUserID" : "606213",
               "privateAsset" : true,
               "relatedAssetIDs" : [],
               "webURL" : "http://zone.quanjing.com/show/1117233"
               },
               */
              if (assetDatas == nil)
              {
                  if (failure != nil)
                  {
                      failure(MakeError(kWTErrorGeneral));
                  }
                  return;
              }
              
              [GetAssetManager() registerAssetDatas:assetDatas];
              
              if (success != nil)
              {
                  NSMutableArray* activities = [NSMutableArray arrayWithCapacity:activitieDatas.count];
                  for (OWTActivityData* activityData in activitieDatas)
                  {
                      OWTActivity* activity = [OWTActivity new];
                      [activity mergeWithData:activityData];
                      [activities addObject:activity];
                  }
                  
                  [activities sortUsingComparator:^(OWTActivity* lhs, OWTActivity* rhs) {
                      if (lhs.timestamp < rhs.timestamp) { return NSOrderedAscending; }
                      if (lhs.timestamp == rhs.timestamp) { return NSOrderedSame; }
                      return NSOrderedDescending;
                  }];
                  
                  NSArray* mergedActivities = [[[OWTActivityMerger alloc] init] mergeActivities:activities];
                  success(mergedActivities);
              }
              //修改的东西
              [self mergeWithData:activitieDatas and:friendUserDatas with:assetDatas
                     dropOldItems:dropOldItems];
          }
          failure:^(RKObjectRequestOperation* o, NSError* error) {
              [o logResponse];
              if (failure != nil)
              {
                  failure(error);
              }
          }
     ];
}
- (void)mergeWithData:(NSArray*)feedData and:(NSArray*)feedData1 with:(NSArray*)feedData2 dropOldItems:(BOOL)dropOldItems
{
    if (feedData == nil)
    {
        return;
    }
    
    if (dropOldItems)
    {
        [_items removeAllObjects];
        [_itemsByID removeAllObjects];
        _maxItemTimestamp = 0;
//        _minItemTimestamp = LONG_LONG_MAX;
        
        for (OWTActivityData* itemData in feedData)
        {
            OWTActivity* item = [OWTActivity new];
            [_items addObject:item];
           [item mergeWithData:itemData];
            
            
            
            _maxItemTimestamp = MAX(_maxItemTimestamp, item.timestamp);
//            _minItemTimestamp = MIN(_minItemTimestamp, item.timestamp);
        }
        
    }
    else
    {
        for (OWTActivityData* itemData in feedData)
        {
            OWTActivity* item = [OWTActivity new];
            [_items addObject:item];
            [item mergeWithData:itemData];
            
            
            _maxItemTimestamp = MAX(_maxItemTimestamp, item.timestamp);
//            _minItemTimestamp = MIN(_minItemTimestamp, item.timestamp);
        }
    }
    
    [_items sortUsingSelector:@selector(compare:)];
}



//圈子接口
//- (void)fetchFriendsActivitiesSuccess:(void (^)(NSArray* mergedActivities))success
//                              failure:(void (^)(NSError* error))failure
//{
//    OWTAuthManager* am = GetAuthManager();
//    if (!am.isAuthenticated)
//    {
//        if (failure != nil)
//        {
//            failure(MakeError(kWTErrorAuthFailed));
//            return;
//        }
//    }
//    
//    RKObjectManager* om = [RKObjectManager sharedManager];
//    [om getObject:nil
//             path:@"activity/friends1"
//       parameters:nil
//         
////    [om getObject:nil
////             path:@"activity/friends1"
////       parameters:@{ @"max_item_timestamp" : @"9223372036854775807",
////                     @"min_item_timestamp" : @"0",
////                     @"count" : @"50" }
//          success:^(RKObjectRequestOperation* o, RKMappingResult* result)
//    {
//              [o logResponse];
//              
//              NSDictionary* resultObjects = result.dictionary;
//              OWTServerError* error = resultObjects[@"error"];
//              if (error != nil)
//              {
//                  if (failure != nil)
//                  {
//                      failure([error toNSError]);
//                  }
//                  return;
//              }
//              
//              NSArray* activitieDatas = resultObjects[@"activities"];
///*
// {
// "activityType" : "upload",
// "friendsOrFans" : "好友",
// "subjectAssetID" : "1126910",
// "subjectUserID" : "",
// "timestamp" : "1419348064",
// "userID" : "302723"
// }
//// */
////               NSLog(@"kkkkkkkkkkkkkkkkkkk%@",activitieDatas[@"userID"]);
////                NSLog(@"kkkkkkkkkkkkkkkkkkk%@",activitieDatas[@"userID"]);
//              if (activitieDatas == nil)
//              {
//                  if (failure != nil)
//                  {
//                      failure(MakeError(kWTErrorGeneral));
//                  }
//                  
//                 
//                  return;
//              }
//              
//              NSArray* friendUserDatas = resultObjects[@"users"];
///*
// {
// "Signature" : null,
// "avatarImageInfo" : {
// "height" : "150",
// "primaryColorHex" : "ffffff",
// "smallURL" : "",
// "url" : "http://zonepic.quanjing.com/head%5Cd0/141210-122225-kmrMK6.jpg",
// "width" : "150"
// },
// "nickname" : "张欣",
// "userID" : "904068"
// },
//*/
//              if (friendUserDatas == nil)
//              {
//                  if (failure != nil)
//                  {
//                      failure(MakeError(kWTErrorGeneral));
//                  }
//                  return;
//              }
//              
//              OWTUserManager* um = GetUserManager();
//              for (OWTUserData* userData in friendUserDatas)
//              {
//                  [um registerUserData:userData];
//              }
//              
//              NSArray* assetDatas = resultObjects[@"assets"];
///*              {
//                  "assetID" : "1117233",
//                  "caption" : "",
//                  "commentNum" : 0,
//                  "createTime" : 1412000653,
//                  "imageInfo" : {
//                      "height" : 393,
//                      "primaryColorHex" : "eeeeee",
//                      "smallURL" : "http://zonepic.quanjing.com/photo/i0/140929/140929-022419-Aed7km.jpg",
//                      "url" : "http://zonepic.quanjing.com/photo/s0/140929/140929-022419-Aed7km.jpg",
//                      "width" : 640
//                  },
//                  "keywords" : "",
//                  "latestComments" : [],
//                  "likedUserIDs" : [],
//                  "oriPic" : "",
//                  "ownerUserID" : "606213",
//                  "privateAsset" : true,
//                  "relatedAssetIDs" : [],
//                  "webURL" : "http://zone.quanjing.com/show/1117233"
//              },
//*/
//              if (assetDatas == nil)
//              {
//                  if (failure != nil)
//                  {
//                      failure(MakeError(kWTErrorGeneral));
//                  }
//                  return;
//              }
//              
//              [GetAssetManager() registerAssetDatas:assetDatas];
//              
//              if (success != nil)
//              {
//                  NSMutableArray* activities = [NSMutableArray arrayWithCapacity:activitieDatas.count];
//                  for (OWTActivityData* activityData in activitieDatas)
//                  {
//                      OWTActivity* activity = [OWTActivity new];
//                      [activity mergeWithData:activityData];
//                      [activities addObject:activity];
//                  }
//                  
//                  [activities sortUsingComparator:^(OWTActivity* lhs, OWTActivity* rhs) {
//                      if (lhs.timestamp < rhs.timestamp) { return NSOrderedAscending; }
//                      if (lhs.timestamp == rhs.timestamp) { return NSOrderedSame; }
//                      return NSOrderedDescending;
//                  }];
//                  
//                  NSArray* mergedActivities = [[[OWTActivityMerger alloc] init] mergeActivities:activities];
//                  success(mergedActivities);
//              }
//          }
//          failure:^(RKObjectRequestOperation* o, NSError* error) {
//              [o logResponse];
//              if (failure != nil)
//              {
//                  failure(error);
//              }
//          }
//     ];
//}

@end
