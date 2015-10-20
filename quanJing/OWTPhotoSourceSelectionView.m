//
//  OWTPhotoSourceSelectionView.m
//  Weitu
//
//  Created by Su on 5/31/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import "OWTPhotoSourceSelectionView.h"
#import "OWTFont.h"
#import <UIImage+RTTint/UIImage+RTTint.h>
#import <KHFlatButton/KHFlatButton.h>

@interface OWTPhotoSourceSelectionView()
{
    IBOutlet KHFlatButton* _cameraButton;
    IBOutlet KHFlatButton* _albumButton;
}

@end

@implementation OWTPhotoSourceSelectionView

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self != nil)
    {
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];

    // XXX This is a hack
    dispatch_async(dispatch_get_main_queue(), ^{
        _cameraButton.layer.cornerRadius = _cameraButton.bounds.size.height * 0.5;
        _albumButton.layer.cornerRadius = _albumButton.bounds.size.height * 0.5;
    });

    UIImage* cameraImage = [[OWTFont cameraIconWithSize:48] imageWithSize:CGSizeMake(48, 48)];
    cameraImage = [cameraImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    cameraImage = [cameraImage rt_tintedImageWithColor:[UIColor whiteColor]];

    [_cameraButton setImage:cameraImage forState:UIControlStateNormal];

    UIImage* albumImage = [[OWTFont albumIconWithSize:48] imageWithSize:CGSizeMake(48, 48)];
    albumImage = [albumImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    albumImage = [albumImage rt_tintedImageWithColor:[UIColor whiteColor]];

    [_albumButton setImage:albumImage forState:UIControlStateNormal];
}

- (IBAction)selectCamera:(id)sender
{
    if (_cameraSelectedAction != nil)
    {
        _cameraSelectedAction();
    }
}

- (IBAction)selectAlbum:(id)sender
{
    if (_albumSelectedAction != nil)
    {
        _albumSelectedAction();
    }
}

@end
