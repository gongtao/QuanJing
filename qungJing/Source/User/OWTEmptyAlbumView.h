//
//  OWTEmptyAlbumViewCon.h
//  Weitu
//
//  Created by Su on 8/25/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OWTEmptyAlbumView : UICollectionReusableView

@property (nonatomic, strong) void (^createAlbumAction)();
@property (nonatomic, strong) void (^uploadPhotoAction)();

@end
