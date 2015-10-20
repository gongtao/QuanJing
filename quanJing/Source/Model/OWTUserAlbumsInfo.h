//
//  OWTUserAlbumsInfo.h
//  Weitu
//
//  Created by Su on 6/27/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import "OWTUserAlbumsInfoData.h"
#import "OWTAlbum.h"

@interface OWTUserAlbumsInfo : NSObject

@property (nonatomic, copy) NSString* userID;
@property (nonatomic, strong) NSMutableArray* albums;

- (void)mergeWithData:(OWTUserAlbumsInfoData*)albumsInfoData;
- (OWTAlbum*)albumWithID:(NSString*)albumID;

@end
