//
//  QJUser.h
//  QuanJingSDK
//
//  Created by QJ on 15/10/19.
//  Copyright © 2015年 QJ. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface QJUser : NSObject

@property (nonatomic, strong) NSNumber * uid;

@property (nonatomic, strong, nullable) NSString * age;

@property (nonatomic, strong, nullable) NSString * avatar;

@property (nonatomic, strong, nullable) NSString * bgUrl;

@property (nonatomic, strong, nullable) NSNumber * bornArea;

@property (nonatomic, strong, nullable) NSNumber * collectAmount;

@property (nonatomic, strong, nullable) NSDate * creatTime;

@property (nonatomic, strong, nullable) NSString * email;

@property (nonatomic, strong, nullable) NSNumber * fansAmount;

@property (nonatomic, strong, nullable) NSNumber * followAmount;

@property (nonatomic, strong, nullable) NSNumber * gender;

@property (nonatomic, strong, nullable) NSString * goodAt;

@property (nonatomic, strong, nullable) NSString * interest;

@property (nonatomic, strong, nullable) NSString * introduce;

@property (nonatomic, strong, nullable) NSString * job;

@property (nonatomic, strong, nullable) NSDate * lastLoginTime;

@property (nonatomic, strong, nullable) NSString * maritalStatus;

@property (nonatomic, strong, nullable) NSString * nickName;

@property (nonatomic, strong, nullable) NSString * password;

@property (nonatomic, strong, nullable) NSString * phone;

@property (nonatomic, strong, nullable) NSString * qq;

@property (nonatomic, strong, nullable) NSString * realName;

@property (nonatomic, strong, nullable) NSNumber * residence;

@property (nonatomic, strong, nullable) NSString * starSign;

@property (nonatomic, strong, nullable) NSNumber * stayArea;

@property (nonatomic, strong, nullable) NSNumber * stayAreaAddress;

@property (nonatomic, strong, nullable) NSNumber * uploadAmount;

@property (nonatomic, strong, nullable) NSNumber * likeAmount;

@property (nonatomic, strong, nullable) NSString * userName;

@property (nonatomic, strong, nullable) NSString * website;

@property (nonatomic, strong, nullable) NSNumber * hasFollowUser;

- (instancetype)initWithJson:(nullable NSDictionary *)json;

- (void)setPropertiesFromJson:(NSDictionary *)json;

@end

NS_ASSUME_NONNULL_END
