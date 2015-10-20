//
//  OWTAssetInfoView.h
//  Weitu
//
//  Created by Su on 4/23/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FSImageViewerViewController;
@interface OWTAssetInfoViewa : UICollectionReusableView
@property(strong, nonatomic) FSImageViewerViewController *imageViewController;
@property (nonatomic, strong) OWTAsset* asset;

@property (nonatomic, strong) void ((^downloadAction)());
@property (nonatomic, strong) void ((^collectAction)());
@property (nonatomic, strong) void ((^shareAction)());
@property(nonatomic,assign)BOOL canClick;

@property (nonatomic, strong) void ((^showAllCommentsAction)());

@property (nonatomic, strong) void ((^showOwnerUserAction)());

@property (nonatomic, strong) void ((^reportAction)());
@property (nonatomic, strong) void ((^showAction)());
@end
