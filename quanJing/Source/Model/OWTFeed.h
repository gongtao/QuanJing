#pragma once

#import "OWTFeedInfo.h"

@interface OWTFeed : NSObject

@property (nonatomic, strong, readonly) OWTFeedInfo* feedInfo;
@property (nonatomic, readonly) NSArray* items;
@property  (nonatomic,readonly)   NSMutableArray *userInformations;
@property(nonatomic,readonly)NSMutableArray *activitiles;
@property (nonatomic, readonly) NSString* feedID;
@property (nonatomic, readonly) NSString* nameZH;
@property (nonatomic, readonly) NSString* nameEN;
@property (nonatomic, readonly) NSDate* lastUpdateTime;
@property (nonatomic, readonly) long generation;
@property(nonatomic,readonly)NSMutableArray *activComment;
@property(nonatomic,readonly)NSMutableArray *activLike;
@property(nonatomic,copy)NSString *gameId;
- (id)initWithFeedInfo:(OWTFeedInfo*)feedInfo;

- (void)refreshWithSuccess:(void (^)())success
                   failure:(void (^)(NSError* error))failure;

- (void)loadMoreWithSuccess:(void (^)())success
                    failure:(void (^)(NSError* error))failure;

- (void)fetchItemsFromID:(long long)fromItemID
                    toID:(long long)toItemID
                   count:(int)count
            dropOldItems:(BOOL)dropOldItems
                 success:(void (^)())success
                 failure:(void (^)(NSError* error))failure;
-(void)fetchItemsFromID:(long long)fromItemID withobject:(NSString*)userID toID:(long long)toItemID count:(int)count dropOldItems:(BOOL)dropOldItems success:(void (^)())success failure:(void (^)(NSError *))failure;
- (void)refreshWithSuccess1:(void (^)())success
                   failure:(void (^)(NSError* error))failure;

- (void)loadMoreWithSuccess1:(void (^)())success
                    failure:(void (^)(NSError* error))failure;

- (void)fetchItemsFromID1:(long long)fromItemID
                    toID:(long long)toItemID
                   count:(int)count
            dropOldItems:(BOOL)dropOldItems
                 success:(void (^)())success
                 failure:(void (^)(NSError* error))failure;
-(void)fetchItemsFromID1:(long long)fromItemID withobject:(NSString*)userID toID:(long long)toItemID count:(int)count dropOldItems:(BOOL)dropOldItems success:(void (^)())success failure:(void (^)(NSError *))failure;
-(void)getResouceWithSuccess:(void (^)())success;
- (void)refreshWithSuccess2:(void (^)())success
                    failure:(void (^)(NSError* error))failure;

- (void)loadMoreWithSuccess2:(void (^)())success
                     failure:(void (^)(NSError* error))failure;

- (void)fetchItemsFromID2:(long long)fromItemID
                     toID:(long long)toItemID
                    count:(int)count
             dropOldItems:(BOOL)dropOldItems
                  success:(void (^)())success
                  failure:(void (^)(NSError* error))failure;
-(void)fetchItemsFromID2:(long long)fromItemID withobject:(NSString*)userID toID:(long long)toItemID count:(int)count dropOldItems:(BOOL)dropOldItems success:(void (^)())success failure:(void (^)(NSError *))failure;
-(void)getResouceWithSuccess2:(void (^)())success;
-(void)setSubCategoriesCacheData2Items:(NSString*)key;

@end
