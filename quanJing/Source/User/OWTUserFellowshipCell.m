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
            _actionButton.tag=0;
            [_actionButton setTitle:@"已关注" forState:UIControlStateNormal];
        }else{
                    _actionButton.hidden = NO;
            if (_user.hasFollowUser.boolValue)
            {
                _actionButton.tag=0;
                [_actionButton setTitle:@"已关注" forState:UIControlStateNormal];
            }
            else
            {
                _actionButton.tag=1;
                [_actionButton setTitle:@"+关注" forState:UIControlStateNormal];
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
    QJPassport * pt = [QJPassport sharedPassport];
    
    
    if (_actionButton.tag == 0){
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSError * error = [pt requestUserFollowUser:_user.uid];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!error) {
                    [SVProgressHUD dismiss];
                    _actionButton.tag = 1;
                    [_actionButton setTitle:@"+关注" forState:UIControlStateNormal];
                }
                else {
                    [SVProgressHUD showError:error];
                }
            });
        });
    }
    else{
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSError * error = [pt requestUserCancelFollowUser:_user.uid];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!error) {
                    [SVProgressHUD dismiss];
                    _actionButton.tag = 0;
                    [_actionButton setTitle:@"已关注" forState:UIControlStateNormal];
                }
                else {
                    [SVProgressHUD showError:error];
                }
            });
        });}

}

- (void)prepareForReuse
{
    _user = nil;
    [_avatarImageView clearImageAnimated:NO];
}

@end
