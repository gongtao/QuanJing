//
//  LJCoreData2.m
//  Weitu
//
//  Created by qj-app on 15/7/7.
//  Copyright (c) 2015年 SparkingSoft Co., Ltd. All rights reserved.
//

#import "LJCoreData2.h"

@implementation LJCoreData2
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
    NSString *path=[[NSBundle mainBundle]pathForResource:@"LJCaptionss" ofType:@"momd"];
    NSManagedObjectModel *model=[[NSManagedObjectModel alloc]initWithContentsOfURL:[NSURL fileURLWithPath:path]];
    NSPersistentStoreCoordinator *persistentStoreCoor=[[NSPersistentStoreCoordinator alloc]initWithManagedObjectModel:model];
    NSString *path1=[NSHomeDirectory()stringByAppendingString:@"/Documents/LJCaptions.sqlite"];
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
+(id)shareIntance
{
    static id s;
    if (s==nil) {
        s=[[self alloc]init];
    }
    
    return s;
}
-(void)insert2:(NSString *)imageUrl withCaption:(NSString *)caption with:(NSString *)number withData:(NSData *)imageData
{
    LJCaptions *model=[NSEntityDescription insertNewObjectForEntityForName:@"LJCaptions" inManagedObjectContext:_managedObjectContext];
    model.imageUrl=imageUrl;
    model.caption=caption;
    model.number=number;
    model.imageData=imageData;
    NSError *saveError;
    @try {
        if ([_managedObjectContext save:&saveError]) {
            NSLog(@"%@",saveError);

        }
    }
    @catch (NSException *exception) {
        NSLog(@"coredata 异常：%@",exception);
    }
  
    [_resource addObject:model];
}
-(BOOL)check2:(NSString *)caption
{
    NSFetchRequest *fectchRequest=[NSFetchRequest fetchRequestWithEntityName:@"LJCaptions"];
    NSPredicate *predicate=[NSPredicate predicateWithFormat:@"caption like %@",caption];
    [fectchRequest setPredicate:predicate];
    NSError *saveError;
    NSArray *arr=[_managedObjectContext executeFetchRequest:fectchRequest error:&saveError];
    [_resource removeAllObjects];
    [_resource addObjectsFromArray:arr];
    if (arr.count>0) {
        return YES;
    }else
    {
        return NO;
    }
}
-(void)deleteImage2:(NSString *)caption
{
    [self check2:caption];
    for (LJCaptions *caption1 in _resource) {
        [_managedObjectContext deleteObject:caption1];
    }

    
}
-(void)update2:(NSData *)imageData  with:(NSString*)caption
{
    if (imageData==nil) {
        return;
    }
    [self check2:caption];
    for (LJCaptions *caption1 in _resource) {
        NSString *num=[NSString stringWithFormat:@"%d",caption1.number.intValue+1];
        caption1.number=num;
        caption1.imageData=imageData;
    }
    [_managedObjectContext save:nil];
}
-(void)updateNum:(NSString *)number with:(NSString *)caption
{
    [self check2:caption];
    for (LJCaptions *caption1 in _resource) {
        caption1.number=number;
        [_managedObjectContext save:nil];
    }
}
-(NSArray *)checkAll2
{
    NSFetchRequest *fectchRequest=[NSFetchRequest fetchRequestWithEntityName:@"LJCaptions"];
    NSError *saveError;
    NSArray *arr=[_managedObjectContext executeFetchRequest:fectchRequest error:&saveError];
    return arr;
}
@end
