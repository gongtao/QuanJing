//
//  OWTUserInfoView1.m
//  Weitu
//
//  Created by Su on 4/12/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import "OWTUserInfoView1.h"
#import "OWTUser.h"
#import "OWTRoundImageView.h"
#import "OWTUserManager.h"
#import "SVProgressHUD+WTError.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <NSAttributedString+CCLFormat/NSAttributedString+CCLFormat.h>
#import <UIColor-HexString/UIColor+HexString.h>
#import "HuanXinManager.h"
#import "TTGlobalUICommon.h"
#import "XHImageViewer.h"
#import "HXChatInitModel.h"
#import "ChatViewController_rename.h"
#import "AGIPCPreviewController.h"

#define kOWTUserInfoBtnNormalColor          [UIColor colorWithHexString:@"9e9e9e"]
#define kOWTUserInfoBtnHighlightedColor     [UIColor colorWithHexString:@"ff2a00"]

typedef enum
{
    nWTUserInfoViewActionButtonNone,
    nWTUserInfoViewActionButtonEdit,
    nWTUserInfoViewActionButtonFollow,
    nWTUserInfoViewActionButtonUnfollow,
} EWTUserInfoViewActionButtonType;

@interface OWTUserInfoView1 ()
{
    IBOutlet UIButton *_hxChatBeginBtn;
    IBOutlet UILabel* _nameLabel;
    IBOutlet UIButton* _actionButton;
    IBOutlet UILabel* _signatureLabel;
    IBOutlet UIButton* _photoNumButton;
    IBOutlet UIButton* _likeNumButton;
    IBOutlet UIButton* _followingNumButton;
    IBOutlet UIButton* _followerNumButton;
    IBOutlet UIImageView* _userImageView;
    
    EWTUserInfoViewActionButtonType _actionButtonType;
}

//圈子 二级控制器头像的数据
@property (nonatomic, strong) IBOutlet OWTRoundImageView* avatarView;

@end

@implementation OWTUserInfoView1

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

//在外部调用赋值
- (void)setUser:(OWTUser*)user
{
    _user = user;
    [self updateWithUser];
}


#pragma -mark 环信聊天入口
- (IBAction)HXChatPress:(UIButton *)sender
{
    if (!_isCared && ![_followingUsers containsObject:GetUserManager().currentUser.userID]){
        TTAlertNoTitle(NSLocalizedString(@"关注成为好友后才能发消息！", @"Like Action First!"));
        return;
    }
    
    NSArray *array = [HXChatInitModel getCountAndPWDbyMD5];
    NSString *hxUsrId = [array firstObject];
    NSString *password = [array lastObject];
    //初始化 并登陆环信
    if (![[EaseMob sharedInstance].chatManager isLoggedIn]) {
        [HuanXinManager sharedTool:hxUsrId passWord:password];
        return;
    }
    NSString *toChat = [@"qj" stringByAppendingString:_user.userID];
    //开始聊天
    ChatViewController_rename *chatVC = [[ChatViewController_rename alloc] initWithChatter:toChat isGroup:NO tile1:@"" title2:@""];
    chatVC.title = _user.nickname;
    chatVC.currentUserImage = GetUserManager().currentUser.currentImage;
    chatVC.senderImage = _avatarView.avatarImage;
    [_owtUserViewVC.navigationController pushViewController:chatVC animated:YES];
    
    NSLog(@"hx btn show");
}

- (void)updateWithUser
{
    [self updateNickname:_user.nickname];
    //通过_user中头像的URL 通过第三方框架 把头像数据 保存到xib初始化出来的视图上做展示
    self.avatarView.placeholderImage = [UIImage imageNamed:@"我的页面默认头像.jpg"];
    [self.avatarView setImageWithInfoAsThumbnail:_user.avatarImageInfo];
    self.avatarView.userInteractionEnabled =YES;
    UITapGestureRecognizer*tapRecognizerleft=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickImage)];
    //avatarView是uiimageView的子类
    [self.avatarView addGestureRecognizer:tapRecognizerleft];
    _mAvatarView = self.avatarView;
    
    if (_user.signature != nil)
    {
        [self updateSignature:_user.signature];
    }
    else
    {
        [self updateSignature:@""];
    }
    
    OWTUserAssetsInfo* assetsInfo = _user.assetsInfo;
    if (assetsInfo != nil)
    {
        NSInteger photoNum = assetsInfo.publicAssetNum;
        if (_user.isCurrentUser)
        {
            photoNum += assetsInfo.privateAssetNum;
        }
        
        [self updatePhotoNum:photoNum];
        [self updateLikesNum:assetsInfo.likedAssetNum];
    }
    else
    {
        [self updatePhotoNum:0];
        [self updateLikesNum:0];
    }
    
    OWTUserFellowshipInfo* fellowshipInfo = _user.fellowshipInfo;
    _followingUsers = _user.fellowshipInfo.followingUserIDs;
    if (fellowshipInfo != nil)
    {
        [self updateFollowingNum:fellowshipInfo.followingNum];
        [self updateFollowerNum:fellowshipInfo.followerNum];
    }
    else
    {
        [self updateFollowingNum:0];
        [self updateFollowerNum:0];
    }
    
    [self updateBasedOnIsCurrentUser];
}


//
-(void)clickImage
{
    
    if (_showAvatorAction != nil)
    {
        _showAvatorAction();
    }
    
}
//
#pragma mark - Action

#pragma mark - Info updating methods

- (void)updateNickname:(NSString*)nickname;
{
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
    //这里改photoNum
    [_photoNumButton setAttributedTitle:[self buildAttributedStringWithNum:photoNum text:@"照片" color:kOWTUserInfoBtnNormalColor]
                               forState:UIControlStateNormal];
    [_photoNumButton setAttributedTitle:[self buildAttributedStringWithNum:photoNum text:@"照片" color:kOWTUserInfoBtnHighlightedColor]
                               forState:UIControlStateHighlighted];
}

- (void)updateLikesNum:(NSInteger)likeNum
{
    [_likeNumButton setAttributedTitle:[self buildAttributedStringWithNum:likeNum text:@"喜欢" color:kOWTUserInfoBtnNormalColor]
                              forState:UIControlStateNormal];
    [_likeNumButton setAttributedTitle:[self buildAttributedStringWithNum:likeNum text:@"喜欢" color:kOWTUserInfoBtnHighlightedColor]
                              forState:UIControlStateHighlighted];
}

- (void)updateFollowingNum:(NSInteger)followingNum
{
    NSString* followingTitle;
    followingTitle = @"关注";
    
    [_followingNumButton setAttributedTitle:[self buildAttributedStringWithNum:followingNum text:followingTitle color:kOWTUserInfoBtnNormalColor]
                                   forState:UIControlStateNormal];
    [_followingNumButton setAttributedTitle:[self buildAttributedStringWithNum:followingNum text:followingTitle color:kOWTUserInfoBtnHighlightedColor]
                                   forState:UIControlStateHighlighted];
}

- (void)updateFollowerNum:(NSInteger)followerNum
{
    NSString* followerTitle;
    followerTitle = @"粉丝";
    
    [_followerNumButton setAttributedTitle:[self buildAttributedStringWithNum:followerNum text:followerTitle color:kOWTUserInfoBtnNormalColor]
                                  forState:UIControlStateNormal];
    [_followerNumButton setAttributedTitle:[self buildAttributedStringWithNum:followerNum text:followerTitle color:kOWTUserInfoBtnHighlightedColor]
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

//看头像
- (void)showavatarView
{
    AGIPCPreviewController *preController = [[AGIPCPreviewController alloc] initWithAssets:@[ ]targetAsset:nil];
    
    preController.delegate = self;
    
    preController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    //    [self.navigationController presentViewController:preController animated:YES completion:^{
    ////
    ////        // do nothing
    ////
    //    }];
}
- (void)updateBasedOnIsCurrentUser
{
    if ([_user.userID isEqualToString:GetUserManager().currentUser.userID]) {
        [_actionButton setTitle:[NSString stringWithFormat:@"ID:%@",_user.userID] forState:UIControlStateNormal];
        _actionButtonType = nWTUserInfoViewActionButtonEdit;
        _actionButton.hidden = NO;
        _signatureLabel.hidden = YES;
        _hxChatBeginBtn.hidden=YES;
        _ifCurrenUserEnter = YES;

    }
    else
    {
        _ifCurrenUserEnter = NO;

        _hxChatBeginBtn.hidden=NO;
        _signatureLabel.text=[NSString stringWithFormat:@"ID:%@",_user.userID];
        OWTUser* currentUser = GetUserManager().currentUser;
        if (currentUser != nil)
        {
            if ([currentUser isFollowingUser:_user])
            {
                _isCared = YES;
                _actionButtonType = nWTUserInfoViewActionButtonUnfollow;
            }
            else
            {
                _isCared = NO;
                _actionButtonType = nWTUserInfoViewActionButtonFollow;
            }
            if ([self.careDelegate respondsToSelector:@selector(didCareButtonPressed:)]) {
                [self.careDelegate didCareButtonPressed:_isCared];
            }
            
            _actionButton.hidden = YES;
            _signatureLabel.hidden = NO;
        }
        else
        {
            _actionButtonType = nWTUserInfoViewActionButtonNone;
            _actionButton.hidden = YES;
            _signatureLabel.hidden = NO;
        }
    }
}

//加关注按钮
- (void)careButtonPressed {
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
//照片
- (IBAction)assetsButtonPressed:(id)sender
{
    if (_showAssetsAction != nil)
    {
        _showAssetsAction();
    }
}
//喜欢的照片
- (IBAction)likedAssetsButtonPressed:(id)sender
{
    if (_showLikedAssetsAction != nil)
    {
        _showLikedAssetsAction();
    }
}
//关注的人
- (IBAction)followingsButtonPressed:(id)sender
{
    if (_showFollowingsAction != nil)
    {
        _showFollowingsAction();
    }
}
//粉丝 喜欢我的人
- (IBAction)followersButtonPressed:(id)sender
{
    if (_showFollowersAction != nil)
    {
        _showFollowersAction();
    }
}

@end