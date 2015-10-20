//
//  OThumbListViewCon.h
//  Weitu
//
//  Created by Su on 5/31/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>


@class FSImageViewerViewController;
@interface OThumbnailListViewCon : UICollectionViewController<UICollectionViewDataSource,UICollectionViewDelegate>

@property (nonatomic, copy) NSArray* thumbImages;
@property (nonatomic, copy) NSArray* thumbImageInfos;
@property (nonatomic,strong)FSImageViewerViewController*imageViewController;
- (id)initWithDefaultLayout;

@end
