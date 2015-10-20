//
//  FusionScrollView.m
//  Weitu
//
//  Created by denghs on 15/9/18.
//  Copyright (c) 2015年 SparkingSoft Co., Ltd. All rights reserved.
//

#import "FusionScrollView.h"
#import "RRConst.h"

@implementation FusionScrollView

@synthesize JCdelegate;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.frame = frame;
        [self setSelf];
    }
    return self;
}
-(void)setSelf{
    self.pagingEnabled = YES;
    self.scrollEnabled = YES;
    self.delegate = self;
    self.showsHorizontalScrollIndicator = NO;
    self.showsVerticalScrollIndicator = NO;
    self.backgroundColor = HWColor(240, 241, 243);
}
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    [self setSelf];
    
    // Drawing code
}

-(void)LoadLoacalImage{
    
}

-(void)upDate{
    NSMutableArray * tempImageArray = [[NSMutableArray alloc]init];
    _cacheArray = [[NSMutableArray alloc]init];
    
    NSInteger order = self.pics.count%4;
    NSInteger  count = _pics.count;
    BOOL queue = YES;
    
    //    [tempImageArray addObject:[self.pics lastObject]];
    //    [tempImageArray addObject:[self.pics objectAtIndex:count-2]];
    //    [tempImageArray addObject:[self.pics objectAtIndex:count-3]];
    //    [tempImageArray addObject:[self.pics objectAtIndex:count-4]];
    
    for (id obj in self.pics) {
        [tempImageArray addObject:obj];
    }
    
    if (order > 0) {
        for (NSInteger i=0; i<4 - order; i++) {
            if (queue) {
                [tempImageArray addObject:[self.pics objectAtIndex:i]];
                
                queue = !queue;
            }else{
                [tempImageArray addObject:[self.pics objectAtIndex:count-i-1]];
                
                queue = !queue;
                
            }
        }
    }
    
    //    [tempImageArray addObject:[self.pics objectAtIndex:0]];
    //    [tempImageArray addObject:[self.pics objectAtIndex:1]];
    //    [tempImageArray addObject:[self.pics objectAtIndex:2]];
    //    [tempImageArray addObject:[self.pics objectAtIndex:3]];
    
    self.pics = Nil;
    self.pics = tempImageArray;
    
    int i = 0;
    for (id obj in self.pics) {
        UIView *pic = [[UIView alloc]initWithFrame:CGRectMake(i*self.frame.size.width/4,0, self.frame.size.width/4, self.frame.size.height)];
        UIImageView * tempImage = [[UIImageView alloc]initWithFrame:CGRectMake(5, 0, pic.frame.size.width-5, pic.frame.size.height)];
        tempImage.contentMode = UIViewContentModeScaleAspectFill;
        [tempImage setClipsToBounds:YES];
        
        UILabel *categroyName = [[UILabel alloc]initWithFrame:CGRectMake(0, tempImage.frame.size.height-17.5, tempImage.frame.size.width, 15)];
        categroyName.textAlignment = NSTextAlignmentCenter;
        categroyName.font =  [UIFont systemFontOfSize:11];
        categroyName.textColor = [UIColor whiteColor];
        categroyName.highlighted = YES;
        
        UIVisualEffectView * effectView = [[UIVisualEffectView alloc]initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
        //设置虚化度
        effectView.alpha = 0.5;
        effectView.frame=CGRectMake(0, tempImage.frame.size.height-20, tempImage.frame.size.width, 20);
        [tempImage addSubview:effectView];
        
        [tempImage addSubview:categroyName];
        
        //设置圆角
        tempImage.layer.cornerRadius = 7;
        tempImage.clipsToBounds = YES;
        
        
        UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(click:)];
        tempImage.tag = i;
        tempImage.userInteractionEnabled = YES;
        [tempImage addGestureRecognizer:tap];
        if ([[obj objectForKey:@"isLoc"]boolValue]) {
            [tempImage setImage:[obj objectForKey:@"pic"]];
        }else{
            if ([obj objectForKey:@"placeholderImage"]) {
                [tempImage setImage:[obj objectForKey:@"placeholderImage"]];
            }
            NSURL *url = [NSURL URLWithString:[obj objectForKey:@"pic"]];
            [tempImage setImageWithURL:url placeholderImage:nil];
            categroyName.text =[obj objectForKey:@"title"];
            
            if(_ifHomePage)
            {
                if ([self.pics lastObject]== obj) {
                    [_progress hide:YES];
                    [_page setHidden:NO];
                    NSLog(@"lastPagehere");
                    [_progress removeFromSuperview];
                }
            }
        }
        [pic addSubview:tempImage];
        [self addSubview:pic];
        [pic setBackgroundColor: HWColor(240, 241, 243)];
        
        pic.tag = i;
        i ++;
    }
    [self setContentSize:CGSizeMake(self.frame.size.width*[self.pics count]/4, self.frame.size.height)];
    [self setContentOffset:CGPointMake(0, 0) animated:NO];
    
    if (scrollTimer) {
        [scrollTimer invalidate];
        scrollTimer = nil;
        
    }
    if ([self.pics count]>3) {
        // scrollTimer = [NSTimer scheduledTimerWithTimeInterval:3.0f target:self selector:@selector(scrollTopic) userInfo:nil repeats:YES];
    }
}

-(void)click:(UIGestureRecognizer*)sender{
    UIImageView *trrigleImageV= (UIImageView*)sender.view;
    [JCdelegate mdidClick:[self.pics objectAtIndex:[sender.view tag]] withImageView:trrigleImageV];
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    NSLog(@"第几次");
    CGFloat Width=self.frame.size.width;
    if (scrollView.contentOffset.x == self.frame.size.width) {
        flag = YES;
        NSLog(@"flag = YES; %f" ,scrollView.contentOffset.x);
    }
    NSLog(@"scrollView.contentOffset.x %f" ,scrollView.contentOffset.x);
    
    if (flag) {
        if (scrollView.contentOffset.x <= 0) {
            //[self setContentOffset:CGPointMake(Width/4*([self.pics count]-2), 0) animated:NO];
        }else if (scrollView.contentOffset.x >= Width/4*([self.pics count]-4-2)) {
            // [self setContentOffset:CGPointMake(self.frame.size.width, 0) animated:NO];
        }
        if (scrollView.contentOffset.x >0 &&  scrollView.contentOffset.x<160) {
            // [self setContentOffset:CGPointMake(Width/4*([self.pics count]-4-4), 0) animated:NO];
            
        }
        
    }
    NSLog(@"scrollView.contentOffset.2x %f" ,scrollView.contentOffset.x);
    
    currentPage = scrollView.contentOffset.x/self.frame.size.width-1;
    [JCdelegate currentPage:currentPage total:[self.pics count]-2];
    scrollTopicFlag = currentPage+2==2?2:currentPage+2;
}
-(void)scrollTopic{
    [self setContentOffset:CGPointMake(self.frame.size.width*scrollTopicFlag, 0) animated:YES];
    
    if (scrollTopicFlag > [self.pics count]) {
        scrollTopicFlag = 1;
    }else {
        scrollTopicFlag++;
    }
}
-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    //scrollTimer = [NSTimer scheduledTimerWithTimeInterval:3.0f target:self selector:@selector(scrollTopic) userInfo:nil repeats:YES];
}
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if (scrollTimer) {
        [scrollTimer invalidate];
        scrollTimer = nil;
    }
    
}
-(void)releaseTimer{
    if (scrollTimer) {
        [scrollTimer invalidate];
        scrollTimer = nil;
        
    }
}

@end
