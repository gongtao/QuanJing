//
//  OWTAssetViewCon.h
//  Weitu
//
//  Created by Su on 4/23/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OWaterFlowLayout.h"
#import "QJImageObject.h"
#import "QJUser.h"
#import "LJFeedWithUserProfileViewCon.h"
@class FSImageViewerViewController;
@interface OWTAssetViewCon : UIViewController <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, OWaterFlowLayoutDataSource>

@property(nonatomic, assign) BOOL isSquare;
@property(nonatomic, assign) BOOL isOpen;
@property(nonatomic, assign) BOOL isLike;
@property(strong, nonatomic) FSImageViewerViewController * imageViewController;
@property (nonatomic, strong) QJUser * user1;
- (instancetype)initWithAsset:(QJImageObject *)asset
	deletionAllowed:(BOOL)deletionAllowed
	onDeleteAction:(void (^)())onDeleteAction;
	
- (instancetype)initWithImageId:(QJImageObject *)imageModel imageType:(NSNumber *)imageType;

- (instancetype)initWithAsset:(QJImageObject *)asset initWithType:(NSInteger)type;

@end
