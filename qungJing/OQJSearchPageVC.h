//
//  OQJSearchPageVC.h
//  Weitu
//
//  Created by denghs on 15/9/29.
//  Copyright (c) 2015年 SparkingSoft Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OQJSearchPageVC : UIViewController<UISearchBarDelegate>

@property (nonatomic, strong)NSString *tile;
- (id)initWithSeachContent:(NSString *)title;
@end
