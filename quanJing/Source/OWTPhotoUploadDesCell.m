//
//  OWTPhotoUploadDesCell.m
//  Weitu
//
//  Created by Gongtao on 15/9/21.
//  Copyright © 2015年 SparkingSoft Co., Ltd. All rights reserved.
//

#import "OWTPhotoUploadDesCell.h"
#import <UIColor+HexString.h>

#define kOWTPhotoUploadDesCellPlaceHolder           [UIColor colorWithHexString:@"#939298"]

@interface OWTPhotoUploadDesCell () {
    UIView *_upLineView;
    UIView *_downLineView;
}

@end

@implementation OWTPhotoUploadDesCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _textView = [[UITextView alloc] init];
        _textView.font = [UIFont systemFontOfSize:15.0];
        _textView.textContainerInset = UIEdgeInsetsMake(4.0, 5.0, 4.0, 5.0);
        _textView.showsVerticalScrollIndicator = NO;
        
        [self.contentView addSubview:_textView];
        
        _placeHolderLabel = [[UILabel alloc] init];
        _placeHolderLabel.font = [UIFont systemFontOfSize:15.0];
        _placeHolderLabel.text = @"添加描述";
        _placeHolderLabel.textColor = kOWTPhotoUploadDesCellPlaceHolder;
        [self.contentView addSubview:_placeHolderLabel];
        
        _upLineView = [[UIView alloc] init];
        _upLineView.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:_upLineView];
        
        _downLineView = [[UIView alloc] init];
        _downLineView.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:_downLineView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect frame = self.bounds;
    _textView.frame = CGRectMake(0.0, 5.0, frame.size.width, frame.size.height - 10.0);
    _placeHolderLabel.frame = CGRectMake(10.0, 8.0, frame.size.width - 20.0, 20.0);
}

@end
