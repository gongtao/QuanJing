//
//  LJAssetInfoView.h
//  Weitu
//
//  Created by qj-app on 15/8/25.
//  Copyright (c) 2015年 SparkingSoft Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OWTImageView.h"
#import "OWTLatestCommentsView.h"
#import "OWTAssetViewCon.h"
@interface LJAssetInfoView : UICollectionReusableView
@property (nonatomic, strong) OWTAsset* asset;

@property (nonatomic, strong) void ((^downloadAction)());
@property (nonatomic, strong) void ((^collectAction)());
@property (nonatomic, strong) void ((^shareAction)());
@property (nonatomic, strong) void ((^showAction)());
@property (nonatomic, strong) void ((^showAllCommentsAction)());
@property(nonatomic,assign)BOOL canClick;
@property (nonatomic, strong) void ((^showOwnerUserAction)());
@property (nonatomic,strong) void((^likeAction)());
@property (nonatomic, strong) void ((^reportAction)());
@property(nonatomic,strong) void((^reloadView)());
@property (nonatomic, strong) UIImageView* assetImageView;
@property (nonatomic, strong) UIButton* downloadButton;
@property (nonatomic, strong) UIButton* collectButton;
@property (nonatomic, strong) UIButton* shareButton;
@property (nonatomic,strong)  UIButton *likeButton;
@property (nonatomic, strong) UILabel* captionLabel;
@property (nonatomic, strong) UILabel *userID;
@property (nonatomic, strong) UIImageView* likesImageView;
@property (nonatomic, strong) UILabel* likesLabel;
@property (nonatomic, strong) OWTLatestCommentsView* latestCommentsView;
@property (nonatomic, strong) OWTImageView* avatarImageView;
@property (nonatomic, strong) NSLayoutConstraint* avatarImageViewWidthConstraint;
@property (nonatomic, strong) NSLayoutConstraint* avatarImageViewToNicknameLabelSpacingConstraint;

@property (weak, nonatomic)  UILabel *picMarkLabel;
@property (nonatomic, strong) OWTUser* assetOwnerUser;
@property(nonatomic,strong)OWTAssetViewCon *controller;
-(void)customViewWithAsset:(OWTAsset *)asset withLikes:(NSArray *)LikeBodys withOpen:(BOOL)isOpen withController:(OWTAssetViewCon*)controller;

@end
