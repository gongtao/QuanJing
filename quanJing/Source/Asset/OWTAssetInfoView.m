//
//  OWTAssetInfoView.m
//  Weitu
//
//  Created by Su on 4/23/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import "OWTAssetInfoView.h"
#import "OWTLatestCommentsView.h"
#import "OWTImageView.h"
#import "OWTAsset.h"
#import "OWTUserManager.h"
#import <QBFlatButton/QBFlatButton.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <FontAwesomeKit/FAKFontAwesome.h>
#import <UIView+Positioning/UIView+Positioning.h>

#import "OWTAssetManager.h"

#import "OWTServerError.h"

#import "FSBasicImage.h"
#import "FSBasicImageSource.h"

@interface OWTAssetInfoView()

@property (nonatomic, strong) IBOutlet OWTImageView* assetImageView;

@property (nonatomic, strong) IBOutlet QBFlatButton* downloadButton;
@property (nonatomic, strong) IBOutlet QBFlatButton* collectButton;
@property (nonatomic, strong) IBOutlet QBFlatButton* shareButton;
@property (nonatomic, strong) IBOutlet UILabel* captionLabel;
@property (nonatomic, strong) IBOutlet UIButton* usernameButton;
@property (nonatomic, strong) IBOutlet UIImageView* likesImageView;
@property (nonatomic, strong) IBOutlet UILabel* likesLabel;
@property (nonatomic, strong) IBOutlet OWTLatestCommentsView* latestCommentsView;
@property (nonatomic, strong) IBOutlet OWTImageView* avatarImageView;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint* avatarImageViewWidthConstraint;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint* avatarImageViewToNicknameLabelSpacingConstraint;

@property (weak, nonatomic) IBOutlet UILabel *picMarkLabel;
@property (nonatomic, strong) OWTUser* assetOwnerUser;

@end

@implementation OWTAssetInfoView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self setup];
    }
    return self;
}

- (void)setup
{

    
}

- (void)awakeFromNib
{
    _avatarImageView.clipsToBounds = YES;
    _avatarImageView.layer.cornerRadius = 16;
    
    UITapGestureRecognizer* gr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(usernameButtonPressed:)];
    [_avatarImageView addGestureRecognizer:gr];
    
    UIImage* heartImage = [[FAKFontAwesome heartIconWithSize:12] imageWithSize:CGSizeMake(12, 12)];
    [_likesImageView setTintColor:[UIColor darkGrayColor]];
    _likesImageView.image = [heartImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    NSArray* buttons = @[ _downloadButton, _collectButton, _shareButton ];
    
    for (QBFlatButton* button in buttons)
    {
        button.cornerRadius = 0;
        button.height = 0.5;
        button.depth = 0;
        
        [button setSurfaceColor:[UIColor colorWithWhite:1.0 alpha:1] forState:UIControlStateNormal];
        [button setSurfaceColor:GetThemer().themeColor forState:UIControlStateHighlighted ];
        button.sideColor = [UIColor colorWithWhite:0.69 alpha:1];
        
        [button setTitleColor:GetThemer().themeColor forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        button.titleLabel.textColor = GetThemer().themeColor;
        button.titleLabel.font = [UIFont systemFontOfSize:15];
    }
    
    __weak OWTAssetInfoView* wself = self;
    
    _latestCommentsView.showAllCommentsAction = ^{
        if (wself.showAllCommentsAction != nil)
        {
            wself.showAllCommentsAction();
        }
    };
}

- (void)setAsset:(OWTAsset*)asset
{
    _asset = asset;
    
    [self updateAssetImageView];
    [self updateCaptionLabel];
    [self updateOwnerUserRelatedViews];
    [self updateLikesLabel];
    [self updateLatestCommentsView];
    
    [self setNeedsLayout];
}

- (void)updateAssetImageView
{
    if (_asset != nil)
    {
        [_assetImageView setImageWithInfo:_asset.imageInfo];
        
        //添加图片点击事件
        
        self.assetImageView.userInteractionEnabled =YES;
        UITapGestureRecognizer*tapRecognizerleft=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickImage)];
        [self.assetImageView addGestureRecognizer:tapRecognizerleft];
    }
    else
    {
        [_assetImageView clearImageAnimated:NO];
    }
}
-(void)clickImage
{
    if (_canClick==YES) {
    if (_showAction != nil)
    {
        _showAction();
    }
        _canClick=NO;
    }
}

- (void)updateCaptionLabel
{
    if (_asset.caption != nil && _asset.caption.length > 0)
    {
        _captionLabel.hidden = NO;
        _captionLabel.text = [NSString stringWithFormat:@"标签：%@", _asset.caption];
         if (_asset.oriPic != nil && _asset.oriPic.length > 0)
        _picMarkLabel.text =[NSString stringWithFormat:@"编号：%@", _asset.oriPic];
        else
             _picMarkLabel.text =[NSString stringWithFormat:@"编号：%@", _asset.assetID];
    }
    else
    {
        _captionLabel.hidden = YES;
        _captionLabel.text = @"";
        if (_asset.oriPic != nil && _asset.oriPic.length > 0)
            _picMarkLabel.text =[NSString stringWithFormat:@"编号：%@", _asset.oriPic];
        else
            _picMarkLabel.text =[NSString stringWithFormat:@"编号：%@", _asset.assetID];
    }
}

- (void)updateOwnerUserRelatedViews
{
    if (_asset != nil)
    {
        _assetOwnerUser = [GetUserManager() userForID:_asset.ownerUserID];
        
        if (_assetOwnerUser != nil)
        {
            _usernameButton.hidden = NO;
            [_usernameButton setTitle:_assetOwnerUser.nickname forState:UIControlStateNormal];
            
            OWTImageInfo* avatarImageInfo = _assetOwnerUser.avatarImageInfo;
            if (avatarImageInfo != nil)
            {
                _avatarImageView.hidden = NO;
                _avatarImageViewWidthConstraint.constant = 32;
                _avatarImageViewToNicknameLabelSpacingConstraint.constant = 4;
                [_avatarImageView setImageWithInfoAsThumbnail:avatarImageInfo];
            }
            else
            {
                _avatarImageView.hidden = YES;
                _avatarImageViewWidthConstraint.constant = 0;
                _avatarImageViewToNicknameLabelSpacingConstraint.constant = 0;
                [_avatarImageView clearImageAnimated:NO];
            }
            
            NSRange aa=[_assetOwnerUser.nickname rangeOfString:@"全景"];
            if (aa.location != NSNotFound) {
                _usernameButton.hidden = YES;
                _avatarImageView.hidden = YES;
                //
                
                
                
                
            }
            else
            {
                _avatarImageView.hidden = NO;
                _avatarImageViewWidthConstraint.constant = 32;
                _avatarImageViewToNicknameLabelSpacingConstraint.constant = 4;
                [_avatarImageView setImageWithInfoAsThumbnail:avatarImageInfo];
            }
        }
        else
        {
            _usernameButton.hidden = YES;
            _avatarImageView.hidden = YES;
        }
    }
    else
    {
        _assetOwnerUser = nil;
        _avatarImageView.hidden = YES;
        _usernameButton.hidden = YES;
    }
}

- (void)updateLikesLabel
{
    NSInteger likeNum = _asset.likeNum;
    if (likeNum == 0)
    {
        _likesLabel.text = @"尚未被喜欢";
    }
    else
    {
        _likesLabel.text = [NSString stringWithFormat:@"%ld人喜欢", (long)likeNum];
    }
}

- (void)updateLatestCommentsView
{
    [_latestCommentsView setComments:self.asset.latestComments commentNum:self.asset.commentNum];
}

#pragma mark - Button Actions

- (IBAction)downloadButtonPressed:(id)sender
{
    if (_downloadAction != nil)
    {
        _downloadAction();
    }
}

- (IBAction)collectButtonPressed:(id)sender
{
    if (_collectAction != nil)
    {
        _collectAction();
    }
}

- (IBAction)shareButtonPressed:(id)sender
{
    if (_shareAction != nil)
    {
        _shareAction();
    }
}

- (IBAction)usernameButtonPressed:(id)sender
{
    if (_showOwnerUserAction != nil)
    {
        _showOwnerUserAction();
    }
}

- (IBAction)reportInappropriate:(id)sender
{
    if (_reportAction != nil)
    {
        _reportAction();
    }
}

@end
