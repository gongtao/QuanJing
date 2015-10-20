//
//  OWTPhotoUploadImagesCell.m
//  Weitu
//
//  Created by Gongtao on 15/9/21.
//  Copyright © 2015年 SparkingSoft Co., Ltd. All rights reserved.
//

#import "OWTPhotoUploadImagesCell.h"
#import "OWTPhotoUploadImageCollectionCell.h"
#import "OWTImageInfo.h"

#import <AssetsLibrary/AssetsLibrary.h>

#define kPhotoUploadCellImageTag        100

@interface OWTPhotoUploadImagesCell () <UICollectionViewDataSource, UICollectionViewDelegate> {
    ALAssetsLibrary *_assetsLibrary;
}

@property (nonatomic, strong) UIView *lineView;

@end

@implementation OWTPhotoUploadImagesCell

static NSString *staticReuseIdentifier = @"cellIdentifier";

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        UIScreen *screen = [UIScreen mainScreen];
        CGFloat size = (screen.bounds.size.width - 35.0) / 4.0;
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.itemSize = CGSizeMake(size, size);
        layout.minimumInteritemSpacing = 5.0;
        layout.minimumLineSpacing = 5.0;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        [_collectionView registerClass:[OWTPhotoUploadImageCollectionCell class] forCellWithReuseIdentifier:staticReuseIdentifier];
        _collectionView.scrollEnabled = NO;
        _collectionView.allowsSelection = NO;
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.dataSource = self;
        [self.contentView addSubview:_collectionView];
        
        if ([ALAssetsLibrary authorizationStatus] == ALAuthorizationStatusAuthorized) {
            _assetsLibrary = [[ALAssetsLibrary alloc] init];
        }
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect frame = self.bounds;
    _collectionView.frame = CGRectMake(10.0, 0.0, frame.size.width - 20.0, frame.size.height - 10.0);
}

#pragma mark - Action

- (void)didTapButton:(UIButton *)button {
    // 获取按钮所在的cell
    OWTPhotoUploadImageCollectionCell *cell = (OWTPhotoUploadImageCollectionCell *)button.superview.superview;
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    NSUInteger count = 0;
    if (_imageInfos) {
        count = _imageInfos.count;
    }
    if (indexPath.row == count) {
        if ([self.delegate respondsToSelector:@selector(didSelectPhotoUploadAddButton)]) {
            [self.delegate didSelectPhotoUploadAddButton];
        }
    }
    else {
        if ([self.delegate respondsToSelector:@selector(didSelectPhotoUploadImageIndex:)]) {
            [self.delegate didSelectPhotoUploadImageIndex:indexPath.row];
        }
    }
}

#pragma mark - Property

- (void)setImageInfos:(NSMutableArray *)imageInfos {
    _imageInfos = imageInfos;
    [self.collectionView reloadData];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (_imageInfos) {
        return (_imageInfos.count >= 9 ? 9 : _imageInfos.count + 1);
    }
    return 1;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    OWTPhotoUploadImageCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:staticReuseIdentifier forIndexPath:indexPath];
    cell.imageView.image = nil;
    [cell.button addTarget:self action:@selector(didTapButton:) forControlEvents:UIControlEventTouchUpInside];
    if (!_imageInfos || indexPath.row >= _imageInfos.count) {
        // Add button
        cell.imageView.image = [UIImage imageNamed:@"上传图片添加按钮.png"];
    }
    else {
        // Image cell
        OWTImageInfo* imageInfo = _imageInfos[indexPath.row];
        if (imageInfo) {
            if (imageInfo.image) {
                cell.imageView.image = imageInfo.image;
            }
            else if (imageInfo.asset) {
                cell.imageView.image = [UIImage imageWithCGImage:[imageInfo.asset thumbnail]];
            }
            else {
                if (_assetsLibrary) {
                    [_assetsLibrary assetForURL:[NSURL URLWithString:imageInfo.url]
                                    resultBlock:^(ALAsset *asset) {
                                        cell.imageView.image = [UIImage imageWithCGImage:[asset thumbnail]];
                                    }
                                   failureBlock:^(NSError *error) {
                                   }];
                }
            }
        }
    }
    return cell;
}

@end
