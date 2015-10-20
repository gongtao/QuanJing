//
//  OWTCommentCell.m
//  Weitu
//
//  Created by Su on 4/25/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import "OWTCommentCell.h"
#import "OWTImageView.h"
#import "OWTUserManager.h"

@interface OWTCommentCell()
{
    
}

@property (nonatomic, strong) IBOutlet OWTImageView* avatarView;
@property (nonatomic, strong) IBOutlet UILabel* usernameLabel;
@property (nonatomic, strong) IBOutlet UILabel* contentLabel;

@end

@implementation OWTCommentCell

- (void)awakeFromNib
{
    _avatarView.layer.cornerRadius = _avatarView.bounds.size.width * 0.5;
    _avatarView.layer.masksToBounds = YES;
    UITapGestureRecognizer* gr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showUser)];
    [_avatarView addGestureRecognizer:gr];
    
    _usernameLabel.textColor = GetThemer().themeColor;
    gr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showUser)];
    [_usernameLabel addGestureRecognizer:gr];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)setComment:(OWTComment*)comment
{
    OWTUser* user = [GetUserManager() userForID:comment.userID];

    [_avatarView setImageWithInfoAsThumbnail:user.avatarImageInfo];
    _usernameLabel.text = user.nickname;

    _contentLabel.text = comment.content;

    [self setNeedsLayout];
}

- (void)showUser
{
    if (_showUserAction != nil)
    {
        _showUserAction();
    }
}

@end
