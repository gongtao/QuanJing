//
//  HXVoiceViewController.m
//  dreamJobs
//
//  Created by denghs on 15/3/21.
//  Copyright (c) 2015年 Renrui. All rights reserved.
//

#import "HXVoiceViewController.h"
#import "HuanXinManager.h"
#import "RRConst.h"
#import "EaseMob.h"

@interface HXVoiceViewController ()<IChatManagerDelegate,IDeviceManagerDelegate>
{
    HuanXinManager *sendMSG;
}

@property (strong, nonatomic) EMConversation *conversation;//会话管理者
@end


@implementation HXVoiceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title =  @"聊一聊";
    [self.view setBackgroundColor:[UIColor grayColor]];
    
    UIButton *btn = [[UIButton alloc]init];
    [btn setTitle:@"发送" forState:UIControlStateNormal];
    btn.frame = CGRectMake(100,100, 70,45);
    [self.view addSubview:btn];
    [btn addTarget:self action:@selector(btnclik) forControlEvents:UIControlEventTouchDown];
    
    [[[EaseMob sharedInstance] deviceManager] addDelegate:self onQueue:nil];
    [[EaseMob sharedInstance].chatManager removeDelegate:self];
    //注册为SDK的ChatManager的delegate
    [[EaseMob sharedInstance].chatManager addDelegate:self delegateQueue:nil];
    
    _conversation = [[EaseMob sharedInstance].chatManager conversationForChatter:@"18612110002" isGroup:NO];
    [_conversation markAllMessagesAsRead:YES];
   
}

#pragma -mark 受到消息后 触发的代理方法
-(void)didReceiveMessage:(EMMessage *)message
{
    if ([_conversation.chatter isEqualToString:message.conversationChatter]) {
       // [self addMessage:message];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
