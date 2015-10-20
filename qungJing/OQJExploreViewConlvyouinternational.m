//
//  OQJCategoryViewCon.m
//  Weitu
//
//  Created by Su on 8/23/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import "OQJExploreViewConlvyouinternational.h"
#import "OQJExploreViewConlvyouinternational1.h"
#import "OQJExploreViewConlvyouinternational2.h"
#import "OQJExploreViewConlvyouinternational3.h"
#import "OQJExploreViewConlvyouinternational4.h"
#import "OQJExploreViewConlvyouinternational5.h"
#import "OQJExploreViewConlvyouinternational6.h"
#import "RRConst.h"
#import "DealErrorPageViewController.h"

#import "OWTCategory.h"
@interface OQJExploreViewConlvyouinternational ()
{
    UIScrollView* _scrollView;
    NSArray* _pageViews1;
    
    NSArray* _pageViewCons1;
    NSMutableArray *dataArr;
    NSMutableArray *dataArr1;
    NSMutableArray *dataArr2;
    NSMutableArray *dataArr3;
    NSMutableArray *dataArr4;
    //NSMutableArray *dataArr5;
    NSMutableArray *dataArr6;
    
    
    
    
    
}
@property (nonatomic, strong) OQJExploreViewConlvyouinternational1* latestViewCon1;
@property (nonatomic, strong) OQJExploreViewConlvyouinternational2* latestViewCon2;
@property (nonatomic, strong) OQJExploreViewConlvyouinternational3* latestViewCon3;
@property (nonatomic, strong) OQJExploreViewConlvyouinternational4* latestViewCon4;
@property (nonatomic, strong) OQJExploreViewConlvyouinternational5* latestViewCon5;
@property (nonatomic, strong) OQJExploreViewConlvyouinternational6* latestViewCon6;

@end

@implementation OQJExploreViewConlvyouinternational

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        
    }
    return self;
}

- (void)viewDidLoad
{
    //    OWTCategoryManagerlvyouinternational *ocm = [[OWTCategoryManagerlvyouinternational alloc ]init];
    //ocm.keyPath =@"categories/app";
    
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    dataArr = [[NSMutableArray alloc]init];
    
    NSURL *url = [NSURL URLWithString:@"http://api.tiankong.com/qjapi/cdn2/feeds/gwly"];
    
    //    NSError *error;
    
    //    NSString *jsonString = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error];
    
    //    NSLog(@"jsonString =%@",jsonString);
    
    //利用三方解析json数据
    DealErrorPageViewController *vc = [[DealErrorPageViewController alloc]init];
    [self addChildViewController:vc];
    NSURLRequest *request =[NSURLRequest requestWithURL:url];
    
    __block NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    
    if (response == nil) {
        [vc.view removeFromSuperview];
        vc.getRefreshAction = ^{
            response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
            if (response != nil) {
                [self doPhrase:response];
            }
        };
        [self.view addSubview:vc.view];
        return;
    }else{
        [self doPhrase:response];
    }
    
    
}

-(void)doPhrase:(NSData*)response
{
    NSDictionary *dic0 =[NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingMutableLeaves error:nil];
    
    NSLog(@"dic0 =%@",dic0);
    
    
    
    NSArray*appList=dic0[@"categories"];
    for (NSDictionary*appdict in appList) {
        
        OWTCategory*model=[[OWTCategory alloc]init];
        
        for (NSString*key in appdict) {
            // NSLog(@"%@",key);
            //kvc---键值编码
            // model.name=@"传奇";
            //[model  setValue:@"传奇" forKey:@"name"];
            [model setValue:appdict[key] forKey:key];
        }
        [dataArr addObject:model];
    }
    //    NSLog(@"_categories =1111111111 %@",dataArr);
    OWTCategory *oc = dataArr[3];
    //    NSLog(@"oc.11111=%@",oc.coverImageInfo);
    
    dataArr1 = [[NSMutableArray alloc]init];
    dataArr2 = [[NSMutableArray alloc]init];
    dataArr3 = [[NSMutableArray alloc]init];
    dataArr4 = [[NSMutableArray alloc]init];
    // dataArr5 = [[NSMutableArray alloc]init];
    dataArr6 = [[NSMutableArray alloc]init];
    for (OWTCategory*oc in dataArr) {
        if ([oc.GroupName  isEqual:@"亚洲"]) {
            [dataArr1 addObject:oc];
        }
        ////
        if ([oc.GroupName  isEqual:@"欧洲"]) {
            [dataArr2 addObject:oc];
        }
        
        if ([oc.GroupName  isEqual:@"大洋洲"]) {
            [dataArr3 addObject:oc];
        }
        
        if ([oc.GroupName  isEqual:@"北美洲"]) {
            [dataArr4 addObject:oc];
        }
        
        //        if ([oc.GroupName  isEqual:@"南美洲"]) {
        //            [dataArr5 addObject:oc];
        //        }
        
        if ([oc.GroupName  isEqual:@"非洲"]) {
            [dataArr6 addObject:oc];
        }
        //        if ([oc.GroupName  isEqual:@"亚洲"]) {
        //            [_categories addObject:oc];
        //        }
        
        
        
    }
    
    
    [self setupContentView];
    
}
-(BOOL)navigationShouldPopOnBackButton
{
//    self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:UITextAttributeTextColor];
//    UIApplication *application = [UIApplication sharedApplication];
//    [application setStatusBarStyle:UIStatusBarStyleLightContent];
//    self.navigationController.navigationBar.barTintColor = GetThemer().homePageColor;
    [self.navigationController popViewControllerAnimated:YES];
    return YES;
}


- (void)setupContentView
{
    //    OWTFeedManager* fm = GetFeedManager();
    _scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, SCREENWIT, self.view.bounds.size.height-40)];
    
    _latestViewCon1 = [[OQJExploreViewConlvyouinternational1 alloc] init];
    // _latestViewCon1.view.userInteractionEnabled = NO;
    
    
    _latestViewCon2 = [[OQJExploreViewConlvyouinternational2 alloc] init];
    // _latestViewCon2.view.userInteractionEnabled = NO;
    
    _latestViewCon3 = [[OQJExploreViewConlvyouinternational3 alloc] init];
    //  _latestViewCon3.view.userInteractionEnabled = NO;
    
    _latestViewCon4 = [[OQJExploreViewConlvyouinternational4 alloc] init];
    // _latestViewCon4.view.userInteractionEnabled = NO;
    
    _latestViewCon5 = [[OQJExploreViewConlvyouinternational5 alloc] init];
    // _latestViewCon5.view.userInteractionEnabled = NO;
    
    _latestViewCon6 = [[OQJExploreViewConlvyouinternational6 alloc] init];
    // _latestViewCon6.view.userInteractionEnabled = NO;
    
    
    
    //    [_scrollView addSubview:_latestViewCon6.view];
    //    [_scrollView addSubview:_latestViewCon5.view];
    //    [_scrollView addSubview:_latestViewCon4.view];
    //    [_scrollView addSubview:_latestViewCon3.view];
    //    [_scrollView addSubview:_latestViewCon2.view];
    //    [_scrollView addSubview:_latestViewCon1.view];
    
    
    
    
    
    
    _pageViews1 =@[_latestViewCon1.view,_latestViewCon2.view,_latestViewCon3.view,_latestViewCon4.view,_latestViewCon6.view];
    _pageViewCons1 = @[ _latestViewCon1,  _latestViewCon2, _latestViewCon3, _latestViewCon4,  _latestViewCon6];
    
    
    for (UIView* view in _pageViews1)
    {
        [_scrollView addSubview:view];
    }
    
    
    for (UIViewController* viewCon in _pageViewCons1)
    {
        [self addChildViewController:viewCon];
    }
    
    
    _scrollView.contentSize = CGSizeMake(_latestViewCon1.view.bounds.size.width, 66+(dataArr1.count+1)/2*184+ 66+(dataArr2.count+1)/2*184+ 66+(dataArr3.count+1)/2*184+ 66+(dataArr4.count+1)/2*184+ 66+(dataArr6.count+1)/2*184+64+44+44-90);
    //       _scrollView.contentSize = CGSizeMake(_latestViewCon1.view.bounds.size.width,
    //
    //                                        (dataArr1.count+1)%2*178+((dataArr1.count+1)%2-1)*6+60
    //
    //
    //
    //                                           +(dataArr2.count+1)%2*178+((dataArr2.count+1)%2-1)*6+60+(dataArr3.count+1)%2*178
    //
    //                                         +((dataArr3.count+1)%2-1)*6+60+(dataArr4.count+1)%2*178+((dataArr4.count+1)%2-1)*6+60
    //
    //                                            +(dataArr5.count+1)%2*178+((dataArr5.count+1)%2-1)*6+60
    //                                           +(dataArr6.count+1)%2*178+((dataArr6.count+1)%2-1)*6+60);
    [self.view addSubview:_scrollView];
    [self layoutPageViews];
    
    
    //latestViewCon1.view.bounds.size.height+latestViewCon2.view.bounds.size.height+latestViewCon3.view.bounds.size.height+latestViewCon4.view.bounds.size.height+latestViewCon5.view.bounds.size.height+latestViewCon6.view.bounds.size.height
    
    
    
}

- (void)viewDidLayoutSubviews
{
    [self layoutPageViews];
}
- (void)layoutPageViews
{
    float b=0;
    _latestViewCon1.view.frame = CGRectMake(0, b, 320,  66+(dataArr1.count+1)/2*184);
    
    _latestViewCon1.view.clipsToBounds = YES;
    b +=  66+(dataArr1.count+1)/2*184;
    
    //   NSLog(@"yyyyyyyyyyyyyy%d",66+(dataArr1.count+1)%2*184);
    _latestViewCon2.view.frame = CGRectMake(0, b, 320,  66+(dataArr2.count+1)/2*184);
    
    _latestViewCon2.view.clipsToBounds = YES;
    b +=  66+(dataArr2.count+1)/2*184;
    
    
    _latestViewCon3.view.frame = CGRectMake(0, b, 320, 66+(dataArr3.count+1)/2*184);
    
    _latestViewCon3.view.clipsToBounds = YES;
    b += 66+(dataArr3.count+1)/2*184;
    
    
    _latestViewCon4.view.frame = CGRectMake(0, b, 320, 66+(dataArr4.count+1)/2*184);
    
    _latestViewCon4.view.clipsToBounds = YES;
    b +=66+(dataArr4.count+1)/2*184;
    
    
    //_latestViewCon5.view.frame = CGRectMake(0, b, 320, 66+(dataArr5.count+1)/2*184);
    
    _latestViewCon5.view.clipsToBounds = YES;
    //b += 66+(dataArr5.count+1)/2*184;
    
    
    _latestViewCon6.view.frame = CGRectMake(0, b, 320, 66+(dataArr6.count+1)/2*184);
    
    _latestViewCon6.view.clipsToBounds = YES;
    //    b += 66+dataArr6.count*184;
    
    
}
//    _latestViewCon1.view.frame = CGRectMake(0, b, 320, (dataArr1.count+1)%2*178+((dataArr1.count+1)%2-1)*6+60);
//
//    _latestViewCon2.view.frame = CGRectMake(0, (dataArr1.count+1)%2*178+((dataArr1.count+1)%2-1)*6+60,
//                                            320, (dataArr1.count+1)%2*178+((dataArr1.count+1)%2-1)*6+60+(dataArr2.count+1)%2*178+((dataArr2.count+1)%2-1)*6+60);
//    _latestViewCon3.view.frame = CGRectMake(0, (dataArr1.count+1)%2*178+((dataArr1.count+1)%2-1)*6+60+(dataArr2.count+1)%2*178+((dataArr2.count+1)%2-1)*6+60
//                                            , 320, (dataArr1.count+1)%2*178+((dataArr1.count+1)%2-1)*6+60+(dataArr2.count+1)%2*178+((dataArr2.count+1)%2-1)*6+60+(dataArr3.count+1)%2*178+((dataArr3.count+1)%2-1)*6+60);
//    _latestViewCon4.view.frame = CGRectMake(0, (dataArr1.count+1)%2*178+((dataArr1.count+1)%2-1)*6+60+(dataArr2.count+1)%2*178+((dataArr2.count+1)%2-1)*6+60+(dataArr3.count+1)%2*178+((dataArr3.count+1)%2-1)*6+60
//                                            , 320, (dataArr1.count+1)%2*178+((dataArr1.count+1)%2-1)*6+60+(dataArr2.count+1)%2*178+((dataArr2.count+1)%2-1)*6+60+(dataArr3.count+1)%2*178+((dataArr3.count+1)%2-1)*6+60+(dataArr4.count+1)%2*178+((dataArr4.count+1)%2-1)*6+60+(dataArr5.count+1)%2*178+((dataArr5.count+1)%2-1)*6+60+(dataArr6.count+1)%2*178+((dataArr6.count+1)%2-1)*6+60);
//    _latestViewCon5.view.frame = CGRectMake(0, (dataArr1.count+1)%2*178+((dataArr1.count+1)%2-1)*6+60+(dataArr2.count+1)%2*178+((dataArr2.count+1)%2-1)*6+60+(dataArr3.count+1)%2*178+((dataArr3.count+1)%2-1)*6+60+(dataArr4.count+1)%2*178+((dataArr4.count+1)%2-1)*6+60+(dataArr5.count+1)%2*178+((dataArr5.count+1)%2-1)*6+60+(dataArr6.count+1)%2*178+((dataArr6.count+1)%2-1)*6+60
//                                            , 320, (dataArr1.count+1)%2*178+((dataArr1.count+1)%2-1)*6+60+(dataArr2.count+1)%2*178+((dataArr2.count+1)%2-1)*6+60+(dataArr3.count+1)%2*178+((dataArr3.count+1)%2-1)*6+60+(dataArr4.count+1)%2*178+((dataArr4.count+1)%2-1)*6+60+(dataArr5.count+1)%2*178+((dataArr5.count+1)%2-1)*6+60);
//    _latestViewCon6.view.frame = CGRectMake(0, (dataArr1.count+1)%2*178+((dataArr1.count+1)%2-1)*6+60+(dataArr2.count+1)%2*178+((dataArr2.count+1)%2-1)*6+60+(dataArr3.count+1)%2*178+((dataArr3.count+1)%2-1)*6+60+(dataArr4.count+1)%2*178+((dataArr4.count+1)%2-1)*6+60+(dataArr5.count+1)%2*178+((dataArr5.count+1)%2-1)*6+60
//                                            , 320, (dataArr1.count+1)%2*178+((dataArr1.count+1)%2-1)*6+60+(dataArr2.count+1)%2*178+((dataArr2.count+1)%2-1)*6+60+(dataArr3.count+1)%2*178+((dataArr3.count+1)%2-1)*6+60+(dataArr4.count+1)%2*178+((dataArr4.count+1)%2-1)*6+60+(dataArr5.count+1)%2*178+((dataArr5.count+1)%2-1)*6+60+(dataArr6.count+1)%2*178+((dataArr6.count+1)%2-1)*6+60);




@end
