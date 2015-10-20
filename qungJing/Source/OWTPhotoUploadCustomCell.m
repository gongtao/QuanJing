//
//  OWTPhotoUploadCustomCell.m
//  Weitu
//
//  Created by Gongtao on 15/9/21.
//  Copyright © 2015年 SparkingSoft Co., Ltd. All rights reserved.
//

#import "OWTPhotoUploadCustomCell.h"

#import <UIColor+HexString.h>

#define kPhotoUploadCellLineBgColor     [UIColor colorWithHexString:@"#dadada"]
#define kPhotoUploadCellSwitchColor     [UIColor colorWithHexString:@"#fb0c09"]

@implementation OWTPhotoUploadCustomCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _upLineView = [[UIView alloc] init];
        _upLineView.backgroundColor = kPhotoUploadCellLineBgColor;
        [self.contentView addSubview:_upLineView];
        
        _customSwitch = [[KLSwitch alloc] initWithFrame:CGRectMake(0.0, 0.0, 49.0, 31.0)];
        [_customSwitch setOnTintColor:kPhotoUploadCellSwitchColor];
        self.accessoryView = _customSwitch;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect frame = self.bounds;
    self.textLabel.frame = CGRectMake(30.0, 0.0, frame.size.width - 40.0, frame.size.height);
    if (self.imageView) {
        CGSize size = CGSizeZero;
        if (self.imageView.image) {
            CGFloat scale = [UIScreen mainScreen].scale;
            size = self.imageView.image.size;
            size = CGSizeMake(size.width / scale, size.height / scale);
        }
        self.imageView.frame = CGRectMake(10.0, (frame.size.height - size.height) / 2.0, size.width, size.height);
    }
    self.upLineView.frame = CGRectMake(10.0, 0.0, frame.size.width - 10.0, 1.0);
}

@end
