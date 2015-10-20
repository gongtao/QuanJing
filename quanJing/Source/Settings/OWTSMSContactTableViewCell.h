//
//  OWTSMSContactTableViewCell.h
//  Weitu
//
//  Created by Su on 6/19/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OWTSMSContactTableViewCell : UITableViewCell

@property (nonatomic, copy) NSString* name;
@property (nonatomic, copy) NSString* cellphone;

@property (nonatomic, strong) void(^inviteFunc)(NSString* name, NSString* cellphone);

@end
