//
//  OWTRecommendedTableCell.h
//  Weitu
//
//  Created by Su on 8/18/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OWTRecommendedTableCell1 : UITableViewCell

@property (nonatomic, strong) OWTUser* user;
@property (nonatomic, copy) NSArray* assets;

@property (nonatomic, strong) void (^presentUserAction)(NSString* userID);
@property (nonatomic, strong) void (^presentAssetAction)(NSString* assetID);

@end
