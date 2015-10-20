//
//  OWTPhotoUploadTagButton.m
//  Weitu
//
//  Created by Gongtao on 15/9/22.
//  Copyright © 2015年 SparkingSoft Co., Ltd. All rights reserved.
//

#import "OWTPhotoUploadTagButton.h"

@interface OWTPhotoUploadTagButton () {
    UILabel *_titleLabel;
}

@end

@implementation OWTPhotoUploadTagButton

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _imageView = [[UIImageView alloc] init];
        _imageView.userInteractionEnabled = NO;
        [self addSubview:_imageView];
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:13.0];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.userInteractionEnabled = NO;
        [self addSubview:_titleLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect frame = self.bounds;
    _titleLabel.frame = CGRectMake(4.0, 0.0, frame.size.width - 30.0, frame.size.height);
    _imageView.frame = frame;
}

- (void)setTitle:(NSString *)title {
    _title = title;
    _titleLabel.text = title;
}

@end
