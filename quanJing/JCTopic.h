//
//  JCTopic.h
//  PSCollectionViewDemo
//
//  Created by jc on 14-1-7.
//
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
@protocol JCTopicDelegate<NSObject>
-(void)didClick:(id)data;
-(void)currentPage:(int)page total:(NSUInteger)total;
@end
@interface JCTopic : UIScrollView<UIScrollViewDelegate>{
    UIButton * pic;
    bool flag;
    int scrollTopicFlag;
    NSTimer * scrollTimer;
    int currentPage;
    CGSize imageSize;
    UIImage *image;
}
@property(nonatomic,strong)NSArray * pics;
@property(nonatomic,strong)NSArray * picsDic;
@property(nonatomic, assign) BOOL ifHomePage;
@property(nonatomic, strong)NSMutableArray *cacheArray;
@property(nonatomic,retain)id<JCTopicDelegate> JCdelegate;
@property(nonatomic, strong)MBProgressHUD * progress;
@property(nonatomic, strong)UIPageControl *page;
-(void)releaseTimer;
-(void)upDate;
-(void)upDate2;
@end
