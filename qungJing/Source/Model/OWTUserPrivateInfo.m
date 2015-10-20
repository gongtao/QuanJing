//
//  OWTUserPrivateInfo.m
//  Weitu
//
//  Created by Su on 6/27/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import "OWTUserPrivateInfo.h"

@implementation OWTUserPrivateInfo

- (void)mergeWithData:(OWTUserPrivateInfoData*)privateInfoData
{
    if (privateInfoData.cellphone != nil)
    {
        _cellphone = privateInfoData.cellphone;
    }

    if (privateInfoData.email != nil)
    {
        _email = privateInfoData.email;
    }

    if (privateInfoData.password != nil)
    {
        _password = privateInfoData.password;
    }
}

@end
