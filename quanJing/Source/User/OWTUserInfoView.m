//
//  OWTUserInfoViewCon.m
//  Weitu
//
//  Created by Su on 4/12/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import "OWTUserInfoView.h"
#import "OWTUser.h"
#import "OWTRoundImageView.h"
#import "OWTUserManager.h"
#import "SVProgressHUD+WTError.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <NSAttributedString+CCLFormat/NSAttributedString+CCLFormat.h>
#import <UIColor-HexString/UIColor+HexString.h>

#define kOWTUserInfoBtnNormalColor          [UIColor colorWithHexString:@"9e9e9e"]
#define kOWTUserInfoBtnHighlightedColor     [UIColor colorWithHexString:@"ff2a00"]

typedef enum
{
    nWTUserInfoViewActionButtonNone,
    nWTUserInfoViewActionButtonEdit,
    nWTUserInfoViewActionButtonFollow,
    nWTUserInfoViewActionButtonUnfollow,
} EWTUserInfoViewActionButtonType;

@interface OWTUserInfoView ()
{
    IBOutlet UILabel* _nameLabel;//编辑
    IBOutlet UIButton* _actionButton;//编辑
    IBOutlet UILabel* _signatureLabel;//编辑
    IBOutlet UIButton* _photoNumButton;
    IBOutlet UIButton* _likeNumButton;
    IBOutlet UIButton* _followingNumButton;
    IBOutlet UIButton* _followerNumButton;
    IBOutlet UIImageView* _userImageView;

    EWTUserInfoViewActionButtonType _actionButtonType;
    NSInteger _colloctionLikeNum;
}
//头像
@property (nonatomic, strong) IBOutlet OWTRoundImageView* avatarView;

@end

@implementation OWTUserInfoView

- (void)awakeFromNib
{
    _photoNumButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _photoNumButton.titleLabel.textAlignment = NSTextAlignmentCenter;

    _likeNumButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _likeNumButton.titleLabel.textAlignment = NSTextAlignmentCenter;

    _followingNumButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _followingNumButton.titleLabel.textAlignment = NSTextAlignmentCenter;

    _followerNumButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _followerNumButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    _avatarView.layer.borderColor = [UIColor whiteColor].CGColor;
    _avatarView.layer.borderWidth = 1.0;
}

- (void)setUser:(QJUser*)user
{
    _user = user;
    [self updateWithUser];
}

- (void)updateWithUser
{
    [self updateNickname:_user.nickName];
    [self.avatarView setImageWithURL:[NSURL URLWithString:[QJInterfaceManager thumbnailUrlFromImageUrl:_user.avatar size:self.avatarView.bounds.size]] placeholderImage:[UIImage imageNamed:@"5"]];
    self.avatarView.userInteractionEnabled =YES;
    UITapGestureRecognizer*tapRecognizerleft=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickImage)];
    [self.avatarView addGestureRecognizer:tapRecognizerleft];
    _nameLabel.userInteractionEnabled = YES;
    [self bringSubviewToFront:_nameLabel];
    _signatureLabel.userInteractionEnabled =YES;
    UITapGestureRecognizer*tapRecognizerleft1=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickImage)];
    
    [_signatureLabel addGestureRecognizer:tapRecognizerleft1];
    
    UITapGestureRecognizer*tapRecognizerleft2=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickImage)];
    [_nameLabel addGestureRecognizer:tapRecognizerleft2];
    [self updateLikesNum:_user.uploadAmount.intValue];
    [self updateFollowingNum:_user.uploadAmount.intValue];
    [self updateFollowerNum:_user.followAmount.intValue with:_user.fansAmount.intValue];
    [self updatePhotoNum:_selfNum];
}

#pragma mark - Action

#pragma mark - Info updating methods

- (void)updateNickname:(NSString*)nickname;
{
    _nameLabel.hidden=NO;
    if (nickname != nil)
    {
        _nameLabel.text = nickname;
    }
    else
    {
        _nameLabel.text = @"";
    }
}

- (void)updateSignature:(NSString*)signature
{
    if (signature != nil)
    {
        _signatureLabel.text = signature;
    }
    else
    {
        _signatureLabel.text = @"";
    }
}

- (void)updatePhotoNum:(NSInteger)photoNum
{
    [_photoNumButton setAttributedTitle:[self buildAttributedStringWithNum:[singleton shareData].value text:@"本机" color:kOWTUserInfoBtnNormalColor]
                               forState:UIControlStateNormal];
    [_photoNumButton setAttributedTitle:[self buildAttributedStringWithNum:[singleton shareData].value text:@"本机" color:kOWTUserInfoBtnHighlightedColor]
                               forState:UIControlStateHighlighted];
}

- (void)updateLikesNum:(NSInteger)likeNum
{
    [_likeNumButton setAttributedTitle:[self buildAttributedStringWithNum:likeNum text:@"相册" color:kOWTUserInfoBtnNormalColor]
                              forState:UIControlStateNormal];
    [_likeNumButton setAttributedTitle:[self buildAttributedStringWithNum:likeNum text:@"相册" color:kOWTUserInfoBtnHighlightedColor]
                              forState:UIControlStateHighlighted];
}

- (void)updateFollowingNum:(NSInteger)followingNum
{
    NSString* followingTitle;
    followingTitle = @"收藏";

    [_followingNumButton setAttributedTitle:[self buildAttributedStringWithNum:followingNum text:followingTitle color:kOWTUserInfoBtnNormalColor]
                                   forState:UIControlStateNormal];
    [_followingNumButton setAttributedTitle:[self buildAttributedStringWithNum:followingNum text:followingTitle color:kOWTUserInfoBtnHighlightedColor]
                                   forState:UIControlStateHighlighted];
}

- (void)updateFollowerNum:(NSInteger)followerNum with:(NSInteger)followingNum
{
    NSString* followerTitle;
    followerTitle = @"圈子";

    [_followerNumButton setAttributedTitle:[self buildAttributedStringWithNum:(followingNum+followerNum) text:followerTitle color:kOWTUserInfoBtnNormalColor]
                                  forState:UIControlStateNormal];
    [_followerNumButton setAttributedTitle:[self buildAttributedStringWithNum:(followingNum+followerNum) text:followerTitle color:kOWTUserInfoBtnHighlightedColor]
                                  forState:UIControlStateHighlighted];
}

- (NSAttributedString*)buildAttributedStringWithNum:(NSInteger)number text:(NSString*)text color:(UIColor *)font
{
    NSAttributedString* photoNumString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%li\n", (long)number]
                                                                         attributes:@{ NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Light" size:12.0], NSForegroundColorAttributeName:[UIColor blackColor] }];
    
    NSAttributedString* lineSpaceString = [[NSAttributedString alloc] initWithString:@"\n"
                                                                          attributes:@{ NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Light" size:5.0], NSForegroundColorAttributeName:font }];

    NSAttributedString* textString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@", text]
                                                                     attributes:@{ NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Light" size:15.0], NSForegroundColorAttributeName:font }];

    NSAttributedString* attributedString = [NSAttributedString attributedStringWithFormat:@"%@%@%@", photoNumString, lineSpaceString, textString];
    return attributedString;
}
-(void)clickImage
{
    if (_editUserInfoAction != nil)
    {
        _editUserInfoAction();
    }

}
- (void)updateBasedOnIsCurrentUser
{
//    BOOL isCurrentUser = [_user isCurrentUser];

    if (0)
    {
        [_actionButton setTitle:@"编辑个人信息" forState:UIControlStateNormal];
        _actionButtonType = nWTUserInfoViewActionButtonEdit;
        _actionButton.hidden = NO;
        _signatureLabel.hidden = YES;
    }
    else
    {
        OWTUser* currentUser = GetUserManager().currentUser;
        if (currentUser != nil)
        {
            if ([currentUser isFollowingUser:_user])
            {
                [_actionButton setTitle:@"已关注" forState:UIControlStateNormal];
//                _actionButton.backgroundColor =GetThemer().themeTintColor;
                _actionButtonType = nWTUserInfoViewActionButtonUnfollow;
            }
            else
            {
                [_actionButton setTitle:@"+关注" forState:UIControlStateNormal];
                _actionButtonType = nWTUserInfoViewActionButtonFollow;
//                _actionButton.backgroundColor =GetThemer().themeTintColor;
            }

            _actionButton.hidden = NO;
            _signatureLabel.hidden = YES;
        }
        else
        {
            _actionButtonType = nWTUserInfoViewActionButtonNone;
            _actionButton.hidden = YES;
            _signatureLabel.hidden = NO;
        }
    }
}

- (IBAction)actionButtonPressed:(id)sender
{
    switch (_actionButtonType)
    {
        case nWTUserInfoViewActionButtonEdit:
        {
            if (_editUserInfoAction != nil)
            {
                _editUserInfoAction();
            }
            break;
        }

        case nWTUserInfoViewActionButtonFollow:
        {
            OWTUserManager* um = GetUserManager();
            [SVProgressHUD show];
            [um followUser:_user
                   success:^{
                       [SVProgressHUD dismiss];
                       [self updateBasedOnIsCurrentUser];
                   }
                   failure:^(NSError* error){
                       [SVProgressHUD showError:error];
                   }];
            break;
        }

        case nWTUserInfoViewActionButtonUnfollow:
        {
            OWTUserManager* um = GetUserManager();
            [SVProgressHUD show];
            [um unfollowUser:_user
                     success:^{
                         [SVProgressHUD dismiss];
                         [self updateBasedOnIsCurrentUser];
                     }
                     failure:^(NSError* error){
                         [SVProgressHUD showError:error];
                     }];
            break;
        }

        default:
            break;
    }
}

- (IBAction)assetsButtonPressed:(id)sender
{
    if (_showAssetsAction != nil)
    {
        _showAssetsAction();
    }
}

- (IBAction)likedAssetsButtonPressed:(id)sender
{
    if (_showLikedAssetsAction != nil)
    {
        _showLikedAssetsAction();
    }
}

- (IBAction)followingsButtonPressed:(id)sender
{
    if (_showFollowingsAction != nil)
    {
        _showFollowingsAction();
    }
}

- (IBAction)followersButtonPressed:(id)sender
{
    if (_showFollowersAction != nil)
    {
        _showFollowersAction();
    }
}

@end
