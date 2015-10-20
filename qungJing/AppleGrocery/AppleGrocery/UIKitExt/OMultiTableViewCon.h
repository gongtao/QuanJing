//
//  OMultiTableViewCon.h
//  Weitu
//
//  Created by Su on 7/17/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OMultiTableViewCon : UITableViewController

@property (nonatomic, strong, readonly) NSString* activeTableID;
@property (nonatomic, strong, readonly) NSArray* tableIDs;
@property (nonatomic, strong, readonly) NSArray* titles;

- (void)setTableIDs:(NSArray *)tableIDs titles:(NSArray*)titles;

- (void)reloadData;

@end
