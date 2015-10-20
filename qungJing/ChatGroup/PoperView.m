//
//  PoperView.m
//  Weitu
//
//  Created by denghs on 15/6/1.
//  Copyright (c) 2015年 SparkingSoft Co., Ltd. All rights reserved.
//

#import "PoperView.h"

@implementation PoperView
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.userInteractionEnabled = YES;
        UIImageView *profileView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"friendList"]];
        profileView.frame = CGRectMake(10, 7+8, 19, 22);
        
        UIImageView *middleLine = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"middleSplitLine"]];
        [middleLine setAlpha:0.3];
        middleLine.frame = CGRectMake(10, self.frame.size.height/2+2, self.frame.size.width-20, 1);
        [self addSubview:middleLine];
        
        
        UIImageView *startTalk = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"startTalk"]];
        startTalk.frame = CGRectMake(profileView.frame.origin.x, profileView.frame.origin.y+18+profileView.frame.size.height, profileView.frame.size.height-2,profileView.frame.size.height-2 );
        
        [self addSubview:profileView];
        [self addSubview:startTalk];
        
        
        UIButton *firendListBtn = [[UIButton alloc]init];
        firendListBtn.frame = CGRectMake(profileView.frame.origin.x+15, profileView.frame.origin.y+2, self.frame.size.width- profileView.frame.size.width-5, profileView.frame.size.height);
        [firendListBtn setTitle:@"通讯录  " forState:UIControlStateNormal];
        [self addSubview:firendListBtn];
        [firendListBtn addTarget:self action:@selector(showFriendList:) forControlEvents:UIControlEventTouchDown];
        
        UIButton *startGropTalk = [[UIButton alloc]init];
        startGropTalk.frame = CGRectMake(firendListBtn.frame.origin.x,startTalk.frame.origin.y, firendListBtn.frame.size.width, firendListBtn.frame.size.height);
        [startGropTalk setTitle:@"发起群聊" forState:UIControlStateNormal];
        [startGropTalk addTarget:self action:@selector(addGropTalk:) forControlEvents:UIControlEventTouchDown];
        
        
        [self addSubview:startGropTalk];
        
    }
    
    return self;
}

-(void)showFriendList:(UIButton*)sender
{
    _showFriendList();
}

-(void)addGropTalk:(UIButton*)sender
{
    _addgroudTalk();
}


@end
