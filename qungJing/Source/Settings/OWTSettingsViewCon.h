//
//  OWTSettingsViewCon.h
//  Weitu
//
//  Created by Su on 5/21/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OWTSettingsViewCon : UIViewController<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic,strong)UITableView *tableView;
- (id)initWithDefaultStyle;

@end
