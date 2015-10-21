//
//  LJCoreData.m
//  Weitu
//
//  Created by qj-app on 15/6/10.
//  Copyright (c) 2015年 SparkingSoft Co., Ltd. All rights reserved.
//

#import "LJCoreData.h"
#import "LJCaptionModel.h"
#import "LJCoreData3.h"
@implementation LJCoreData
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
    NSString *path=[[NSBundle mainBundle]pathForResource:@"LJCaption" ofType:@"momd"];
    NSManagedObjectModel *model=[[NSManagedObjectModel alloc]initWithContentsOfURL:[NSURL fileURLWithPath:path]];
    NSPersistentStoreCoordinator *persistentStoreCoor=[[NSPersistentStoreCoordinator alloc]initWithManagedObjectModel:model];
    NSString *path1=[NSHomeDirectory()stringByAppendingString:@"/Documents/LJCaption.sqlite"];
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
+(id)shareIntance
{
    static id s;
    if (s==nil) {
        s=[[self alloc]init];
    }
    
    return s;
}
-(void)insert:(NSString *)imageUrl withCaption:(NSString *)caption with:(NSString *)isSelfInsert
{
    LJCaptionModel *model=[NSEntityDescription  insertNewObjectForEntityForName:@"LJCaptionModel" inManagedObjectContext:_managedObjectContext];
    model.imageUrl=imageUrl;
    model.caption=caption;
    model.isSelfInsert=isSelfInsert;
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
-(LJCaptionModel *)check:(NSString *)imageUrl
{
    if (!imageUrl) {
        return nil;
    }
    NSFetchRequest *fetchRequest=[NSFetchRequest fetchRequestWithEntityName:@"LJCaptionModel"];
    NSPredicate *predicate=[NSPredicate predicateWithFormat:@"imageUrl like %@",imageUrl];
    [fetchRequest setPredicate:predicate];
    NSArray *result=[_managedObjectContext executeFetchRequest:fetchRequest error:nil];
    NSLog(@"%lu",(unsigned long)result.count);
    if (result.count==0) {
        return nil;
    }else{
        if (![_resource isKindOfClass:[NSMutableArray class]]||_resource.count==0) {
            return nil;
        }
    [_resource removeAllObjects];
    [_resource addObjectsFromArray:result];
        if (result.count>1) {
            for (NSInteger i=1; i<result.count; i++) {
                LJCaptionModel *model1=result[i];
                [_managedObjectContext deleteObject:model1];
            }
        }
    LJCaptionModel *model=result[0];
        return model;}
}
-(NSArray *)checkAll
{
    NSFetchRequest *fetchRequest=[NSFetchRequest fetchRequestWithEntityName:@"LJCaptionModel"];
    NSArray *result=[_managedObjectContext executeFetchRequest:fetchRequest error:nil];
    
    return result;
}
-(void)checkAllAndUpdate
{
    NSFetchRequest *fetchRequest=[NSFetchRequest fetchRequestWithEntityName:@"LJCaptionModel"];
    NSArray *result=[_managedObjectContext executeFetchRequest:fetchRequest error:nil];
    [_resource addObjectsFromArray:result];
    if (_resource.count>0) {
        for (LJCaptionModel *model in _resource) {
            model.caption=[NSString stringWithFormat:@" %@ ",model.caption];
        }
        [_managedObjectContext save:nil];
    }
}
-(void)deleteImage:(NSString *)imageUrl
{
    [self check:imageUrl];
    if (_resource.count>0) {
        for (LJCaptionModel *model in _resource) {
            [_managedObjectContext deleteObject:model];
        }
    }

}
-(void)update:(NSString *)str  with:(NSString*)caption
{
    [self check:str];
    
    if (_resource.count!=0) {
        for (LJCaptionModel *model in _resource) {
            model.caption=caption;
            [_managedObjectContext save:nil];
        }
    }
    }
-(NSArray *)checkSomeImageUrl:(NSArray *)someCaptions
{
        NSFetchRequest *fetchRequest=[NSFetchRequest fetchRequestWithEntityName:@"LJCaptionModel"];
    NSMutableArray *precap=[[NSMutableArray alloc]init];
    
    for (NSString *str in someCaptions) {
        
        if (str.length!=0) {
         NSMutableArray *preArr=[[NSMutableArray alloc]init];
       NSArray *similarArr=[[LJCoreData3 shareIntance]checkCaptionSimilar:str];
        for (NSString *str1 in similarArr) {
            NSString *str2=[NSString stringWithFormat:@" %@ ",str1];
            [preArr addObject:str2];
        }
        [precap addObject:preArr];
        }
    }
   NSString *sqlite=[self getTheSQLITE:precap];
    NSPredicate *predicate=[NSPredicate predicateWithFormat:sqlite];
//    switch (preArr.count) {
//        case 1:
//           predicate=[NSPredicate predicateWithFormat:@"caption CONTAINS %@",preArr[0]];
//            break;
//        case 2:
//            predicate=[NSPredicate predicateWithFormat:@"caption CONTAINS  %@  AND caption CONTAINS  %@ ",preArr[0],preArr[1]];
//            break;
//        case 3:
//            predicate=[NSPredicate predicateWithFormat:@"(caption CONTAINS  %@  OR caption CONTAINS  %@ ) AND caption CONTAINS  %@ ",preArr[0],preArr[1],preArr[2]];
//            break;
//        case 4:
//            predicate=[NSPredicate predicateWithFormat:@"caption CONTAINS  %@  AND caption CONTAINS  %@  AND caption CONTAINS  %@  AND caption CONTAINS  %@ ",preArr[0],preArr[1],preArr[2],preArr[3]];
//            break;
//        case 5:
//            predicate=[NSPredicate predicateWithFormat:@"caption CONTAINS  %@  AND caption CONTAINS  %@  AND caption CONTAINS  %@  AND caption CONTAINS  %@  AND caption CONTAINS  %@ ",preArr[0],preArr[1],preArr[2],preArr[3],preArr[4]];
//            break;
//        case 6:
//            predicate=[NSPredicate predicateWithFormat:@"caption CONTAINS  %@  AND caption CONTAINS  %@  AND caption CONTAINS  %@  AND caption CONTAINS  %@  AND caption CONTAINS  %@  AND caption CONTAINS  %@ ",preArr[0],preArr[1],preArr[2],preArr[3],preArr[4],preArr[5]];
//            break;
//        default:
//            break;
//    }
//    NSLog(@"%@",predicate);
    [fetchRequest setPredicate:predicate];
    return [_managedObjectContext executeFetchRequest:fetchRequest error:nil];
}
-(NSString *)getTheSQLITE:(NSArray *)captions
{
    NSMutableArray *sqStr1=[[NSMutableArray alloc]init];
    NSMutableArray *sqStr2=[[NSMutableArray alloc]init];
    for (NSArray *arr in captions) {
        [sqStr1 removeAllObjects];
        for (NSString *str in arr) {
            NSString *str1=[NSString stringWithFormat:@"caption CONTAINS '%@'",str];
            [sqStr1 addObject:str1];
        }
        NSString *str2=[sqStr1 componentsJoinedByString:@" OR "];
        [sqStr2 addObject:str2];
    }
    if (sqStr2.count>1) {
        NSMutableArray *sqStr3=[[NSMutableArray alloc]init];
        for (NSString *str3 in sqStr2) {
            NSString *str4=[NSString stringWithFormat:@"(%@)",str3];
            [sqStr3 addObject:str4];
        }
        [sqStr2 removeAllObjects];
        [sqStr2 addObjectsFromArray:sqStr3];
    }
    NSString *str5=[sqStr2 componentsJoinedByString:@" AND "];
    return str5;
}
@end
