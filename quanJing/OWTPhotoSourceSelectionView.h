//
//  OWTPhotoSourceSelectionView.h
//  Weitu
//
//  Created by Su on 5/31/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OWTPhotoSourceSelectionView : UIView

@property (nonatomic, strong) void (^cameraSelectedAction)();
@property (nonatomic, strong) void (^albumSelectedAction)();

@end
