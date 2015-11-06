/************************************************************
 *  * EaseMob CONFIDENTIAL
 * __________________
 * Copyright (C) 2013-2014 EaseMob Technologies. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of EaseMob Technologies.
 * Dissemination of this information or reproduction of this material
 * is strictly forbidden unless prior written permission is obtained
 * from EaseMob Technologies.
 */

#import <UIKit/UIKit.h>
#import "DXMessageToolBar.h"
#import "QJUser.h"
@interface ChatViewController_rename : UIViewController

@property (nonatomic,strong)NSString *hxUserID;
@property (nonatomic,strong)NSString *currentUserName;
@property (nonatomic,strong)UIImage *currentUserImage;
@property (nonatomic,strong)UIImage *senderImage;
@property (nonatomic, strong)QJUser *otherUser;
@property (nonatomic, strong)QJUser *currentUser;

@property (strong, nonatomic) UITableView *tableView;

@property (nonatomic, assign)NSInteger  chatType;
@property (nonatomic, strong)NSString *bottomTextContend;
@property (nonatomic, strong)UIImage  *bootomPhotoContend;
@property (nonatomic, strong)EMChatVoice *bootomVoiceContend;

@property (strong, nonatomic) EMConversation *conversation;//会话管理者
@property (nonatomic, assign)BOOL ifpopToRootView;
@property (strong, nonatomic) DXMessageToolBar *chatToolBar;

-(void)sendTextMessage:(NSString *)textMessage;

- (instancetype)initWithChatter:(NSString *)chatter isGroup:(BOOL)isGroup tile1:(NSString*)compyName title2:(NSString*)positionName;

- (void)reloadData;
@end
