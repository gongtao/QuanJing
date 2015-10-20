//
//  LJPickerViewController.h
//  Weitu
//
//  Created by qj-app on 15/6/4.
//  Copyright (c) 2015年 SparkingSoft Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LJPickerViewController : UIViewController


@property(nonatomic,strong)UIImage *backgroundImage;
@property(nonatomic,strong)NSArray *dataArray;
@property (nonatomic, strong) void (^doneFunc)();
@property(nonatomic,copy)NSString *backString1;
@property(nonatomic,copy)NSString *backString2;
@property(nonatomic,assign)BOOL isArea;
@end
