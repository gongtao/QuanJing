//
//  OWTFollowingUsersViewCon.m
//  Weitu
//
//  Created by Su on 6/16/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import "OWTFollowingUsersViewCon.h"
#import "OWTUserFlowViewCon.h"
#import "OWTUser.h"
#import "OWTUserManager.h"

#import "SVProgressHUD+WTError.h"
#import "UIView+EasyAutoLayout.h"
#import "UIViewController+WTExt.h"


#import "AlbumPhotosListView1.h"

#import "OWTUserViewCon.h"
@interface OWTFollowingUsersViewCon ()

@property (nonatomic, strong) OWTUserFlowViewCon* userFlowViewCon;
@property (nonatomic, copy) NSOrderedSet* followingUsers;

@end

@implementation OWTFollowingUsersViewCon

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        [self setup];
    }
    return self;
}

- (void)setup
{
    _userFlowViewCon = [[OWTUserFlowViewCon alloc] initWithNibName:nil bundle:nil];
    [self addChildViewController:_userFlowViewCon];

    __weak OWTFollowingUsersViewCon* wself = self;
    _userFlowViewCon.isShowingFollowerUsers=YES;
    //将block对外部抖出一个口,外部在合适的时候掉用
    _userFlowViewCon.numberOfUsersFunc = ^
    {
        return wself.user.followAmount.intValue;
    };
    
    _userFlowViewCon.userAtIndexFunc = ^(NSUInteger index)
    {
        NSOrderedSet* followingUsers = [wself followingUsers];
        if (followingUsers != nil)
        {
            return (OWTUser*)[followingUsers objectAtIndex:index];
        }
        else
        {
            return (OWTUser*)nil;
        }
    };

    _userFlowViewCon.onUserSelectedFunc = ^(QJUser* ownerUser)
    {
        if (ownerUser != nil)
        {
            
                OWTUserViewCon* userViewCon1 = [[OWTUserViewCon alloc] initWithNibName:nil bundle:nil];
                userViewCon1.hidesBottomBarWhenPushed = YES;
                [wself.navigationController pushViewController:userViewCon1 animated:YES];
            userViewCon1.quser=ownerUser;
        }
    };
    //请求喜欢当前用户 人的数据
    _userFlowViewCon.refreshDataFunc = ^(void (^refreshDoneFunc)())
    {
        [wself.userFlowViewCon.dataResouce removeAllObjects];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [[QJPassport sharedPassport]requestUserFollowList:wself.user.uid pageNum:1 pageSize:30 finished:^(NSArray * _Nonnull followUserArray, BOOL isLastPage, NSArray * _Nonnull resultArray, NSError * _Nonnull error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                if (error) {
                        [SVProgressHUD showError:error];
                    if (refreshDoneFunc!=nil) {
                        refreshDoneFunc();
                    }
                }else {
                    wself.userFlowViewCon.islast=isLastPage;
                    [wself.userFlowViewCon.dataResouce addObjectsFromArray:followUserArray];
                    if (refreshDoneFunc!=nil) {
                        refreshDoneFunc();
                    }
                }
                });
            }];
        });
        
    };
    
    _userFlowViewCon.loadMoreDataFunc = ^(void (^loadMoreDoneFunc)()){
        if (wself.userFlowViewCon.islast) {
            [SVProgressHUD showErrorWithStatus:@"没有更多图片"];
            if (loadMoreDoneFunc) {
                loadMoreDoneFunc();
            }
            return ;
        }
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[QJPassport sharedPassport]requestUserFollowList:wself.user.uid pageNum:_userFlowViewCon.dataResouce.count/30+1 pageSize:30 finished:^(NSArray * _Nonnull followUserArray, BOOL isLastPage, NSArray * _Nonnull resultArray, NSError * _Nonnull error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (error) {
                    [SVProgressHUD showError:error];
                    if (loadMoreDoneFunc) {
                        loadMoreDoneFunc();
                    }
                }else {
                    [wself.userFlowViewCon.dataResouce addObjectsFromArray:followUserArray];
                    if (loadMoreDoneFunc) {
                        loadMoreDoneFunc();
                    }
                }
            });
        }];
    });

    };
    [_userFlowViewCon manualRefresh];
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

    if ([self followingUsers] != nil)
    {
        return;
    }

    [_userFlowViewCon manualRefresh];
}

#pragma mark -

- (void)setUser:(QJUser*)user
{
    _user = user;
    if (_user != nil)
    {
        self.navigationItem.title = [NSString stringWithFormat:@"%@关注的人", _user.nickName];
        _userFlowViewCon.totalUserNum = _user.followAmount;
    }
    else
    {
        self.navigationItem.title = @"";
        _userFlowViewCon.totalUserNum = nil;
    }
}
#pragma mark -getData
-(void)getTheData
{

}
@end
