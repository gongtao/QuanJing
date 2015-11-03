//
//  QJServerConstants.h
//  QuanJingSDK
//
//  Created by QJ on 15/10/20.
//  Copyright © 2015年 QJ. All rights reserved.
//

#ifndef QJServerConstants_h
#define QJServerConstants_h

#import <Foundation/Foundation.h>

// Cookie Host
static NSString * const kQJCookieHost = @".tiankong.com";

// 域名地址
static NSString * const kQJServerURL = @"http://mapp.tiankong.com";

// 要替换的图片域名地址
static NSString * const kQJFakePhotoServerHost = @"quanjing-photo.oss.aliyuncs.com";

// 图片域名地址
static NSString * const kQJPhotoServerHost = @"mpic.tiankong.com";

// 图片故事详情url
static NSString * const kQJArticleDetailURL = @"http://mapp.tiankong.com/articleSys/show?id=";

// 发送注册短息
static NSString * const kQJUserSendRegistSMSPath = @"/user/smsRegistered";

// 注册用户
static NSString * const kQJUserRegisterPath = @"/user/regist";

// 登录用户
static NSString * const kQJUserLoginPath = @"/user/login";

// 发送登录短信
static NSString * const kQJUserSendLoginSMSPath = @"/user/sendloginCode";

// 短信登录
static NSString * const kQJUserLoginSMSPath = @"/user/smsLogin";

// 用户重登录（更换ticket）
static NSString * const kQJUserReloginPath = @"/user/resetTicket";

// 用户信息
static NSString * const kQJUserInfoPath = @"/user/info.user";

// 其他用户信息
static NSString * const kQJOtherUserInfoPath = @"/user/info/%@";

// 修改用户信息
static NSString * const kQJUserInfoModifyPath = @"/user/update.user";

// 首页
static NSString * const kQJHomeIndexPath = @"/index";

// 搜索
static NSString * const kQJSearchPath = @"/search";

// 图片分类
static NSString * const kQJImageCategoryPath = @"/imageCategory/root";

// 图片故事分类
static NSString * const kQJArticleCategoryPath = @"/articleSys/category";

// 图片故事列表
static NSString * const kQJArticleListPath = @"/articleSys/list";

// 圈子列表
static NSString * const kQJActionListPath = @"/action/list";

// 圈子喜欢
static NSString * const kQJLikeActionPath = @"/action/like.user";

// 圈子取消喜欢
static NSString * const kQJCancelLikeActionPath = @"/action/likeCancel.user";

// 圈子收藏
static NSString * const kQJCollectActionPath = @"/action/collect.user";

// 圈子取消收藏
static NSString * const kQJCollectCancelActionPath = @"/action/collectCancel.user";

// 圈子评论
static NSString * const kQJCommentActionPath = @"/action/comment.user";

// 图片详情
static NSString * const kQJImageDetailPath = @"/imageUser/detail";

// 图片评论
static NSString * const kQJImageCommentPath = @"/imageComment/save.user";

// 图片喜欢
static NSString * const kQJImageLikePath = @"/imageLike/save.user";

// 图片取消喜欢
static NSString * const kQJImageCancelLikePath = @"/imageLike/cancel.user";

// 图片收藏
static NSString * const kQJImageCollectPath = @"/userCollect/save.user";

// 图片取消收藏
static NSString * const kQJImageCancelCollectPath = @"/userCollect/cancel.user";

// 图片增加一次下载
static NSString * const kQJImageAddDownloadPath = @"/imageUser/addDownload";

// 用户图片收藏列表
static NSString * const kQJUserCollectListPath = @"/userCollect/list";

// 用户评论列表
static NSString * const kQJUserCommentImageListPath = @"/imageComment/list.user";

// 用户的图片列表
static NSString * const kQJUserImageListPath = @"/imageUser/list";

// 用户喜欢图片列表
static NSString * const kQJUserLikeImageListPath = @"/imageLike/list";

// 用户关注列表
static NSString * const kQJUserFollowListPath = @"/userFollow/list";

// 用户粉丝列表
static NSString * const kQJUserFollowMeListPath = @"/userFollow/fllowMe";

// 用户新增关注
static NSString * const kQJUserFollowUserPath = @"/userFollow/save.user";

// 用户取消关注
static NSString * const kQJUserCancelFollowUserPath = @"/userFollow/cancel.user";

// 关注用户的图片列表
static NSString * const kQJUserFollowUserImageListPath = @"/imageUser/followDetail.user";

// 用户相册列表
static NSString * const kQJUserAlbumListPath = @"/album/list.user";

// 用户相册图片列表
static NSString * const kQJUserAlbumImageListPath = @"/album/show.user";

// 用户上传临时图片
static NSString * const kQJUserPostTempImagePath = @"/upload/pic";

// 用户发布圈子
static NSString * const kQJUserPostActionPath = @"/imageUser/saveImage.user";

#endif	/* QJServerConstants_h */
