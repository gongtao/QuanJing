//
//  CustomLocalAblumAssertVC.h
//  Weitu
//
//  Created by denghs on 15/6/12.
//  Copyright (c) 2015年 SparkingSoft Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "AGImagePickerController.h"

@interface CustomLocalAblumAssertVC :UIViewController

@property (ag_weak, readonly) NSMutableArray *assetsGroups;

// change strong to weak, springox(20140422)
@property (ag_weak) AGImagePickerController *imagePickerController;

- (id)initWithImagePickerController:(AGImagePickerController *)imagePickerController;

- (void)pushFirstAssetsController;

@end