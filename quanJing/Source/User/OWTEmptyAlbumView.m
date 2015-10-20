//
//  OWTEmptyAlbumViewCon.m
//  Weitu
//
//  Created by Su on 8/25/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import "OWTEmptyAlbumView.h"
#import <QBFlatButton/QBFlatButton.h>

@interface OWTEmptyAlbumView ()
{
    IBOutlet QBFlatButton* _createAlbumButton;
    IBOutlet QBFlatButton* _uploadPhotoButton;
}

@end

@implementation OWTEmptyAlbumView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self != nil)
    {
        
    }
    return self;
}

- (void)awakeFromNib
{
    NSArray* buttons = @[ _createAlbumButton, _uploadPhotoButton ];

    for (QBFlatButton* button in buttons)
    {
        button.cornerRadius = 5;
        button.height = 0;
        button.depth = 0;
        button.borderColor = [UIColor clearColor];
        [button setSurfaceColor:GetThemer().themeColor forState:UIControlStateNormal];
        [button setSurfaceColor:GetThemer().themeHighlightColor forState:UIControlStateHighlighted];
    }
    
    self.backgroundColor = GetThemer().themeColorBackground;
}

- (IBAction)onCreateAlbumButtonPressed:(id)sender
{
    if (_createAlbumAction != nil)
    {
        _createAlbumAction();
    }
}

- (IBAction)onUploadPhotoButtonPressed:(id)sender
{
    if (_uploadPhotoAction != nil)
    {
        _uploadPhotoAction();
    }
}

@end
