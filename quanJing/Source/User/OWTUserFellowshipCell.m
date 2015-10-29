//
//  OWTUserFellowshipCell.m
//  Weitu
//
//  Created by Su on 6/16/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import "OWTUserFellowshipCell.h"
#import "OWTImageView.h"
#import "OWTUser.h"
#import "OWTUserManager.h"
#import "SVProgressHUD+WTError.h"
#import <SIAlertView/SIAlertView.h>

@interface OWTUserFellowshipCell()
{
    IBOutlet UILabel* _usernameLabel;
    IBOutlet OWTImageView* _avatarImageView;
    IBOutlet UIButton* _actionButton;
    __weak IBOutlet UIImageView *_assetImageViewA;
    
    __weak IBOutlet UIImageView *_assetImageViewB;
    __weak IBOutlet UIImageView *_assetImageViewC;
    __weak IBOutlet UIImageView *_assetImageViewD;

}

@property (nonatomic, strong) QJUser* user;
@property (nonatomic, assign) BOOL isFollowerUser;

@end

@implementation OWTUserFellowshipCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    _avatarImageView.layer.cornerRadius = _avatarImageView.bounds.size.width * 0.5;
    _avatarImageView.clipsToBounds = YES;
}

- (void)setUser:(QJUser*)user isFollowerUser:(BOOL)isFollowerUser;
{
    _user = user;
    _isFollowerUser = isFollowerUser;
    
    if (_user != nil)
    {
        _usernameLabel.text = user.nickName;
        [_avatarImageView setImageWithURL:[NSURL URLWithString:[QJInterfaceManager thumbnailUrlFromImageUrl:user.avatar size:_avatarImageView.bounds.size]] placeholderImage:[UIImage imageNamed:@"5"]];
        if (_isFollowerUser) {
            _actionButton.hidden=NO;
            [_actionButton setTitle:@"已关注" forState:UIControlStateNormal];
        }else{
        if (_user)
        {
            _actionButton.hidden = NO;
            if (_user.hasFollowUser.boolValue)
            {
                [_actionButton setTitle:@"已关注" forState:UIControlStateNormal];
            }
            else
            {
                [_actionButton setTitle:@"+关注" forState:UIControlStateNormal];
            }
        }
        else
        {
            _actionButton.hidden = YES;
        }
        }
        [self setNeedsLayout];
    }
    else
    {
        _usernameLabel.text = @"";
        [_avatarImageView clearImageAnimated:NO];

        _actionButton.hidden = YES;
    }
}

- (IBAction)actionButtonPressed:(id)sender
{
    OWTUserManager* um = GetUserManager();

    OWTUser* currentUser = um.currentUser;
    if ([currentUser isFollowingUser:_user])
    {
        [SVProgressHUD show];
        [um unfollowUser:_user
                 success:^{
                     [SVProgressHUD dismiss];
                     [_actionButton setTitle:@"+关注" forState:UIControlStateNormal];
                 }
                 failure:^(NSError* error) {
                     [SVProgressHUD showError:error];
                 }];
    }
    else
    {
        [um followUser:_user
               success:^{
                   [SVProgressHUD dismiss];
                   [_actionButton setTitle:@"已关注" forState:UIControlStateNormal];
               }
               failure:^(NSError* error) {
                   [SVProgressHUD showError:error];
               }];
    }
}

- (void)prepareForReuse
{
    _user = nil;
    [_avatarImageView clearImageAnimated:NO];
}

@end
