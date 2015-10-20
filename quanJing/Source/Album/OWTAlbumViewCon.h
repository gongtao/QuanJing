//
//  OWTAlbumViewCon.h
//  Weitu
//
//  Created by Su on 6/30/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OWaterFlowLayoutDataSource.h"
#import "XHRefreshControl.h"

@interface OWTAlbumViewCon : UIViewController

- (instancetype)initWithAlbum:(OWTAlbum*)album;

@property (nonatomic, strong) void (^onDeleteAction)();

@end
