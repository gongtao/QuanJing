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

-(NSString*)cityCode2CityName:(NSNumber*)cityCode
{
    NSString *homeDictionary = NSHomeDirectory();//获取根目录
    NSString *homePath  = [homeDictionary stringByAppendingString:@"/Documents/cityDode2Name.archiver"];//添加储存的文件名
    NSArray *array =  [NSKeyedUnarchiver unarchiveObjectWithFile:homePath];
    NSString *result = nil;
    if (array == nil) {
        return nil;
    }else{
        for (NSDictionary *dic in array) {
            if ([dic[@"DictId"] isEqualToString:[cityCode stringValue]]) {
                NSString *city = dic[@"DictName"];
                NSString* provinceID = dic[@"ParentID"];
                NSString *province = @"";
                for (NSDictionary *dic in array) {
                    if (dic[@"DictId"] == provinceID) {
                        province = dic[@"DictName"];
                    }
                }
                result = [NSString stringWithFormat:@"%@ - %@",province,city];
                
            }
        }
    }
    
    return result;
}

-(NSNumber*)cityName2CityCode:(NSString*)cityName
{
    NSArray *arraytmp = [cityName componentsSeparatedByString:@"-"];
    NSString *tmp  = [arraytmp lastObject];
    cityName =  [tmp substringFromIndex:1];//截取

    NSString *homeDictionary = NSHomeDirectory();//获取根目录
    NSString *homePath  = [homeDictionary stringByAppendingString:@"/Documents/cityDode2Name.archiver"];//添加储存的文件名
    NSArray *array =  [NSKeyedUnarchiver unarchiveObjectWithFile:homePath];
    NSNumber *result = nil;
    if (array == nil) {
        return nil;
    }else{
        for (NSDictionary *dic in array) {
            if ([dic[@"DictName"] isEqualToString:cityName]) {
                NSString *cityCode = dic[@"DictId"];
                result = [NSNumber numberWithInteger:[cityCode integerValue]];
                
            }
        }
    }
    
    return result;
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
    
    if (user.stayAreaAddress != nil) {
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
