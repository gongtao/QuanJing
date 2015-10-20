//
//  OWTPhotoUploadTagView.h
//  Weitu
//
//  Created by Gongtao on 15/9/22.
//  Copyright © 2015年 SparkingSoft Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kPhotoUploadTagViewDefaultHeight        119.0

@protocol OWTPhotoUploadTagViewDelegate <NSObject>

- (void)didTagsValueChanged:(NSString *)tag;

@end

@interface OWTPhotoUploadTagView : UIView

@property (nonatomic, strong) UITextField *textField;

@property (nonatomic, strong) UIButton *defaultListBtn;

@property (nonatomic, strong) UIImageView *textFieldBgView;

@property (nonatomic, strong) UIView *selectedView;

@property (nonatomic, weak) id<OWTPhotoUploadTagViewDelegate> delegate;

@property (nonatomic, strong) void (^showDefaultList)();

+ (CGFloat)heightFromTagString:(NSString *)tagStr width:(CGFloat)width font:(UIFont *)font;

- (void)setTagStr:(NSString *)tagStr;

- (void)updateTagButtons;

- (NSString *)photoUploadTags;

- (void)addTagStr:(NSString *)tagStr;

@end
