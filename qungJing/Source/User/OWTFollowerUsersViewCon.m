//
//  OWTFollowerUsersViewCon.m
//  Weitu
//
//  Created by Su on 6/16/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import "OWTFollowerUsersViewCon.h"
#import "OWTUserFlowViewCon.h"
#import "OWTUser.h"
#import "OWTUserManager.h"
#import "OWTUserViewCon.h"
#import "SVProgressHUD+WTError.h"
#import "UIView+EasyAutoLayout.h"
#import "UIViewController+WTExt.h"
#import "AlbumPhotosListView1.h"
@interface OWTFollowerUsersViewCon ()

@property (nonatomic, strong) OWTUserFlowViewCon* userFlowViewCon;
@property (nonatomic, copy) NSOrderedSet* followerUsers;

@end

@implementation OWTFollowerUsersViewCon

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        [self setup];
    }
    return self;
}

- (NSOrderedSet*)followerUsers
{
    if (self.user != nil && self.user.fellowshipInfo != nil && self.user.fellowshipInfo.followerUsers != nil)
    {
        return self.user.fellowshipInfo.followerUsers;
    }
    else
    {
        return nil;
    }
}

- (void)setup
{
    _userFlowViewCon = [[OWTUserFlowViewCon alloc] initWithNibName:nil bundle:nil];
    _userFlowViewCon.isShowingFollowerUsers = YES;
    [self addChildViewController:_userFlowViewCon];
    
    __weak OWTFollowerUsersViewCon* wself = self;
    
    _userFlowViewCon.numberOfUsersFunc = ^
    {
        NSOrderedSet* followerUsers = [wself followerUsers];
        if (followerUsers != nil)
        {
            return (int)followerUsers.count;
        }
        else
        {
            return 0;
        }
    };
    
    _userFlowViewCon.userAtIndexFunc = ^(NSUInteger index)
    {
        NSOrderedSet* followerUsers = [wself followerUsers];
        if (followerUsers != nil)
        {
            return (OWTUser*)[followerUsers objectAtIndex:index];
        }
        else
        {
            return (OWTUser*)nil;
        }
    };
    
    _userFlowViewCon.onUserSelectedFunc = ^(OWTUser* ownerUser)
    {
        if (ownerUser != nil)
        {
            
//            if ([ownerUser.userID isEqualToString:GetUserManager().currentUser.userID ]) {
//                AlbumPhotosListView1 * userViewCon = [[AlbumPhotosListView1 alloc] initWithNibName:nil bundle:nil];
//                [self.navigationController pushViewController:userViewCon animated:YES];
//                
//            }
//            //        userViewCon.user = ownerUser;
//            else
//            {
                OWTUserViewCon* userViewCon1 = [[OWTUserViewCon alloc] initWithNibName:nil bundle:nil];
                [self.navigationController pushViewController:userViewCon1 animated:YES];
                userViewCon1.user =ownerUser;
          
                
//            }
            
        }

    };
    
    _userFlowViewCon.refreshDataFunc = ^(void (^refreshDoneFunc)())
    {
        OWTUserManager* um = GetUserManager();
        [um refreshUserFollowerUsers:wself.user
                             success:^{
                                 if (refreshDoneFunc != nil)
                                 {
                                     refreshDoneFunc();
                                 }
                             }
                             failure:^(NSError* error) {
                                 [SVProgressHUD showError:error];
                                 if (refreshDoneFunc != nil)
                                 {
                                     refreshDoneFunc();
                                 }
                             }];
    };

    _userFlowViewCon.loadMoreDataFunc = ^(void (^loadMoreDoneFunc)()){
        OWTUserManager* um = GetUserManager();
        [um loadMoreUserFollowerUsers:wself.user
                              success:^{
                                  if (loadMoreDoneFunc != nil)
                                  {
                                      loadMoreDoneFunc();
                                  }
                              }
                              failure:^(NSError* error) {
                                  [SVProgressHUD showError:error];
                                  if (loadMoreDoneFunc != nil)
                                  {
                                      loadMoreDoneFunc();
                                  }
                              }];
    };
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view addSubview:_userFlowViewCon.view];
    [_userFlowViewCon.view easyFillSuperview];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self substituteNavigationBarBackItem];
    [_userFlowViewCon reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self refreshFollowingUsersIfNeeded];
}

- (void)refreshFollowingUsersIfNeeded
{
    if (_user == nil)
    {
        return;
    }
    
    if ([self followerUsers] != nil)
    {
        return;
    }
    
    [_userFlowViewCon manualRefresh];
}

#pragma mark -

- (void)setUser:(OWTUser*)user
{
    _user = user;

    if (_user != nil)
    {
        self.navigationItem.title = [NSString stringWithFormat:@"关注%@的人", _user.displayName];
//        UILabel * label = [[UILabel alloc]initWithFrame:CGRectMake(0, 20, 100, 44)];
//        label.text = [NSString stringWithFormat:@"关注%@的人", _user.displayName];
//
//        
//       label.font = [UIFont fontWithName:@"Arial-BoldItalicMT" size:24];
//        
//        [label setTextAlignment:NSTextAlignmentCenter];
//        label.textColor = GetThemer().themeTintColor;
//        self.navigationItem.titleView =label;

        
        
        NSNumber* totalUserNum = [NSNumber numberWithInteger:_user.fellowshipInfo.followerNum];
        _userFlowViewCon.totalUserNum = totalUserNum;
    }
    else
    {
        self.navigationItem.title = @"";
        _userFlowViewCon.totalUserNum = nil;
    }
}

@end
