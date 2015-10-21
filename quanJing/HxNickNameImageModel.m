//
//  HxNickNameImageModel.m
//  Weitu
//
//  Created by denghs on 15/5/26.
//  Copyright (c) 2015年 SparkingSoft Co., Ltd. All rights reserved.
//

#import "HxNickNameImageModel.h"
#import "OWTUser.h"
@implementation HxNickNameImageModel

+(NSString*)getNickName:(NSString*)userId
{
    NSString *usrID = [userId substringFromIndex:2];
    NSDictionary *rootDic =  [[NSUserDefaults standardUserDefaults]objectForKey:@"HxChatData"];
    
    if ([rootDic[usrID] isKindOfClass:[NSNull  class]]) {
        return @"";
    }
    if ([[rootDic[usrID] objectForKey:@"nickName"]isKindOfClass:[NSNull class]])
    {
        return @"";
    }
    return [rootDic[usrID] objectForKey:@"nickName"];
}

+(UIImage*)getProfileImage:(NSString*)userId
{
    NSString *usrID = [userId substringFromIndex:2];
    NSDictionary *rootDic =  [[NSUserDefaults standardUserDefaults]objectForKey:@"HxChatData"];
    //TODO  异常需要解决
    if ([rootDic[usrID] isKindOfClass:[NSNull  class]]) {
        return nil;
    }
    if ([[rootDic[usrID] objectForKey:@"smallURLImage"]isKindOfClass:[NSNull class]])
    {
        return nil;
    }
    NSData* iamgeData =  [rootDic[usrID] objectForKey:@"smallURLImage"];
    return [UIImage imageWithData:iamgeData];
    
}

+(UIImage*)getProfileImageWithoutPrefix:(NSString*)userId
{
    NSDictionary *rootDic =  [[NSUserDefaults standardUserDefaults]objectForKey:@"HxChatData"];
    //TODO  异常需要解决
    if ([rootDic[userId] isKindOfClass:[NSNull  class]]) {
        return nil;
    }
    if ([[rootDic[userId] objectForKey:@"smallURLImage"]isKindOfClass:[NSNull class]])
    {
        return nil;
    }
    NSData* iamgeData =  [rootDic[userId] objectForKey:@"smallURLImage"];
    return [UIImage imageWithData:iamgeData];
    
}

+(void)synDeleChatData:(NSString *)userId;
{
    NSString *usrID = [userId substringFromIndex:2];
    NSDictionary *tmpDic =  [[NSUserDefaults standardUserDefaults]objectForKey:@"HxChatData"];
    //removeObjectForKey
    NSMutableDictionary *rootDic = [NSMutableDictionary dictionaryWithDictionary:tmpDic];
    if ([[rootDic allKeys]containsObject:usrID])
    {
        [rootDic removeObjectForKey:usrID];
        [[NSUserDefaults standardUserDefaults]setValue:rootDic forKey:@"HxChatData"];
        [[NSUserDefaults standardUserDefaults]synchronize];
    }
    
}

+(void)askProfileNickNamebyUserIds:(NSArray*)usrId
{
#pragma TODO 后期抽出时间 把这些BaseURL 定义在一个MODel里面
    //如果本地沙河不存在
    NSDictionary *tmpDic = [[NSUserDefaults standardUserDefaults]objectForKey:@"HxChatData"];
    NSMutableDictionary *rootDic;
    if (!tmpDic)
    {
        rootDic = [[NSMutableDictionary alloc]init];
        
    }
    else
    {
        rootDic = [[NSMutableDictionary alloc]initWithDictionary:tmpDic];
    }
    NSArray *allKeys = [rootDic allKeys];
    //拿subPath作为主键去遍历保存 环信数据的沙盒
    for (NSString *subPath  in usrId)
    {
        BOOL ifAskServerAPI  = [allKeys containsObject:subPath];
        //去遍历根字典 当前的UserID不存在时 去网络请求数据
        if (!ifAskServerAPI)
        {
            NSString *urlBasePath = @"http://api.tiankong.com/qjapi/users/";
            urlBasePath = [urlBasePath stringByAppendingFormat:@"%@/info",subPath];
            NSURL *url = [NSURL URLWithString:urlBasePath];
            NSURLRequest *request =[NSURLRequest requestWithURL:url];
            NSMutableDictionary *mDic = [[NSMutableDictionary alloc]init];
            
            //同步网络请求
            NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
            
            //NSJSONSerialization解析
            if (response!=nil)
            {
                NSDictionary  *dic0 =[NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingMutableLeaves error:nil];
                NSLog(@"解析出来的JSON数据  %@",dic0);
                NSDictionary *appList=dic0[@"user"];
                
                //获取昵称数据
                if ([appList[@"truename"] isKindOfClass:[NSNull class]])
                {
                    [mDic setValue:@"nil" forKey:@"nickName"];
                }else
                {
                    [mDic setValue:appList[@"truename"] forKey:@"nickName"];
                }
                
                
                //获取头像数据
                if ([appList[@"headpic"] isKindOfClass:[NSNull class]])
                {
                    //do something
                    [mDic setValue:@"nil" forKey:@"smallURLImage"];
                }else
                {
                    NSData *smallURLImage = [NSData dataWithContentsOfURL:[NSURL URLWithString:appList[@"headpic"]]];
                    [mDic setValue:smallURLImage forKey:@"smallURLImage"];
                }
                [mDic setValue:subPath forKey:@"userID"];
                
                
                
            }
            
            //把每个元素写入根字典
            [rootDic setValue:mDic forKey:subPath];
           
        }
    }
    //数据持久化
    [[NSUserDefaults standardUserDefaults]setValue:rootDic forKey:@"HxChatData"];
    [[NSUserDefaults standardUserDefaults]synchronize];
}

+(void)getProfileByavatarUrl:(NSArray*)userArray
{
#pragma TODO 后期抽出时间 把这些BaseURL 定义在一个MODel里面
    //如果本地沙河不存在
    NSDictionary *tmpDic = [[NSUserDefaults standardUserDefaults]objectForKey:@"HxChatData"];
    if ([tmpDic isKindOfClass:[NSNull class]]) {
        tmpDic = [[NSMutableDictionary alloc]init];
    }
    NSMutableDictionary *rootDic = [[NSMutableDictionary alloc]initWithDictionary:tmpDic];
    
    NSArray *allKeys = [rootDic allKeys];
    
    //好友列表返回的 不带qj
    for(OWTUser* user in userArray)
    {
        BOOL ifAskServerAPI  = [allKeys containsObject:user.userID];
        //去遍历根字典 当前的UserID不存在时 去网络请求数据
        if (!ifAskServerAPI)
        {
            NSMutableDictionary *mDic = [[NSMutableDictionary alloc]init];
            [mDic setValue:user.nickname forKey:@"nickName"];
            
            NSData *smallURLImage = [NSData dataWithContentsOfURL:[NSURL URLWithString:user.avatarImageInfo.url]];
            [mDic setValue:smallURLImage forKey:@"smallURLImage"];
            [mDic setValue:user.userID forKey:@"userID"];
            
            //把每个元素写入根字典
            [rootDic setValue:mDic forKey:user.userID];
            //数据持久化
        }
        
    }
    [[NSUserDefaults standardUserDefaults]setValue:rootDic forKey:@"HxChatData"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    

}

+(NSMutableArray*)getAvatarNickNameArray:(NSArray*)userArray
{
#pragma TODO 后期抽出时间 把这些BaseURL 定义在一个MODel里面
    //如果本地沙河不存在
    NSDictionary *tmpDic = [[NSUserDefaults standardUserDefaults]objectForKey:@"HxChatData"];
    if ([tmpDic isKindOfClass:[NSNull class]]) {
        tmpDic = [[NSMutableDictionary alloc]init];
    }
    NSMutableDictionary *rootDic = [[NSMutableDictionary alloc]initWithDictionary:tmpDic];
    
    NSArray *allKeys = [rootDic allKeys];
    
    NSMutableArray *avatarNickNameArray = [[NSMutableArray alloc]init];
    //好友列表返回的 不带qj
    for(OWTUser* user in userArray)
    {
        BOOL ifAskServerAPI  = [allKeys containsObject:user.userID];
        //去遍历根字典 当前的UserID不存在时 去网络请求数据
        if (!ifAskServerAPI)
        {
            NSMutableDictionary *mDic = [[NSMutableDictionary alloc]init];
            [mDic setValue:user.nickname forKey:@"nickName"];
            
            NSData *smallURLImage = [NSData dataWithContentsOfURL:[NSURL URLWithString:user.avatarImageInfo.url]];
            [mDic setValue:smallURLImage forKey:@"smallURLImage"];
            
            [mDic setValue:user.userID forKey:@"userID"];
            
            //把每个元素写入根字典
            [rootDic setValue:mDic forKey:user.userID];
            
            //带出去
            [avatarNickNameArray addObject:mDic];
            //数据持久化
        }
        else{
            
            NSDictionary *mdic = [rootDic objectForKey:user.userID];
            [avatarNickNameArray addObject:mdic];
            
        }
        
    }
    [[NSUserDefaults standardUserDefaults]setValue:rootDic forKey:@"HxChatData"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    
    return  avatarNickNameArray;
}

+(NSMutableArray*)getAvatarNickNameRequest:(NSArray*)userArray
{

    NSMutableDictionary *rootDic = [[NSMutableDictionary alloc]init];
    
    NSMutableArray *avatarNickNameArray = [[NSMutableArray alloc]init];
    //好友列表返回的 不带qj
    for(OWTUser* user in userArray)
    {
        if (true)
        {
            NSMutableDictionary *mDic = [[NSMutableDictionary alloc]init];
            [mDic setValue:user.nickname forKey:@"nickName"];
            
            NSData *smallURLImage = [NSData dataWithContentsOfURL:[NSURL URLWithString:user.avatarImageInfo.url]];
            [mDic setValue:smallURLImage forKey:@"smallURLImage"];
            
            [mDic setValue:user.userID forKey:@"userID"];
            
            //把每个元素写入根字典
            [rootDic setValue:mDic forKey:user.userID];
            
            //带出去
            [avatarNickNameArray addObject:mDic];
        }
       
        
    }
    if (rootDic.count>0) {
        //数据持久化
        [[NSUserDefaults standardUserDefaults]setValue:rootDic forKey:@"HxChatData"];
        [[NSUserDefaults standardUserDefaults]synchronize];
    }
    
    return  avatarNickNameArray;
}

@end