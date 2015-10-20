//
//  OWTAlbumInfoEditViewCon.h
//  Weitu
//
//  Created by Su on 6/16/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OWTAlbumInfoEditViewCon : UITableViewController

- (id)initForCreation;
- (id)initForEditingAlbum:(OWTAlbum*)album;

@property (nonatomic, strong) void (^doneAction)(EWTDoneType doneType);

@end
