//
//  LJExploreCell.m
//  Weitu
//
//  Created by qj-app on 15/9/1.
//  Copyright (c) 2015年 SparkingSoft Co., Ltd. All rights reserved.
//

#import "LJExploreCell.h"
#import "LJUIController.h"
#import "OWTAsset.h"
#import "UIImageView+AFNetworking.h"
#import "OWTUser.h"
#import "OWTActivityData.h"
#import "LJLike.h"
#import "LJComment.h"
#import "LJFeedWithUserProfileViewCon.h"
#import "OWTUserViewCon.h"
#import "OWTAssetViewCon.h"
#import <SDWebImage/SDWebImageManager.h>
#import <ALAssetsLibrary-CustomPhotoAlbum/ALAssetsLibrary+CustomPhotoAlbum.h>
#import "WTCommon.h"
#import "OWTUserManager.h"
#import "OWTAuthManager.h"
#import "SIAlertView.h"
#import "OWTAssetManager.h"
#import "OWTServerError.h"
#import "SVProgressHUD+WTError.h"
#import "UIColor+HexString.h"
#import "OWTAsset.h"
#import "UMSocial.h"
#import "LJExploreSquareController.h"
#define COMMENTWIT 10

@implementation LJExploreCell
{
	LJExploreSquareController * _viewContoller;
	UIImageView * _headerImageView;
	UILabel * _userName;
	UILabel * _upTime;
	OWTUser * _user;
	NSMutableArray * _assets;
	OWTActivityData * _activity;
	NSMutableArray * _likes;
	NSMutableArray * _comments;
	UILabel * _caption;
	UIScrollView * _scrollView;
	UIScrollView * _bigImageScrollView;
	UIButton * _likeBtn;
	UIButton * _downLoadBtn;
	UIButton * _collectionBtn;
	UIButton * _shareBtn;
	UIButton * _commentBtn;
	BOOL isSmallImageTap;
	UIImageView * _heartView;
	UILabel * _line1;
	UILabel * _line2;
	UILabel * _line3;
}

- (void)awakeFromNib
{
	// Initialization code
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withViewController:(LJExploreSquareController *)viewConctroller withComment:(void (^)(OWTActivityData *, NSInteger))cb
{
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	
	if (self) {
		commentcb = [cb copy];
		_viewContoller = viewConctroller;
		_user = GetUserManager().currentUser;
		self.contentView.backgroundColor = GetThemer().themeColorBackground;
		_imageNum = 0;
		[self customUI];
	}
	
	return self;
}

- (void)customUI
{
	_backView = [[UIView alloc]initWithFrame:CGRectZero];
	_backView.backgroundColor = [UIColor whiteColor];
	[self.contentView addSubview:_backView];
	_headerImageView = [LJUIController createImageViewWithFrame:CGRectMake(15, 10, 40, 40) imageName:nil];
	[self.contentView addSubview:_headerImageView];
	UITapGestureRecognizer * tap3 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onTap3)];
	[_headerImageView addGestureRecognizer:tap3];
	_userName = [LJUIController createLabelWithFrame:CGRectZero Font:12 Text:nil];
	[self.contentView addSubview:_userName];
	
	_upTime = [LJUIController createLabelWithFrame:CGRectZero Font:12 Text:nil];
	_upTime.textColor = [UIColor grayColor];
	[self.contentView addSubview:_upTime];
	_scrollView = [[UIScrollView alloc]initWithFrame:CGRectZero];
	_scrollView.delegate = self;
	[self.contentView addSubview:_scrollView];
	_bigImageScrollView = [[UIScrollView alloc]initWithFrame:CGRectZero];
	_bigImageScrollView.delegate = self;
	[self.contentView addSubview:_bigImageScrollView];
	_caption = [LJUIController createLabelWithFrame:CGRectZero Font:12 Text:nil];
	[self.contentView addSubview:_caption];
	_likeBtn = [LJUIController createButtonWithFrame:CGRectZero imageName:@"圈子5_31.png" title:nil target:self action:@selector(likeBtnClick:)];
	_downLoadBtn = [LJUIController createButtonWithFrame:CGRectZero imageName:@"圈子5_33.png" title:nil target:self action:@selector(downLoadBtnClick)];
	_collectionBtn = [LJUIController createButtonWithFrame:CGRectZero imageName:@"圈子5_34.png" title:nil target:self action:@selector(collectionBtnClick)];
	_shareBtn = [LJUIController createButtonWithFrame:CGRectZero imageName:@"圈子5_35.png" title:nil target:self action:@selector(shareBtnClick)];
	_commentBtn = [LJUIController createButtonWithFrame:CGRectZero imageName:@"圈子5_36.png" title:nil target:self action:@selector(commentBtnClick)];
	[self.contentView addSubview:_commentBtn];
	[self.contentView addSubview:_likeBtn];
	[self.contentView addSubview:_downLoadBtn];
	[self.contentView addSubview:_collectionBtn];
	[self.contentView addSubview:_shareBtn];
	_heartView = [LJUIController createImageViewWithFrame:CGRectZero imageName:nil];
	[self.contentView addSubview:_heartView];
	_line1 = [LJUIController createLabelWithFrame:CGRectZero Font:12 Text:nil];
	_line2 = [LJUIController createLabelWithFrame:CGRectZero Font:12 Text:nil];
	_line3 = [LJUIController createLabelWithFrame:CGRectZero Font:12 Text:nil];
	_line1.backgroundColor = [UIColor grayColor];
	_line2.backgroundColor = [UIColor grayColor];
	_line3.backgroundColor = [UIColor grayColor];
	[self.contentView addSubview:_line1];
	[self.contentView addSubview:_line2];
	[self.contentView addSubview:_line3];
}

#pragma mark btnAndTap
- (void)commentBtnClick
{
	_viewContoller.replyid = nil;
	commentcb(_activity, _number);
}

- (void)onLikeTap:(UIGestureRecognizer *)sender
{
	LJLike * ljlike = _likes[sender.view.tag - 700];
	OWTUser * ownerUser = [GetUserManager() userForID:ljlike.likeUserid];
	
	if (ownerUser != nil) {
		OWTUserViewCon * userViewCon1 = [[OWTUserViewCon alloc] initWithNibName:nil bundle:nil];
		userViewCon1.hidesBottomBarWhenPushed = YES;
		[_viewContoller.navigationController pushViewController:userViewCon1 animated:YES];
		userViewCon1.user = ownerUser;
	}
}

- (void)likeBtnClick:(UIButton *)sender
{
	RKObjectManager * um = [RKObjectManager sharedManager];
	NSString * activityid = _activity.commentid;
	
	_user = GetUserManager().currentUser;
	CGFloat imageHeight = 20;
	
	if (sender.selected == NO) {
		_likeBtn.selected = YES;
		[_likeBtn setBackgroundImage:[UIImage imageNamed:@"赞01"] forState:UIControlStateNormal];
		
		NSMutableArray * arr = _viewContoller.likes[_number];
		
		if (arr.count % 9 == 0) {
			NSString * height = _viewContoller.heights[_number];
			NSString * str;
			
			if (arr.count / 9 != 0)
				str = [NSString stringWithFormat:@"%f", height.floatValue + imageHeight + 10];
			else
				str = [NSString stringWithFormat:@"%f", height.floatValue + imageHeight];
			[_viewContoller.heights replaceObjectAtIndex:_number withObject:str];
		}
		LJLike * like = [[LJLike alloc]init];
		like.likeUserid = _user.userID;
		[arr addObject:like];
		[_viewContoller.likes replaceObjectAtIndex:_number withObject:arr];
		[_viewContoller reloadData:_number];
		[um postObject:nil path:@"activity/like" parameters:@{
			@"Activityid":activityid
		} success:^(RKObjectRequestOperation * operation, RKMappingResult * mappingResult) {} failure:^(RKObjectRequestOperation * operation, NSError * error) {}];
	}
	else {
		_likeBtn.selected = NO;
		[_likeBtn setBackgroundImage:[UIImage imageNamed:@"赞00"] forState:UIControlStateNormal];
		NSMutableArray * arr = _viewContoller.likes[_number];
		
		if (arr.count % 9 == 1) {
			NSString * height = _viewContoller.heights[_number];
			NSString * str;
			
			if (arr.count / 9 != 0)
				str = [NSString stringWithFormat:@"%f", height.floatValue - imageHeight - 10];
			else
				str = [NSString stringWithFormat:@"%f", height.floatValue - imageHeight];
				
			[_viewContoller.heights replaceObjectAtIndex:_number withObject:str];
		}
		
		for (LJLike * ljlike in arr)
			if ([ljlike.likeUserid isEqualToString:_user.userID]) {
				[arr removeObject:ljlike];
				break;
			}
			
		[_viewContoller.likes replaceObjectAtIndex:_number withObject:arr];
		[_viewContoller reloadData:_number];
		[um postObject:nil path:@"activity/like" parameters:@{
			@"Activityid":activityid
		} success:^(RKObjectRequestOperation * operation, RKMappingResult * mappingResult) {} failure:^(RKObjectRequestOperation * operation, NSError * error) {}];
	}
}

- (void)downLoadBtnClick
{
	OWTAsset * asset = _assets[_imageNum];
	
	[SVProgressHUD showWithStatus:@"保存图片中..." maskType:SVProgressHUDMaskTypeBlack];
	
	SDWebImageManager * manager = [SDWebImageManager sharedManager];
	NSURL * url = [NSURL URLWithString:asset.imageInfo.url];
	[manager downloadWithURL:url
	options:SDWebImageHighPriority
	progress:nil
	completed:^(UIImage * image, NSError * error, SDImageCacheType cacheType, BOOL finished) {
		if (image != nil) {
			ALAssetsLibrary * assetsLibrary = [[ALAssetsLibrary alloc] init];
			[assetsLibrary saveImage:image
			toAlbum:@"全景"
			completion:^(NSURL * assetURL, NSError * error) {
				[SVProgressHUD showSuccessWithStatus:@"保存成功"];
			}
			failure:^(NSError * error) {
				[SVProgressHUD showSuccessWithStatus:@"保存成功"];
			}];
		}
		else {
			[SVProgressHUD showSuccessWithStatus:@"无法下载图片，请稍后再试。"];
		}
	}];
}

- (void)collectionBtnClick
{
	OWTAsset * asset = _assets[_imageNum];
	OWTAuthManager * am = GetAuthManager();
	NSMutableSet * _belongingAlbums;
	
	if (!am.isAuthenticated) {
		SIAlertView * alertView = [[SIAlertView alloc] initWithTitle:@"请登录" andMessage:@"收藏相关功能需要登录后使用"];
		[alertView addButtonWithTitle:@"登录"
		type:SIAlertViewButtonTypeDefault
		handler:^(SIAlertView * alertView) {
			dispatch_async(dispatch_get_main_queue(),
			^{
				//                                                     [am showAuthViewConWithSuccess:^{
				//
				//                                                         OWTAssetManager* am = GetAssetManager();
				//
				//                                                         [SVProgressHUD show];
				//                                                         [am updateAsset:asset
				//                                                         belongingAlbums:_belongingAlbums
				//                                                                 success:^{
				//                                                                     [SVProgressHUD showSuccessWithStatus:@"收藏成功"];
				//                                                                     [SVProgressHUD dismiss];
				//                                                                 }
				//                                                                 failure:^(NSError* error) {
				//                                                                     [SVProgressHUD showErrorWithStatus:@"收藏失败"];
				//                                                                 }];
				//
				//
				//                                                     }
				//                                                                             cancel:^{
				//                                                                             }];
			});
			[alertView dismissAnimated:YES];
		}];
		
		[alertView addButtonWithTitle:@"取消"
		type:SIAlertViewButtonTypeCancel
		handler:^(SIAlertView * alertView) {
			[alertView dismissAnimated:YES];
		}];
		
		alertView.transitionStyle = SIAlertViewTransitionStyleFade;
		[alertView show];
	}
	else {
		// 写收藏
		
		OWTAssetManager * am = GetAssetManager();
		
		[SVProgressHUD show];
		[am updateAsset:asset
		belongingAlbums:_belongingAlbums
		success:^{
			[SVProgressHUD showSuccessWithStatus:@"收藏成功"];
		}
		failure:^(NSError * error) {
			[SVProgressHUD showErrorWithStatus:@"收藏失败"];
		}];
	}
}

- (void)shareBtnClick
{
	OWTAsset * asset = _assets[_imageNum];
	
	[SVProgressHUD showWithStatus:@"准备图片中..." maskType:SVProgressHUDMaskTypeBlack];
	
	SDWebImageManager * manager = [SDWebImageManager sharedManager];
	NSURL * url = [NSURL URLWithString:asset.imageInfo.url];
	
	[manager downloadWithURL:url
	options:SDWebImageHighPriority
	progress:nil
	completed:^(UIImage * image, NSError * error, SDImageCacheType cacheType, BOOL finished) {
		[SVProgressHUD dismiss];
		[UMSocialData defaultData].extConfig.wxMessageType = UMSocialWXMessageTypeImage;
		[UMSocialData defaultData].extConfig.qqData.qqMessageType = UMSocialQQMessageTypeImage;
		[UMSocialSnsService presentSnsIconSheetView:_viewContoller
		appKey:nil
		shareText:nil
		shareImage:image
		shareToSnsNames:[NSArray arrayWithObjects:UMShareToWechatSession, UMShareToWechatTimeline, UMShareToSina, UMShareToWechatFavorite, UMShareToQzone, UMShareToQQ, UMShareToSms, nil]
		delegate:nil];
	}];
}

- (void)onCommentTap:(UITapGestureRecognizer *)sender
{
	LJComment * ljcomment = [[LJComment alloc]init];
	OWTUser * ownerUser = [[OWTUser alloc]init];
	
	if (sender.view.tag < 600) {
		ljcomment = _comments[sender.view.tag - 500];
		ownerUser = [GetUserManager() userForID:ljcomment.userid];
	}
	else {
		ljcomment = _comments[sender.view.tag - 600];
		ownerUser = [GetUserManager() userForID:ljcomment.replyuserid];
	}
	
	if (ownerUser != nil) {
		OWTUserViewCon * userViewCon1 = [[OWTUserViewCon alloc] initWithNibName:nil bundle:nil];
		userViewCon1.hidesBottomBarWhenPushed = YES;
		[_viewContoller.navigationController pushViewController:userViewCon1 animated:YES];
		userViewCon1.user = ownerUser;
	}
}

- (void)onReplyTap:(UITapGestureRecognizer *)sender
{
	LJComment * ljcomment = _comments[sender.view.tag - 600];
	
	if ([ljcomment.userid isEqualToString:GetUserManager().currentUser.userID])
		_viewContoller.replyid = nil;
	else
		_viewContoller.replyid = ljcomment.userid; commentcb(_activity, _number);
}

- (void)onTap3
{
	_headerImagecb();
}

- (void)onTapBigImage:(UIGestureRecognizer *)sender
{
	OWTAsset * asset = [[OWTAsset alloc]init];
	
	[asset mergeWithData:_assets[sender.view.tag - 400]];
	
	OWTAssetViewCon * assetViewCon = [[OWTAssetViewCon alloc] initWithAsset:asset deletionAllowed:NO onDeleteAction:^{[_viewContoller reloadData:_number]; }];
	assetViewCon.isSquare = YES;
	assetViewCon.hidesBottomBarWhenPushed = YES;
	[_viewContoller.navigationController pushViewController:assetViewCon animated:NO];
}

- (void)onTapSmallImage:(UIGestureRecognizer *)sender
{
	_imageNum = sender.view.tag - 400;
	isSmallImageTap = YES;
	
	[_bigImageScrollView setContentOffset:CGPointMake(_imageNum * (SCREENWIT - 10), 0) animated:YES];
	
	for (UIView * view in self.contentView.subviews) {
		if ([view isKindOfClass:[UIScrollView class]])
			for (UIView * view1 in view.subviews)
				if ((view1.tag >= 600) && (view1.tag <= 620)) {
					if (view1.tag == 600 + _imageNum)
						view1.backgroundColor = [UIColor colorWithHexString:@"#ff2a00"];
					else
						view1.backgroundColor = [UIColor whiteColor];
				}
	}
}

#pragma mark setUpCell
- (void)customCell:(NSArray *)assets withUserInformation:(NSArray *)users withLike:(NSArray *)like withComment:(NSArray *)comment withActivityData:(OWTActivityData *)activityData withImageNumber:(NSInteger)number;
{
	_imageNum = number;
	_viewContoller.height = 0;
	_assets = [[NSMutableArray alloc]initWithArray:assets];
	_likes = [[NSMutableArray alloc]initWithArray:like];
	_comments = [[NSMutableArray alloc]initWithArray:comment];
	_activity = [[OWTActivityData alloc]init];
	_activity = activityData;
	CGFloat cellHeight = 0;
	
	for (OWTUser * user in users)
		if ([activityData.userID isEqualToString:user.userID]) {
			[_headerImageView setImageWithURL:[NSURL URLWithString:user.avatarImageInfo.url] placeholderImage:nil];
			CGSize size = [user.nickname sizeWithFont:[UIFont systemFontOfSize:12] constrainedToSize:CGSizeMake(300, 200)];
			_userName.frame = CGRectMake(65, 13, size.width, size.height);
			_userName.text = user.nickname;
			break;
		}
		
	_upTime.frame = CGRectMake(65, 30, 100, 10);
	_upTime.text = [self getTheTime:activityData.timestamp];
	
	cellHeight += 45;
	CGFloat x = SCREENWIT - 10;
	CGFloat height;
	CGFloat width;
	OWTAsset * asset = assets[number];
	OWTAsset * asset1 = [[OWTAsset alloc]init];
	[asset1 mergeWithData:(OWTAssetData *)asset];
	
	if ([self isLike:like]) {
		_likeBtn.selected = YES;
		[_likeBtn setBackgroundImage:[UIImage imageNamed:@"圈子5_32.png"] forState:UIControlStateNormal];
	}
	else {
		_likeBtn.selected = NO;
		[_likeBtn setBackgroundImage:[UIImage imageNamed:@"圈子5_31.png"] forState:UIControlStateNormal];
	}
	
	UIImageView * ImageView;
	
	if (assets.count == 1) {
		_bigImageScrollView.frame = CGRectZero;
		_bigImageScrollView.hidden = YES;
		
		if (asset.imageInfo.width > asset.imageInfo.height) {
			height = x / asset.imageInfo.width * asset.imageInfo.height;
			ImageView = [[UIImageView alloc]initWithFrame:CGRectMake(5, cellHeight + 10, x, height)];
			cellHeight += (10 + height);
		}
		else {
			width = x / asset.imageInfo.height * asset.imageInfo.width;
			ImageView = [[UIImageView alloc]initWithFrame:CGRectMake(5 + (x - width) / 2, cellHeight + 10, width, x)];
			cellHeight += (10 + x);
		}
		ImageView.tag = 400 + number;
		ImageView.userInteractionEnabled = YES;
		[ImageView setImageWithURL:[NSURL URLWithString:asset.imageInfo.url]];
		[self.contentView addSubview:ImageView];
		UITapGestureRecognizer * bigImageTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onTapBigImage:)];
		[ImageView addGestureRecognizer:bigImageTap];
	}
	else {
		_bigImageScrollView.frame = CGRectMake(5, cellHeight + 10, x, x);
		_bigImageScrollView.hidden = NO;
		NSInteger pa = 0;
		
		for (OWTAsset * asset1 in assets) {
			if (asset1.imageInfo.width > asset1.imageInfo.height) {
				height = x / asset1.imageInfo.width * asset1.imageInfo.height;
				ImageView = [[UIImageView alloc]initWithFrame:CGRectMake(pa * x, (x - height) / 2, x, height)];
			}
			else {
				width = x / asset1.imageInfo.height * asset1.imageInfo.width;
				ImageView = [[UIImageView alloc]initWithFrame:CGRectMake(pa * x + (x - width) / 2, 0, width, x)];
			}
			ImageView.tag = 400 + pa;
			ImageView.userInteractionEnabled = YES;
			[ImageView setImageWithURL:[NSURL URLWithString:asset1.imageInfo.url]];
			[_bigImageScrollView addSubview:ImageView];
			UITapGestureRecognizer * bigImageTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onTapBigImage:)];
			[ImageView addGestureRecognizer:bigImageTap];
			pa++;
		}
		
		cellHeight += (10 + x);
		_bigImageScrollView.pagingEnabled = YES;
		_bigImageScrollView.contentSize = CGSizeMake(x * pa, x);
	}
	float c = (x - 30) / 5;
	_scrollView.frame = CGRectMake(9, cellHeight + 4, x - 8, c + 2);
	int i = 0;
	
	if (assets.count > 1) {
		for (OWTAsset * asset in assets) {
			UIImageView * imageView1 = [[UIImageView alloc]initWithFrame:CGRectMake((c + 5) * i, 0, c + 2, c + 2)];
			
			if (i == number)
				imageView1.backgroundColor = [UIColor colorWithHexString:@"#0090ff"];
			imageView1.tag = 600 + i;
			[_scrollView addSubview:imageView1];
			UIImageView * imageView = [[UIImageView alloc]initWithFrame:CGRectMake((c + 5) * i + 1, 1, c, c)];
			imageView.userInteractionEnabled = YES;
			imageView.tag = 400 + i;
			imageView.backgroundColor = [UIColor whiteColor];
			[imageView setImageWithURL:[NSURL URLWithString:asset.imageInfo.smallURL]];
			[_scrollView addSubview:imageView];
			UITapGestureRecognizer * smallImageTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onTapSmallImage:)];
			[imageView addGestureRecognizer:smallImageTap];
			i++;
		}
		
		_scrollView.contentSize = CGSizeMake((c + 5) * i - 5, c);
		cellHeight += (c + 5);
	}
	
	if (asset.caption.length > 0) {
		CGSize size = [asset.caption sizeWithFont:[UIFont systemFontOfSize:12] constrainedToSize:CGSizeMake(x, 100)];
		_caption.frame = CGRectMake(10, cellHeight + 7, size.width, size.height);
		_caption.text = asset.caption;
		cellHeight += (size.height + 7);
	}
	else {
		_caption.text = nil;
		_caption.frame = CGRectZero;
	}
	_likeBtn.frame = CGRectMake(SCREENWIT - 230, cellHeight + 5, 45, 30);
	_downLoadBtn.frame = CGRectMake(SCREENWIT - 185, cellHeight + 5, 45, 30);
	_collectionBtn.frame = CGRectMake(SCREENWIT - 140, cellHeight + 5, 45, 30);
	_shareBtn.frame = CGRectMake(SCREENWIT - 95, cellHeight + 5, 45, 30);
	_commentBtn.frame = CGRectMake(SCREENWIT - 50, cellHeight + 5, 45, 30);
	_line1.frame = CGRectMake(5, cellHeight + 5, SCREENWIT - 10, 0.2);
	_line2.frame = CGRectMake(5, cellHeight + 35 - 0.1, SCREENWIT - 10, 0.2);
	cellHeight += 40;
	CGFloat likeHeight = 0;
	CGFloat imageHeight = (SCREENWIT - 100) / 9;
	
	if (like.count != 0) {
		CGFloat likeWidth = 10;
		CGFloat likeheight = 0;
		
		for (NSInteger i = 0; i < like.count; i++) {
			LJLike * ljlike = like[i];
			NSString * likeBodys = [self getTheLikeImage:ljlike.likeUserid withUser:users];
			
			if (likeWidth + imageHeight + 10 > SCREENWIT) {
				likeWidth = 0;
				likeHeight += (imageHeight + 10);
			}
			UIImageView * likebody = [LJUIController createImageViewWithFrame:CGRectMake(likeWidth, cellHeight + likeHeight, imageHeight, imageHeight) imageName:nil];
			[likebody setImageWithURL:[NSURL URLWithString:likeBodys]];
			UITapGestureRecognizer * liketap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onLikeTap:)];
			likebody.userInteractionEnabled = YES;
			likebody.tag = 700 + i;
			[likebody addGestureRecognizer:liketap];
			[self.contentView addSubview:likebody];
			likeWidth = likeWidth + imageHeight + 10;
		}
		
		likeHeight += imageHeight;
	}
	cellHeight += likeHeight;
	
	if ((like.count != 0) && (comment.count != 0)) {
		_line3.hidden = NO;
		_line3.frame = CGRectMake(5, cellHeight + 4, SCREENWIT - 10, 0.2);
	}
	else {
		_line3.hidden = YES;
	}
	CGFloat commentHeight = 0;
	
	if (comment.count != 0) {
		cellHeight += 5;
		
		for (NSInteger i = 0; i < comment.count; i++) {
			LJComment * ljcomment = comment[i];
			NSString * imageurl = [self getTheLikeImage:ljcomment.userid withUser:users];
			UIImageView * commentImage = [LJUIController createImageViewWithFrame:CGRectMake(10, cellHeight + commentHeight + 3, imageHeight, imageHeight) imageName:nil];
			commentImage.tag = 500 + i;
			UITapGestureRecognizer * commentTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onCommentTap:)];
			commentImage.userInteractionEnabled = YES;
			[commentImage setImageWithURL:[NSURL URLWithString:imageurl]];
			[commentImage addGestureRecognizer:commentTap];
			[self.contentView addSubview:commentImage];
			
			if ([ljcomment.replyuserid isEqualToString:@"0"]) {
				NSString * name = [self getTheNickname:ljcomment.userid withUser:users];
				NSString * commentContent = [NSString stringWithFormat:@"%@", ljcomment.content];
				NSString * commentText = [NSString stringWithFormat:@"%@:%@", name, commentContent];
				NSMutableAttributedString * attString = [[NSMutableAttributedString alloc]initWithString:commentText];
				NSRange range1 = [commentText rangeOfString:name];
				[attString addAttribute:NSForegroundColorAttributeName value:GetThemer().themeTintColor range:range1];
				CGSize size2 = [commentText sizeWithFont:[UIFont systemFontOfSize:12] constrainedToSize:CGSizeMake(SCREENWIT - 20 - imageHeight, 500)];
				UILabel * commentLabel = [LJUIController createLabelWithFrame:CGRectMake(15 + imageHeight, cellHeight + commentHeight + 3, size2.width, size2.height) Font:12 Text:nil];
				commentLabel.attributedText = attString;
				commentLabel.tag = 600 + i;
				commentLabel.userInteractionEnabled = YES;
				UITapGestureRecognizer * replyTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onReplyTap:)];
				[commentLabel addGestureRecognizer:replyTap];
				[self.contentView addSubview:commentLabel];
				
				if (size2.height > imageHeight)
					commentHeight = commentHeight + size2.height + 5;
				else
					commentHeight = commentHeight + imageHeight + 5;
			}
			else {
				NSString * name1 = [self getTheNickname:ljcomment.userid withUser:users];
				NSString * name2 = [self getTheNickname:ljcomment.replyuserid withUser:users];
				NSString * commentContent = [NSString stringWithFormat:@"%@", ljcomment.content];
				NSString * commentText = [NSString stringWithFormat:@"%@回复%@:%@", name1, name2, commentContent];
				NSMutableAttributedString * attString = [[NSMutableAttributedString alloc]initWithString:commentText];
				NSRange range1 = [commentText rangeOfString:name1];
				NSRange range2 = [commentText rangeOfString:name2];
				[attString addAttribute:NSForegroundColorAttributeName value:GetThemer().themeTintColor range:range1];
				[attString addAttribute:NSForegroundColorAttributeName value:GetThemer().themeTintColor range:range2];
				CGSize size2 = [commentText sizeWithFont:[UIFont systemFontOfSize:12] constrainedToSize:CGSizeMake(SCREENWIT - 20 - imageHeight, 500)];
				UILabel * commentLabel = [LJUIController createLabelWithFrame:CGRectMake(15 + imageHeight, cellHeight + commentHeight + 3, size2.width, size2.height) Font:12 Text:nil];
				commentLabel.attributedText = attString;
				commentLabel.tag = 600 + i;
				commentLabel.userInteractionEnabled = YES;
				UITapGestureRecognizer * replyTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onReplyTap:)];
				[commentLabel addGestureRecognizer:replyTap];
				[self.contentView addSubview:commentLabel];
				
				if (size2.height > imageHeight)
					commentHeight = commentHeight + size2.height + 5;
				else
					commentHeight = commentHeight + imageHeight + 5;
			}
		}
	}
	cellHeight += commentHeight;
	_backView.frame = CGRectMake(5, 5, SCREENWIT - 10, cellHeight);
}

- (NSArray *)getTheAllCellHeight:(NSArray *)assets1 withUserInformation:(NSArray *)users withLike:(NSArray *)like1 withComment:(NSArray *)comment1 withActivityData:(NSArray *)activityData
{
	NSMutableArray * arr = [[NSMutableArray alloc]init];
	
	for (NSInteger i = 0; i < activityData.count; i++) {
		NSArray * assets = assets1[i];
		NSArray * like = like1[i];
		NSArray * comment = comment1[i];
		float cellHeight = 0;
		CGFloat height = 0;
		OWTAsset * asset = assets[0];
		CGFloat x = SCREENWIT - 10;
		height = x / asset.imageInfo.width * asset.imageInfo.height;
		float c;
		
		if (assets.count > 1) {
			c = (x - 40) / 5 + 5;
		}
		else {
			c = 0;
			
			if (asset.imageInfo.width > asset.imageInfo.height) {
				height = x / asset.imageInfo.width * asset.imageInfo.height;
				x = height;
			}
		}
		
		if (asset.caption.length > 0) {
			CGSize size = [asset.caption sizeWithFont:[UIFont systemFontOfSize:12] constrainedToSize:CGSizeMake(x, 100)];
			cellHeight = 50 + 10 + x + c + 47 + size.height;
		}
		else {
			cellHeight = 50 + 10 + x + c + 40;
		}
		CGFloat likeHeight = 0;
		CGFloat imageHeight = (SCREENWIT - 100) / 9;
		
		if (like.count != 0) {
			cellHeight += 3;
			CGFloat likeWidth = 10;
			CGFloat likeheight = 0;
			
			for (NSInteger i = 0; i < like.count; i++) {
				LJLike * ljlike = like[i];
				NSString * likeBodys = [self getTheLikeImage:ljlike.likeUserid withUser:users];
				
				if (likeWidth + imageHeight + 10 > SCREENWIT) {
					likeWidth = 0;
					likeHeight += (imageHeight + 10);
				}
				UIImageView * likebody = [LJUIController createImageViewWithFrame:CGRectMake(likeWidth, cellHeight + likeHeight, imageHeight, imageHeight) imageName:nil];
				[likebody setImageWithURL:[NSURL URLWithString:likeBodys]];
				UITapGestureRecognizer * liketap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onLikeTap:)];
				likebody.userInteractionEnabled = YES;
				likebody.tag = 700 + i;
				[likebody addGestureRecognizer:liketap];
				[self.contentView addSubview:likebody];
				likeWidth = likeWidth + imageHeight + 10;
			}
			
			likeHeight += imageHeight;
		}
		cellHeight += likeHeight;
		CGFloat commentHeight = 0;
		
		if (comment.count != 0) {
			cellHeight += 5;
			
			for (NSInteger i = 0; i < comment.count; i++) {
				LJComment * ljcomment = comment[i];
				
				if ([ljcomment.replyuserid isEqualToString:@"0"]) {
					NSString * name = [self getTheNickname:ljcomment.userid withUser:users];
					NSString * commentContent = [NSString stringWithFormat:@"%@", ljcomment.content];
					NSString * commentText = [NSString stringWithFormat:@"%@:%@", name, commentContent];
					CGSize size2 = [commentText sizeWithFont:[UIFont systemFontOfSize:12] constrainedToSize:CGSizeMake(SCREENWIT - 20 - imageHeight, 500)];
					
					if (size2.height > imageHeight)
						commentHeight = commentHeight + size2.height + 5;
					else
						commentHeight = commentHeight + imageHeight + 5;
				}
				else {
					NSString * name1 = [self getTheNickname:ljcomment.userid withUser:users];
					NSString * name2 = [self getTheNickname:ljcomment.replyuserid withUser:users];
					NSString * commentContent = [NSString stringWithFormat:@"%@", ljcomment.content];
					NSString * commentText = [NSString stringWithFormat:@"%@回复%@:%@", name1, name2, commentContent];
					CGSize size2 = [commentText sizeWithFont:[UIFont systemFontOfSize:12] constrainedToSize:CGSizeMake(SCREENWIT - 20 - imageHeight, 500)];
					
					if (size2.height > imageHeight)
						commentHeight = commentHeight + size2.height + 5;
					else
						commentHeight = commentHeight + imageHeight + 5;
				}
			}
		}
		cellHeight += commentHeight;
		NSString * str = [NSString stringWithFormat:@"%f", cellHeight];
		[arr addObject:str];
	}
	
	return arr;
}

#pragma mark   scrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView;
{
	CGFloat x = SCREENWIT - 10;
	float c = x / 5;
	
	if (scrollView == _bigImageScrollView) {
		NSInteger imageNumber = scrollView.contentOffset.x / x;
		_imageNum = imageNumber;
		
		if ((imageNumber > 4) && (isSmallImageTap == NO))
			[_scrollView setContentOffset:CGPointMake(c * (imageNumber - 4), 0) animated:YES];
		isSmallImageTap = NO;
		
		for (UIView * view in self.contentView.subviews) {
			if ([view isKindOfClass:[UIScrollView class]])
				for (UIView * view1 in view.subviews)
					if ((view1.tag >= 600) && (view1.tag <= 620)) {
						if (view1.tag == 600 + imageNumber)
							view1.backgroundColor = [UIColor colorWithHexString:@"#0090ff"];
						else
							view1.backgroundColor = [UIColor whiteColor];
					}
		}
	}
}

- (BOOL)isLike:(NSArray *)like
{
	for (LJLike * ljlike in like)
		if ([_user.userID isEqualToString:ljlike.likeUserid])
			return YES;
			
	return NO;
}

- (NSString *)getTheNickname:(NSString *)userid withUser:(NSArray *)users
{
	for (OWTUser * user in users)
		if ([userid isEqualToString:user.userID])
			return [NSString stringWithFormat:@"%@", user.nickname];
			
	if ([userid isEqualToString:_user.userID])
		return _user.nickname;
		
	return nil;
}

- (NSString *)getTheLikeImage:(NSString *)likeBody withUser:(NSArray *)user
{
	for (OWTUser * userBody in user)
		if ([likeBody isEqualToString:userBody.userID])
			return userBody.avatarImageInfo.smallURL;
			
	if ([likeBody isEqualToString:_user.userID])
		return _user.avatarImageInfo.smallURL;
		
	return nil;
}

- (NSString *)getTheLikeBody:(LJLike *)likeBody withUser:(NSArray *)user
{
	for (OWTUser * userBody in user)
		if ([likeBody.likeUserid isEqualToString:userBody.userID])
			return [NSString stringWithFormat:@"%@", userBody.nickname];
			
	if ([likeBody.likeUserid isEqualToString:_user.userID])
		return _user.nickname;
		
	return nil;
}

- (NSString *)getTheTime:(NSNumber *)timeStamp
{
	int b = timeStamp.intValue;
	NSDate * date = [NSDate dateWithTimeIntervalSince1970:b];
	NSDate * now = [NSDate date];
	NSTimeInterval apartTime = [now timeIntervalSinceDate:date];
	int a = (int)apartTime;
	
	if (a / 86400 != 0) {
		return [NSString stringWithFormat:@"%d天前", a / 86400];
	}
	else {
		if (a / 3600 != 0) {
			return [NSString stringWithFormat:@"%d小时前", a / 3600];
		}
		else {
			if (a / 60 != 0)
				return [NSString stringWithFormat:@"%d分钟前", a / 60];
			else
			
				return @"刚刚";
		}
	}
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
	[super setSelected:selected animated:animated];
	
	// Configure the view for the selected state
}

- (void)markLikedByMe:(BOOL)liked
	success:(void (^)())success
	failure:(void (^)())failure withAsset:(OWTAsset *)asset
{
	[SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];
	
	NSString * action = liked ? @"like" : @"unlike";
	
	RKObjectManager * om = [RKObjectManager sharedManager];
	[om postObject:nil
	path:[NSString stringWithFormat:@"assets/%@/likes", asset.assetID]
	parameters:@{@"action" : action}
	success:^(RKObjectRequestOperation * o, RKMappingResult * result) {
		[o logResponse];
		
		NSDictionary * resultObjects = result.dictionary;
		OWTServerError * error = resultObjects[@"error"];
		
		if (error != nil) {
			[SVProgressHUD showServerError:error];
			
			if (failure != nil)
				failure();
			return;
		}
		
		OWTUser * currentUser = GetUserManager().currentUser;
		OWTAssetData * assetData = _assets[_imageNum];
		NSMutableArray * likeBodys = [[NSMutableArray alloc]initWithArray:assetData.likedUserIDs];
		
		if (liked) {
			[likeBodys addObject:currentUser.userID];
			assetData.likedUserIDs = likeBodys;
			[_assets replaceObjectAtIndex:_imageNum withObject:assetData];
			[_viewContoller.assets replaceObjectAtIndex:_number withObject:_assets];
			currentUser.assetsInfo.likedAssetNum = currentUser.assetsInfo.likedAssetNum + 1;
			currentUser.assetsInfo.likedAssets = nil;
		}
		else {
			[likeBodys removeObject:currentUser.userID];
			[_assets replaceObjectAtIndex:_imageNum withObject:assetData];
			assetData.likedUserIDs = likeBodys;
			[_viewContoller.assets replaceObjectAtIndex:_number withObject:_assets];
			currentUser.assetsInfo.likedAssetNum = currentUser.assetsInfo.likedAssetNum - 1;
			
			if (currentUser.assetsInfo.likedAssetNum < 0)
				currentUser.assetsInfo.likedAssetNum = 0;
			currentUser.assetsInfo.likedAssets = nil;
		}
		
		// 这里要做点什么
		
		[SVProgressHUD dismiss];
		
		if (success != nil)
			success();
	}
	failure:^(RKObjectRequestOperation * o, NSError * error) {
		[o logResponse];
		[SVProgressHUD showError:error];
		
		if (failure != nil)
			failure();
	}
	];
}

@end
