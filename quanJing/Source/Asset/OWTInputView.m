//
//  OWTInputView.m
//  Weitu
//
//  Created by Su on 4/25/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import "OWTInputView.h"
#import <QBFlatButton/QBFlatButton.h>

@interface OWTInputView ()

@property (nonatomic, strong) IBOutlet QBFlatButton* sendButton;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint* heightConstraint;

@end

@implementation OWTInputView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self awakeFromNib];
    }
    return self;
}

- (void)awakeFromNib
{
    self.textView.delegate = self;
    self.textView.autoresizesVertically = YES;
    self.textView.minimumHeight = 32.0f;
    self.textView.maximumHeight = 120.0f;
    self.textView.layer.cornerRadius = 5;
    self.textView.placeholder = @"请输入评论";

    self.textView.layer.borderWidth = 1.0f;
    self.textView.layer.borderColor = [[UIColor lightGrayColor] CGColor];

    [_sendButton setSurfaceColor:GetThemer().themeColor];
    [_sendButton setSideColor:[UIColor clearColor]];
    _sendButton.height = 0;
    _sendButton.depth = 0;
}

- (IBAction)sendButtonPressed:(id)sender
{
    if (_sendAction != nil)
    {
        _sendAction();
    }
}

- (void)textView:(EAMTextView *)textView willChangeFromHeight:(CGFloat)oldHeight toHeight:(CGFloat)newHeight
{
    _heightConstraint.constant = newHeight;
    [self setNeedsLayout];
    [self setNeedsUpdateConstraints];
}

- (NSString*)text
{
    return _textView.text;
}

- (void)setText:(NSString *)text
{
    [_textView setText:text];
}

@end
