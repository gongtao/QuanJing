//
//  OWTSocialAddViewCon.m
//  Weitu
//
//  Created by Su on 8/18/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import "OWTSocialAddViewCon.h"

@interface OWTSocialAddViewCon ()

@end

@implementation OWTSocialAddViewCon

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (IBAction)capture:(id)sender
{
    if (_captureAction != nil)
    {
        _captureAction();
    }
}

- (IBAction)upload:(id)sender
{
    if (_uploadAction != nil)
    {
        _uploadAction();
    }
}

- (IBAction)inviteFriends:(id)sender
{
    if (_inviteFriendsAction != nil)
    {
        _inviteFriendsAction();
    }
}

@end
