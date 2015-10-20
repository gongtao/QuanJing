//
//  OWTDefalutTagsViewController.h
//  Weitu
//
//  Created by denghs on 15/10/9.
//  Copyright © 2015年 SparkingSoft Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OWTDefalutTagsViewController : UITableViewController

@property (nonatomic, strong) void (^tagSelectedAction)(NSString *str);

@end
