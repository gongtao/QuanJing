//
//  OWTCategoryViewCon.h
//  Weitu
//
//  Created by Su on 5/12/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OWTCategory.h"
#import "UIViewController+BackButtonHandler.h"
@interface OWTCategoryViewCon : UIViewController<UISearchBarDelegate>

@property(nonatomic, assign)BOOL ifNeedSetbackground;
- (id)initWithCategory:(OWTCategory*)category;

@end
