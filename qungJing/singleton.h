//
//  singleton.h
//  Singleton
//
//  Created by willingseal on 13-11-21.
//  Copyright (c) 2013年 willingseal. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface singleton : NSObject



@property (assign, nonatomic) NSInteger value;

//+(id)shareData:
+(singleton *)shareData;


@end
