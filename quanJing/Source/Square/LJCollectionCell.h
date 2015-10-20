//
//  LJCollectionCell.h
//  Weitu
//
//  Created by qj-app on 15/6/24.
//  Copyright (c) 2015年 SparkingSoft Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LJCollectionCell : UICollectionViewCell

@property(nonatomic,strong)UIImageView *imageView;
@property(nonatomic,strong)void(^touchImagecb)();
@end
