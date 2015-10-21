//
//  OWTAssetCategoryManager.m
//  Weitu
//
//  Created by Su on 5/8/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import "OWTCategoryManagerlife.h"
#import "OWTDataManager.h"
#import "OWTServerError.h"
#import "OWTUserSubscriptionInfoData.h"
#import "SVProgressHUD+WTError.h"
#import "OWTUserManager.h"

@interface OWTCategoryManagerlife()

@property (nonatomic, strong) NSDate* lastRefreshTime;

@end

@implementation OWTCategoryManagerlife

@synthesize categories = _categories;

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
    _cateBeautityful=[[NSMutableArray alloc]init];
    [self setupObjectMapping];
}

- (void)setupObjectMapping
{
    OWTDataManager* dm = GetDataManager();
    
    RKResponseDescriptor* responseDescriptor;
    responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:dm.categoryMapping
                                                                      method:RKRequestMethodGET | RKRequestMethodPOST
                                                                 pathPattern:nil
                                                                     keyPath:@"categories"
                                                                 statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
//    responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:dm.categoryMapping
//                                                                      method:RKRequestMethodGET | RKRequestMethodPOST
//                                                                 pathPattern:nil
//                                                                     keyPath:@"life"
//                                                                 statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [[RKObjectManager sharedManager] addResponseDescriptor:responseDescriptor];

    responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:dm.userSubscriptionInfoMapping
                                                                      method:RKRequestMethodGET | RKRequestMethodPOST
                                                                 pathPattern:nil
                                                                     keyPath:@"subscriptionInfo"
                                                                 statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [[RKObjectManager sharedManager] addResponseDescriptor:responseDescriptor];
}

- (BOOL)isCategorySubscribedByCurrentUser:(OWTCategory*)category
{
    OWTUser* user = GetUserManager().currentUser;
    if (user == nil)
    {
        return NO;
    }

    OWTUserSubscriptionInfo* subscriptionInfo = user.subscriptionInfo;
    if (subscriptionInfo == nil)
    {
        return NO;
    }

    return [subscriptionInfo.subscribedCategoryIDs containsObject:category.categoryID];
}

- (BOOL)refreshIfNeededCategoriesWithSuccess:(void(^)())success
                                     failure:(void(^)(NSError* error))failure
{
    if (![self isRefreshNeeded])
    {
        return NO;
    }

    [self refreshCategoriesWithSuccess:success failure:failure];

    return YES;
}

- (BOOL)isRefreshNeeded
{
    if (_categories == nil)
    {
        return YES;
    }
    
    if (_lastRefreshTime == nil)
    {
        return YES;
    }

    NSTimeInterval elapsedTimeInterval = [[NSDate date] timeIntervalSinceDate:_lastRefreshTime];
    if (elapsedTimeInterval > 3600)
    {
        return YES;
    }

    return NO;
}

- (void)refreshCategoriesWithSuccess:(void(^)())success
                             failure:(void(^)(NSError* error))failure
{
    _lastRefreshTime = [NSDate date];
    NSLog(@"_keyPath =%@",_keyPath);
    if (_keyPath ==0) {
        RKObjectManager* om = [RKObjectManager sharedManager];
        [om getObject:nil
                 path:@"cdn2/index-WonderfulLife_new4search"
           parameters:nil
              success:^(RKObjectRequestOperation* o, RKMappingResult* result) {
                  [o logResponse];
                  
                  NSDictionary* resultObjects = result.dictionary;
                  OWTServerError* error = resultObjects[@"error"];
                  if (error != nil)
                  {
                      if (failure != nil) { failure(MakeError((EWTErrorCodes)error.code)); }
                      return;
                  }
                  
                  NSArray* categorieDatas = resultObjects[@"categories"];
                  //保存数据
                  NSString *homeDictionary = NSHomeDirectory();//获取根目录
                  NSString *homePath  = [homeDictionary stringByAppendingString:@"/Documents/home1.archiver"];//添加储存的文件名
                  BOOL flag = [NSKeyedArchiver archiveRootObject:categorieDatas toFile:homePath];
                  if (categorieDatas == nil)
                  {
                      if (failure != nil) { failure(MakeError(kWTErrorGeneral)); }
                      return;
                  }
                  
                  [self updateWithCategoryDatas:categorieDatas];
                  if (success != nil) { success(); }
              }
              failure:^(RKObjectRequestOperation* o, NSError* error) {
                  [o logResponse];
                  if (failure != nil) { failure(error); }
              }
         ];
        [om getObject:nil
                 path:@"cdn2/index-BeautyOfLife"
           parameters:nil
              success:^(RKObjectRequestOperation* o, RKMappingResult* result) {
                  [o logResponse];
                  
                  NSDictionary* resultObjects = result.dictionary;
                  OWTServerError* error = resultObjects[@"error"];
                  if (error != nil)
                  {
                      if (failure != nil) { failure(MakeError((EWTErrorCodes)error.code)); }
                      return;
                  }
                  
                  NSArray* categorieDatas = resultObjects[@"categories"];
                  //保存数据
                  NSString *homeDictionary = NSHomeDirectory();//获取根目录
                  NSString *homePath  = [homeDictionary stringByAppendingString:@"/Documents/home2.archiver"];//添加储存的文件名
                  BOOL flag = [NSKeyedArchiver archiveRootObject:categorieDatas toFile:homePath];
                  if (categorieDatas == nil)
                  {
                      if (failure != nil) { failure(MakeError(kWTErrorGeneral)); }
                      return;
                  }
                  
                  [self updateWithCategoryDatas1:categorieDatas];
                  if (success != nil) { success(); }
              }
              failure:^(RKObjectRequestOperation* o, NSError* error) {
                  [o logResponse];
                  if (failure != nil) { failure(error); }
              }
         ];


    }
}

- (void)updateWithCategoryDatas:(NSArray*)categorieDatas
{
    NSMutableArray* categories = [NSMutableArray arrayWithCapacity:categorieDatas.count];

    for (OWTCategoryData* categoryData in categorieDatas)
    {
        OWTCategory* category = [OWTCategory new];
        [category mergeWithData:categoryData];
        [categories addObject:category];
    }

    [categories sortUsingComparator:^(OWTCategory* lhs, OWTCategory* rhs) {
        if (lhs.priority > rhs.priority) { return NSOrderedAscending; }
        if (lhs.priority == rhs.priority) { return NSOrderedSame; }
        return NSOrderedDescending;
    }];

    _categories = categories;
}
- (void)updateWithCategoryDatas1:(NSArray*)categorieDatas
{
    NSMutableArray* categories = [NSMutableArray arrayWithCapacity:categorieDatas.count];
    
    for (OWTCategoryData* categoryData in categorieDatas)
    {
        OWTCategory* category = [OWTCategory new];
        [category mergeWithData:categoryData];
        [categories addObject:category];
    }
    
    [categories sortUsingComparator:^(OWTCategory* lhs, OWTCategory* rhs) {
        if (lhs.priority > rhs.priority) { return NSOrderedAscending; }
        if (lhs.priority == rhs.priority) { return NSOrderedSame; }
        return NSOrderedDescending;
    }];
    [_cateBeautityful removeAllObjects];
    [_cateBeautityful addObjectsFromArray:categories];
}

- (void)modifyCategory:(OWTCategory*)category
          subscription:(BOOL)isSubscribing
               success:(void(^)())success
               failure:(void(^)(NSError* error))failure
{
    NSString* action = isSubscribing ? @"subscribe" : @"unsubscribe";
    [self modifyCategorySubscription:category action:action success:success failure:failure];
}

- (void)modifyCategorySubscription:(OWTCategory*)category
                            action:(NSString*)action
                           success:(void(^)())success
                           failure:(void(^)(NSError* error))failure
{
    RKObjectManager* om = [RKObjectManager sharedManager];
    [om postObject:nil
              path:[NSString stringWithFormat:@"categories/subscriptions"]
        parameters:@{ @"action" : action,
                      @"category_id" : category.categoryID }
           success:^(RKObjectRequestOperation* o, RKMappingResult* result) {
               [o logResponse];

               NSDictionary* resultObjects = result.dictionary;
               OWTServerError* error = resultObjects[@"error"];
               if (error != nil)
               {
                   if (failure != nil) { failure([error toNSError]); }
                   return;
               }

               OWTUserSubscriptionInfoData* subscriptionInfoData = resultObjects[@"subscriptionInfo"];
               if (subscriptionInfoData != nil)
               {
                   OWTUser* user = GetUserManager().currentUser;
                   if (user != nil)
                   {
                       [user mergeWithSubscriptionInfoData:subscriptionInfoData];
                   }
               }

               if (success != nil) { success(); }
           }
           failure:^(RKObjectRequestOperation* o, NSError* error) {
               [o logResponse];
               if (failure != nil) { failure(error); }
           }
     ];
}
- (void)getResouceData:(void(^)())success;
{
    NSString *homeDictionary = NSHomeDirectory();//获取根目录
    NSString *homePath  = [homeDictionary stringByAppendingString:@"/Documents/home1.archiver"];//添加储存的文件名
    NSArray *arr=[NSKeyedUnarchiver unarchiveObjectWithFile:homePath];
    if (arr!=nil) {
     [self updateWithCategoryDatas:arr];
        success();
    }
    NSString *homePath1=[homeDictionary stringByAppendingString:@"/Documents/home2.archiver"];
    NSArray *arr1=[NSKeyedUnarchiver unarchiveObjectWithFile:homePath1];
    if (arr!=nil) {
        [self updateWithCategoryDatas1:arr1];
        success();
    }

}
@end