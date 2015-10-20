//
//  OWTChannelManager.h
//  Weitu
//
//  Created by Su on 3/10/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OWTChannel.h"

extern NSString* kWTChannelIDDefault;
extern NSString* kWTChannelLatestUploads;
extern NSString* kWTChannelWallpaper;
extern NSString* kWTChannelFollowing;
extern NSString* kWTChannelSubscription;

@interface OWTChannelManager : NSObject

@property (nonatomic, readonly) OWTChannel* defaultChannel;
@property (nonatomic, readonly) NSArray* allChannels;

+ (OWTChannelManager*) one;

- (OWTChannel*)channelWithID:(NSString*)channelID;

- (void)refreshChannel:(OWTChannel*)channel
               success:(void (^)(OWTChannel* channel, BOOL hasMutated))successHandler
               failure:(void (^)(OWTChannel* channel, NSError* error))failureHandler;

- (void)fetchChannelItemsBackwardFromIndex:(NSInteger)startingIndex
                                numToFetch:(NSInteger)numToFetch
                                   success:(void (^)(OWTChannel* channel, NSInteger numFetched))successHandler
                                   failure:(void (^)(OWTChannel* channel, NSError* error))failureHandler;

@end
