//
//  LJCoreData1.m
//  Weitu
//
//  Created by qj-app on 15/6/25.
//  Copyright (c) 2015年 SparkingSoft Co., Ltd. All rights reserved.
//

#import "LJCoreData1.h"
@implementation LJCoreData1

{
    NSManagedObjectContext *_managedObjectContext;
    NSMutableArray *_resource;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        [self prepare];
        _resource=[[NSMutableArray alloc]init];
    }
    return self;
}
-(void)prepare
{
    NSString *path=[[NSBundle mainBundle]pathForResource:@"LJHuancun" ofType:@"momd"];
    NSManagedObjectModel *model=[[NSManagedObjectModel alloc]initWithContentsOfURL:[NSURL fileURLWithPath:path]];
    NSPersistentStoreCoordinator *persistentStoreCoor=[[NSPersistentStoreCoordinator alloc]initWithManagedObjectModel:model];
    NSString *path1=[NSHomeDirectory()stringByAppendingString:@"/Documents/LJHuancun.sqlite"];
    NSLog(@"%@",path1);
    NSError *error;
    NSPersistentStore *persistentStore=[persistentStoreCoor addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:[NSURL fileURLWithPath:path1] options:nil error:&error];
    if (!persistentStore) {
        NSLog(@"dddd%@",error);
        return;
    }
    _managedObjectContext=[[NSManagedObjectContext alloc]init];
    _managedObjectContext.persistentStoreCoordinator=persistentStoreCoor;
    
}
+(id)shareInstance
{
    static id s;
    if (s==nil) {
        s=[[self alloc]init];
    }
    
    return s;
}
-(void)insert:(NSData *)response withType:(NSString *)type withUserId:(NSString *)userid
{

    LJHuancunModel *model=[NSEntityDescription  insertNewObjectForEntityForName:@"LJHuancunModel" inManagedObjectContext:_managedObjectContext];
    model.response=response;
    model.type=type;
    model.userid=userid;
    NSError *saveError;
    if ([_managedObjectContext save:&saveError]) {
        NSLog(@"%@",saveError);
    }
    [_resource addObject:model];
}
-(LJHuancunModel*)check:(NSString *)type withUserid:(NSString *)userid
{
    NSFetchRequest *fetchRequest=[NSFetchRequest fetchRequestWithEntityName:@"LJHuancunModel"];
    NSPredicate *predicate=[NSPredicate predicateWithFormat:@"type like %@",type];
    [fetchRequest setPredicate:predicate];
    NSArray *result=[_managedObjectContext executeFetchRequest:fetchRequest error:nil];
    if (result.count==0) {
        return nil;
    }else{
        [_resource removeAllObjects];
        [_resource addObjectsFromArray:result];
        LJHuancunModel *model=result[0];
        return model;}
}
-(void)update:(NSString *)type with:(NSData *)response withUserid:(NSString *)userid
{
    [self check:type withUserid:userid];
    
    if (_resource.count!=0) {
        for (LJHuancunModel *model in _resource) {
            model.response=response;
            [_managedObjectContext save:nil];
        }
    }
}
-(void)deleteAll
{
    NSFetchRequest *fetchRequest=[NSFetchRequest fetchRequestWithEntityName:@"LJHuancunModel"];
    NSArray *result=[_managedObjectContext executeFetchRequest:fetchRequest error:nil];
    for (LJHuancunModel *model in result) {
    [_managedObjectContext deleteObject:model];   
    }
}
@end
