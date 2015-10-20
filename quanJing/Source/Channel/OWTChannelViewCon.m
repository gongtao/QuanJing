//
//  OWTChannelViewCon.m
//  Weitu
//
//  Created by Su on 3/10/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import "OWTChannelViewCon.h"
#import "OWaterFlowViewCon.h"
#import "OWTChannelItem.h"
#import "OWTChannelManager.h"
#import <UIColor-HexString/UIColor+HexString.h>
#import <FontAwesomeKit/FAKFontAwesome.h>
#import <REMenu/REMenu.h>

@interface OWTChannelViewCon ()
{
    OWTChannel* _channel;
    REMenu* _navMenu;
}

@property (nonatomic, strong) OWaterFlowViewCon* waterFlowViewCon;

@property (nonatomic, strong) REMenuItem* latestItem;

@end

@implementation OWTChannelViewCon

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
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
    _waterFlowViewCon = [[OWaterFlowViewCon alloc] init];
    _waterFlowViewCon.waterFlowDataSource = self;
    __weak OWTChannelViewCon* weakSelf = self;
    _waterFlowViewCon.refreshAction = ^{ [weakSelf refreshChannel]; };
    [self addChildViewController:self.waterFlowViewCon];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.view addSubview:self.waterFlowViewCon.view];

    self.waterFlowViewCon.view.translatesAutoresizingMaskIntoConstraints = NO;
    NSDictionary* parameters = @{ @"view" : self.waterFlowViewCon.view };
    [self.view addConstraint:[NSLayoutConstraint constraintWithExpressionFormat:@"view.left = superview.left" parameters:parameters]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithExpressionFormat:@"view.right = superview.right" parameters:parameters]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithExpressionFormat:@"view.top = superview.top" parameters:parameters]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithExpressionFormat:@"view.bottom = superview.bottom" parameters:parameters]];

    [_waterFlowViewCon reloadData];

    [self setupNavigationBar];
}

- (void)setupNavigationBar
{
    UIImage* barsIconImage = [[FAKFontAwesome barsIconWithSize:22] imageWithSize:CGSizeMake(22, 22)];
    barsIconImage = [barsIconImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:barsIconImage
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(toggleNavMenu)];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor colorWithHexString:@"#3399cc"];

    UIImage* searchImage = [[FAKFontAwesome searchIconWithSize:22] imageWithSize:CGSizeMake(22, 22)];
    searchImage = [searchImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIImageView* searchView = [[UIImageView alloc] initWithImage:searchImage];
    searchView.tintColor = [UIColor colorWithHexString:@"#3399cc"];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:searchView];

    [self setupNavMenu];
}

- (void)setupNavMenu
{
    _latestItem = [[REMenuItem alloc] initWithTitle:@"最新上传"
                                           subtitle:@"所有最新最炫图片都在这里"
                                              image:[[FAKFontAwesome boltIconWithSize:22] imageWithSize:CGSizeMake(22, 22)]
                                   highlightedImage:nil
                                             action:^(REMenuItem* item){
                                                 [self presentLatestChannel];
                                             }];
    
    REMenuItem* wallpaperItem = [[REMenuItem alloc] initWithTitle:@"热门壁纸"
                                                         subtitle:@"各种美丽壁纸一网打尽"
                                                            image:[[FAKFontAwesome mobileIconWithSize:22] imageWithSize:CGSizeMake(22, 22)]
                                                 highlightedImage:nil
                                                           action:^(REMenuItem* item){
                                                               [self presentWallpaperChannel];
                                                           }];
    
    REMenuItem* followingItem = [[REMenuItem alloc] initWithTitle:@"我的关注"
                                                         subtitle:@"小伙伴们的图片在这里"
                                                            image:[[FAKFontAwesome usersIconWithSize:22] imageWithSize:CGSizeMake(22, 22)]
                                                 highlightedImage:nil
                                                           action:^(REMenuItem* item){
                                                               [self presentFollowingChannel];
                                                           }];
    
    REMenuItem* subscriptionItem = [[REMenuItem alloc] initWithTitle:@"我的订阅"
                                                            subtitle:@"分类订阅中的最新图片"
                                                               image:[[FAKFontAwesome tagsIconWithSize:22] imageWithSize:CGSizeMake(22, 22)]
                                                    highlightedImage:nil
                                                              action:^(REMenuItem* item){
                                                                  [self presentSubscriptionChannel];
                                                              }];

    _navMenu = [[REMenu alloc] initWithItems:@[ _latestItem, wallpaperItem, followingItem, subscriptionItem ]];
    _navMenu.liveBlur = YES;
    _navMenu.liveBlurBackgroundStyle = REMenuLiveBackgroundStyleLight;
    _navMenu.closeOnSelection = YES;

    _navMenu.font = [UIFont boldSystemFontOfSize:16];
    _navMenu.textOffset = CGSizeMake(0, 2);
    _navMenu.textColor = [UIColor darkGrayColor];
    _navMenu.subtitleFont = [UIFont systemFontOfSize:13];
    _navMenu.subtitleTextColor = [UIColor darkGrayColor];
    _navMenu.subtitleTextOffset = CGSizeMake(0, -1);
    _navMenu.subtitleTextShadowColor = nil;
    _navMenu.borderWidth = 0.5;
    _navMenu.borderColor = [UIColor lightGrayColor];
    _navMenu.separatorColor = [UIColor lightGrayColor];
    _navMenu.separatorHeight = 0.5;

    _navMenu.highlightedTextShadowColor = nil;
    _navMenu.highlightedTextColor = [UIColor blackColor];
    _navMenu.subtitleHighlightedTextColor = [UIColor blackColor];
    _navMenu.subtitleHighlightedTextShadowColor = nil;
    _navMenu.highlightedBackgroundColor = [UIColor colorWithHexString:@"#3399cc"];

    _navMenu.cornerRadius = 4;

    _navMenu.imageOffset = CGSizeMake(10, 0);
    _navMenu.waitUntilAnimationIsComplete = NO;
}

- (void)toggleNavMenu
{
    if (_navMenu.isOpen)
    {
        return [_navMenu close];
    }

    [_navMenu showFromNavigationController:self.navigationController];
}

- (void)presentLatestChannel
{
    self.navigationItem.title = nil;
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"weitu_logo"]];

    OWTChannel* channel = [[OWTChannelManager one] channelWithID:kWTChannelLatestUploads];
    [self presentChannel:channel animated:YES];
    [self refreshChannel];
}

- (void)presentWallpaperChannel
{
    self.navigationItem.title = @"热门壁纸";
    self.navigationItem.titleView = nil;

    OWTChannel* channel = [[OWTChannelManager one] channelWithID:kWTChannelWallpaper];
    [self presentChannel:channel animated:YES];
    [self refreshChannel];
}

- (void)presentFollowingChannel
{
    self.navigationItem.title = @"我的关注";
    self.navigationItem.titleView = nil;

    OWTChannel* channel = [[OWTChannelManager one] channelWithID:kWTChannelFollowing];
    [self presentChannel:channel animated:YES];
    [self refreshChannel];
}

- (void)presentSubscriptionChannel
{
    self.navigationItem.title = @"我的订阅";
    self.navigationItem.titleView = nil;

    OWTChannel* channel = [[OWTChannelManager one] channelWithID:kWTChannelSubscription];
    [self presentChannel:channel animated:YES];
    [self refreshChannel];
}

#pragma mark - Actions

- (void)presentChannel:(OWTChannel*)channel animated:(BOOL)animated
{
    if (channel == _channel)
    {
        return;
    }

    _channel = channel;

    [_waterFlowViewCon reloadData];

    if ([_channel.channelID compare:@"latest"] == NSOrderedSame)
    {
        [self.navigationItem setTitle:nil];
        UIImageView* logoView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"weitu_logo"]];
        [self.navigationItem setTitleView:logoView];
    }
    else
    {
        [self.navigationItem setTitle:_channel.nameZH];
    }
}

- (NSInteger)numberOfItems
{
    if (_channel != nil)
    {
        return _channel.items.count;
    }
    else
    {
        return 0;
    }
}

- (OWTChannelItem*)itemAtIndexPath:(NSIndexPath *)indexPath
{
    if (_channel != nil && indexPath != nil)
    {
        NSInteger row = indexPath.row;
        if (row < _channel.items.count)
        {
            return _channel.items[row];
        }
    }

    return nil;
}

#pragma mark - Refreshing related

- (void)refreshChannel
{
    [_channel refreshWithSuccess:^{ [_waterFlowViewCon notifyRefreshDone]; }
                         failure:^(NSError* error) {
                             [_waterFlowViewCon notifyRefreshDone];

                             EWTErrorCodes code = (EWTErrorCodes)error.code;
                             switch (code)
                             {
                                 case kWTErrorNetwork:
                                     [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"NETWORK_ERROR", @"Notify user network error.")];
                                     break;
                                 default:
                                     [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"GENERAL_ERROR_TRY_LATER", @"General error occurred, please try later.")];
                                     break;
                             }
                         }];
}

@end
