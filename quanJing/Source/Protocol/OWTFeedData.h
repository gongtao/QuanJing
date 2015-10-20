#pragma once

#import "OWTFeedInfoData.h"

@interface OWTFeedData : NSObject

@property (nonatomic, strong) OWTFeedInfoData* feedInfoData;
@property (nonatomic, copy) NSArray* itemDatas;

@end
