//
//  OWTPhotoUploadTagView.m
//  Weitu
//
//  Created by Gongtao on 15/9/22.
//  Copyright © 2015年 SparkingSoft Co., Ltd. All rights reserved.
//

#import "OWTPhotoUploadTagView.h"
#import "OWTPhotoUploadTagButton.h"

@interface OWTPhotoUploadTagView () {
    UIView *_tagsView;
    UIImageView *_textFieldIconView;
    NSArray *_imageArray;
    NSMutableArray *_tagsArray;
    NSMutableSet *_tagKeys;
}

@end

@implementation OWTPhotoUploadTagView

+ (CGFloat)heightFromTagString:(NSString *)tagStr width:(CGFloat)width font:(UIFont *)font {
    // 计算编辑tag界面的高度
    if (tagStr && tagStr.length > 0) {
        CGFloat height = 0.0;
        tagStr = [tagStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        __block NSArray *tags = [tagStr componentsSeparatedByString:@" "];
        __block NSInteger lineNum = 1;
        __block CGFloat spaceWidth = width;
        __block NSInteger num = 0;
        [tags enumerateObjectsUsingBlock:^(NSString *tag, NSUInteger idx, BOOL *stop) {
            CGRect frame = [tag boundingRectWithSize:CGSizeMake(NSUIntegerMax, NSUIntegerMax)
                                             options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading)
                                          attributes:@{NSFontAttributeName: font}
                                             context:nil];
            frame.size.width += 30.0;
            if (spaceWidth < frame.size.width) {
                if (num == 0) {
                    // 按钮占据整行
                    spaceWidth = width;
                    if (idx < tags.count - 1) {
                        // 不是最后一个按钮
                        lineNum++;
                    }
                }
                else {
                    lineNum++;
                    spaceWidth = width;
                    num = 0;
                    if (spaceWidth <= frame.size.width) {
                        // 按钮占据整行
                        if (idx < tags.count - 1) {
                            // 不是最后一个按钮
                            lineNum++;
                        }
                        spaceWidth = width;
                    }
                    else {
                        // 插入当前行
                        spaceWidth -= frame.size.width + 5.0;
                        num++;
                    }
                }
            }
            else {
                // 插入当前行
                spaceWidth -= frame.size.width + 5.0;
                num++;
            }
        }];
        height = 30.0 * lineNum + 55.0;
        if (height > kPhotoUploadTagViewDefaultHeight) {
            return height;
        }
    }
    return kPhotoUploadTagViewDefaultHeight;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        _textFieldBgView = [[UIImageView alloc] init];
        UIImage *image = [UIImage imageNamed:@"上传图片标签输入框.png"];
        _textFieldBgView.image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(12.0, 120.0, 12.0, 120.0)];
        [self addSubview:_textFieldBgView];
        
        _textFieldIconView = [[UIImageView alloc] init];
        _textFieldIconView.image = [UIImage imageNamed:@"上传图片标签icon_.png"];
        [self addSubview:_textFieldIconView];
        
        _defaultListBtn = [[UIButton alloc]init];
        [_defaultListBtn addTarget:self action:@selector(defaultTags:) forControlEvents:UIControlEventTouchDown];
        _defaultListBtn.backgroundColor = [UIColor darkGrayColor];
        _defaultListBtn.alpha = 0.3;
        [_defaultListBtn setTitle:@"#" forState:UIControlStateNormal];
        
        _textFieldBgView.userInteractionEnabled = YES;
        [_textFieldBgView addSubview:_defaultListBtn];
        
        _textField = [[UITextField alloc] init];
        _textField.placeholder = @"输入标签";
        _textField.font = [UIFont systemFontOfSize:13.0];
        _textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _textField.returnKeyType = UIReturnKeyDone;
        _textField.tintColor=[UIColor lightGrayColor];
        [self addSubview:_textField];
        _tagsView = [[UIView alloc] init];
        [self addSubview:_tagsView];
        
        _selectedView = [[UIView alloc] init];
        [self addSubview:_selectedView];
        [_selectedView setHidden:YES];
        
        _imageArray = @[@"红", @"黄", @"蓝"];
        _tagsArray = [[NSMutableArray alloc] init];
        _tagKeys = [[NSMutableSet alloc] init];
    }
    return self;
}

-(void)defaultTags:(UIButton*)sender
{
    NSLog(@"nima wozaizheli");
    _showDefaultList();
}
- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect frame = self.bounds;
    _textFieldBgView.frame = CGRectMake(10.0, 10.0, frame.size.width - 20.0, 30.0);
    _textFieldIconView.frame = CGRectMake(20.0, 19.0, 12.0, 12.0);
    _defaultListBtn.frame = CGRectMake(0, 0, 40-10, 30);
    _textField.frame = CGRectMake(42.0, 10.0, frame.size.width - 62.0, 30.0);
    _tagsView.frame = CGRectMake(10.0, 40.0, frame.size.width - 20.0, frame.size.height - 40.0);
    _selectedView.frame = CGRectMake(0.0, 30.0, frame.size.width - 20.0, 300);


}

#pragma mark - Private

- (void)addSingleTagStr:(NSString *)tagStr {
    if (!tagStr || tagStr.length == 0 || [_tagKeys containsObject:tagStr]) {
        return;
    }
    UIFont *font = [UIFont systemFontOfSize:13.0];
    CGRect frame = [tagStr boundingRectWithSize:CGSizeMake(NSUIntegerMax, NSUIntegerMax)
                                        options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading)
                                     attributes:@{NSFontAttributeName: font}
                                        context:nil];
    frame.size.width += 30.0;
    OWTPhotoUploadTagButton *button = [[OWTPhotoUploadTagButton alloc] initWithFrame:CGRectMake(0.0, 0.0, frame.size.width, 25.0)];
    [button addTarget:self action:@selector(deleteTag:) forControlEvents:UIControlEventTouchUpInside];
    button.title = tagStr;
    int value = arc4random() % 3;
    NSString *imgStr = [NSString stringWithFormat:@"上传图片tag%@.png", _imageArray[value]];
    UIImage *image = [UIImage imageNamed:imgStr];
    button.imageView.image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 2.0, 0.0, 27.0)];
    [_tagsView addSubview:button];
    [_tagsArray addObject:button];
    [_tagKeys addObject:tagStr];
}

#pragma mark - Action

- (void)deleteTag:(OWTPhotoUploadTagButton *)button {
    if (button.superview) {
        [button removeFromSuperview];
    }
    [_tagsArray removeObject:button];
    if ([self.delegate respondsToSelector:@selector(didTagsValueChanged:)]) {
        [self.delegate didTagsValueChanged:[self photoUploadTags]];
    }
}

#pragma mark - Property

- (void)setTagStr:(NSString *)tagStr {
    tagStr = [tagStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSArray *array = [_tagsView.subviews copy];
    [array enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL *stop) {
        [view removeFromSuperview];
    }];
    [_tagsArray removeAllObjects];
    
    // 计算编辑tag界面的高度
    if (tagStr && tagStr.length > 0) {
        __block NSArray *tags = [tagStr componentsSeparatedByString:@" "];
        __weak __typeof(self) weakSelf = self;
        [tags enumerateObjectsUsingBlock:^(NSString *tag, NSUInteger idx, BOOL *stop) {
            [weakSelf addSingleTagStr:tag];
        }];
    }
}

#pragma mark - Public

- (NSString *)photoUploadTags {
    NSMutableArray *tags = [[NSMutableArray alloc] init];
    [_tagsArray enumerateObjectsUsingBlock:^(OWTPhotoUploadTagButton *button, NSUInteger idx, BOOL *stop) {
        [tags addObject:button.title];
    }];
    NSString *str = [tags componentsJoinedByString:@" "];
    str = [NSString stringWithFormat:@" %@ ", str];
    return str;
}

- (void)updateTagButtons {
    CGFloat width = self.frame.size.width - 20.0;
    __block CGFloat spaceWidth = width;
    __block NSInteger num = 0;
    __block CGFloat x = 0.0;
    __block CGFloat y = 10.0;
    NSInteger count = _tagsArray.count;
    [_tagsArray enumerateObjectsUsingBlock:^(OWTPhotoUploadTagButton *button, NSUInteger idx, BOOL *stop) {
        CGRect frame = button.frame;
        if (spaceWidth < frame.size.width) {
            if (num == 0) {
                // 按钮占据整行
                button.frame = CGRectMake(x, y, frame.size.width, frame.size.height);
                spaceWidth = width;
                if (idx < count - 1) {
                    // 不是最后一个按钮
                    x = 0.0;
                    y += 30.0;
                }
            }
            else {
                x = 0.0;
                y += 30.0;
                spaceWidth = width;
                num = 0;
                if (spaceWidth <= frame.size.width) {
                    // 按钮占据整行
                    button.frame = CGRectMake(x, y, frame.size.width, frame.size.height);
                    if (idx < count - 1) {
                        // 不是最后一个按钮
                        x = 0.0;
                        y += 30.0;
                    }
                    spaceWidth = width;
                }
                else {
                    // 插入当前行
                    button.frame = CGRectMake(x, y, frame.size.width, frame.size.height);
                    x += frame.size.width + 5.0;
                    spaceWidth -= frame.size.width + 5.0;
                    num++;
                }
            }
        }
        else {
            // 插入当前行
            button.frame = CGRectMake(x, y, frame.size.width, frame.size.height);
            x += frame.size.width + 5.0;
            spaceWidth -= frame.size.width + 5.0;
            num++;
        }
    }];
}

- (void)addTagStr:(NSString *)tagStr {
    // 计算编辑tag界面的高度
    if (tagStr && tagStr.length > 0) {
        tagStr = [tagStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        if (tagStr && tagStr.length > 0) {
            __block NSArray *tags = [tagStr componentsSeparatedByString:@" "];
            __weak __typeof(self) weakSelf = self;
            [tags enumerateObjectsUsingBlock:^(NSString *tag, NSUInteger idx, BOOL *stop) {
                [weakSelf addSingleTagStr:tag];
            }];
            
            if ([self.delegate respondsToSelector:@selector(didTagsValueChanged:)]) {
                [self.delegate didTagsValueChanged:[self photoUploadTags]];
            }
        }
    }
}

@end
