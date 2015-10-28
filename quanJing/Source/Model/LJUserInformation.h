//
//  LJUserInformation.h
//  Weitu
//
//  Created by qj-app on 15/5/27.
//  Copyright (c) 2015年 SparkingSoft Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QJUser.h"
@interface LJUserInformation : NSObject
@property(nonatomic,copy)NSString *userID;
@property(nonatomic,copy)NSString *Sex;
@property(nonatomic,copy)NSString *decade;
@property(nonatomic,copy)NSString *Constellation;
@property(nonatomic,copy)NSString *Marriage;
@property(nonatomic,copy)NSString *BirthLocation;
@property(nonatomic,copy)NSString *City;
@property(nonatomic,copy)NSString *HomeCity;
@property(nonatomic,copy)NSString *Occupation;
@property(nonatomic,copy)NSString *Favourite;
@property(nonatomic,copy)NSString *Mobile;
@property(nonatomic,copy)NSString *truename;
@property(nonatomic,copy)NSString *Userinfo;

-(void)userAdaptInformation:(QJUser*)user;

-(NSString*)cityCode2CityName:(NSNumber*)cityCode ;

-(NSNumber*)cityName2CityCode:(NSString*)cityName;
@end
