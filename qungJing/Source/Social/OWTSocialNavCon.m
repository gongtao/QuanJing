//
//  OWTNotificationViewCon.m
//  Weitu
//
//  Created by Su on 4/21/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import "OWTSocialNavCon.h"


#import "OWTFont.h"



#import "OWTFeedManager.h"
#import "LJFeedWithUserProfileViewCon.h"
@interface OWTSocialNavCon ()






@end

@implementation OWTSocialNavCon

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
    [self setupTabBarItem];

    
    
    LJFeedWithUserProfileViewCon *ljvc=[[LJFeedWithUserProfileViewCon alloc]initWithNibName:nil bundle:nil];
    if (ljvc.feed == nil)
    {
        OWTFeed* feed = [GetFeedManager() feedWithID:kWTFeedSquare];
        [ljvc presentFeed:feed animated:YES refresh:YES];
    }
    // hidesBottomBarWhenPushed
    [self pushViewController:ljvc animated:NO];

}

- (void)setupTabBarItem
{
    
  UIImage* tabBarIconImage = [UIImage imageNamed:@"社区.png"];
  self.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"社区" image:tabBarIconImage selectedImage:nil];

}

@end
