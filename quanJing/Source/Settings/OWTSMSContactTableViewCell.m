//
//  OWTSMSContactTableViewCell.m
//  Weitu
//
//  Created by Su on 6/19/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import "OWTSMSContactTableViewCell.h"
#import <KHFlatButton/KHFlatButton.h>

@interface OWTSMSContactTableViewCell()

@property (nonatomic, strong) IBOutlet UILabel* nameLabel;
@property (nonatomic, strong) IBOutlet UILabel* cellphoneLabel;
@property (nonatomic, strong) IBOutlet KHFlatButton* inviteButton;

@end

@implementation OWTSMSContactTableViewCell

- (void)awakeFromNib
{
    _inviteButton.layer.cornerRadius = 2.0;
}

- (void)setName:(NSString *)name
{
    _name = name;
    _nameLabel.text = _name;
}

- (void)setCellphone:(NSString *)cellphone
{
    _cellphone = cellphone;
    _cellphoneLabel.text = _cellphone;
}

- (IBAction)inviteButtonPressed:(id)sender
{
    if (_inviteFunc != nil)
    {
        _inviteFunc(_name, _cellphone);
    }
}

@end
