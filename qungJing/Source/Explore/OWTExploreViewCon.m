//
//  OWTExploreViewCon.m
//  Weitu
//
//  Created by Su on 4/21/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import "OWTExploreViewCon.h"
#import "OWTFont.h"
#import "OWTCategoryListViewCon.h"

@interface OWTExploreViewCon ()

@property (nonatomic, strong) OWTCategoryListViewCon* categoryListViewCon;

@end

@implementation OWTExploreViewCon

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

    _categoryListViewCon = [[OWTCategoryListViewCon alloc] initWithNibName:nil bundle:nil];
    [self pushViewController:_categoryListViewCon animated:NO];
}

- (void)setupTabBarItem
{
    
    UIImage* eyeImage = [[OWTFont eyeIconWithSize:32] imageWithSize:CGSizeMake(32, 32)];
    self.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"发现" image:eyeImage selectedImage:nil];
}

@end
