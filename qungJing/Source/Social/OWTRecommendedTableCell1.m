//
//  OWTRecommendedTableCell.m
//  Weitu
//
//  Created by Su on 8/18/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import "OWTRecommendedTableCell1.h"
#import "OWTImageView.h"
#import "OWTUser.h"
#import "OWTAsset.h"
#import "OWTUserManager.h"
#import <KHFlatButton/KHFlatButton.h>
#import "UIButton+HitTestExt.h"
#import "SVProgressHUD+WTError.h"

@interface OWTRecommendedTableCell1()
{
    IBOutlet OWTImageView* _avatarView;
    IBOutlet UILabel* _nicknameLabel;
    IBOutlet UILabel* _signatureLabel;
    IBOutlet KHFlatButton* _actionButton;
    IBOutlet OWTImageView* _assetImageViewA;
    IBOutlet OWTImageView* _assetImageViewB;
    IBOutlet OWTImageView* _assetImageViewC;

    UITapGestureRecognizer* _avatarViewTappedGR;
    UITapGestureRecognizer* _nicknameLabelTappedGR;
    UITapGestureRecognizer* _assetImageViewATappedGR;
    UITapGestureRecognizer* _assetImageViewBTappedGR;
    UITapGestureRecognizer* _assetImageViewCTappedGR;

    NSArray* _assetImageViews;
}

@end

@implementation OWTRecommendedTableCell1

- (void)awakeFromNib
{
    _avatarView.fadeTransitionEnabled = NO;
    _avatarView.layer.cornerRadius = 2;
    _avatarView.clipsToBounds = YES;

    _assetImageViews = @[_assetImageViewA, _assetImageViewB, _assetImageViewC];
    for (OWTImageView* imageView in _assetImageViews)
    {
        imageView.maintainAspectRatio = NO;
    }

    [_actionButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _actionButton.backgroundColor = GetThemer().themeColor;
    _actionButton.hitTestEdgeInsets = UIEdgeInsetsMake(-10, -10, -10, -10);
    
    _avatarViewTappedGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(presentUser:)];
    _nicknameLabelTappedGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(presentUser:)];
    
    _assetImageViewATappedGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(presentAsset:)];
    _assetImageViewBTappedGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(presentAsset:)];
    _assetImageViewCTappedGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(presentAsset:)];
    
    [_avatarView addGestureRecognizer:_avatarViewTappedGR];
    [_nicknameLabel addGestureRecognizer:_nicknameLabelTappedGR];
    
    [_assetImageViewA addGestureRecognizer:_assetImageViewATappedGR];
    [_assetImageViewB addGestureRecognizer:_assetImageViewBTappedGR];
    [_assetImageViewC addGestureRecognizer:_assetImageViewCTappedGR];
}

- (void)setUser:(OWTUser *)user
{
    _user = user;

    if (_user != nil)
    {
        [_avatarView setImageWithInfoAsThumbnail:_user.avatarImageInfo];
        _nicknameLabel.text = _user.nickname ?: @"";
        _signatureLabel.text = _user.signature ?: @"";
        [self updateActionButton];
    }
    else
    {
        [_avatarView clearImageAnimated:NO];
        _nicknameLabel.text = @"";
        _signatureLabel.text = @"";
    }
}

- (void)updateActionButton
{
    OWTUser* currentUser = GetUserManager().currentUser;
    if (currentUser != nil)
    {
        _actionButton.hidden = NO;
        if ([currentUser isFollowingUser:_user])
        {
            [_actionButton setTitle:@"取消" forState:UIControlStateNormal];
            [_actionButton setButtonColor:[UIColor darkGrayColor]];
        }
        else
        {
            [_actionButton setTitle:@"+关注" forState:UIControlStateNormal];
            [_actionButton setButtonColor:GetThemer().themeColor];
        }
    }
    else
    {
        _actionButton.hidden = YES;
    }
}

- (void)setAssets:(NSArray *)assets
{
    _assets = [assets copy];

    int assetNum = _assets.count;
    assetNum = MIN(assetNum, _assetImageViews.count);
    int i = 0;
    for (; i < assetNum; ++i)
    {
        OWTAsset* asset = (OWTAsset*)_assets[i];
        OWTImageView* assetImageView = _assetImageViews[i];
        assetImageView.hidden = NO;
        [assetImageView setImageWithInfo:asset.imageInfo];
    }

    for (; i < _assetImageViews.count; ++i)
    {
        OWTImageView* assetImageView = _assetImageViews[i];
        [assetImageView clearImageAnimated:NO];
        assetImageView.hidden = YES;
    }
}

- (void)presentUser:(id)sender
{
    if (_presentUserAction != nil)
    {
        _presentUserAction(_user.userID);
    }
}

- (void)presentAsset:(id)sender
{
    if (_presentAssetAction != nil)
    {
        if (sender == _assetImageViewATappedGR)
        {
            _presentAssetAction(((OWTAsset*)_assets[0]).assetID);
        }
        else if (sender == _assetImageViewBTappedGR)
        {
            _presentAssetAction(((OWTAsset*)_assets[1]).assetID);
        }
        else if (sender == _assetImageViewCTappedGR)
        {
            _presentAssetAction(((OWTAsset*)_assets[2]).assetID);
        }
    }
}

- (IBAction)onActionButtonPressed:(id)sender
{
    OWTUserManager* um = GetUserManager();
    
    OWTUser* currentUser = um.currentUser;
    if ([currentUser isFollowingUser:_user])
    {
        [SVProgressHUD show];
        [um unfollowUser:_user
                 success:^{
                     [SVProgressHUD dismiss];
                     [self updateActionButton];
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
                   [self updateActionButton];
               }
               failure:^(NSError* error) {
                   [SVProgressHUD showError:error];
               }];
    }
}

- (void)prepareForReuse
{
    [self setUser:nil];
    [self setAssets:nil];
}

@end
