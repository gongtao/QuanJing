//
//  OWTUserInfoEditViewCon.h
//  Weitu
//
//  Created by Su on 4/13/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OWTUser.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <QuartzCore/QuartzCore.h>
#import "QJUser.h"
@interface OWTUserInfoEditViewCon : UIViewController<UITableViewDelegate,UIActionSheetDelegate>

@property (nonatomic, strong) QJUser* user1;
@property (nonatomic, strong) OWTUser* user;

@property (nonatomic, strong) void (^cancelAction)();
@property (nonatomic, strong) void (^doneFunc)();
@property (nonatomic, strong) NSString* sex;
@property (nonatomic, strong) NSString* decade;
@property (nonatomic, strong) NSString* constellation;
@property (nonatomic, strong) NSString* marrige;
@property (nonatomic, strong) NSString* birthLocation;
@property (nonatomic, strong) NSString* city;
@property (nonatomic, strong) NSString* homeCity;
@property (nonatomic, strong) NSString* occupation;
@property (nonatomic, strong) NSString* favourite;
@property (nonatomic, strong) NSString* mobile;
@property (nonatomic, strong) NSString* truename;
@property (nonatomic, strong) NSString* userinfo;
@end
