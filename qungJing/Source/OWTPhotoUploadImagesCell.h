//
//  OWTPhotoUploadImagesCell.h
//  Weitu
//
//  Created by Gongtao on 15/9/21.
//  Copyright © 2015年 SparkingSoft Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol OWTPhotoUploadImagesCellDelegate;

@interface OWTPhotoUploadImagesCell : UITableViewCell

@property (nonatomic, strong) NSMutableArray *imageInfos;

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, weak) id<OWTPhotoUploadImagesCellDelegate> delegate;

@end

@protocol OWTPhotoUploadImagesCellDelegate <NSObject>

- (void)didSelectPhotoUploadImageIndex:(NSUInteger)index;

- (void)didSelectPhotoUploadAddButton;

@end
