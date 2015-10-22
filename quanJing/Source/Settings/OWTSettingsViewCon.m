//
//  OWTSettingsViewCon.m
//  Weitu
//
//  Created by Su on 5/21/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import "OWTSettingsViewCon.h"
#import "RETableViewManager.h"
#import "OWTAuthManager.h"
#import "OWTUserManager.h"
#import "OWTUsageViewCon.h"
#import "OWTLicenseViewCon.h"
#import "UIViewController+WTExt.h"
#import "OWTSMSInviteViewCon.h"
#import <SIAlertView/SIAlertView.h>
#import "LJCollectionViewController.h"

#import "OQJHomeViewCon.h"
@interface OWTSettingsViewCon ()
{
    RETableViewManager* _manager;
}

@end

@implementation OWTSettingsViewCon

//- (id)initWithDefaultStyle
//{
//    self = [super initWithStyle:UITableViewStyleGrouped];
//    if (self)
//    {
//    }
//    return self;
//}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setup];
}
-(void)viewWillAppear:(BOOL)animated
{
    self.tabBarController.tabBar.hidden=YES;
}
-(void)setUpTableView
{
    self.tableView=[[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREENWIT, SCREENHEI-64) style:UITableViewStyleGrouped];

    [self.view addSubview:_tableView];
    _tableView.delegate=self;
    _tableView.dataSource=self;
    
}
- (void)setup
{
    self.title = @"设置";
    [self setUpTableView];
    _manager = [[RETableViewManager alloc] initWithTableView:self.tableView];
   
#if 0
    [self setupLicenseHelpSection];
#endif
    [self setupFindFriendsSection];
    [self setupLikeSection];
    [self setupAboutSection];
    [self setupLogoutSection];
    
    [self substituteNavigationBarBackItem];
}
-(void)setupLikeSection
{
    RETableViewSection *section=[RETableViewSection sectionWithHeaderTitle:@"图片"];
    RETableViewItem *item1=[RETableViewItem itemWithTitle:@"喜欢的图片" accessoryType:UITableViewCellAccessoryNone selectionHandler:^(RETableViewItem *item) {
        LJCollectionViewController *lvc=[[LJCollectionViewController alloc]init];
        lvc.isLike=YES;
        [self.navigationController pushViewController:lvc animated:YES];
        
    }];
    RETableViewItem *item2=[RETableViewItem itemWithTitle:@"评论的图片" accessoryType:UITableViewCellAccessoryNone selectionHandler:^(RETableViewItem *item) {
        LJCollectionViewController *lvc=[[LJCollectionViewController alloc]init];
        
        [self.navigationController pushViewController:lvc animated:YES];
        
    }];
    [section addItem:item1];
    [section addItem:item2];
    [_manager addSection:section];
}
- (void)setupAboutSection
{
    RETableViewSection* section = [RETableViewSection sectionWithHeaderTitle:@"关于"];
    
    NSDictionary* appInfos = [[NSBundle mainBundle] infoDictionary];
//    NSString* bundleVersion = appInfos[@"CFBundleVersion"];
    NSString* bundleShortVersion = appInfos[@"CFBundleShortVersionString"];
    
//    NSDictionary* buildInfos = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"BuildInfo" ofType:@"plist"]];
//    NSString* gitRef = [buildInfos[@"BuildEnvironment"][@"GitRef"] substringToIndex:16];
    
    RETableViewItem* item;
    item = [RETableViewItem itemWithTitle:[NSString stringWithFormat:@"全景 v%@", bundleShortVersion]];
    item.selectionStyle = UITableViewCellSelectionStyleNone;
    [section addItem:item];
    
//    item = [RETableViewItem itemWithTitle:[NSString stringWithFormat:@"Build %@ / %@", bundleVersion, gitRef]];
//    item.selectionStyle = UITableViewCellSelectionStyleNone;
//    [section addItem:item];
    [_manager addSection:section];
}

- (void)setupFindFriendsSection
{
    RETableViewSection* section = [RETableViewSection sectionWithHeaderTitle:@"找朋友"];
    
    [section addItem:[RETableViewItem itemWithTitle:@"邀请朋友"
                                      accessoryType:UITableViewCellAccessoryDisclosureIndicator
                                   selectionHandler:^(RETableViewItem *item) {
//                                       item.style=UITableViewCellStyleDefault;
                                       item.selectionStyle=UITableViewCellSelectionStyleNone;
                                       OWTSMSInviteViewCon* inviteViewCon = [[OWTSMSInviteViewCon alloc] init];
                                       inviteViewCon.hidesBottomBarWhenPushed=YES;
                                       inviteViewCon.failFunc = ^{
//                                        item.selectionStyle=UITableViewCellSelectionStyleNone;
                                           [self.navigationController popViewControllerAnimated:YES];
                                       };
                                       [self.navigationController pushViewController:inviteViewCon
                                                                            animated:YES];
                                   }]];
    
    [_manager addSection:section];
}

- (void)setupLicenseHelpSection
{
    RETableViewSection* section = [RETableViewSection sectionWithHeaderTitle:@"帮助"];
    
    [section addItem:[RETableViewItem itemWithTitle:@"使用说明"
                                      accessoryType:UITableViewCellAccessoryDisclosureIndicator
                                   selectionHandler:^(RETableViewItem *item) {
                                       item.selectionStyle=UITableViewCellSelectionStyleNone;
                                       [self.navigationController pushViewController:[[OWTUsageViewCon alloc] initWithNibName:nil bundle:nil]
                                                                            animated:YES];
                                   }]];
    
    [section addItem:[RETableViewItem itemWithTitle:@"服务条款"
                                      accessoryType:UITableViewCellAccessoryDisclosureIndicator
                                   selectionHandler:^(RETableViewItem *item) {
                                       item.selectionStyle=UITableViewCellSelectionStyleNone;
                                       [self.navigationController pushViewController:[[OWTLicenseViewCon alloc] initWithNibName:nil bundle:nil]
                                                                            animated:YES];
                                   }]];
    
    [_manager addSection:section];
}

- (void)setupLogoutSection
{
    RETableViewSection* section = [RETableViewSection sectionWithHeaderTitle:@"账户"];
    [section addItem:[RETableViewItem itemWithTitle:@"退出当前用户"
                                      accessoryType:UITableViewCellAccessoryNone
                                   selectionHandler:^(RETableViewItem *item) {
                                       item.selectionStyle=UITableViewCellSelectionStyleNone;
                                       [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
                                       [self performLogout];
                                   }]];
    [_manager addSection:section];
}

- (void)performLogout
{
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"请确认"
                                                     andMessage:@"确认退出当前帐户吗？"];
    
    [alertView addButtonWithTitle:@"退出"
                             type:SIAlertViewButtonTypeDestructive
                          handler:^(SIAlertView *alert) {
                              [GetAuthManager() logout];
                              
//                              [self.navigationController popToRootViewControllerAnimated:NO];
//                              [[NSNotificationCenter defaultCenter] postNotificationName:kWTLoggedOutNotification object:nil];
//                               [self.navigationController popToRootViewControllerAnimated:YES];
                              @try {
                              self.tabBarController.selectedIndex =0;
                              [[NSNotificationCenter defaultCenter] postNotificationName:kWTLoggedOutNotification object:nil];
                              }
                              @catch (NSException *exception) {
                                  NSLog(@"异常的原因 %@",exception);
                              }

                              [self.navigationController popToRootViewControllerAnimated:NO];
                          }];
    
    [alertView addButtonWithTitle:@"取消"
                             type:SIAlertViewButtonTypeCancel
                          handler:^(SIAlertView *alert) {
                          }];
    
    alertView.transitionStyle = SIAlertViewTransitionStyleFade;
    
    [alertView show];
}

@end
