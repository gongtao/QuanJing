//
//  LJImageAndProfileCell.m
//  Weitu
//
//  Created by qj-app on 15/5/19.
//  Copyright (c) 2015年 SparkingSoft Co., Ltd. All rights reserved.
//

#import "LJImageAndProfileCell.h"
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
@implementation LJImageAndProfileCell
{
	LJFeedWithUserProfileViewCon * _viewContoller;
	UIImageView * _headerImageView;
	UILabel * _userName;
	UILabel * _upTime;
	OWTUser * _user;
    QJUser * _qjuser;
	NSMutableArray * _assets;
	OWTActivityData * _activity;
	NSMutableArray * _likes;
	NSMutableArray * _comments;
	UILabel * _caption;
	UIScrollView * _scrollView;
	UIScrollView * _bigImageScrollView;
	UIButton * _careBtn;
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
	UIImageView * _commentBackView;
	UIImageView * _commentView;
	OWTUserData * _careUser;
    UIButton *_jubaobtn;
    UIView *_TapBackView;
}

- (void)awakeFromNib
{
	// Initialization code
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withViewController:(LJFeedWithUserProfileViewCon *)viewConctroller withComment:(void (^)(OWTActivityData *, NSInteger))cb
{
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	
	if (self) {
		commentcb = [cb copy];
		_viewContoller = viewConctroller;
        _qjuser=[QJPassport sharedPassport].currentUser;
		_careUser = [[OWTUserData alloc]init];
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
	_headerImageView = [LJUIController createCircularImageViewWithFrame:CGRectMake(15, 15, 40, 40) imageName:nil];
	[self.contentView addSubview:_headerImageView];
	UITapGestureRecognizer * tap3 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onTap3)];
	[_headerImageView addGestureRecognizer:tap3];
	_userName = [LJUIController createLabelWithFrame:CGRectZero Font:12 Text:nil];
	_userName.textColor = [UIColor colorWithHexString:@"#4c5c8d"];
	[self.contentView addSubview:_userName];
	
	_upTime = [LJUIController createLabelWithFrame:CGRectZero Font:12 Text:nil];
	_upTime.textColor = [UIColor colorWithHexString:@"#a2a2a2"];
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
	_careBtn = [LJUIController createButtonWithFrame:CGRectMake(SCREENWIT - 50, 20, 40, 17.5) imageName:@"关注00" title:nil target:self action:@selector(careBtnClick:)];
	_likeBtn = [LJUIController createButtonWithFrame:CGRectZero imageName:@"赞00" title:nil target:self action:@selector(likeBtnClick:)];
	_downLoadBtn = [LJUIController createButtonWithFrame:CGRectZero imageName:@"圈子5_33.png" title:nil target:self action:@selector(downLoadBtnClick)];
	_collectionBtn = [LJUIController createButtonWithFrame:CGRectZero imageName:@"圈子5_34.png" title:nil target:self action:@selector(collectionBtnClick)];
	_shareBtn = [LJUIController createButtonWithFrame:CGRectZero imageName:@"分享" title:nil target:self action:@selector(shareBtnClick)];
	_commentBtn = [LJUIController createButtonWithFrame:CGRectZero imageName:@"评论" title:nil target:self action:@selector(commentBtnClick)];
	[self.contentView addSubview:_commentBtn];
	[self.contentView addSubview:_likeBtn];
	[self.contentView addSubview:_downLoadBtn];
	[self.contentView addSubview:_collectionBtn];
	[self.contentView addSubview:_shareBtn];
	[self.contentView addSubview:_careBtn];
	_commentBackView = [LJUIController createImageViewWithFrame:CGRectZero imageName:nil];
	UIImage * backImage = [UIImage imageNamed:@"聊天背景框"];
	//    backImage=[backImage stretchableImageWithLeftCapWidth:0 topCapHeight:50];
	backImage = [backImage resizableImageWithCapInsets:UIEdgeInsetsMake(10, 50, 5, 50)];
	_commentBackView.image = backImage;
	[self.contentView addSubview:_commentBackView];
	_line1 = [LJUIController createLabelWithFrame:CGRectZero Font:12 Text:nil];
	_line1.backgroundColor = [UIColor grayColor];
	_heartView = [LJUIController createImageViewWithFrame:CGRectZero imageName:@"赞小标"];
	_commentView = [LJUIController createImageViewWithFrame:CGRectZero imageName:@"评论小标"];
	[self.contentView addSubview:_commentView];
	[self.contentView addSubview:_heartView];
	[self.contentView addSubview:_line1];
    _jubaobtn=[LJUIController createButtonWithFrame:CGRectMake(0, 0, 57, 41) imageName:@"jubao" title:nil target:self action:@selector(jubao)];
//    [_jubaobtn setBackgroundColor:[UIColor blackColor]];
    _jubaobtn.hidden=YES;
    [self.contentView addSubview:_jubaobtn];
    _TapBackView=[[UIView alloc]initWithFrame:CGRectZero];
    [self.contentView addSubview:_TapBackView];
    [self.contentView sendSubviewToBack:_TapBackView];
    UITapGestureRecognizer *tap1=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onClickBack:)];
    [_TapBackView addGestureRecognizer:tap1];
    _TapBackView.hidden=YES;
    UILongPressGestureRecognizer * LongP = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(onLongAction:)];
	
	[self.contentView addGestureRecognizer:LongP];
}

#pragma mark btnAndTap
-(void)onClickBack:(UIGestureRecognizer *)sender
{
    _jubaobtn.hidden=YES;
    _TapBackView.hidden=YES;
}
-(void)jubao
{
    RKObjectManager *om=[RKObjectManager sharedManager];
    OWTAsset * asset1 = _assets[_imageNum];
    _jubaobtn.hidden=YES;
    _TapBackView.hidden=YES;
    NSDictionary *dict=@{@"url":asset1.webURL};
[om postObject:nil path:@"report" parameters:dict success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
    NSLog(@"dd");
    NSDictionary *dict=mappingResult.dictionary;
    OWTServerError *error=dict[@"error"];
    [SVProgressHUD showSuccessWithStatus:@"举报成功"];
} failure:^(RKObjectRequestOperation *operation, NSError *error) {
    NSLog(@"%@",error);
}];
}
-(void)onLongAction:(UIGestureRecognizer *)sender
{
    CGPoint point=[sender locationInView:self.contentView];
    _jubaobtn.hidden=NO;
    _jubaobtn.center=CGPointMake(point.x, point.y-21);
    _TapBackView.hidden=NO;
    [self.contentView bringSubviewToFront:_TapBackView];
    [self.contentView bringSubviewToFront:_jubaobtn];
}
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

- (void)careBtnClick:(UIButton *)sender
{
	[SVProgressHUD show];
	OWTUserManager * um = GetUserManager();
	OWTUser * user = [[OWTUser alloc]init];
	[user mergeWithData:_careUser];
	
	if (sender.tag == 0) {
		_careBtn.tag = 1;
		[um followUser:user
		success:^{
			[SVProgressHUD dismiss];
			[_careBtn setBackgroundImage:[UIImage imageNamed:@"关注01"] forState:UIControlStateNormal];
		}
		failure:^(NSError * error) {
			[SVProgressHUD showError:error];
		}];
	}
	else {
		_careBtn.tag = 0;
		[um unfollowUser:user
		success:^{
			[SVProgressHUD dismiss];
			[_careBtn setBackgroundImage:[UIImage imageNamed:@"关注00"] forState:UIControlStateNormal];
		}
		failure:^(NSError * error) {
			[SVProgressHUD showError:error];
		}];
	}
}

- (void)likeBtnClick:(UIButton *)sender
{
    QJInterfaceManager *fm=[QJInterfaceManager sharedManager];
    CGFloat imageHeight = 20;
	if (sender.selected == NO) {
		_likeBtn.selected = YES;
		[_likeBtn setBackgroundImage:[UIImage imageNamed:@"发现10_24.png"] forState:UIControlStateNormal];
        QJActionObject *actionModel=_viewContoller.activeList[_number];
        NSMutableArray *arr;
        if (actionModel.likes) {
            arr=(NSMutableArray *)actionModel.likes;
        }else
        {
            arr=[[NSMutableArray alloc]init];
        }
        NSMutableArray * arr1 = (NSMutableArray *)actionModel.comments;
		if (arr1.count > 0)
			imageHeight += 20;
		else
			imageHeight += 10;
			
		if (arr.count % 10 == 0) {
			NSString * height = _viewContoller.heights[_number];
			NSString * str;
			if (arr.count / 10 != 0)
				str = [NSString stringWithFormat:@"%f", height.floatValue + imageHeight + 5];
			else
				str = [NSString stringWithFormat:@"%f", height.floatValue + imageHeight];
			[_viewContoller.heights replaceObjectAtIndex:_number withObject:str];
		}
		[arr addObject:_qjuser];
        actionModel.likes=arr;
        [_viewContoller.activeList replaceObjectAtIndex:_number withObject:actionModel];
		[_viewContoller reloadData:_number];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [fm requestLikeAction:actionModel.aid];
        });
    }
	else {
		_likeBtn.selected = NO;
		[_likeBtn setBackgroundImage:[UIImage imageNamed:@"发现10_25.png"] forState:UIControlStateNormal];
        QJActionObject *actionModel=_viewContoller.activeList[_number];
        NSMutableArray *arr=(NSMutableArray *)actionModel.likes;
        NSMutableArray * arr1 = (NSMutableArray *)actionModel.comments;
		if (arr1.count > 0)
			imageHeight += 20;
		else
			imageHeight += 10;
			
		if (arr.count % 10 == 1) {
			NSString * height = _viewContoller.heights[_number];
			NSString * str;
			
			if (arr.count / 10 != 0)
				str = [NSString stringWithFormat:@"%f", height.floatValue - imageHeight - 5];
			else
				str = [NSString stringWithFormat:@"%f", height.floatValue - imageHeight];
				
			[_viewContoller.heights replaceObjectAtIndex:_number withObject:str];
		}
		
		for (QJUser * likeUser in arr)
			if ([likeUser.uid.stringValue isEqualToString:_qjuser.uid.stringValue]) {
				[arr removeObject:likeUser];
				break;
			}
			
        actionModel.likes=arr;
        [_viewContoller.activeList replaceObjectAtIndex:_number withObject:actionModel];
		[_viewContoller reloadData:_number];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [fm requestCancelLikeAction:actionModel.aid];
        });
	}
}

- (void)downLoadBtnClick
{
	QJImageObject *imageModel = _assets[_imageNum];
    QJInterfaceManager *fm=[QJInterfaceManager sharedManager];
	[SVProgressHUD showWithStatus:@"保存图片中..." maskType:SVProgressHUDMaskTypeBlack];
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
     NSError *error= [fm requestImageAddDownload:imageModel.imageId imageType:imageModel.imageType];
        dispatch_async(dispatch_get_main_queue(), ^{
            
        });
    });
	SDWebImageManager * manager = [SDWebImageManager sharedManager];
	NSURL * url = [NSURL URLWithString:imageModel.url];
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


- (void)shareBtnClick
{
	QJImageObject *imageModel = _assets[_imageNum];
	
	[SVProgressHUD showWithStatus:@"准备图片中..." maskType:SVProgressHUDMaskTypeBlack];
	
	SDWebImageManager * manager = [SDWebImageManager sharedManager];
	NSURL * url = [NSURL URLWithString:imageModel.url];
	
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
    _viewContoller.replyid = nil;
    commentcb(_activity, _number);
}

- (void)onTap3
{
	_headerImagecb(_number);
}

- (void)onTapBigImage:(UIGestureRecognizer *)sender
{
    QJImageObject *imageModel=_assets[sender.view.tag-400];
    OWTAssetViewCon *assetViewCon=[[OWTAssetViewCon alloc]initWithImageId:imageModel imageType:imageModel.imageType];
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
						view1.backgroundColor = [UIColor colorWithHexString:@"#4c5c8d"];
					else
						view1.backgroundColor = [UIColor whiteColor];
				}
	}
}

#pragma mark setUpCell
-(void)customcell:(QJActionObject*)actionModel withImageNumber:(NSInteger)number
{
    _imageNum=number;
    _viewContoller.height=0;
    _assets=[[NSMutableArray alloc]initWithArray:actionModel.images];
    _likes=[[NSMutableArray alloc]initWithArray:actionModel.likes];
    _comments=[[NSMutableArray alloc]initWithArray:actionModel.comments];
    CGFloat cellHeight = 0;
//头像部分
    QJUser *user=actionModel.user;
    [_headerImageView setImageWithURL:[NSURL URLWithString:[QJInterfaceManager thumbnailUrlFromImageUrl:user.avatar size:_headerImageView.bounds.size]] placeholderImage:[UIImage imageNamed:@"头像"]];
    CGSize size = [user.nickName sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(300, 200)];
    if (0) {
        _careBtn.tag = 0;
        [_careBtn setBackgroundImage:[UIImage imageNamed:@"关注00"] forState:UIControlStateNormal];
    }
    else {
        _careBtn.tag = 1;
        [_careBtn setBackgroundImage:[UIImage imageNamed:@"关注01"] forState:UIControlStateNormal];
    }
    _userName.frame = CGRectMake(65, 13, size.width, size.height);
    _userName.text = user.nickName;
    _upTime.frame = CGRectMake(65, 35, 100, 15);
    _upTime.text = [self getTheTime:actionModel.creatTime];
    cellHeight += 65;
//图片部分
    //是否喜欢
    if ([self isLike:_likes]) {
        _likeBtn.selected = YES;
        [_likeBtn setBackgroundImage:[UIImage imageNamed:@"赞01"] forState:UIControlStateNormal];
    }
    else {
        _likeBtn.selected = NO;
        [_likeBtn setBackgroundImage:[UIImage imageNamed:@"赞00"] forState:UIControlStateNormal];
    }

    CGFloat x = SCREENWIT - 10;
    CGFloat height;
    CGFloat width;
    UIImageView * ImageView;
    
    if (_assets.count == 1) {
        _bigImageScrollView.frame = CGRectZero;
        _bigImageScrollView.hidden = YES;
        ImageView = [[UIImageView alloc]initWithFrame:CGRectZero];
        //        ImageView.contentMode=UIViewContentModeScaleAspectFit;
        QJImageObject *imageModel=_assets[0];
        if (imageModel.width&&imageModel.height) {
        float imageWidth=imageModel.width.floatValue;
        float imageHeight=imageModel.height.floatValue;
        if (imageWidth > imageHeight) {
            height = x / imageWidth * imageHeight;
            ImageView.frame = CGRectMake(5, cellHeight, x, height);
            cellHeight += (10 + height);
        }
        else {
            ImageView.contentMode = UIViewContentModeScaleAspectFill;
            
            ImageView.clipsToBounds = YES;
            height = x / imageWidth* imageHeight;
            
            if (height > 380) {
                ImageView.frame = CGRectMake(5, cellHeight, x, 380);
                cellHeight += (380 + 10);
            }
            else {
                ImageView.frame = CGRectMake(5, cellHeight, x, height);
                cellHeight += (10 + height);
            }
        }
        }else {
            ImageView.contentMode = UIViewContentModeScaleAspectFill;
            ImageView.clipsToBounds = YES;
            ImageView.frame=CGRectMake(5, cellHeight, x, 320);
            cellHeight +=330;
        }
        [ImageView setImageWithURL:[NSURL URLWithString:[QJInterfaceManager thumbnailUrlFromImageUrl:imageModel.url size:ImageView.bounds.size]]];
        ImageView.tag = 400 + number;
        ImageView.userInteractionEnabled = YES;
        [self.contentView addSubview:ImageView];
        UITapGestureRecognizer * bigImageTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onTapBigImage:)];
        [ImageView addGestureRecognizer:bigImageTap];
    }	else {
        NSInteger assetNum = 0;
        
        for (QJImageObject *imageModel in _assets) {
            if (imageModel.width.floatValue > imageModel.height.floatValue)
                break;
            assetNum++;
        }
        
        float imageH;
        
        if (assetNum == _assets.count)
            imageH = 320;
        else
            imageH = 240;
        _bigImageScrollView.frame = CGRectMake(5, cellHeight, x, imageH);
        _bigImageScrollView.hidden = NO;
        NSInteger pa = 0;
        
        for (QJImageObject *imageModel in _assets) {
            ImageView = [[UIImageView alloc]initWithFrame:CGRectMake(pa * x, 0, x, imageH)];
            ImageView.clipsToBounds = YES;
            ImageView.contentMode = UIViewContentModeScaleAspectFill;
            ImageView.tag = 400 + pa;
            ImageView.userInteractionEnabled = YES;
            [ImageView setImageWithURL:[NSURL URLWithString:[QJInterfaceManager thumbnailUrlFromImageUrl:imageModel.url size:ImageView.bounds.size]]];
            [_bigImageScrollView addSubview:ImageView];
            UITapGestureRecognizer * bigImageTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onTapBigImage:)];
            [ImageView addGestureRecognizer:bigImageTap];
            pa++;
        }
        
        cellHeight += (10 + imageH);
        _bigImageScrollView.pagingEnabled = YES;
        _bigImageScrollView.contentSize = CGSizeMake(x * pa, imageH);
    }
    if (actionModel.descript.length> 0) {
        CGSize size = [ actionModel.descript sizeWithFont:[UIFont systemFontOfSize:12] constrainedToSize:CGSizeMake(x, 100)];
        _caption.frame = CGRectMake(10, cellHeight - 5, size.width, size.height);
        _caption.text = actionModel.descript;
        cellHeight += size.height;
    }
    else {
        _caption.text = nil;
        _caption.frame = CGRectZero;
    }
    float c = (x - 27.5) / 4;
    _scrollView.frame = CGRectMake(5, cellHeight, x, c + 2);
//小图部分
    int i = 0;
    if (_assets.count > 1) {
        for (QJImageObject *imageModel in _assets) {
            UIImageView * imageView1 = [[UIImageView alloc]initWithFrame:CGRectMake((c + 7.5) * i, 0, c + 2, c + 2)];
            
            if (i == number)
                imageView1.backgroundColor = [UIColor colorWithHexString:@"#4c5c8d"];
            imageView1.tag = 600 + i;
            [_scrollView addSubview:imageView1];
            UIImageView * imageView = [[UIImageView alloc]initWithFrame:CGRectMake((c + 7.5) * i + 1, 1, c, c)];
            imageView.clipsToBounds = YES;
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            imageView.userInteractionEnabled = YES;
            imageView.tag = 400 + i;
            imageView.backgroundColor = [UIColor whiteColor];
            [imageView setImageWithURL:[NSURL URLWithString:[QJInterfaceManager thumbnailUrlFromImageUrl:imageModel.url size:ImageView.bounds.size]]];
            [_scrollView addSubview:imageView];
            UITapGestureRecognizer * smallImageTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onTapSmallImage:)];
            [imageView addGestureRecognizer:smallImageTap];
            i++;
        }
        
        _scrollView.contentSize = CGSizeMake((c + 5) * i - 5, c);
        cellHeight += (c + 5);
    }
    _likeBtn.frame = CGRectMake(SCREENWIT - 170, cellHeight + 5, 45, 17.5);
    _shareBtn.frame = CGRectMake(SCREENWIT - 115, cellHeight + 5, 45, 17.5);
    _commentBtn.frame = CGRectMake(SCREENWIT - 60, cellHeight + 5, 45, 17.5);
    cellHeight += 37.5;
    CGFloat likeHeight = 0;
    CGFloat imageHeight = 20;
    _heartView.hidden = YES;
    if (_likes.count != 0) {
        _heartView.hidden = NO;
        _heartView.frame = CGRectMake(25, cellHeight + 4, 13, 12);
        CGFloat likeWidth = 45;
        
        for (NSInteger i = 0; i < _likes.count; i++) {
            QJUser *user=_likes[i];
            if (likeWidth + imageHeight + 5 > SCREENWIT - 25) {
                likeWidth = 45;
                likeHeight += (imageHeight + 5);
            }
            UIImageView * likebody = [LJUIController createCircularImageViewWithFrame:CGRectMake(likeWidth, cellHeight + likeHeight, imageHeight, imageHeight) imageName:@"头像"];
            //            likebody.clipsToBounds=YES;
            //            likebody.contentMode=UIViewContentModeCenter;
            [likebody setImageWithURL:[NSURL URLWithString:[QJInterfaceManager thumbnailUrlFromImageUrl:user.avatar size:likebody.bounds.size]] placeholderImage:[UIImage imageNamed:@"头像.png"]];
            UITapGestureRecognizer * liketap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onLikeTap:)];
            likebody.userInteractionEnabled = YES;
            likebody.tag = 700 + i;
            [likebody addGestureRecognizer:liketap];
            [self.contentView addSubview:likebody];
            likeWidth = likeWidth + imageHeight + 5;
        }
        
        likeHeight += imageHeight;
    }
    cellHeight += likeHeight;
    
 //评论部分
    CGFloat commentHeight = 0;
    _line1.hidden = YES;
    _commentView.hidden = YES;
    
    if (_comments.count != 0) {
        if (likeHeight != 0) {
            cellHeight += 20;
            _line1.hidden = NO;
            _line1.frame = CGRectMake(25, cellHeight - 10, SCREENWIT - 40, 0.2);
        }
        _commentView.hidden = NO;
        _commentView.frame = CGRectMake(25, cellHeight + 4, 13, 12);
        
        for (NSInteger i = 0; i < _comments.count; i++) {
            QJCommentObject *commentModel=_comments[i];
            QJUser *user=commentModel.user;
            UIImageView * commentImage = [LJUIController createCircularImageViewWithFrame:CGRectMake(45, cellHeight + commentHeight, imageHeight, imageHeight) imageName:nil];
            commentImage.tag = 500 + i;
            UITapGestureRecognizer * commentTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onCommentTap:)];
            commentImage.userInteractionEnabled = YES;
            [commentImage setImageWithURL:[NSURL URLWithString:[QJInterfaceManager thumbnailUrlFromImageUrl:user.avatar size:commentImage.bounds.size]]placeholderImage:[UIImage imageNamed:@"头像"]];
            [commentImage addGestureRecognizer:commentTap];
            [self.contentView addSubview:commentImage];
            
            if (1) {
                NSString * name = user.nickName;
                if (user.nickName.length==0) {
                    name=user.uid.stringValue;
                }
                NSString * commentContent = [NSString stringWithFormat:@"%@", commentModel.comment];
                NSString * commentText = [NSString stringWithFormat:@"%@:%@", name, commentContent];
                NSMutableAttributedString * attString = [[NSMutableAttributedString alloc]initWithString:commentText];
                NSRange range1 = [commentText rangeOfString:name];
                [attString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"4c5c8d"] range:range1];
                CGSize size2 = [commentText sizeWithFont:[UIFont systemFontOfSize:12] constrainedToSize:CGSizeMake(SCREENWIT - 75 - imageHeight, 500)];
                UILabel * commentLabel = [LJUIController createLabelWithFrame:CGRectMake(50 + imageHeight, cellHeight + commentHeight + 3, size2.width, size2.height) Font:12 Text:nil];
                commentLabel.attributedText = attString;
                commentLabel.lineBreakMode = NSLineBreakByClipping;
                commentLabel.lineBreakMode = UILineBreakModeClip;
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
                NSString * name1 = user.nickName;
                NSString * name2 = nil;
                NSString * commentContent = [NSString stringWithFormat:@"%@", commentModel.comment];
                NSString * commentText = [NSString stringWithFormat:@"%@回复%@:%@", name1, name2, commentContent];
                NSMutableAttributedString * attString = [[NSMutableAttributedString alloc]initWithString:commentText];
                NSRange range1 = [commentText rangeOfString:name1];
                NSRange range2 = [commentText rangeOfString:name2];
                [attString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"4c5c8d"] range:range1];
                [attString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"4c5c8d"] range:range2];
                CGSize size2 = [commentText sizeWithFont:[UIFont systemFontOfSize:12] constrainedToSize:CGSizeMake(SCREENWIT - 75 - imageHeight, 500)];
                UILabel * commentLabel = [LJUIController createLabelWithFrame:CGRectMake(50 + imageHeight, cellHeight + commentHeight + 3, size2.width, size2.height) Font:12 Text:nil];
                commentLabel.attributedText = attString;
                commentLabel.lineBreakMode = NSLineBreakByClipping;
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
    else if (likeHeight != 0) {
        cellHeight += 10;
    }
    _commentBackView.hidden = YES;
    cellHeight += commentHeight;
    
    if ((likeHeight != 0) && (commentHeight != 0)) {
        _commentBackView.hidden = NO;
        _commentBackView.frame = CGRectMake(15, cellHeight - likeHeight - commentHeight - 20 - 15, SCREENWIT - 28, likeHeight + commentHeight + 15 + 20);
    }
    else if ((likeHeight != 0) && (commentHeight == 0)) {
        _commentBackView.hidden = NO;
        _commentBackView.frame = CGRectMake(15, cellHeight - likeHeight - commentHeight - 10 - 5 - 10, SCREENWIT - 28, likeHeight + commentHeight + 10 + 10);
    }
    else if ((likeHeight == 0) && (commentHeight != 0)) {
        _commentBackView.hidden = NO;
        _commentBackView.frame = CGRectMake(15, cellHeight - likeHeight - commentHeight - 5 - 10, SCREENWIT - 28, likeHeight + commentHeight + 5 + 10);
    }
    _backView.frame = CGRectMake(5, 5, SCREENWIT - 10, cellHeight);
    _TapBackView.frame=CGRectMake(5, 5, SCREENWIT-10, cellHeight);
}
-(NSArray *)getTheAllCellHeight:(NSArray *)actionList
{
    NSMutableArray * arr = [[NSMutableArray alloc]init];
    for (QJActionObject *actionModel in actionList) {
        NSArray *assets=actionModel.images;
        NSArray *like=actionModel.likes;
        NSArray *comment=actionModel.comments;
        float cellHeight=0;
        cellHeight += 65;
        CGFloat x = SCREENWIT - 10;
        CGFloat height;
        CGFloat width;
        if (assets.count == 1) {
            QJImageObject *imageModel=assets[0];
            float imageWidth=imageModel.width.floatValue;
            float imageHeight=imageModel.height.floatValue;
            if (imageWidth > imageHeight) {
                height = x / imageWidth * imageHeight;
                cellHeight += (10 + height);
            }
            else {
                height = x / imageWidth* imageHeight;
                if (height > 380) {
                    cellHeight += (380 + 10);
                }
                else {
                    cellHeight += (10 + height);
                }
            }
        }	else {
            NSInteger assetNum = 0;
            
            for (QJImageObject *imageModel in assets) {
                if (imageModel.width.floatValue > imageModel.height.floatValue)
                    break;
                assetNum++;
            }
            
            float imageH;
            
            if (assetNum == assets.count)
                imageH = 320;
            else
                imageH = 240;
            cellHeight += (10 + imageH);
        }
        if (actionModel.descript.length> 0) {
            CGSize size = [ actionModel.descript sizeWithFont:[UIFont systemFontOfSize:12] constrainedToSize:CGSizeMake(x, 100)];
            cellHeight += size.height;
        }
        float c = (x - 27.5) / 4;
        if (assets.count > 1) {
            cellHeight += (c + 5);
        }
        cellHeight += 37.5;
        CGFloat likeHeight = 0;
        CGFloat imageHeight = 20;
        if (like.count != 0) {
            CGFloat likeWidth = 45;
            for (NSInteger i = 0; i < like.count; i++) {
                if (likeWidth + imageHeight + 5 > SCREENWIT - 25) {
                    likeWidth = 45;
                    likeHeight += (imageHeight + 5);
                }
                likeWidth = likeWidth + imageHeight + 5;
            }
            
            likeHeight += imageHeight;
        }
        cellHeight += likeHeight;
        CGFloat commentHeight = 0;
        if (comment.count != 0) {
            if (likeHeight != 0) {
                cellHeight += 20;
                            }
            for (NSInteger i = 0; i < comment.count; i++) {
                QJCommentObject *commentModel=comment[i];
                QJUser *user=commentModel.user;
                if (1) {
                    NSString * name = user.nickName;
                    NSString * commentContent = [NSString stringWithFormat:@"%@", commentModel.comment];
                    NSString * commentText = [NSString stringWithFormat:@"%@:%@", name, commentContent];
                    CGSize size2 = [commentText sizeWithFont:[UIFont systemFontOfSize:12] constrainedToSize:CGSizeMake(SCREENWIT - 75 - imageHeight, 500)];
                                       if (size2.height > imageHeight)
                        commentHeight = commentHeight + size2.height + 5;
                    else
                        commentHeight = commentHeight + imageHeight + 5;
                }
                else {
                    NSString * name1 = user.nickName;
                    NSString * name2 = nil;
                    NSString * commentContent = [NSString stringWithFormat:@"%@", commentModel.comment];
                    NSString * commentText = [NSString stringWithFormat:@"%@回复%@:%@", name1, name2, commentContent];
                    CGSize size2 = [commentText sizeWithFont:[UIFont systemFontOfSize:12] constrainedToSize:CGSizeMake(SCREENWIT - 75 - imageHeight, 500)];
                                        if (size2.height > imageHeight)
                        commentHeight = commentHeight + size2.height + 5;
                    else
                        commentHeight = commentHeight + imageHeight + 5;
                }
            }
        }
        else if (likeHeight != 0) {
            cellHeight += 10;
        }
        cellHeight += (commentHeight + 5);
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
							view1.backgroundColor = [UIColor colorWithHexString:@"#4c5c8d"];
						else
							view1.backgroundColor = [UIColor whiteColor];
					}
		}
	}
}

- (BOOL)isLike:(NSArray *)like
{
	for (QJUser * ljlike in like)
		if ([_qjuser.uid.stringValue isEqualToString:ljlike.uid.stringValue])
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

- (NSString *)getTheLikeBody:(LJLike *)likeBody withUser:(NSArray *)user
{
	for (OWTUser * userBody in user)
		if ([likeBody.likeUserid isEqualToString:userBody.userID])
			return [NSString stringWithFormat:@"%@", userBody.nickname];
			
	if ([likeBody.likeUserid isEqualToString:_user.userID])
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

- (NSString *)getTheTime:(NSDate *)date
{
	
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
