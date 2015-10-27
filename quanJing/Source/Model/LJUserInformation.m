//
//  LJUserInformation.m
//  Weitu
//
//  Created by qj-app on 15/5/27.
//  Copyright (c) 2015年 SparkingSoft Co., Ltd. All rights reserved.
//

#import "LJUserInformation.h"

@implementation LJUserInformation
-(void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    
}

-(void)userAdaptInformation:(QJUser*)user
{
    if (user.uid != nil) {
        _userID = [user.uid stringValue];
    }
    if (user.gender != NULL) {
        
        _Sex = [user.gender stringValue];
        if ([_Sex isEqualToString:@"0"]) {
            _Sex =  @"男";
        }else if([_Sex isEqualToString:@"1"]){
            _Sex =  @"女";
        }else{
          _Sex =  @"保密";
        }
    }
    
    if (user.age != nil && ![user.age isEqualToString:@""]) {
        _decade = user.age;
    }else{
        _decade = @"保密";

    }
    if (user.starSign != nil &&  ![user.starSign isEqualToString:@""]) {
        _Constellation = user.starSign;
    }else{
        _Constellation = @"保密";

    }
    if (user.maritalStatus != nil && ![user.maritalStatus isEqualToString:@""]) {
        _Marriage = user.maritalStatus;
    }else{
        _Marriage = @"保密";

    }
    if (user.bornArea != nil) {
       // _BirthLocation= user.bornArea;
    }else{
        _BirthLocation = @"保密";

    }
    if (user.stayArea != nil ) {
       // _City = user.stayArea;
    }else{
        _City = @"保密";

    }
    
    if (user.stayAreaAddress != nil && ![user.stayAreaAddress isEqualToString:@""]) {
        _HomeCity = user.stayAreaAddress;
    }else{
        _HomeCity = @"保密";
    }
    if (user.job != nil) {
        _Occupation = user.job;
    }else{
        _Occupation = @"保密";

    }
    if (user.interest != nil) {
        _Favourite = user.interest;
    }
    if (user.phone != nil) {
        _Mobile = user.phone;
    }
    if (user.nickName != nil) {
        _truename = user.nickName;
    }
    if (user.interest  != nil) {
        _Favourite = user.interest;
    }
    if (user.introduce  != nil) {
        _Userinfo = user.introduce;
    }
}

@end
