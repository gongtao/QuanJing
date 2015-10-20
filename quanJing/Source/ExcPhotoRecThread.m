//
//  ExcPhotoRecThread.m
//  Weitu
//
//  Created by denghs on 15/7/17.
//  Copyright (c) 2015年 SparkingSoft Co., Ltd. All rights reserved.
//

#import "ExcPhotoRecThread.h"
#import "LJCoreData.h"
#import "LJCaptionModel.h"
#import "PostFormData.h"

@interface ExcPhotoRecThread ()
{
    NSMutableURLRequest *_request;
    NSArray *_array;
    NSString *_caption;
}
@end

@implementation ExcPhotoRecThread
-(void)executePicThread:(NSArray*)array request:(NSMutableURLRequest*)request
{
    _array = array;
    _request = request;
    if (_array.count>0) {
        for (NSInteger i=_array.count-1;i>=0;i--) {
            NSDictionary *dict=_array[i];
            LJCaptionModel *model=[[LJCoreData shareIntance]check:dict[@"imageurl"]];
            //_isSI=model.isSelfInsert;
            //_caption=model.caption;
            if (model==nil||[model.isSelfInsert isEqualToString:@"yes"]) {
                //                [_lock lock];
                [self getResouceWithImage:dict[@"image"] withNumber:i];
                //                [_lock unlock];
            }
        }
    }

}

-(void)getResouceWithImage:(UIImage *)image withNumber:(NSInteger)number
{
    NSData *data=UIImageJPEGRepresentation(image, 1.0f);
    NSString *imageurl=[data base64Encoding];
    
    [self ASIHttpRequestWithImageurl:imageurl withNumber:number];
    data = nil;
    imageurl = nil;
}
-(void)ASIHttpRequestWithImageurl:(NSString *)imageurl withNumber:(NSInteger)number
{
    NSError *error = nil;
    NSData *mData = [PostFormData bulidPostFormData:imageurl forKey:@"base64"];
    _request.HTTPBody = mData;
    NSURLResponse *reponse = [[NSURLResponse alloc]init];
    NSData *received = nil;
    received = [NSURLConnection sendSynchronousRequest:_request returningResponse:&reponse error:&error];
    if ( received != nil) {
        [self requestFinisheda1:received number:number];
        
    }
    imageurl = nil;
    mData = nil;
    
}

-(void)requestFinisheda1:(NSData *)responseData number:(NSInteger)num
{
    UIApplication *application = [UIApplication sharedApplication];
    application.networkActivityIndicatorVisible = YES;
    
    //    NSThread *thread = [NSThread currentThread];
    //    if (thread !=nil) {
    //        NSLog(@"不是主线程下  %@",thread);
    //    }
    //    if (thread.isMainThread) {
    //        NSLog(@"主线程下");
    //    }
    // sleep(10);
    NSMutableString *caption=[[NSMutableString alloc]init];
    NSDictionary *dict=[NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:nil];
    //NSString *str=[[NSString alloc]initWithData:_data encoding:NSUTF8StringEncoding];
    NSArray *arr=dict[@"scene_understanding"][@"matches"];
    NSInteger arrayCont = arr.count;
    for (NSDictionary *dict1 in arr) {
        if (dict1==arr[arrayCont-1]) {
            [caption appendString:[NSString stringWithFormat:@"%@",dict1[@"tag"]]];
        }
        else{
            [caption appendString:[NSString stringWithFormat:@"%@ ",dict1[@"tag"]]];}
    }
    NSDictionary *dict2=_array[num];
    NSString *imageUrl=dict2[@"imageurl"];
    NSLog(@"拿到的 caption：%@",caption);
    LJCaptionModel *model=[[LJCoreData shareIntance]check:dict[@"imageurl"]];
    if ([model.isSelfInsert isEqualToString:@"yes"]) {
        [caption appendString:[NSString stringWithFormat:@" %@",_caption]];
        [[LJCoreData shareIntance]update:imageUrl with:caption];
    }else {
        [[LJCoreData shareIntance]insert:imageUrl withCaption:caption with:@""];
    }
    
}

@end
