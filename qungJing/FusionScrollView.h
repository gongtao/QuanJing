//
//  FusionScrollView.h
//  Weitu
//
//  Created by denghs on 15/9/18.
//  Copyright (c) 2015年 SparkingSoft Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
@protocol FusionDelegate<NSObject>
-(void)mdidClick:(id)data;
-(void)mdidClick:(id)data withImageView:(UIImageView*)imageV;

-(void)currentPage:(int)page total:(NSUInteger)total;
@end
@interface FusionScrollView : UIScrollView<UIScrollViewDelegate>{
//    UIButton * pic;
    bool flag;
    int scrollTopicFlag;
    NSTimer * scrollTimer;
    int currentPage;
    CGSize imageSize;
    UIImage *image;
}
@property(nonatomic,strong)NSArray * pics;
@property(nonatomic, assign) BOOL ifHomePage;
@property(nonatomic, strong)NSMutableArray *cacheArray;
@property(nonatomic,retain)id<FusionDelegate> JCdelegate;
@property(nonatomic, strong)MBProgressHUD * progress;
@property(nonatomic, strong)UIPageControl *page;
-(void)releaseTimer;
-(void)upDate;
-(void)upDate2;
@end

