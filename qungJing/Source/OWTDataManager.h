#pragma once

#import <RestKit/RestKit.h>

@interface OWTDataManager : NSObject

@property (nonatomic, strong, readonly) RKObjectMapping* serverErrorMapping;

@property (nonatomic, strong, readonly) RKObjectMapping* userMapping;

@property (nonatomic, strong, readonly) RKObjectMapping* userAssetsInfoMapping;
@property (nonatomic, strong, readonly) RKObjectMapping* userFellowshipInfoMapping;
@property (nonatomic, strong, readonly) RKObjectMapping* userAlbumsInfoMapping;
@property (nonatomic, strong, readonly) RKObjectMapping* userSubscriptionInfoMapping;
@property (nonatomic, strong, readonly) RKObjectMapping* userPrivateInfoMapping;

@property (nonatomic, strong, readonly) RKObjectMapping* albumMapping;
@property (nonatomic, strong, readonly) RKObjectMapping* albumItemMapping;

@property (nonatomic, strong, readonly) RKObjectMapping* userMappingInversed;
@property (nonatomic, strong, readonly) RKObjectMapping* accessTokenMapping;

@property (nonatomic, strong, readonly) RKObjectMapping* imageInfoMapping;
@property (nonatomic, strong, readonly) RKObjectMapping* assetMapping;
@property (nonatomic, strong, readonly) RKObjectMapping* commentMapping;
@property (nonatomic, strong, readonly) RKObjectMapping* feedItemMapping;
@property (nonatomic, strong, readonly) RKObjectMapping* feedInfoMapping;
@property (nonatomic, strong, readonly) RKObjectMapping* feedFragmentMapping;
@property (nonatomic, strong, readonly) RKObjectMapping* likedUserIDsMapping;
@property (nonatomic, strong, readonly) RKObjectMapping* categoryMapping;
@property (nonatomic, strong, readonly) RKObjectMapping* activityMapping;
@property (nonatomic, strong, readonly) RKObjectMapping* stringArrayMapping;

@property (nonatomic, strong, readonly) RKObjectManager* objectManager;
@property(nonatomic,strong,readonly)RKObjectMapping *ljcommentMapping;
@property(nonatomic,strong,readonly)RKObjectMapping *ljLikeMapping;
- (id)init;

@end
