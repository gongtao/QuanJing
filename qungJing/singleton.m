//
//  singleton.m
//  Singleton
//
//  Created by willingseal on 13-11-21.
//  Copyright (c) 2013年 willingseal. All rights reserved.
//

#import "singleton.h"

@implementation singleton

static singleton *singletonData = nil;
+(singleton *)shareData {
    
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        singletonData = [[singleton alloc] init];
    });
  
    return singletonData;
  
}

-(id)init {
    
    if (self = [super init]) {
       

//        self.value = [[UITextField alloc]init];
        
    }
    
    return self;
 
    
}

@end
