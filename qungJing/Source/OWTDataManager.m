#import "OWTDataManager.h"
#import "OWTServerError.h"
#import "OWTAccessToken.h"
#import "OWTFeedInfoData.h"
#import "OWTFeedItemData.h"
#import "OWTFeedData.h"
#import "OWTAssetData.h"
#import "OWTCommentData.h"
#import "OWTImageInfo.h"
#import "OWTCategoryData.h"

#import "OWTUserData.h"
#import "OWTAlbumData.h"
#import "OWTAlbumItem.h"
#import "OWTUserAssetsInfoData.h"
#import "OWTUserFellowshipInfoData.h"
#import "OWTUserAlbumsInfoData.h"
#import "OWTUserSubscriptionInfoData.h"
#import "OWTUserPrivateInfoData.h"

#import "OWTActivityData.h"
#import "RKObjectMapping+Transforming.h"
#import "OStringArray.h"
#import <RestKit/CoreData.h>
#import <RestKit/Network/RKManagedObjectRequestOperation.h>
#import "LJComment.h"
#import "LJLike.h"
#if 0
static NSString* kWTBaseURL = @"http://castle.local:8080";
#elif 0
static NSString* kWTBaseURL = @"http://retina.local:8080";
#elif 0
static NSString* kWTBaseURL = @"http://127.0.0.1:8080";
#elif 0
static NSString* kWTBaseURL = @"http://weitu.xv57.com:8080";
//#elif 0
//static NSString* kWTBaseURL = @"http://api.tiankong.com/qjapi";//
#else
//static NSString* kWTBaseURL = @"http://api.tiankong.com/qjapi";//
//static NSString* kWTBaseURL = @"http://api.tiankong.com/qjapi";//
static NSString* kWTBaseURL = @"http://api.tiankong.com/qjapi";
#endif

#pragma mark -

@interface OWTDataManager ()

@end

@implementation OWTDataManager

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
    NSURL* rootURL = [NSURL URLWithString:kWTBaseURL];
    _objectManager = [RKObjectManager managerWithBaseURL:rootURL];
    [RKObjectManager setSharedManager:_objectManager];

    AFHTTPClient* client = [RKObjectManager sharedManager].HTTPClient;
    [client setDefaultHeader:@"Accept-Encoding" value:@"gzip, deflate"];

    [self setupCommonMappings];
    [self setupCommonResponseDescriptors];
    [self setupRestKitDebugging];
}

- (void)setupRestKitDebugging
{
#if 0
    RKLogConfigureByName("RestKit/Network", RKLogLevelTrace);
#endif
    
#if 0
    RKLogConfigureByName("RestKit/ObjectMapping", RKLogLevelTrace);
#endif
}

- (void)setupCommonMappings
{
    _serverErrorMapping = [RKObjectMapping mappingForClass:[OWTServerError class]];
    [_serverErrorMapping addAttributeMappingsFromArray:@[@"code", @"message"]];
    
    _imageInfoMapping = [RKObjectMapping mappingForClass:[OWTImageInfo class]];
    [_imageInfoMapping addAttributeMappingsFromArray:@[@"url", @"smallURL", @"primaryColorHex", @"width", @"height"]];
    
    _accessTokenMapping = [RKObjectMapping mappingForClass:[OWTAccessToken class]];
    [_accessTokenMapping addAttributeMappingsFromArray:@[@"tokenValue", @"expiresIn", @"isNewUser"]];

    _assetMapping = [RKObjectMapping mappingForClass:[OWTAssetData class]];
    [_assetMapping addAttributeMappingsFromArray:@[@"assetID",
                                                   @"caption",
                                                   @"oriPic",
                                                   @"webURL",
                                                   @"serial",
                                                   @"ownerUserID",
                                                   @"likedUserIDs",
                                                   @"commentNum",@"createTime",@"keywords",@"position"]];
    [_assetMapping addAttributeMappingsFromDictionary:@{@"privateAsset": @"isPrivate"}];
    [_assetMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"imageInfo"
                                                                                  toKeyPath:@"imageInfo"
                                                                                withMapping:_imageInfoMapping]];

    _commentMapping = [RKObjectMapping mappingForClass:[OWTCommentData class]];
    [_commentMapping addAttributeMappingsFromArray:@[@"commentID", @"userID", @"content", @"timestamp"]];
    
    [_assetMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"latestComments"
                                                                                  toKeyPath:@"latestCommentDatas"
                                                                                withMapping:_commentMapping]];
    
    _feedItemMapping = [RKObjectMapping mappingForClass:[OWTFeedItemData class]];
    [_feedItemMapping addAttributeMappingsFromArray:@[@"itemID", @"timestamp"]];
    [_feedItemMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"asset"
                                                                                     toKeyPath:@"assetData"
                                                                                   withMapping:_assetMapping]];
    
    _feedInfoMapping = [RKObjectMapping mappingForClass:[OWTFeedInfoData class]];
    [_feedInfoMapping addAttributeMappingsFromArray:@[@"feedID", @"nameZH", @"nameEN", @"lastUpdateTime", @"generation"]];

    _feedFragmentMapping = [RKObjectMapping mappingForClass:[OWTFeedData class]];
    [_feedFragmentMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"feedInfo"
                                                                                         toKeyPath:@"feedInfoData"
                                                                                       withMapping:_feedInfoMapping]];

    [_feedFragmentMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"items"
                                                                                         toKeyPath:@"itemDatas"
                                                                                       withMapping:_feedItemMapping]];

    _likedUserIDsMapping = [RKObjectMapping mappingForClass:[NSArray class]];
    [_likedUserIDsMapping addPropertyMapping:[RKAttributeMapping attributeMappingFromKeyPath:nil toKeyPath:@"likedUserIDs"]];

    _stringArrayMapping = [RKObjectMapping mappingForClass:[OStringArray class]];
    [_stringArrayMapping addPropertyMapping:[RKAttributeMapping attributeMappingFromKeyPath:@"strings" toKeyPath:@"strings"]];
    
    _categoryMapping = [RKObjectMapping mappingForClass:[OWTCategoryData class]];
    [_categoryMapping addAttributeMappingsFromArray:@[@"categoryID", @"categoryName",@"type",@"priority", @"feedID",@"GroupName",@"searchWords"]];
    [_categoryMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"coverImageInfo"
                                                                                     toKeyPath:@"coverImageInfo"
                                                                                   withMapping:_imageInfoMapping]];

    [self setupUserMappings];

    _activityMapping = [RKObjectMapping mappingForClass:[OWTActivityData class]];
    [_activityMapping addAttributeMappingsFromArray:@[@"timestamp", @"activityType", @"userID", @"subjectUserID", @"subjectAssetID",@"friendsOrFans"]];
    [_activityMapping addAttributeMappingsFromDictionary:@{@"id":@"commentid"}];
    _ljcommentMapping=[RKObjectMapping mappingForClass:[LJComment class]];
    [_ljcommentMapping addAttributeMappingsFromArray:@[@"activityId",@"content",@"pasttime",@"userid",@"replyuserid"]];
    _ljLikeMapping=[RKObjectMapping mappingForClass:[LJLike class]];
    [_ljLikeMapping addAttributeMappingsFromArray:@[@"activityid",@"likeDate",@"likeUserid"]];
}

- (void)setupUserMappings
{
    _userAssetsInfoMapping = [RKObjectMapping mappingForClass:[OWTUserAssetsInfoData class]];
    [_userAssetsInfoMapping addAttributeMappingsFromArray:@[@"publicAssetNum", @"privateAssetNum", @"likedAssetNum",@"lightbox"]];

    _userFellowshipInfoMapping = [RKObjectMapping mappingForClass:[OWTUserFellowshipInfoData class]];
    [_userFellowshipInfoMapping addAttributeMappingsFromArray:@[@"followingNum", @"followerNum", @"followingUserIDs"]];

    _albumMapping = [RKObjectMapping mappingForClass:[OWTAlbumData class]];
    [_albumMapping addAttributeMappingsFromArray:@[@"albumID",
                                                   @"albumName",
                                                   @"albumDescription",
                                                   @"categoryID",
                                                   @"albumCoverAssetID"]];

    _albumItemMapping = [RKObjectMapping mappingForClass:[OWTAlbumItem class]];
    [_albumItemMapping addAttributeMappingsFromArray:@[@"timestamp", @"assetID"]];

    _userAlbumsInfoMapping = [RKObjectMapping mappingForClass:[OWTUserAlbumsInfoData class]];
    [_userAlbumsInfoMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"albums"
                                                                                           toKeyPath:@"albumDatas"
                                                                                         withMapping:_albumMapping]];

    _userSubscriptionInfoMapping = [RKObjectMapping mappingForClass:[OWTUserSubscriptionInfoData class]];
    [_userSubscriptionInfoMapping addAttributeMappingsFromArray:@[@"subscribedCategoryIDs"]];

    _userPrivateInfoMapping = [RKObjectMapping mappingForClass:[OWTUserPrivateInfoData class]];
    [_userPrivateInfoMapping addAttributeMappingsFromArray:@[@"cellphone", @"email", @"password"]];

    _userMapping = [RKObjectMapping mappingForClass:[OWTUserData class]];
    [_userMapping addAttributeMappingsFromArray:@[@"userID", @"nickname", @"signature",@"Fans"]];

    [_userMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"avatarImageInfo"
                                                                                 toKeyPath:@"avatarImageInfo"
                                                                               withMapping:_imageInfoMapping]];

    [_userMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"assetsInfo"
                                                                                 toKeyPath:@"assetsInfoData"
                                                                               withMapping:_userAssetsInfoMapping]];
    
    [_userMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"fellowshipInfo"
                                                                                 toKeyPath:@"fellowshipInfoData"
                                                                               withMapping:_userFellowshipInfoMapping]];
    
    [_userMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"albumsInfo"
                                                                                 toKeyPath:@"albumsInfoData"
                                                                               withMapping:_userAlbumsInfoMapping]];
    
    [_userMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"subscriptionInfo"
                                                                                 toKeyPath:@"subscriptionInfoData"
                                                                               withMapping:_userSubscriptionInfoMapping]];
    
    [_userMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"privateInfo"
                                                                                 toKeyPath:@"privateInfoData"
                                                                               withMapping:_userPrivateInfoMapping]];

    _userMappingInversed = [_userMapping inverseMapping];
}

- (void)setupCommonResponseDescriptors
{
    RKResponseDescriptor* responseDescriptor;
    
    responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:_serverErrorMapping
                                                                      method:RKRequestMethodAny
                                                                 pathPattern:nil
                                                                     keyPath:@"error"
                                                                 statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [_objectManager addResponseDescriptor:responseDescriptor];
    
    responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:_feedInfoMapping
                                                                      method:RKRequestMethodAny
                                                                 pathPattern:nil
                                                                     keyPath:@"feedInfos"
                                                                 statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [_objectManager addResponseDescriptor:responseDescriptor];
    
    responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:_feedFragmentMapping
                                                                      method:RKRequestMethodAny
                                                                 pathPattern:nil
                                                                     keyPath:@"feedFragment"
                                                                 statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [_objectManager addResponseDescriptor:responseDescriptor];
    
    responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:_userMapping
                                                                      method:RKRequestMethodAny
                                                                 pathPattern:nil
                                                                     keyPath:@"relatedUsers"
                                                                 statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [_objectManager addResponseDescriptor:responseDescriptor];
    
    responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:_userMapping
                                                                      method:RKRequestMethodAny
                                                                 pathPattern:nil
                                                                     keyPath:@"users"
                                                                 statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [_objectManager addResponseDescriptor:responseDescriptor];
    
    responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:_assetMapping
                                                                      method:RKRequestMethodAny
                                                                 pathPattern:nil
                                                                     keyPath:@"asset"
                                                                 statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [_objectManager addResponseDescriptor:responseDescriptor];
    
    responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:_assetMapping
                                                                      method:RKRequestMethodAny
                                                                 pathPattern:nil
                                                                     keyPath:@"assets"
                                                                 statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [_objectManager addResponseDescriptor:responseDescriptor];
    
    responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:_assetMapping
                                                                      method:RKRequestMethodAny
                                                                 pathPattern:nil
                                                                     keyPath:@"relatedAssets"
                                                                 statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [_objectManager addResponseDescriptor:responseDescriptor];
    
    responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:_commentMapping
                                                                      method:RKRequestMethodAny
                                                                 pathPattern:nil
                                                                     keyPath:@"comment"
                                                                 statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [_objectManager addResponseDescriptor:responseDescriptor];
    
    responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:_commentMapping
                                                                      method:RKRequestMethodAny
                                                                 pathPattern:nil
                                                                     keyPath:@"comments"
                                                                 statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [_objectManager addResponseDescriptor:responseDescriptor];

    responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:_likedUserIDsMapping
                                                                      method:RKRequestMethodAny
                                                                 pathPattern:nil
                                                                     keyPath:nil
                                                                 statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [_objectManager addResponseDescriptor:responseDescriptor];

    responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:_stringArrayMapping
                                                                      method:RKRequestMethodAny
                                                                 pathPattern:nil
                                                                     keyPath:@"albumIDs"
                                                                 statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [_objectManager addResponseDescriptor:responseDescriptor];
    
    responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:_activityMapping
                                                                      method:RKRequestMethodAny
                                                                 pathPattern:nil
                                                                     keyPath:@"activities"
                                                                 statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [_objectManager addResponseDescriptor:responseDescriptor];

    responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:_userAlbumsInfoMapping
                                                                      method:RKRequestMethodAny
                                                                 pathPattern:nil
                                                                     keyPath:@"albumsInfo"
                                                                 statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [_objectManager addResponseDescriptor:responseDescriptor];

    responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:_albumMapping
                                                                      method:RKRequestMethodAny
                                                                 pathPattern:nil
                                                                     keyPath:@"album"
                                                                 statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [_objectManager addResponseDescriptor:responseDescriptor];
    
    responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:_assetMapping
                                                                      method:RKRequestMethodAny
                                                                 pathPattern:nil
                                                                     keyPath:@"recommendedUserAssets"
                                                                 statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [_objectManager addResponseDescriptor:responseDescriptor];
    responseDescriptor=[RKResponseDescriptor responseDescriptorWithMapping:_ljcommentMapping method:RKRequestMethodAny pathPattern:nil keyPath:@"activComment" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [_objectManager addResponseDescriptor:responseDescriptor];
    responseDescriptor=[RKResponseDescriptor responseDescriptorWithMapping:_ljLikeMapping method:RKRequestMethodAny pathPattern:nil keyPath:@"activLike" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [_objectManager addResponseDescriptor:responseDescriptor];
   
}
//每日一图
//http://api.tiankong.com/qjapi/DailyPic
//
//标签
//http://api.tiankong.com/qjapi/homepage
@end
