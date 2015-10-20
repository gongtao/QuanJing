//
//  OWTFeed.m
//  Weitu
//
//  Created by Su on 3/10/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import "OWTFeed.h"
#import "OWTServerError.h"
#import "OWTFeedData.h"
#import "OWTFeedItem.h"
#import "OWTUserManager.h"
#import "OWTAccessToken.h"
#import "AFNetworking.h"
#import "LJAssetModel.h"
#import "OWTAsset.h"
#import "OWTUser.h"
#import "OWTActivity.h"
#import "LJComment.h"
#import "LJLike.h"
#import "OWTActivityData.h"
static const int kDefaultLoadItemNum = 20;

@interface OWTFeed ()
{
    NSMutableArray* _items;
        NSMutableDictionary* _itemsByID;
    }

@property (nonatomic, assign) long long maxItemTimestamp;
@property (nonatomic, assign) long long minItemTimestamp;

@end

@implementation OWTFeed

- (id)initWithFeedInfo:(OWTFeedInfo*)feedInfo
{
    self = [super init];
    if (self != nil)
    {
        _feedInfo = feedInfo;
        _items = [NSMutableArray array];
        _userInformations=[[NSMutableArray alloc]init];
        _itemsByID = [NSMutableDictionary dictionary];
        _activitiles=[[NSMutableArray alloc]init];
        _activComment=[[NSMutableArray alloc]init];
        _activLike=[[NSMutableArray alloc]init];
    }
    return self;
}

- (NSString*)feedID
{
    return _feedInfo.feedID;
}

- (NSString*)nameZH
{
    return _feedInfo.nameZH;
}

- (NSString*)nameEN
{
    return _feedInfo.nameEN;
}

- (NSDate*)lastUpdateTime
{
    return [NSDate dateWithTimeIntervalSince1970:_feedInfo.lastUpdateTime];

}

- (void)refreshWithSuccess1:(void (^)())success
                   failure:(void (^)(NSError* error))failure
{
   
    [self fetchItemsFromID1:LONG_LONG_MAX
                      toID:0
                     count:kDefaultLoadItemNum
              dropOldItems:YES
                   success:success
                   failure:failure];
    }

- (void)loadMoreWithSuccess1:(void (^)())success
                    failure:(void (^)(NSError* error))failure
{
    [self fetchItemsFromID1:_minItemTimestamp
                      toID:0
                     count:kDefaultLoadItemNum
              dropOldItems:NO
                   success:success
                   failure:failure];
}

- (void)fetchItemsFromID1:(long long)fromItemTimestamp
                    toID:(long long)toItemTimestamp
                   count:(int)count
            dropOldItems:(BOOL)dropOldItems
                 success:(void (^)())success
                 failure:(void (^)(NSError* error))failure
{
    RKObjectManager* om = [RKObjectManager sharedManager];
    NSDictionary *dict=@{@"max_item_timestamp" : [NSString stringWithFormat:@"%lld", fromItemTimestamp],@"min_item_timestamp" : [NSString stringWithFormat:@"%lld", toItemTimestamp],@"count" : [NSString stringWithFormat:@"%d",count]};
    [om getObject:nil
              path:[NSString stringWithFormat:@"activity/friends4"]
       parameters:dict
          success:^(RKObjectRequestOperation* o, RKMappingResult* result) {
              [o logResponse];
              _minItemTimestamp=fromItemTimestamp;
              
              if (dropOldItems) {
                  
                  [_items removeAllObjects];
                  [_userInformations removeAllObjects];
                  [_activitiles removeAllObjects];
                  [_activComment removeAllObjects];
                  [_activLike removeAllObjects];
              }
              NSDictionary* resultObjects = result.dictionary;
              NSLog(@"%@",resultObjects);
              OWTUserManager* um = GetUserManager();
              for (OWTAsset *asset in resultObjects[@"assets"]) {
                  OWTAsset *_asset=[[OWTAsset alloc]init];
                  _asset=asset;
                  [_items addObject:_asset];
              }
              for (OWTUserData *user in  resultObjects[@"users"]) {
                  OWTUserData *user1=[[OWTUserData alloc]init];
                  user1=user;
                  [um registerUserData:user];
                  [_userInformations addObject:user1];
              }
              for (OWTActivityData *activity1 in  resultObjects[@"activities"]) {
                  OWTActivityData *activity=[[OWTActivityData alloc]init];
                  _minItemTimestamp=MIN(activity1.timestamp.intValue, _minItemTimestamp);
                  activity=activity1;
                  if (!dropOldItems) {
                      OWTActivityData *activity2=_activitiles[_activitiles.count-1];
                      if ([activity2.commentid isEqualToString:activity1.commentid]) {
                          continue;
                      }
                  }
                  [_activitiles addObject:activity];
              }
              for (LJComment *comment in resultObjects[@"activComment"]) {
                  LJComment *ljcomment=[[LJComment alloc]init];
                  ljcomment=comment;
                  [_activComment addObject:ljcomment];
              }
              for (LJLike *like in resultObjects[@"activLike"]) {
                  LJLike *ljLike=[[LJLike alloc]init];
                  ljLike=like;
                  [_activLike addObject:ljLike];
              }
              if (success) {
                  success();
              }
              if (dropOldItems) {
                  NSMutableArray *arr=[[NSMutableArray alloc]init];
                  [arr addObject:_items];
                  [arr addObject:_userInformations];
                  [arr addObject:_activComment];
                  [arr addObject:_activitiles];
                  [arr addObject:_activLike];
                  NSString *homeDictionary = NSHomeDirectory();//获取根目录
                  NSString *homePath  = [homeDictionary stringByAppendingString:@"/Documents/atany.archiver"];//添加储存的文件名
                  BOOL flag = [NSKeyedArchiver archiveRootObject:arr toFile:homePath];
                
              }
              
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
- (void)refreshWithSuccess:(void (^)())success
                   failure:(void (^)(NSError* error))failure
{
    [self fetchItemsFromID:LONG_LONG_MAX
                      toID:0
                     count:kDefaultLoadItemNum
              dropOldItems:YES
                   success:success
                   failure:failure];
}

- (void)loadMoreWithSuccess:(void (^)())success
                    failure:(void (^)(NSError* error))failure
{
    [self fetchItemsFromID:_minItemTimestamp
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
                 success:(void (^)())success
                 failure:(void (^)(NSError* error))failure
{
    RKObjectManager* om = [RKObjectManager sharedManager];
    [om getObject:nil
             path:[NSString stringWithFormat:@"cdn2/feeds/%@", self.feedID]//此处打印，确定feedID具体值
       parameters:@{ @"max_item_timestamp" : [NSString stringWithFormat:@"%lld", fromItemTimestamp],
                     @"min_item_timestamp" : [NSString stringWithFormat:@"%lld", toItemTimestamp],
                     @"count" : [NSString stringWithFormat:@"%d", count] }
          success:^(RKObjectRequestOperation* o, RKMappingResult* result) {
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
              
              OWTFeedData* feedData = resultObjects[@"feedFragment"];

              if (feedData == nil)
              {
                  if (failure != nil)
                  {
                      failure([[OWTServerError unknownError] toNSError]);
                  }
                  return;
              }
              
              [self mergeWithData:feedData dropOldItems:dropOldItems];
              
              NSArray* relatedUserDatas = resultObjects[@"relatedUsers"];
              if (relatedUserDatas != nil)
              {
                  OWTUserManager* um = GetUserManager();
                  for (OWTUserData* userData in relatedUserDatas)
                  {
                      [um registerUserData:userData];
                  }
              }
              
              if (success != nil)
              {
                  success();
              }
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

- (void)mergeWithData:(OWTFeedData*)feedData dropOldItems:(BOOL)dropOldItems
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
        _minItemTimestamp = LONG_LONG_MAX;
        
        for (OWTFeedItemData* itemData in feedData.itemDatas)
        {
            OWTFeedItem* item = [OWTFeedItem new];
            [_itemsByID setObject:item forKey:itemData.itemID];
            [_items addObject:item];
            
            [item mergeWithData:itemData];
            _maxItemTimestamp = MAX(_maxItemTimestamp, item.timestamp);
            _minItemTimestamp = MIN(_minItemTimestamp, item.timestamp);
            
        }
        
        NSString *homeDictionary = NSHomeDirectory();//获取根目录
        NSString *homePath  = [homeDictionary stringByAppendingString:@"/Documents/cacheSubCategorise.archiver"];
        if (_feedInfo.nameZH != nil) {
            
            NSDictionary *rootdic = [NSKeyedUnarchiver unarchiveObjectWithFile:homePath];
            if (rootdic != nil) {
                rootdic = [[NSMutableDictionary alloc]initWithDictionary:rootdic];
            }else{
                rootdic = [[NSMutableDictionary alloc]init];
                
            }
            [rootdic setValue:_items forKey:_feedInfo.nameZH ];
            [NSKeyedArchiver archiveRootObject:rootdic toFile:homePath];
        }
        
    }
    else
    {
        for (OWTFeedItemData* itemData in feedData.itemDatas)
        {
            OWTFeedItem* item = [_itemsByID objectForKey:itemData.itemID];
            if (item == nil)
            {
                item = [OWTFeedItem new];
                [_itemsByID setObject:item forKey:itemData.itemID];
                [_items addObject:item];
            }
            
            [item mergeWithData:itemData];
            _maxItemTimestamp = MAX(_maxItemTimestamp, item.timestamp);
            _minItemTimestamp = MIN(_minItemTimestamp, item.timestamp);
        }
    }
    
    [_items sortUsingSelector:@selector(compare:)];
}
- (void)refreshWithSuccess2:(void (^)())success
                    failure:(void (^)(NSError* error))failure
{
    
    [self fetchItemsFromID2:LONG_LONG_MAX
                       toID:0
                      count:kDefaultLoadItemNum
               dropOldItems:YES
                    success:success
                    failure:failure];
}

- (void)loadMoreWithSuccess2:(void (^)())success
                     failure:(void (^)(NSError* error))failure
{
    [self fetchItemsFromID2:_minItemTimestamp
                       toID:0
                      count:kDefaultLoadItemNum
               dropOldItems:NO
                    success:success
                    failure:failure];
}

- (void)fetchItemsFromID2:(long long)fromItemTimestamp
                     toID:(long long)toItemTimestamp
                    count:(int)count
             dropOldItems:(BOOL)dropOldItems
                  success:(void (^)())success
                  failure:(void (^)(NSError* error))failure
{
    RKObjectManager* om = [RKObjectManager sharedManager];
    NSDictionary *dict=@{@"max_item_timestamp" : [NSString stringWithFormat:@"%lld", fromItemTimestamp],@"min_item_timestamp" : [NSString stringWithFormat:@"%lld", toItemTimestamp],@"count" : [NSString stringWithFormat:@"%d",count]};
    [om getObject:nil
             path:[NSString stringWithFormat:@"gamepic/%@",_gameId]
       parameters:dict
          success:^(RKObjectRequestOperation* o, RKMappingResult* result) {
              [o logResponse];
              _minItemTimestamp=fromItemTimestamp;
              
              if (dropOldItems) {
                  
                  [_items removeAllObjects];
                  [_userInformations removeAllObjects];
                  [_activitiles removeAllObjects];
                  [_activComment removeAllObjects];
                  [_activLike removeAllObjects];
              }
              NSDictionary* resultObjects = result.dictionary;
              NSLog(@"%@",resultObjects);
              OWTUserManager* um = GetUserManager();
              for (OWTAsset *asset in resultObjects[@"assets"]) {
                  OWTAsset *_asset=[[OWTAsset alloc]init];
                  _asset=asset;
                  [_items addObject:_asset];
              }
              for (OWTUserData *user in  resultObjects[@"users"]) {
                  OWTUserData *user1=[[OWTUserData alloc]init];
                  user1=user;
                  [um registerUserData:user];
                  [_userInformations addObject:user1];
              }
              for (OWTActivityData *activity1 in  resultObjects[@"activities"]) {
                  OWTActivityData *activity=[[OWTActivityData alloc]init];
                  _minItemTimestamp=MIN(activity1.timestamp.intValue, _minItemTimestamp);
                  activity=activity1;
                  if (!dropOldItems) {
                      OWTActivityData *activity2=_activitiles[_activitiles.count-1];
                      if ([activity2.commentid isEqualToString:activity1.commentid]) {
                          continue;
                      }
                  }
                  [_activitiles addObject:activity];
              }
              for (LJComment *comment in resultObjects[@"activComment"]) {
                  LJComment *ljcomment=[[LJComment alloc]init];
                  ljcomment=comment;
                  [_activComment addObject:ljcomment];
              }
              for (LJLike *like in resultObjects[@"activLike"]) {
                  LJLike *ljLike=[[LJLike alloc]init];
                  ljLike=like;
                  [_activLike addObject:ljLike];
              }
              if (success) {
                  success();
              }
              if (dropOldItems) {
                  NSMutableArray *arr=[[NSMutableArray alloc]init];
                  [arr addObject:_items];
                  [arr addObject:_userInformations];
                  [arr addObject:_activComment];
                  [arr addObject:_activitiles];
                  [arr addObject:_activLike];
                  NSString *homeDictionary = NSHomeDirectory();//获取根目录
                  NSString *homePath  = [homeDictionary stringByAppendingString:@"/Documents/gameSquare.archiver"];//添加储存的文件名
                  BOOL flag = [NSKeyedArchiver archiveRootObject:arr toFile:homePath];
                  
              }
              
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

-(void)getResouceWithSuccess:(void (^)())success
{
    NSString *homeDictionary = NSHomeDirectory();//获取根目录
    NSString *homePath  = [homeDictionary stringByAppendingString:@"/Documents/atany.archiver"];//添加储存的文件名
    NSArray *arr=[NSKeyedUnarchiver unarchiveObjectWithFile:homePath];
    if (arr[0]) {
        [_items addObjectsFromArray:arr[0]];
        [_userInformations addObjectsFromArray:arr[1]];
        [_activitiles addObjectsFromArray:arr[3]];
        [_activComment addObjectsFromArray:arr[2]];
        [_activLike addObjectsFromArray:arr[4]];
        success();
    }
}
-(void)getResouceWithSuccess2:(void (^)())success
{
    NSString *homeDictionary = NSHomeDirectory();//获取根目录
    NSString *homePath  = [homeDictionary stringByAppendingString:@"/Documents/gameSquare.archiver"];//添加储存的文件名
    NSArray *arr=[NSKeyedUnarchiver unarchiveObjectWithFile:homePath];
    if (arr[0]) {
        [_items addObjectsFromArray:arr[0]];
        [_userInformations addObjectsFromArray:arr[1]];
        [_activitiles addObjectsFromArray:arr[3]];
        [_activComment addObjectsFromArray:arr[2]];
        [_activLike addObjectsFromArray:arr[4]];
        success();
    }
}

-(void)setSubCategoriesCacheData2Items:(NSString*)key
{
    NSString *homeDictionary = NSHomeDirectory();//获取根目录
    NSString *homePath  = [homeDictionary stringByAppendingString:@"/Documents/cacheSubCategorise.archiver"];
    NSDictionary *tmpDic = [NSKeyedUnarchiver unarchiveObjectWithFile:homePath];
    NSArray *result = [tmpDic objectForKey:key];
    if (result != nil) {
        _items = [NSMutableArray arrayWithArray:result];
    }
    
}

@end
