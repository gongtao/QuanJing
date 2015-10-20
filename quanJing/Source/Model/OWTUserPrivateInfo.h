//
//  OWTUserPrivateInfo.h
//  Weitu
//
//  Created by Su on 6/27/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import "OWTUserPrivateInfoData.h"

@interface OWTUserPrivateInfo : NSObject

@property (nonatomic, strong) NSString* cellphone;
@property (nonatomic, strong) NSString* email;
@property (nonatomic, strong) NSString* password;

- (void)mergeWithData:(OWTUserPrivateInfoData*)privateInfoData;

@end
