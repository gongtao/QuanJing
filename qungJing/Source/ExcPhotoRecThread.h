//
//  ExcPhotoRecThread.h
//  Weitu
//
//  Created by denghs on 15/7/17.
//  Copyright (c) 2015年 SparkingSoft Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ExcPhotoRecThread : NSObject

-(void)executePicThread:(NSArray*)array request:(NSMutableURLRequest*)request;
@end
