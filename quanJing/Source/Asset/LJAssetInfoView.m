//
//  LJAssetInfoView.m
//  Weitu
//
//  Created by qj-app on 15/8/25.
//  Copyright (c) 2015年 SparkingSoft Co., Ltd. All rights reserved.
//

#import "LJAssetInfoView.h"
#import "OWTAsset.h"
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
#import "UIImageView+AFNetworking.h"
#import "FSBasicImage.h"
#import "FSBasicImageSource.h"
#import "LJAssetLikeModel.h"
#import "OWTComment.h"
#import "OWTUserViewCon.h"
#import "UIColor+HexString.h"

@implementation LJAssetInfoView
{
	UILabel * _line1;
	UILabel * _line2;
	UIImageView * _heartView;
	UILabel * _openComment;
	NSArray * _likes;
	UIImageView * _commentView;
	UIImageView * _backgroudView;
	UIImageView * _commentBackView;
	UIButton * _reportBtn;
	UIButton * _reportTapBtn;
	UIView * _tapBackView;
	UITapGestureRecognizer * _tap1;
}
- (instancetype)init
{
	self = [super init];
	
	if (self) {}
	return self;
}

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	
	if (self)
		[self customUI];
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	
	if (self)
		[self setup];
	return self;
}

- (void)setup
{}

- (void)customUI
{
	self.backgroundColor = [UIColor whiteColor];
	_backgroudView = [[UIImageView alloc]initWithFrame:CGRectZero];
	_backgroudView.backgroundColor = [UIColor whiteColor];
	[self addSubview:_backgroudView];
	_likes = [[NSArray alloc]init];
	_assetImageView = [LJUIController createImageViewWithFrame:CGRectZero imageName:nil];
	[self addSubview:_assetImageView];
	_downloadButton = [LJUIController createButtonWithFrame:CGRectZero imageName:nil title:nil target:self action:@selector(downLoadClick)];
	_collectButton = [LJUIController createButtonWithFrame:CGRectZero imageName:nil title:nil target:self action:@selector(collectClick)];
	_shareButton = [LJUIController createButtonWithFrame:CGRectZero imageName:nil title:nil target:self action:@selector(shareClick)];
	_likeButton = [LJUIController createButtonWithFrame:CGRectZero imageName:nil title:nil target:self action:@selector(likeClick)];
	NSArray * buttons = @[_likeButton, _downloadButton, _collectButton, _shareButton];
	NSArray * images = @[@"赞00.png", @"下载图标0.png", @"收藏五角星0.png", @"分享.png"];
	int i = 0;
	
	for (UIButton * btn in buttons) {
		[btn setBackgroundImage:[UIImage imageNamed:images[i]] forState:UIControlStateNormal];
		i++;
	}
	
	_captionLabel = [LJUIController createLabelWithFrame:CGRectZero Font:13 Text:nil];
	_userID = [LJUIController createLabelWithFrame:CGRectZero Font:13 Text:nil];
	
	_reportBtn = [LJUIController createButtonWithFrame:CGRectMake(SCREENWIT - 10 - 40, _userID.frame.origin.y, 40, 17.5) imageName:@"举报" title:@"" target:self action:@selector(reportAction:)];
	
	[self addSubview:_downloadButton];
	[self addSubview:_collectButton];
	[self addSubview:_shareButton];
	[self addSubview:_likeButton];
	[self addSubview:_captionLabel];
	[self addSubview:_userID];
	// [self addSubview:_reportBtn];
	
	_openComment = [LJUIController createLabelWithFrame:CGRectZero Font:12 Text:@"查看全部评论"];
	_openComment.userInteractionEnabled = YES;
	[self addSubview:_openComment];
	UITapGestureRecognizer * openCom = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openCommentTap:)];
	[_openComment addGestureRecognizer:openCom];
	_heartView = [LJUIController createImageViewWithFrame:CGRectZero imageName:@"赞小标.png"];
	_commentView = [LJUIController createImageViewWithFrame:CGRectZero imageName:@"评论小标.png"];
	[self addSubview:_commentView];
	[self addSubview:_heartView];
	_commentBackView = [LJUIController createImageViewWithFrame:CGRectZero imageName:nil];
	UIImage * backImage = [UIImage imageNamed:@"聊天背景框"];
	//    backImage=[backImage stretchableImageWithLeftCapWidth:0 topCapHeight:50];
	backImage = [backImage resizableImageWithCapInsets:UIEdgeInsetsMake(10, 50, 5, 50)];
	_commentBackView.image = backImage;
	[self addSubview:_commentBackView];
	_line1 = [LJUIController createLabelWithFrame:CGRectZero Font:12 Text:nil];
	
	_line1.backgroundColor = [UIColor grayColor];
	[self addSubview:_line1];
	
	_reportTapBtn = [LJUIController createButtonWithFrame:CGRectMake(0, 0, 57, 41) imageName:@"jubao" title:nil target:self action:@selector(jubao)];
	_reportTapBtn.hidden = YES;
	[_assetImageView addSubview:_reportTapBtn];
	
	_tapBackView = [[UIView alloc]initWithFrame:CGRectZero];
	[_assetImageView addSubview:_tapBackView];
	[_assetImageView sendSubviewToBack:_assetImageView];
	
	_tap1 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onClickBack:)];
	[_tapBackView addGestureRecognizer:_tap1];
	_tapBackView.hidden = YES;
	UILongPressGestureRecognizer * LongP = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(onLongAction:)];
	
	[_assetImageView addGestureRecognizer:LongP];
}

- (void)onClickBack:(UIGestureRecognizer *)sender
{
	_reportTapBtn.hidden = YES;
	_tapBackView.hidden = YES;
}

- (void)jubao
{
	RKObjectManager * om = [RKObjectManager sharedManager];
	
	// OWTAsset * asset1 = _asset[_imageNum];
	_reportTapBtn.hidden = YES;
	_tapBackView.hidden = YES;
	NSDictionary * dict = @{@"url":_asset.url};
	[om postObject:nil path:@"report" parameters:dict success:^(RKObjectRequestOperation * operation, RKMappingResult * mappingResult) {
		[SVProgressHUD showSuccessWithStatus:@"举报成功"];
	} failure:^(RKObjectRequestOperation * operation, NSError * error) {
		NSLog(@"%@", error);
	}];
}

- (void)onLongAction:(UIGestureRecognizer *)sender
{
	_reportTapBtn.hidden = NO;
	_reportTapBtn.center = CGPointMake(_assetImageView.bounds.size.width / 2, _assetImageView.bounds.size.height / 2);
	_tapBackView.hidden = NO;
	[_assetImageView bringSubviewToFront:_tapBackView];
	[_assetImageView bringSubviewToFront:_reportTapBtn];
}

- (void)setUpUI
{
	_avatarImageView.clipsToBounds = YES;
	_avatarImageView.layer.cornerRadius = 16;
	
	UITapGestureRecognizer * gr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(usernameButtonPressed:)];
	[_avatarImageView addGestureRecognizer:gr];
	
	UIImage * heartImage = [[FAKFontAwesome heartIconWithSize:12] imageWithSize:CGSizeMake(12, 12)];
	[_likesImageView setTintColor:[UIColor darkGrayColor]];
	_likesImageView.image = [heartImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
	
	NSArray * buttons = @[_downloadButton, _collectButton, _shareButton];
	
	for (QBFlatButton * button in buttons) {
		button.cornerRadius = 0;
		button.height = 0.5;
		button.depth = 0;
		
		[button setSurfaceColor:[UIColor colorWithWhite:1.0 alpha:1] forState:UIControlStateNormal];
		[button setSurfaceColor:GetThemer().themeColor forState:UIControlStateHighlighted];
		button.sideColor = [UIColor colorWithWhite:0.69 alpha:1];
		
		[button setTitleColor:GetThemer().themeColor forState:UIControlStateNormal];
		[button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
		button.titleLabel.textColor = GetThemer().themeColor;
		button.titleLabel.font = [UIFont systemFontOfSize:15];
	}
	
	__weak LJAssetInfoView * wself = self;
	
	_latestCommentsView.showAllCommentsAction = ^{
		if (wself.showAllCommentsAction != nil)
			wself.showAllCommentsAction();
	};
}

- (void)customViewWithAsset:(QJImageObject *)asset withOpen:(BOOL)isOpen withController:(OWTAssetViewCon *)controller isLikeTrigger:(BOOL)trigger
{
	_likes = [[asset.likes reverseObjectEnumerator] allObjects];
	_controller = controller;
	_asset = asset;
	_taptrigger = trigger;
	CGFloat viewHeight = 0;
	// 头像定制
	float width = [_asset.width floatValue];
	float height = [_asset.height floatValue];
	float scr = SCREENWIT - 20;
	_assetImageView.frame = CGRectMake(10, 10, SCREENWIT - 20, scr / width * height);
	NSString * adpatUrl = [QJInterfaceManager thumbnailUrlFromImageUrl:_asset.url originalSize:CGSizeMake(_asset.width.floatValue, _asset.height.floatValue) size:CGSizeMake(scr, scr / width * height)];
	_assetImageView.backgroundColor = [UIColor clearColor];
	_assetImageView.alpha = 0.0;
	__weak UIImageView * weakImageView = _assetImageView;
	[_assetImageView setImageWithURL:[NSURL URLWithString:adpatUrl]
	completed:^(UIImage * image, NSError * error, SDImageCacheType cacheType) {
		if (cacheType == SDImageCacheTypeNone) {
			[UIView animateWithDuration:0.3
			animations:^{
				weakImageView.alpha = 1.0;
			}];
			return;
		}
		weakImageView.alpha = 1.0;
	}];
	
	UITapGestureRecognizer * tapRecognizerleft = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickImage)];
	[self.assetImageView addGestureRecognizer:tapRecognizerleft];
	viewHeight += (10 + scr / width * height);
	// 标签 编号
	_userID.frame = CGRectMake(10, viewHeight + 10, 200, 20);
	_reportBtn.frame = CGRectMake(SCREENWIT - 10 - 40, _userID.frame.origin.y, 40, 17.5);
	
	// *To do 编号 待补全*/
	if ((_asset.captionCn != nil) && (_asset.captionCn > 0))
		_userID.text = [NSString stringWithFormat:@"编号：%@", _asset.captionCn];
	else
		_userID.text = [NSString stringWithFormat:@"编号：%@", [_asset.imageId stringValue]];
		
	//
	if ((_asset.tag.length > 0) && (_asset.descript == nil)) {
		_captionLabel.hidden = NO;
		_captionLabel.frame = CGRectMake(10, viewHeight + 30, SCREENWIT - 20, 20);
		_captionLabel.text = [NSString stringWithFormat:@"标签：%@", _asset.tag];
		viewHeight += 50;
	}
	else if ((_asset.descript.length > 0) && (_asset.tag == nil)) {
		_captionLabel.hidden = NO;
		_captionLabel.frame = CGRectMake(10, viewHeight + 30, SCREENWIT - 20, 20);
		_captionLabel.text = [NSString stringWithFormat:@"标签：%@", _asset.descript];
		viewHeight += 50;
	}
	else {
		_captionLabel.hidden = YES;
		viewHeight += 30;
	}
	
	// 四个按钮定制
	
	_shareButton.frame = CGRectMake(SCREENWIT - 60, viewHeight + 5, 45, 17.5);
	
	if ([self isLiked:_likes])
		[_likeButton setBackgroundImage:[UIImage imageNamed:@"赞01"] forState:UIControlStateNormal];
	else
		[_likeButton setBackgroundImage:[UIImage imageNamed:@"赞00"] forState:UIControlStateNormal];
	_downloadButton.frame = CGRectMake(SCREENWIT - 115, viewHeight + 5, 45, 17.5);
	_collectButton.frame = CGRectMake(SCREENWIT - 170, viewHeight + 5, 45, 17.5);
	_likeButton.frame = CGRectMake(SCREENWIT - 235, viewHeight + 5, 45, 17.5);
	viewHeight += (10 + 30);
	// 喜欢的人
	float x = scr;
	CGFloat likeHeight = 0;
	CGFloat imageHeight = 20;
	_heartView.hidden = YES;
	
	if (_likes.count != 0) {
		_heartView.hidden = NO;
		_heartView.frame = CGRectMake(25, viewHeight + 4, 12, 12);
		CGFloat likeWidth = 45;
		CGFloat likeheight = 0;
		
		for (NSInteger i = 0; i < _likes.count; i++) {
			QJUser * modelUser = _likes[i];
			
			if (likeWidth + imageHeight + 5 > SCREENWIT - 25) {
				likeWidth = 45;
				likeHeight += (imageHeight + 5);
			}
			UIImageView * likebody = [LJUIController createCircularImageViewWithFrame:CGRectMake(likeWidth, viewHeight + likeHeight, imageHeight, imageHeight) imageName:@"头像"];
			//            likebody.clipsToBounds=YES;
			//            likebody.contentMode=UIViewContentModeCenter;
			
			[likebody setImageWithURL:[NSURL URLWithString:[QJInterfaceManager thumbnailUrlFromImageUrl:modelUser.avatar size:likebody.bounds.size]] placeholderImage:[UIImage imageNamed:@"头像.png"]];
			UITapGestureRecognizer * liketap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onLikeTap:)];
			likebody.userInteractionEnabled = YES;
			likebody.tag = 700 + i;
			[likebody addGestureRecognizer:liketap];
			[self addSubview:likebody];
			likeWidth = likeWidth + imageHeight + 10;
		}
		
		likeHeight += imageHeight;
	}
	viewHeight += likeHeight;
	NSArray * comment = asset.comments;
	
	CGFloat commentHeight = 0;
	_line1.hidden = YES;
	_commentView.hidden = YES;
	
	if (comment.count != 0) {
		if (likeHeight != 0) {
			viewHeight += 20;
			_line1.hidden = NO;
			_line1.frame = CGRectMake(25, viewHeight - 10, SCREENWIT - 40, 0.2);
		}
		_commentView.hidden = NO;
		_commentView.frame = CGRectMake(25, viewHeight + 4, 12, 12);
		
		for (NSInteger i = 0; i < comment.count; i++) {
			QJCommentObject * commentModel = comment[i];
			UIImageView * commentImage = [LJUIController createCircularImageViewWithFrame:CGRectMake(45, viewHeight + commentHeight + 3, imageHeight, imageHeight) imageName:nil];
			commentImage.tag = 500 + i;
			UITapGestureRecognizer * commentTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onCommentTap:)];
			commentImage.userInteractionEnabled = YES;
			[commentImage setImageWithURL:[NSURL URLWithString:commentModel.user.avatar]];
			[commentImage addGestureRecognizer:commentTap];
			[self addSubview:commentImage];
			
			NSString * name = commentModel.user.nickName;
			
			if (commentModel.user.nickName.length == 0)
				name = @"匿名";
			NSString * commentContent = [NSString stringWithFormat:@"%@", commentModel.comment];
			NSString * commentText = [NSString stringWithFormat:@"%@:%@", name, commentContent];
			NSMutableAttributedString * attString = [[NSMutableAttributedString alloc]initWithString:commentText];
			NSRange range1 = [commentText rangeOfString:name];
			[attString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"4c5c8d"] range:range1];
			CGSize size2 = [commentText sizeWithFont:[UIFont systemFontOfSize:12] constrainedToSize:CGSizeMake(SCREENWIT - 75 - imageHeight, 500)];
			UILabel * commentLabel = [LJUIController createLabelWithFrame:CGRectMake(50 + imageHeight, viewHeight + commentHeight + 3, size2.width, size2.height) Font:12 Text:nil];
			commentLabel.attributedText = attString;
			commentLabel.lineBreakMode = NSLineBreakByClipping;
			commentLabel.lineBreakMode = UILineBreakModeClip;
			commentLabel.tag = 600 + i;
			commentLabel.userInteractionEnabled = YES;
			[self addSubview:commentLabel];
			
			if (size2.height > imageHeight)
				commentHeight = commentHeight + size2.height + 5;
			else
				commentHeight = commentHeight + imageHeight + 5;
		}
	}
	else if (likeHeight != 0) {
		viewHeight += 10;
	}
	
	viewHeight += commentHeight;
	_commentBackView.hidden = YES;
	_backgroudView.hidden = YES;
	
	if ((likeHeight != 0) && (commentHeight != 0)) {
		_commentBackView.hidden = NO;
		//        _backgroudView.hidden=NO;
		
		_commentBackView.frame = CGRectMake(15, viewHeight - likeHeight - commentHeight - 20 - 15, SCREENWIT - 28, likeHeight + commentHeight + 15 + 20);
	}
	else if ((likeHeight != 0) && (commentHeight == 0)) {
		_commentBackView.hidden = NO;
		_commentBackView.frame = CGRectMake(15, viewHeight - likeHeight - commentHeight - 10 - 5 - 10, SCREENWIT - 28, likeHeight + commentHeight + 10 + 10);
	}
	else if ((likeHeight == 0) && (commentHeight != 0)) {
		_commentBackView.hidden = NO;
		_commentBackView.frame = CGRectMake(15, viewHeight - likeHeight - commentHeight - 5 - 10, SCREENWIT - 28, likeHeight + commentHeight + 5 + 10);
	}
	
	//    if (comment.count>3) {
	//        _openComment.frame=CGRectMake(10, viewHeight+3, 100, 15);
	//        viewHeight+=20;
	//    }
}

- (BOOL)isLiked:(NSArray *)likes
{
	QJUser * currentUser = [QJPassport sharedPassport].currentUser;
	
	for (QJUser * user in likes)
		if ([user.uid.stringValue isEqualToString:[currentUser.uid stringValue]])
			return YES;
			
	return NO;
}

- (void)setAsset:(OWTAsset *)asset
{
	_asset = asset;
	
	//    [self updateAssetImageView];
	//    [self updateCaptionLabel];
	//    [self updateOwnerUserRelatedViews];
	//    [self updateLikesLabel];
	//    [self updateLatestCommentsView];
	//
	//    [self setNeedsLayout];
}

- (void)clickImage
{
	if (![_reportTapBtn isHidden]) {
		[self onClickBack:nil];
		return;
	}
	
	if (_canClick == YES) {
		if (_showAction != nil)
			_showAction();
		_canClick = NO;
	}
}

- (void)updateCaptionLabel
{
	if ((_asset.tag != nil) && (_asset.tag.length > 0) && (_asset.description == nil)) {
		_captionLabel.hidden = NO;
		_captionLabel.text = [NSString stringWithFormat:@"标签：%@", _asset.tag];
		
		if ((_asset.captionCn != nil) && (_asset.captionCn > 0))
			_picMarkLabel.text = [NSString stringWithFormat:@"编号：%@", _asset.captionCn];
		else
			_picMarkLabel.text = [NSString stringWithFormat:@"编号：%@", [_asset.imageId stringValue]];
	}
	else if ((_asset.tag == nil) && (_asset.description != nil)) {
		_captionLabel.hidden = NO;
		_captionLabel.text = [NSString stringWithFormat:@"标签：%@", _asset.descript];
		
		if ((_asset.captionCn != nil) && (_asset.captionCn > 0))
			_picMarkLabel.text = [NSString stringWithFormat:@"编号：%@", _asset.captionCn];
		else
			_picMarkLabel.text = [NSString stringWithFormat:@"编号：%@", [_asset.imageId stringValue]];
	}
	else {
		_captionLabel.hidden = YES;
		_captionLabel.text = @"";
		
		if ((_asset.captionCn != nil) && (_asset.captionCn > 0))
			_picMarkLabel.text = [NSString stringWithFormat:@"编号：%@", _asset.captionCn];
		else
			_picMarkLabel.text = [NSString stringWithFormat:@"编号：%@", [_asset.imageId stringValue]];
	}
}

- (void)updateLikesLabel
{
	NSInteger likeNum = _asset.likes.count;
	
	if (likeNum == 0)
		_likesLabel.text = @"尚未被喜欢";
	else
		_likesLabel.text = [NSString stringWithFormat:@"%ld人喜欢", (long)likeNum];
}

- (void)updateLatestCommentsView
{
	// [_latestCommentsView setComments:self.asset.comments commentNum:self.asset.commentNum];
}

#pragma mark buttonClick AND  tap
- (void)openCommentTap:(UIGestureRecognizer *)sender
{
	UILabel * label = (UILabel *)sender.view;
	
	if ([label.text isEqualToString:@"查看全部评论"]) {
		_controller.isOpen = YES;
		
		if (_reloadView)
			_reloadView();
		label.text = @"收起评论";
	}
	else {
		_controller.isOpen = NO;
		_reloadView();
		label.text = @"查看全部评论";
	}
}

- (void)reportAction:(UIButton *)sender
{
	if (_reportAction != nil)
		_reportAction();
}

- (void)downLoadClick
{
	if (_downloadAction)
		_downloadAction();
}

- (void)collectClick
{
	if (_collectAction)
		_collectAction();
}

- (void)shareClick
{
	if (_shareAction)
		_shareAction();
}

- (void)likeClick
{
	if (_likeAction)
		_likeAction();
}

- (void)onLikeTap:(UIGestureRecognizer *)sender
{
	QJUser * model = _likes[sender.view.tag - 700];
	
	if (model != nil) {
		OWTUserViewCon * userViewCon1 = [[OWTUserViewCon alloc] initWithNibName:nil bundle:nil];
		userViewCon1.hidesBottomBarWhenPushed = YES;
		[_controller.navigationController pushViewController:userViewCon1 animated:YES];
		userViewCon1.quser = model;
	}
}

- (void)onCommentTap:(UITapGestureRecognizer *)sender
{
	NSArray * _comments = _asset.comments;
	QJCommentObject * ljcomment;
	QJUser * ownerUser;
	
	if (sender.view.tag < 600) {
		ljcomment = _comments[sender.view.tag - 500];
		ownerUser = ljcomment.user;
	}
	
	if (ownerUser != nil) {
		OWTUserViewCon * userViewCon1 = [[OWTUserViewCon alloc] initWithNibName:nil bundle:nil];
		userViewCon1.hidesBottomBarWhenPushed = YES;
		userViewCon1.quser = ownerUser;
		
		[_controller.navigationController pushViewController:userViewCon1 animated:YES];
	}
}

@end
