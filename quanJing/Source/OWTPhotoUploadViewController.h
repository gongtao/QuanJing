//
//  OWTPhotoUploadViewController.h
//  Weitu
//
//  Created by Gongtao on 15/9/21.
//  Copyright © 2015年 SparkingSoft Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OWTPhotoUploadViewController : UITableViewController

@property (nonatomic, assign) BOOL isCameraImages;

@property (nonatomic, strong) NSMutableArray *imageInfos;

@property (nonatomic, copy) void (^doneAction)();
@property(nonatomic,copy)void(^cancelAction)();
@end
