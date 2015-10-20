//
//  OWTPhotoUploadInfoViewCon.h
//  Weitu
//
//  Created by Su on 5/31/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>


@class FSImageViewerViewController;
@interface OWTPhotoUploadInfoViewCon : UITableViewController

@property (nonatomic, copy) NSArray* pendingUploadImages;
@property (nonatomic, copy) NSArray* pendingUploadImageInfos;
@property (nonatomic, strong) void (^doneAction)();
@property(nonatomic,strong)CLLocation *location;
@property(nonatomic,strong)NSString *Name;
@property (nonatomic,assign)NSInteger *Index;
@property (nonatomic,strong)FSImageViewerViewController*imageViewController;
- (id)initWithDefaultStyle;

@end
