//
//  OWTUserAssetsViewCon.h
//  Weitu
//
//  Created by Su on 6/14/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>


#import "OWTAssetFlowViewCon.h"
@interface OWTUserAssetsViewCon : UIViewController

@property (nonatomic, strong) OWTUser* user;
@property (nonatomic, strong) OWTAssetFlowViewCon* assetViewCon;
@end
