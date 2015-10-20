//
//  OWTSMSInviteViewCon.h
//  Weitu
//
//  Created by Su on 6/19/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@interface OWTSMSInviteViewCon : UIViewController<MFMessageComposeViewControllerDelegate,UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) void (^failFunc)();

@end
