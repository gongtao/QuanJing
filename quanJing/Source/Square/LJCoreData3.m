//
//  LJCoreData3.m
//  Weitu
//
//  Created by qj-app on 15/8/5.
//  Copyright (c) 2015年 SparkingSoft Co., Ltd. All rights reserved.
//

#import "LJCoreData3.h"
#import "LJCaptionSimilar.h"
@implementation LJCoreData3
{
    NSManagedObjectContext *_managedObjectContext;
    NSMutableArray *_resource;
}
+(id)shareIntance
{
    static id s;
    if (s==nil) {
        s=[[self alloc]init];
    }
    
    return s;
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
    NSString *path=[[NSBundle mainBundle]pathForResource:@"LJCoreData3" ofType:@"momd"];
    NSManagedObjectModel *model=[[NSManagedObjectModel alloc]initWithContentsOfURL:[NSURL fileURLWithPath:path]];
    NSPersistentStoreCoordinator *persistentStoreCoor=[[NSPersistentStoreCoordinator alloc]initWithManagedObjectModel:model];
    NSString *path1=[NSHomeDirectory()stringByAppendingString:@"/Documents/LJCaptionSimilar.sqlite"];
//    NSLog(@"%@",path1);
    NSError *error;
    NSPersistentStore *persistentStore=[persistentStoreCoor addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:[NSURL fileURLWithPath:path1] options:nil error:&error];
    if (!persistentStore) {
        NSLog(@"dddd%@",error);
        return;
    }
    _managedObjectContext=[[NSManagedObjectContext alloc]init];
    _managedObjectContext.persistentStoreCoordinator=persistentStoreCoor;
}
-(void)insertCaptionSimilar:(NSString *)word withDetail:(NSString *)Detail
{
LJCaptionSimilar *similarModel=[NSEntityDescription insertNewObjectForEntityForName:@"LJCaptionSimilar" inManagedObjectContext:_managedObjectContext];
    similarModel.word=word;
    NSString *detailStr=[NSString stringWithFormat:@"、%@、%@、",Detail,word];
    if (detailStr==nil) {
        return;
    }
    similarModel.detailed=detailStr;
    NSError *saveError;
    @try {
        if ([_managedObjectContext save:&saveError]) {
            NSLog(@"%@",saveError);
            
        }
    }
    @catch (NSException *exception) {
        NSLog(@"coredata 异常：%@",exception);
    }
    [_resource addObject:similarModel];

}
-(NSArray *)checkCaptionSimilar:(NSString *)word
{
    NSFetchRequest *fectchRequest=[NSFetchRequest fetchRequestWithEntityName:@"LJCaptionSimilar"];
    NSString *str=[NSString stringWithFormat:@"、%@、",word];
    NSPredicate *predicate=[NSPredicate predicateWithFormat:@"detailed CONTAINS %@",str];
    [fectchRequest setPredicate:predicate];
    NSError *saveError;
    NSArray *arr=[_managedObjectContext executeFetchRequest:fectchRequest error:&saveError];
    NSMutableArray *captions=[[NSMutableArray alloc]init];
    if (arr.count>0) {
        LJCaptionSimilar *model=arr[0];
        NSMutableString *words=[[NSMutableString alloc]initWithString:model.detailed];
        [captions addObjectsFromArray:[words componentsSeparatedByString:@"、"]];
        [captions removeObjectAtIndex:0];
        [captions removeLastObject];
    }else {
        [captions addObject:word];
    }
   
    return captions;
}
-(void)deleteAll
{
    NSFetchRequest *fectchRequest=[NSFetchRequest fetchRequestWithEntityName:@"LJCaptionSimilar"];
    NSError *saveError;
    NSArray *arr=[_managedObjectContext executeFetchRequest:fectchRequest error:&saveError];
    for (LJCaptionSimilar *model in arr) {
        [_managedObjectContext deleteObject:model];
    }
}

@end
