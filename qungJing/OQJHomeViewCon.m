//
//  OQJHomeViewCon.m
//  Weitu
//
//  Created by Su on 8/23/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import "OQJHomeViewCon.h"
#import "OWTSearchManager.h"
#import "OWTSearchResultsViewCon.h"
#import "OWTSearchViewCon.h"
#import "SVProgressHUD+WTError.h"
#import <FontAwesomeKit/FontAwesomeKit.h>
#import "OWTImageView.h"
#import "OWTCategory.h"
#import "OWTFeedViewCon.h"
#import "OWTFeedManager.h"
#import "UIViewController+WTExt.h"
#import "exploreViewController.h"
#import "WLJWebViewController.h"
#import "OWTexploreModel.h"
#import <SDWebImage/SDWebImageManager.h>
#import "OQJSelectedViewCon1.h"
#import "OWTAssetViewCon.h"
#import "WTCommon.h"
#import "OWTAssetManager.h"
#import <UIColor-HexString/UIColor+HexString.h>
#import "OWTAssetData.h"
#import "OWTAsset.h"
#import "MJRefresh.h"
#import "OWTUser.h"
#import "OWTUserViewCon.h"
#import "OWTUserManager.h"
#import "OWTFeedViewCon.h"
#import "OWTFeed.h"
#import "OWTFeedInfo.h"
#import "LJCoreData1.h"
#import "LJHuancunModel.h"
@interface OQJHomeViewCon ()<NSURLConnectionDataDelegate>
{
    UIScrollView *scrollV;

    
    UIButton* _searchButton;
//  MPGTextField* _keywordTextField;
    UITextField* _keywordTextField;
    NSArray *seArr;
    
    NSArray *titleArr;
    NSArray *dataArr1;
    NSArray *dataArr2;
    
    NSMutableArray *dataArr;
    NSMutableArray *coverUrlArr;
    NSMutableArray *SubtitleArr;
    NSMutableArray *imagearr1 ;
    //这地方时title
    NSMutableArray *tArr;
    NSMutableArray *SummaryArr;
    NSMutableArray *UrlArr;
    NSMutableArray *  HcoverUrlArr;
    
    NSString *assetStr;
    NSString *assetStr1;
    NSString *assetStr2;
    
    NSString *assetStr3;
    NSString *assetStr4;
    
    NSDictionary *dic0;
    NSMutableData *response2;
    NSMutableArray *keyLabels;
    NSMutableArray *keywords;
    NSMutableArray *titleKeyArr;
    NSURLConnection *_connection;
    NSURLConnection *_connection1;
    NSMutableData *response1;
    LJCoreData1 *_coreData1;
    OWTUser *_user;
//  DropDownList *Dlist;
    BOOL isfirst;
    
}
@property (nonatomic, assign) NSInteger pageCount;
@property (nonatomic, strong) XHRefreshControl* refreshControl;
@end

@implementation OQJHomeViewCon

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
        //
        self.navigationController.navigationBarHidden =YES;
        
        response2=[[NSMutableData alloc]init];
        response1=[[NSMutableData alloc]init];
    }
    return self;
}
-(void)loadViewData
{
    
    NSURL *url = [NSURL URLWithString:@"http://api.tiankong.com/qjapi/cdn1/articleHome"];
    
    
    //利用三方解析json数据
    
    NSURLRequest *request =[NSURLRequest requestWithURL:url];
    
    _connection=[[NSURLConnection alloc]initWithRequest:request delegate:self];
    //NSJSONSerialization解析
    
    
    
}
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    if (_connection==connection) {
        [response2 setLength:0];
    }else if(_connection1==connection){
        [response1 setLength:0];
    }

}
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if (_connection==connection) {
           [response2 appendData:data];
    }else if(_connection1==connection){
        [response1 appendData:data];
    }

}
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [scrollV headerEndRefreshing];
    [SVProgressHUD showErrorWithStatus:@"网络连接错误"];
}
-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if (_connection ==connection) {
        [scrollV headerEndRefreshing];
        dic0 =[NSJSONSerialization JSONObjectWithData:response2 options:NSJSONReadingMutableLeaves error:nil];
        
        //NSLog(@"dic0 =%@",dic0);
        
        NSArray*appList=dic0[@"article"];
        [dataArr removeAllObjects];
        for (NSDictionary*appdict in appList) {
            OWTexploreModel*model=[[OWTexploreModel alloc]init];
            for (NSString*key in appdict) {
                //
                if ([appdict[key] isKindOfClass:[NSNull class]]) {
                    // do something
                    [model setValue:@"" forKey:key];
                }else{
                    // do something
                    [model setValue:appdict[key] forKey:key];
                }
            }
            
            [dataArr addObject:model];
        }
        
        LJHuancunModel *model=[_coreData1 check:@"response" withUserid:_user.userID];
        if (model) {
            [_coreData1 update:@"response" with:response2 withUserid:_user.userID];
        }else {
            [_coreData1 insert:response2 withType:@"response" withUserId:_user.userID];}
        [self refresh];
        [SVProgressHUD dismiss];
    }else if(_connection1==connection){
    
        if (response1!=nil) {
            
            //NSJSONSerialization解析
            NSDictionary*appList = [[NSDictionary alloc]init];
            NSDictionary *dic1 =[NSJSONSerialization JSONObjectWithData:response1 options:NSJSONReadingMutableLeaves error:nil];
            
            //
            appList=dic1[@"daily"];
            
            
            assetStr = appList[@"originalid"];
            assetStr1 = appList[@"caption"];
            assetStr2 = appList[@"imageurl"];
            assetStr3 = appList[@"_class"];
            assetStr4 = appList[@"originalid"];
            //每日一图
            UIImageView *dailV = [[UIImageView alloc]initWithFrame:CGRectMake(8, 730-10+60-36+0, 304, 214)];
            [ dailV setImageWithURL:[NSURL URLWithString:appList[@"imageurl"]]placeholderImage:nil];
            NSString *str=appList[@"imageurl"];
            NSString *str1=appList[@"caption"];
            [[NSUserDefaults standardUserDefaults]setObject:str forKey:@"everyImage"];
            [[NSUserDefaults standardUserDefaults]setObject:str1 forKey:@"everyLabel"];
            //
            UILabel *label3 = [[UILabel alloc]initWithFrame:CGRectMake(20, 730+202-10+4+4+60-36+0, 280, 36)];
            label3.font = [UIFont systemFontOfSize:14];
            label3.backgroundColor =[UIColor whiteColor];
            label3.text =appList[@"caption"];
            label3.textAlignment=0;
            [scrollV addSubview:label3];
            
            [scrollV addSubview:dailV];
        }

    }
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];
    dataArr = [[NSMutableArray alloc]init];
    _pageCount=1;
    keywords =[[NSMutableArray alloc]init];
    titleKeyArr = [[NSMutableArray alloc]init];
    [self loadFirst];
    [self loadViewData];
}

-(void)loadFirst
{
    isfirst=YES;
    _user=GetUserManager().currentUser;
    _coreData1=[LJCoreData1 shareInstance];
    
   LJHuancunModel *model1=[_coreData1 check:@"response" withUserid:_user.userID];
    if (model1) {
        [response2 appendData:model1.response];
        dic0 =[NSJSONSerialization JSONObjectWithData:response2 options:NSJSONReadingMutableLeaves error:nil];
        
        //NSLog(@"dic0 =%@",dic0);
        
        NSArray*appList=dic0[@"article"];
        for (NSDictionary*appdict in appList) {
            OWTexploreModel*model=[[OWTexploreModel alloc]init];
            for (NSString*key in appdict) {
                //
                if ([appdict[key] isKindOfClass:[NSNull class]]) {
                    // do something
                    [model setValue:@"" forKey:key];
                }else{
                    // do something
                    [model setValue:appdict[key] forKey:key];
                }
            }
            
            [dataArr addObject:model];
        }
        [self refresh];
        
        
    }else {
        [SVProgressHUD show];
    }
    isfirst=NO;
}
#pragma -mark 假的数据刷新  不知产品为何做次安排
- (void)beginPullDownR
{
//    [self performSelector:@selector(endr) withObject:nil afterDelay:1];
    [self loadViewData];
}
#pragma mark - refresh刷新
- (void)refresh
{
    for(UIView *subview in [self.view subviews])
    {
       
            [subview removeFromSuperview];
            NSLog(@"===================");
    }
    
    UIView *view =[[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 20)];
    view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:view];
    if (isfirst==YES) {
    scrollV = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 20, 320, self.view.bounds.size.height-50)];
    }else{
        scrollV = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 20, 320, self.view.bounds.size.height)];}
    scrollV.contentSize =CGSizeMake(320, 1197+20+30+10+10+60-36-100);
    scrollV.delegate =self;
    [self.view addSubview:scrollV];
    [scrollV addHeaderWithTarget:self action:@selector(beginPullDownR)];
    scrollV.headerPullToRefreshText = @"";
    scrollV.headerReleaseToRefreshText = @"";
    scrollV.headerRefreshingText = @"";
    keywords =[[NSMutableArray alloc]init];
    titleKeyArr = [[NSMutableArray alloc]init];
    [self reloadData1];
    
    _pageCount=1;
    
    if (response2==nil) {
        [SVProgressHUD showGeneralError];
    }
    if (response2!=nil) {
        if (![dic0 isKindOfClass:[NSNull class]]) {
            
            keyLabels = [[NSMutableArray alloc]init];
            coverUrlArr = [[NSMutableArray alloc]init];
            SubtitleArr = [[NSMutableArray alloc]init];
            
            //这地方时title
            tArr =[[NSMutableArray alloc]init];
            SummaryArr =[[NSMutableArray alloc]init];
            UrlArr =[[NSMutableArray alloc]init];
            
            HcoverUrlArr =[[NSMutableArray alloc]init];
            if (dataArr.count>3) {
                
                for (int i=0; i<dataArr.count; i++) {
                    
                    OWTexploreModel *model =[[OWTexploreModel alloc]init];
                    
                    model =dataArr[i];
                    
                    [coverUrlArr addObject:model.CoverUrl];
                    
                    [SubtitleArr addObject:model.Subtitle];
                    
                    [tArr addObject:model.Caption];
                    
                    [SummaryArr addObject:model.Summary];
                    
                    [UrlArr addObject:model.Url];
                    [HcoverUrlArr addObject:model.HCoverUrl];
                  
                }
                
                
                UIImageView *imageV1 = [[UIImageView alloc]init];
                imageV1.image = [UIImage imageNamed:@"首页1.jpg"];
                //    imageV.frame = CGRectMake(0, 0, 320, 1197);
                UIImageView *imageV11 = [[UIImageView alloc]init];
                imageV11.image = [UIImage imageNamed:@"首页11.jpg"];
                UIImageView *imageV2 = [[UIImageView alloc]init];
                imageV2.image = [UIImage imageNamed:@"首页2.jpg"];//
                
                UIImageView *imageV3 = [[UIImageView alloc]init];
                imageV3.image = [UIImage imageNamed:@"旅行.jpg"];
                
                // scrollV = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 20, 320, self.view.bounds.size.height)];
                [scrollV addSubview:imageV1];
                [scrollV addSubview:imageV11];
                [scrollV addSubview:imageV2];
                [scrollV addSubview:imageV3];
                if (isfirst==YES) {
                    NSString *str=[[NSUserDefaults standardUserDefaults]objectForKey:@"everyImage"];
                    NSString *str1=[[NSUserDefaults standardUserDefaults]objectForKey:@"everyLabel"];
                    if (str) {
                        UIImageView *dailV = [[UIImageView alloc]initWithFrame:CGRectMake(8, 730-10+60-36+0, 304, 214)];
                        [ dailV setImageWithURL:[NSURL URLWithString:str] placeholderImage:nil];
                        dailV.backgroundColor=[UIColor whiteColor];
                        [scrollV addSubview:dailV];
                        UILabel *label3 = [[UILabel alloc]initWithFrame:CGRectMake(20, 730+202-10+4+4+60-36+5, 280, 36)];
                        label3.font = [UIFont systemFontOfSize:14];
                        label3.backgroundColor =[UIColor whiteColor];
                        label3.text =str1;
                        label3.textAlignment=0;
                        [scrollV addSubview:label3];
                    }}
                scrollV.showsHorizontalScrollIndicator = YES;
//
                
                UIView *view1 =[[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 20)];
                view1.backgroundColor = [UIColor whiteColor];
                [scrollV addSubview:view1];
                
                
//                
//                UIView *mview = [[UIView alloc]init];
//                mview.frame = CGRectMake(160-25, 240-25, 50, 50);
//                [mview setBackgroundColor:[UIColor redColor]];
//                [self.view addSubview:mview];
                
                
                imageV1.frame = CGRectMake(0, 20, 320, 150);
                
                imageV11.frame = CGRectMake(0, 170, 320, 52);
                
                
                imageV2.frame = CGRectMake(0, 424-36, 320, 857);
                
                imageV3.frame = CGRectMake(8.5, 222, 303, 202-36);
                
                scrollV.contentSize =CGSizeMake(320, 1197+20+30+10+10-36+10+20);
                
                _keywordTextField =[[UITextField alloc]init ];
                _keywordTextField.frame =CGRectMake(25, 67+20, 240, 40);
                _keywordTextField.returnKeyType =UIReturnKeySearch;
                _keywordTextField.enablesReturnKeyAutomatically = YES;
                
                
                [_keywordTextField setDelegate:self];
                
                _searchButton = [[UIButton alloc]init];
                _searchButton.frame=CGRectMake(260, 67+20, 40, 40);
                //[_searchButton setBackgroundColor:[UIColor redColor]];
                
                [[UITextField appearance] setTintColor:GetThemer().themeTintColor];
                for (int i = 0; i<22; i++) {
//                    NSLog(@"@@@@@@@@@@@@@@@@@%d",i);
                    UIButton *btn = [[ UIButton alloc]init];
                    
                    if (i==21) {
                        btn.frame = CGRectMake(20+270/6*6-8, 120+20+4+5, 15, 15);
                        [btn setBackgroundImage:[UIImage imageNamed:@"ic_index_more.png"] forState:UIControlStateNormal];
                        [btn setBackgroundImage:[UIImage imageNamed:@"ic_index_less.png"] forState:UIControlStateSelected];
                        btn.backgroundColor = [UIColor whiteColor];
                        [btn setTitleColor:[UIColor colorWithWhite:0.3 alpha:1.0]forState:UIControlStateNormal];
                        //                        btn.titleLabel.font = [UIFont  systemFontOfSize:12];
//                        NSLog(@"\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\");
                    }
                    //
                    if (i<6) {
                        
                        UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(20+270/6*i-8, 120+20+4, 270/6, 25)];
                        NSArray *arr = @[@"旅游",@"家居",@"汽车",@"美食",@"时尚",@"壁纸"];
                        [btn setTitle: arr[i] forState: UIControlStateNormal];
                        btn.backgroundColor = [UIColor whiteColor];
                        [btn setTitleColor:[UIColor colorWithWhite:0.3 alpha:1.0]forState:UIControlStateNormal];
                        btn.titleLabel.font = [UIFont  systemFontOfSize:13];
                        btn.tag = i;
                        [scrollV addSubview:btn];
                        [btn addTarget:self action:@selector(btnclick:) forControlEvents:UIControlEventTouchUpInside];
                        
                        
                    }
                
                    
                    
                    UILabel *label4 = [[UILabel alloc]initWithFrame:CGRectMake(16, 198+20-30, 293, 28)];
                    
                    label4.backgroundColor =[UIColor whiteColor];
                    
                    label4.text =@"每日一图";
                    
                    [scrollV addSubview:label4];
                    
                    UILabel *label5 = [[UILabel alloc]initWithFrame:CGRectMake(16, 730-10+60-36-30+0, 293, 28)];
                    
                    label5.backgroundColor =[UIColor whiteColor];
                    
                    label5.text =@"今日推荐";
                    
                    [scrollV addSubview:label5];
                    
                    if (i>5&&i<11) {
                        
                        //这个是要改的
                        
                        UIImageView *imagV = [[UIImageView alloc]init];
                        
                        imagV.backgroundColor = [UIColor whiteColor];
                        
                        
                        UILabel *label2 =[[UILabel alloc]init];
                        if (i==6) {
                            
                            btn.frame = CGRectMake(8.5-1-0.5, 198+20+0, 303+1+2, 202 -36);
                            UIImageView * imV = [[UIImageView alloc]init];
                            
                            [imV setImageWithURL:[NSURL URLWithString:HcoverUrlArr[i-6]] placeholderImage:[UIImage imageNamed:@""]];
                            
                            imV.frame =CGRectMake(8.5-1-0.5, 198+20+0, 303+1+2, 202 -36);
                            [scrollV addSubview:imV];
                        }
                        
                        if (i>6) {
                            
                            if(i==7)
                                
                            {
                                
                                label2.frame =CGRectMake(105, 342+76*(i-7)+40+2*(i-5)+5-10+5+60-36+0, 205, 76-10);
                                
                                imagV.frame = CGRectMake(16, 342+76*(i-7)+40-20-10+60-36+5+22-1+0, 80, 60);
                               
                            }
                            
                            if(i==8)
                                
                            {
                                
                                label2.frame =CGRectMake(105, 342+76*(i-7)+40+2*(i-5)+5-10+4+60-36-2+0, 205, 76-10);
                                
                                imagV.frame = CGRectMake(16, 342+76*(i-7)+40-20-10+60-36+5+22-2+0, 80, 60);
                                
                            }
                            
                            if(i==9)
                                
                            {
                                
                                label2.frame =CGRectMake(105, 342+76*(i-7)+40+2*(i-5)+5-10+2+60-36+0, 205, 76-10);
                                
                                imagV.frame = CGRectMake(16, 342+76*(i-7)+40-20-10+60-36+5+22+0, 80, 60);
                              
                            }
                            
                            if(i==10)
                                
                            {
                                
                                label2.frame =CGRectMake(105, 342+76*(i-7)+40+2*(i-5)+5-10+2+60-36+0, 205, 76-10);
                                
                                imagV.frame = CGRectMake(16, 342+76*(i-7)+40-20-10+60-36+5+22+2+0, 80, 60);
                              
                            }
                            
                            [imagV setImageWithURL:[NSURL URLWithString:coverUrlArr[i-6]] placeholderImage:[UIImage imageNamed:@""]];
                            
                            label2.font = [UIFont  systemFontOfSize:12];
                            label2.text =@"";
                            
                            
                            NSAttributedString *attributedString =[[NSAttributedString alloc] initWithString:SummaryArr[i-6] attributes:@{NSForegroundColorAttributeName : [UIColor lightGrayColor],NSKernAttributeName : @(1.3f)}];
                            
                            UIView *view2 =[[UIView alloc]initWithFrame:CGRectMake(100, 342+76*(i-7)+40-10+60-36+0, 205, 76-10)];
                            
                            view2.backgroundColor = [UIColor whiteColor];
                            
                            [scrollV addSubview:view2];
                            
                            UILabel *label1 =[[UILabel alloc]init];
                            
                            label1.frame=CGRectMake(105, 342+76*(i-7)+40-20-10+60-36+5+0, 205, 76-10);

                            label1.font = [UIFont  systemFontOfSize:15];
                            
                            label1.text =SubtitleArr[i-6];
                            [scrollV addSubview:label1];
                            
                            [label2 setAttributedText:attributedString];
                            
                            [label2 setNumberOfLines:3];
                            
                            [scrollV addSubview:label2];
                            
                            [scrollV addSubview:imagV];
                            
                            
                            btn.frame = CGRectMake(0, 342+76*(i-7)+30-10+60-36+0, 320, 76);
                      
                        }
                        
                    }
                    
                    
                    if (i==11) {
                        
                        NSURL *url1 = [NSURL URLWithString:@"http://api.tiankong.com/qjapi/cdn1/daily"];
                        
                        //利用三方解析json数据
                        
                        NSURLRequest *request1 =[NSURLRequest requestWithURL:url1];
                        
                        _connection1=[[NSURLConnection alloc]initWithRequest:request1 delegate:self];
                        btn.frame = CGRectMake(8, 730-10+60-36+0, 304, 214);

                    }
                    
                    
                    
                    if (i>11&&i<20) {
                        if (isfirst==NO) {
                        btn.frame = CGRectMake(5+155*(i%2), 994+37*((i-12)/2)+30-10+0-36+60, 155, 37);
                        
                        
                        UILabel *label3 = [[UILabel alloc]initWithFrame:CGRectMake(24+155*(i%2), 994+37*((i-12)/2)+30-10+60-36+8+0, 125, 35)];
                                               label3.textColor = [UIColor blackColor];;
                        label3.text =@"";
                        label3.font = [UIFont systemFontOfSize:14];
                        [scrollV addSubview:label3];
                        
                        //                        label3.backgroundColor = [UIColor redColor];
                        
                        [keyLabels addObject:label3];
                        
                        
                        for (int i=0; i<keyLabels.count; i++) {
                            UILabel *lab =keyLabels[i];
                            lab.backgroundColor = [UIColor whiteColor];
                            @try {
                                lab.text =titleKeyArr[i];
                            }
                            @catch (NSException *exception) {
                                
                            }
                            
                        }}
                        
                    }
                    if (i==20) {
                        
                        btn.frame = CGRectMake(5, 1137+30-10+60-36+10+10+0, 310, 45);
                        UILabel *label3 = [[UILabel alloc]initWithFrame:CGRectMake(24, 1137+30-10+60-36+10+10+0, 290, 35)];
                        label3.backgroundColor = [UIColor whiteColor];
                        //
                        
                        
                        label3.textColor = [UIColor colorWithHexString:@"#3399cc"];;
                        label3.text =@"换一批>>";
                        [scrollV addSubview:label3];
                        
                        
                    }

                    UILabel *label3 = [[UILabel alloc]initWithFrame:CGRectMake(16, 730+202-10+55+60+5-36+0, 290, 35)];
                    label3.backgroundColor =[UIColor whiteColor];
                    label3.text =@"热门标签";
                    [scrollV addSubview:label3];
                    
                    btn.tag =i;
                   
                    seArr = @[@"旅游",@"家居",@"汽车",@"美食",@"时尚",@"美图",@"http://m.quanjing.com/topic/l01.html",
                              @"http://m.quanjing.com/topic/l01.html",
                              @"http://m.quanjing.com/topic/l01.html",@"http://m.quanjing.com/topic/l01.html",@"http://m.quanjing.com/topic/l01.html",
                              @"",@"马尔代夫",@"美食",@"九寨沟",@"法拉利",@"宝宝",@"家居",@"美女",@"动物",@"壁纸"];
                    
                    
                    [btn addTarget:self action:@selector(btnclick:) forControlEvents:UIControlEventTouchUpInside];
                    [_searchButton addTarget:self action:@selector(onSearchButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
                    
                    [scrollV addSubview:btn];
                    [scrollV addSubview:_searchButton];
                    [scrollV addSubview:_keywordTextField];
                    
                    for (UIView* subView in self.view.subviews)
                        
                    {
                        if (![subView isKindOfClass:[UITextField class]])
                        {
                            UITapGestureRecognizer* singleRecognizer;
                            singleRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(SingleTap)];
                            //点击的次数
                            singleRecognizer.numberOfTapsRequired = 1; // 单击
                            
                            //给self.view添加一个手势监测；
                            
                            subView.userInteractionEnabled =YES;
                            [subView addGestureRecognizer:singleRecognizer];
                        }
                        
                    }
                    
                    
                    
                    
                }
            }
        }
    }
    
}

- (void)reloadData1
{
    
    
    [keywords removeAllObjects];
    [titleKeyArr removeAllObjects];
    
//    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://api.tiankong.com/qjapi/cdn1/hottag?count=8&page=%d",_pageCount]];
    
    //利用三方解析json数据
    
    NSURLRequest *request =[NSURLRequest requestWithURL:url];
    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    //NSJSONSerialization解析
    if (response!=nil) {
        NSDictionary *dic0 =[NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingMutableLeaves error:nil];
        
//   NSLog(@"dic0 =%@",dic0);
        if (response!=nil) {
            NSArray*appList=dic0[@"hottag"];
            if (appList.count!=0&&appList.count>=8) {
                for (NSDictionary*appdict in appList) {
                    [keywords addObject:appdict[@"searchkeywords"]];
                    [titleKeyArr addObject:appdict[@"tag"]];
                }
                
            }
            else{
                _pageCount =1;
                [self reloadData1];
            }
        }
    }
}

-(void)whenClickImage
{
}

#pragma -mark   
-(void)btnclick:(UIButton*)button
{
    NSLog(@"点击下按钮的tag值： %d",button.tag);
    if (button.tag<6) {

        
        if (button.tag<4) {
            _keywordTextField.text =seArr[button.tag];
            [self performSearch];
            [_keywordTextField resignFirstResponder];
        }
        else{
            if (button.tag==4) {
                OQJSelectedViewCon1 *svc =[[OQJSelectedViewCon1 alloc]init];
                svc.isFashion=YES;
                [self.navigationController pushViewController:svc animated:YES];
                [svc substituteNavigationBarBackItem];
            }else {
            OQJSelectedViewCon1 *svc =[[OQJSelectedViewCon1 alloc]init];
            [self.navigationController pushViewController:svc animated:YES];
            [svc substituteNavigationBarBackItem];
            }
        }
        
    }
    if (button.tag>5&&button.tag<11) {
        WLJWebViewController *evc = [[WLJWebViewController alloc]init];
        
        
        evc.titleS=tArr[button.tag-6];
        evc.urlString=UrlArr[button.tag-6];
        evc.assetUrl =coverUrlArr[button.tag-6];
        
        evc.SummaryStr =SummaryArr[button.tag-6];
        
        //???
        [self.navigationController pushViewController:evc animated:YES];
        [evc substituteNavigationBarBackItem];
        
    }
    if (button.tag>=100) {
//        self.view.backgroundColor = [UIColor redColor];
        
        if (button.tag ==100) {
            OWTFeedInfo* homeFeedInfo = [[OWTFeedInfo alloc] initWithFeedID:@"3"
                                                                     nameZH:@"创意"
                                                                     nameEN:@"Wonderful Pictures"
                                                             lastUpdateTime:[[NSDate date] timeIntervalSince1970]
                                                                 generation:1];
            OWTFeed* homeFeed = [[OWTFeed alloc] initWithFeedInfo:homeFeedInfo];
            OWTFeedViewCon *fvc = [[OWTFeedViewCon alloc]init];
            [fvc presentFeed:homeFeed animated:YES refresh:YES];
            [self.navigationController pushViewController:fvc animated:YES];
            [fvc substituteNavigationBarBackItem];
            fvc.title =@"全景创意";
        }
        if (button.tag ==101) {
            OWTFeedInfo* homeFeedInfo = [[OWTFeedInfo alloc] initWithFeedID:@"2"
                                                                     nameZH:@"创意"
                                                                     nameEN:@"Wonderful Pictures"
                                                             lastUpdateTime:[[NSDate date] timeIntervalSince1970]
                                                                 generation:1];
            OWTFeed* homeFeed = [[OWTFeed alloc] initWithFeedInfo:homeFeedInfo];
            OWTFeedViewCon *fvc = [[OWTFeedViewCon alloc]init];
            [fvc presentFeed:homeFeed animated:YES refresh:YES];
            [self.navigationController pushViewController:fvc animated:YES];
            [fvc substituteNavigationBarBackItem];
            fvc.title =@"全景大师";
        }
        if (button.tag ==102) {
            OWTFeedInfo* homeFeedInfo = [[OWTFeedInfo alloc] initWithFeedID:@"6"
                                                                     nameZH:@"创意"
                                                                     nameEN:@"Wonderful Pictures"
                                                             lastUpdateTime:[[NSDate date] timeIntervalSince1970]
                                                                 generation:1];
            OWTFeed* homeFeed = [[OWTFeed alloc] initWithFeedInfo:homeFeedInfo];
            OWTFeedViewCon *fvc = [[OWTFeedViewCon alloc]init];
            [fvc presentFeed:homeFeed animated:YES refresh:YES];
            [self.navigationController pushViewController:fvc animated:YES];
            [fvc substituteNavigationBarBackItem];
            fvc.title =@"全景艺术";
        }
        if (button.tag ==103) {
            OWTFeedInfo* homeFeedInfo = [[OWTFeedInfo alloc] initWithFeedID:@"7"
                                                                     nameZH:@"创意"
                                                                     nameEN:@"Wonderful Pictures"
                                                             lastUpdateTime:[[NSDate date] timeIntervalSince1970]
                                                                 generation:1];
            OWTFeed* homeFeed = [[OWTFeed alloc] initWithFeedInfo:homeFeedInfo];
            OWTFeedViewCon *fvc = [[OWTFeedViewCon alloc]init];
            [fvc presentFeed:homeFeed animated:YES refresh:YES];
            [self.navigationController pushViewController:fvc animated:YES];
            [fvc substituteNavigationBarBackItem];
            fvc.title =@"全景T台";
        }
 
        
    }
    
    
    if (button.tag==11){
//

        if ([assetStr3 intValue]==2) {

           
            RKObjectManager* om = [RKObjectManager sharedManager];
            [om getObjectsAtPath:[NSString stringWithFormat:@"users/%@", assetStr4]
                      parameters:nil
                         success:^(RKObjectRequestOperation* o, RKMappingResult* result) {
                             [o logResponse];
                             
                             NSDictionary* resultObjects = result.dictionary;
                             OWTServerError* error = resultObjects[@"error"];
                             
                             
                             OWTUserData* incomingUserData = resultObjects[@"user"];
                             if (incomingUserData == nil)
                             {
                                 [SVProgressHUD showGeneralError];
                                 return;
                             }
                             OWTUser* User = [[OWTUser alloc]init];
                             
                             
                             [User mergeWithData:incomingUserData];
                             if (User !=nil) {
                                 OWTUserViewCon* userViewCon1 = [[OWTUserViewCon alloc] initWithNibName:nil bundle:nil];
                                 userViewCon1.hidesBottomBarWhenPushed = YES;
                                 [self.navigationController pushViewController:userViewCon1 animated:YES];
                                 userViewCon1.user =User;
                             }
                             
                            
                         }
                         failure:^(RKObjectRequestOperation* o, NSError* error) {
                              [SVProgressHUD showGeneralError];
                         }];
            
            }
        
        
        if ([assetStr3 intValue]==1) {

            
        OWTImageInfo* imageInfo =[[OWTImageInfo alloc]init];
        imageInfo.url =assetStr2;
        imageInfo.smallURL =assetStr2;
        imageInfo.primaryColorHex =@"425320";
        imageInfo.width = 304;
        imageInfo.height =214;
        
        OWTAssetData *asData = [[OWTAssetData alloc]init];
        asData.assetID =assetStr;
        asData.caption =assetStr1;
        asData.serial =@"";
        asData.ownerUserID =@"";
        asData.isPrivate =FALSE;
        asData.imageInfo =imageInfo;
        asData.likedUserNum =0;
        asData.commentNum = 0;
        asData.commentDatas =@[];
        asData.likedUserIDs =@[];
        
        
        
        asData.webURL= [NSString stringWithFormat:@"http://m.quanjing.com/share.aspx?pic_id=%@",assetStr];
        
//
        OWTAssetManager *ASManger = [[OWTAssetManager alloc]init];
        
        OWTAsset* asset = [ASManger registerAssetData:asData];
        if (asset != nil)
        {
            OWTAssetViewCon* assetViewCon = [[OWTAssetViewCon alloc] initWithAsset:asset];
            [self.navigationController pushViewController:assetViewCon animated:YES];
        }
        }
        
        
    }
    if (button.tag>11&&button.tag<20){
        
        _keywordTextField.text =keywords[button.tag-12];
        [self performSearch];
        [_keywordTextField resignFirstResponder];
    }
    if (button.tag==20) {
        _pageCount++;
         [self reloadData1];
        
               [self updadekeyLabel];
    }
    
    if (button.tag==21) {
        
        if (button.selected ==NO) {
//
            for(UIView *subview in [self.view subviews])
            {
                
                [subview removeFromSuperview];
            }
            UIView *view =[[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 20)];
            view.backgroundColor = [UIColor whiteColor];
            [self.view addSubview:view];
            scrollV = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 20, 320, self.view.bounds.size.height)];
            scrollV.contentSize =CGSizeMake(320, 1197+20+30+10+10+60-36+20);
            scrollV.delegate =self;
            [self.view addSubview:scrollV];

            //[self loadViewData];
            _refreshControl = [[XHRefreshControl alloc] initWithScrollView:scrollV delegate:self];

            keywords =[[NSMutableArray alloc]init];
            titleKeyArr = [[NSMutableArray alloc]init];
            [self reloadData1];
            
            _pageCount=1;
            
            if (response2==nil) {
                               [SVProgressHUD showGeneralError];
            }
            if (response2!=nil) {
                if (![dic0 isKindOfClass:[NSNull class]]) {
                    
                    keyLabels = [[NSMutableArray alloc]init];
                    coverUrlArr = [[NSMutableArray alloc]init];
                    SubtitleArr = [[NSMutableArray alloc]init];
                   
                    tArr =[[NSMutableArray alloc]init];
                    SummaryArr =[[NSMutableArray alloc]init];
                    UrlArr =[[NSMutableArray alloc]init];
                    
                    HcoverUrlArr =[[NSMutableArray alloc]init];
                    if (dataArr.count>3) {
                        
                        for (int i=0; i<dataArr.count; i++) {
                            
                            OWTexploreModel *model =[[OWTexploreModel alloc]init];
                            
                            model =dataArr[i];
                            
                            [coverUrlArr addObject:model.CoverUrl];
                            
                            [SubtitleArr addObject:model.Subtitle];
                            
                            [tArr addObject:model.Caption];
                            
                            [SummaryArr addObject:model.Summary];
                            
                            [UrlArr addObject:model.Url];
                            [HcoverUrlArr addObject:model.HCoverUrl];
                            
                        }
                        
                        
                        UIImageView *imageV1 = [[UIImageView alloc]init];
                        imageV1.image = [UIImage imageNamed:@"首页1.jpg"];
                        
                        UIImageView *imageV11 = [[UIImageView alloc]init];
                        imageV11.image = [UIImage imageNamed:@"首页11.jpg"];
                        UIImageView *imageV2 = [[UIImageView alloc]init];
                        imageV2.image = [UIImage imageNamed:@"首页2.jpg"];//
                        
                        UIImageView *imageV3 = [[UIImageView alloc]init];
                        imageV3.image = [UIImage imageNamed:@"旅行.jpg"];
                        
                        [scrollV addSubview:imageV1];
                        [scrollV addSubview:imageV11];
                        [scrollV addSubview:imageV2];
                        [scrollV addSubview:imageV3];
                       
                        scrollV.showsHorizontalScrollIndicator = YES;
                        UIView *view1 =[[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 20)];
                        view1.backgroundColor = [UIColor whiteColor];
                        [scrollV addSubview:view1];
                        
                        
                        imageV1.frame = CGRectMake(0, 20, 320, 150);
                        
                        
                        //
                        UIView *view3 =[[UIView alloc]initWithFrame:CGRectMake(0, 170, 320, 40)];
                        view3.backgroundColor = [UIColor whiteColor];
                        [scrollV addSubview:view3];
                        
                        for (int i =0; i<4; i++) {
                            UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(20+270/6*i-8, 120+20+4+30, 270/6, 25)];
                            NSArray *arr = @[@"创意",@"大师",@"艺术",@"T台"];
                            [btn setTitle: arr[i] forState: UIControlStateNormal];
                            btn.backgroundColor = [UIColor whiteColor];
                            [btn setTitleColor:[UIColor colorWithWhite:0.3 alpha:1.0]forState:UIControlStateNormal];
                            btn.titleLabel.font = [UIFont  systemFontOfSize:13];
                            [scrollV addSubview:btn];
                            btn.tag=100+i;
                            [btn addTarget:self action:@selector(btnclick:) forControlEvents:UIControlEventTouchUpInside];
                        }
                        
                        
                        imageV11.frame = CGRectMake(0, 170+40, 320, 52);
                        
                        
                        imageV2.frame = CGRectMake(0, 424-36+40, 320, 857);
                        
                        imageV3.frame = CGRectMake(8.5, 222+40, 303, 202-36);
                        
                        scrollV.contentSize =CGSizeMake(320, 1197+20+30+10+10+60-36+20+40-48);
                        
                         _keywordTextField =[[UITextField alloc]init ];
                        _keywordTextField.frame =CGRectMake(25, 67+20, 240, 40);
                        _keywordTextField.returnKeyType =UIReturnKeySearch;
                        _keywordTextField.enablesReturnKeyAutomatically = YES;
                        
                        
                        [ _keywordTextField setDelegate:self];
                        
                        _searchButton = [[UIButton alloc]init];
                        _searchButton.frame=CGRectMake(260, 67+20, 40, 40);
                        
                        [[UITextField appearance] setTintColor:GetThemer().themeTintColor];//??
                        for (int i = 0; i<22; i++) {
                                                      UIButton *btn = [[ UIButton alloc]init];
                            
                            if (i==21) {
                                btn.frame = CGRectMake(20+270/6*6-8, 120+20+4+5, 15, 15);
                                [btn setBackgroundImage:[UIImage imageNamed:@"ic_index_more.png"] forState:UIControlStateNormal];
                                [btn setBackgroundImage:[UIImage imageNamed:@"ic_index_less.png"] forState:UIControlStateSelected];
                                btn.backgroundColor = [UIColor whiteColor];
                                [btn setTitleColor:[UIColor colorWithWhite:0.3 alpha:1.0]forState:UIControlStateNormal];
                                [btn setSelected:YES];
                         
                            }
                            //
                            if (i<6) {
                                
                                UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(20+270/6*i-8, 120+20+4, 270/6, 25)];
                                NSArray *arr = @[@"旅游",@"家居",@"汽车",@"美食",@"时尚",@"壁纸"];
                                [btn setTitle: arr[i] forState: UIControlStateNormal];
                                btn.backgroundColor = [UIColor whiteColor];
                                [btn setTitleColor:[UIColor colorWithWhite:0.3 alpha:1.0]forState:UIControlStateNormal];
                                btn.titleLabel.font = [UIFont  systemFontOfSize:13];
                                btn.tag = i;
                                [scrollV addSubview:btn];
                                [btn addTarget:self action:@selector(btnclick:) forControlEvents:UIControlEventTouchUpInside];
                                
                            }
                            
                            UILabel *label4 = [[UILabel alloc]initWithFrame:CGRectMake(16, 198+20-30+40, 293, 28)];
                            
                            label4.backgroundColor =[UIColor whiteColor];
                            
                            label4.text =@"每日一图";
                            
                            [scrollV addSubview:label4];
                            
                            
                            UILabel *label5 = [[UILabel alloc]initWithFrame:CGRectMake(16, 730-10+60-36-30+40, 293, 28)];
                            
                            label5.backgroundColor =[UIColor whiteColor];
                            
                            label5.text =@"今日推荐";
                            
                            [scrollV addSubview:label5];
                            
                            if (i>5&&i<11) {
                                
                                //这个是要改的
                                
                                UIImageView *imagV = [[UIImageView alloc]init];
                                
                                imagV.backgroundColor = [UIColor whiteColor];
                                
                                
                                UILabel *label2 =[[UILabel alloc]init];
                                
                                
                                if (i==6) {
                                    
                                    btn.frame = CGRectMake(8.5-1-0.5, 198+20+40, 303+1+2, 202 -36);
                                                                        UIImageView * imV = [[UIImageView alloc]init];
                                    
                                    [imV setImageWithURL:[NSURL URLWithString:HcoverUrlArr[i-6]] placeholderImage:[UIImage imageNamed:@""]];
                                    
                                    imV.frame =CGRectMake(8.5-1-0.5, 198+20+40, 303+1+2, 202 -36);
                                    [scrollV addSubview:imV];
                                    
                                    UIView *view4 = [[UIView alloc]initWithFrame:CGRectMake(8.5-1-0.5, 198+20+40+202 -36, 303+1+2, 5)];
                                    view4.backgroundColor = [UIColor whiteColor];
                                    [scrollV addSubview: view4];
                                    
                                }
                                
                                if (i>6) {
                                    
                                    if(i==7)
                                        
                                    {
                                        
                                        label2.frame =CGRectMake(105, 342+76*(i-7)+40+2*(i-5)+5-10+5+60-36+40, 205, 76-10);
                                        
                                        imagV.frame = CGRectMake(16, 342+76*(i-7)+40-20-10+60-36+5+22-1+40, 80, 60);
                                        
                                    }
                                    
                                    if(i==8)
                                        
                                    {
                                        
                                        label2.frame =CGRectMake(105, 342+76*(i-7)+40+2*(i-5)+5-10+4+60-36-2+40, 205, 76-10);
                                        
                                        imagV.frame = CGRectMake(16, 342+76*(i-7)+40-20-10+60-36+5+22-2+40, 80, 60);
                                        
                                    }
                                    
                                    if(i==9)
                                        
                                    {
                                        
                                        label2.frame =CGRectMake(105, 342+76*(i-7)+40+2*(i-5)+5-10+2+60-36+40, 205, 76-10);
                                        
                                        imagV.frame = CGRectMake(16, 342+76*(i-7)+40-20-10+60-36+5+22+40, 80, 60);
                                       
                                    }
                                    
                                    if(i==10)
                                        
                                    {
                                        
                                        label2.frame =CGRectMake(105, 342+76*(i-7)+40+2*(i-5)+5-10+2+60-36+40, 205, 76-10);
                                        
                                        imagV.frame = CGRectMake(16, 342+76*(i-7)+40-20-10+60-36+5+22+2+40, 80, 60);
                                     
                                    }
                                    
                                    [imagV setImageWithURL:[NSURL URLWithString:coverUrlArr[i-6]] placeholderImage:[UIImage imageNamed:@""]];
                                    
                                    label2.font = [UIFont  systemFontOfSize:12];
                                    
                                    label2.text =@"";
                                    
                                    
                                    NSAttributedString *attributedString =[[NSAttributedString alloc] initWithString:SummaryArr[i-6] attributes:@{NSForegroundColorAttributeName : [UIColor lightGrayColor],NSKernAttributeName : @(1.3f)}];
                                    
                                    UIView *view2 =[[UIView alloc]initWithFrame:CGRectMake(100, 342+76*(i-7)+40-10+60-36+40, 205, 76-10)];
                                    
                                    view2.backgroundColor = [UIColor whiteColor];
                                    
                                    [scrollV addSubview:view2];
                                   
                                    
                                    UILabel *label1 =[[UILabel alloc]init];
                                    
                                    label1.frame=CGRectMake(105, 342+76*(i-7)+40-20-10+60-36+5+40, 205, 76-10);
                                    
                                    label1.font = [UIFont  systemFontOfSize:15];
                                    
                                    label1.text =SubtitleArr[i-6];
                                   
                                    [scrollV addSubview:label1];
                                    
                                    
                                    [label2 setAttributedText:attributedString];
                                    
                                    
                                    
                                    [label2 setNumberOfLines:3];
                                    
                                    [scrollV addSubview:label2];
                                    
                                    [scrollV addSubview:imagV];
                                    
                                    
                                    btn.frame = CGRectMake(0, 342+76*(i-7)+30-10+60-36+40, 320, 76);
                                 
                                }
                                
                            }
                            
                            
                            if (i==11) {
                                NSDictionary*appList = [[NSDictionary alloc]init];
                                NSURL *url1 = [NSURL URLWithString:@"http://api.tiankong.com/qjapi/cdn1/daily"];
                                
                                
                                //利用三方解析json数据
                                
                                NSURLRequest *request1 =[NSURLRequest requestWithURL:url1];
                                
                                NSData *response1 = [NSURLConnection sendSynchronousRequest:request1 returningResponse:nil error:nil];
                                if (response1!=nil) {
                                    
                                    //NSJSONSerialization解析
                                    
                                    NSDictionary *dic1 =[NSJSONSerialization JSONObjectWithData:response1 options:NSJSONReadingMutableLeaves error:nil];
                                    
                                    
                                    appList=dic1[@"daily"];
                                    
                                    
                                    assetStr = appList[@"originalid"];
                                    assetStr1 = appList[@"caption"];
                                    assetStr2 = appList[@"imageurl"];
                                    assetStr3 = appList[@"_class"];
                                    assetStr4 = appList[@"originalid"];
                                   
                                    UIImageView *dailV = [[UIImageView alloc]initWithFrame:CGRectMake(8, 730-10+60-36+40, 304, 214)];
                                    [ dailV setImageWithURL:[NSURL URLWithString:appList[@"imageurl"]] placeholderImage:[UIImage imageNamed:@""]];
                                   
                                    
                                    btn.frame = CGRectMake(8, 730-10+60-36+40, 304, 214);
                                    
                                   
                                    UILabel *label3 = [[UILabel alloc]initWithFrame:CGRectMake(20, 730+202-10+4+4-36+40, 280, 36)];
                                    label3.font = [UIFont systemFontOfSize:14];
                                    label3.backgroundColor =[UIColor whiteColor];
                                    label3.text =appList[@"caption"];
                                    label3.textAlignment=0;
                                    [scrollV addSubview:label3];
                                    
                                    [scrollV addSubview:dailV];
                                }
                            }
                            
                            
                            
                            if (i>11&&i<20) {
                                
                                btn.frame = CGRectMake(5+155*(i%2), 994+37*((i-12)/2)+30-10+40-36+60, 155, 37);
                                
                                
                                UILabel *label3 = [[UILabel alloc]initWithFrame:CGRectMake(24+155*(i%2), 994+37*((i-12)/2)+30-10+60-36+8+40, 125, 35)];
                                
                                label3.textColor = [UIColor blackColor];;
                                label3.text =@"";
                                label3.font = [UIFont systemFontOfSize:14];
                                [scrollV addSubview:label3];
                                
                                
                                [keyLabels addObject:label3];
                                
                                
                                for (int i=0; i<keyLabels.count; i++) {
                                    UILabel *lab =keyLabels[i];
                                    lab.backgroundColor = [UIColor whiteColor];
                                    lab.text =titleKeyArr[i];
                                    
                                }
                                
                                
                            }
                            if (i==20) {
                                
                                btn.frame = CGRectMake(5, 1137+30-10+60-36+10+40, 310, 45);
                                UILabel *label3 = [[UILabel alloc]initWithFrame:CGRectMake(24, 1137+30-10+60-36+10+10+40, 290, 35)];
                                label3.backgroundColor = [UIColor whiteColor];
                                //
                                label3.textColor = [UIColor colorWithHexString:@"#3399cc"];;
                                label3.text =@"换一批>>";
                                [scrollV addSubview:label3];
                                
                                
                            }
                            UILabel *label3 = [[UILabel alloc]initWithFrame:CGRectMake(16, 730+202-10+55+60+5-36+40, 290, 35)];
                            label3.backgroundColor =[UIColor whiteColor];
                            label3.text =@"热门标签";
                            [scrollV addSubview:label3];
                            
                            btn.tag =i;
                            
                            seArr = @[@"旅游",@"家居",@"汽车",@"美食",@"时尚",@"美图",@"http://m.quanjing.com/topic/l01.html",
                                      @"http://m.quanjing.com/topic/l01.html",
                                      @"http://m.quanjing.com/topic/l01.html",@"http://m.quanjing.com/topic/l01.html",@"http://m.quanjing.com/topic/l01.html",
                                      @"",@"马尔代夫",@"美食",@"九寨沟",@"法拉利",@"宝宝",@"家居",@"美女",@"动物",@"壁纸"];
                            
                            [btn addTarget:self action:@selector(btnclick:) forControlEvents:UIControlEventTouchUpInside];
                            [_searchButton addTarget:self action:@selector(onSearchButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
                            
                            [scrollV addSubview:btn];
                            [scrollV addSubview:_searchButton];
                            [scrollV addSubview:_keywordTextField];
                            
                            for (UIView* subView in self.view.subviews)
                                
                            {
                                if (![subView isKindOfClass:[UITextField class]])
                                {
                                    UITapGestureRecognizer* singleRecognizer;
                                    singleRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(SingleTap)];
                                    //
                                    singleRecognizer.numberOfTapsRequired = 1; // 单击
                                    
                                    //
                                    subView.userInteractionEnabled =YES;
                                    [subView addGestureRecognizer:singleRecognizer];
                                }
                                
                            }
  
                        }
                    }
                }
            }
            
            [button setSelected:YES];

        }
        else
        {
            for(UIView *subview in [self.view subviews])
            {
                
                [subview removeFromSuperview];
                           }
            UIView *view =[[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 20)];
            view.backgroundColor = [UIColor whiteColor];
            [self.view addSubview:view];
            scrollV = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 20, 320, self.view.bounds.size.height)];
            _refreshControl = [[XHRefreshControl alloc] initWithScrollView:scrollV delegate:self];

            scrollV.contentSize =CGSizeMake(320, 1197+20+30+10+10+60-36+20);
            scrollV.delegate =self;
            [self.view addSubview:scrollV];

            //[self loadViewData];
            keywords =[[NSMutableArray alloc]init];
            titleKeyArr = [[NSMutableArray alloc]init];
            [self reloadData1];
            
            _pageCount=1;
            
            if (response2==nil) {
               
                [SVProgressHUD showGeneralError];
            }
            if (response2!=nil) {
                if (![dic0 isKindOfClass:[NSNull class]]) {
                    
                    keyLabels = [[NSMutableArray alloc]init];
                    coverUrlArr = [[NSMutableArray alloc]init];
                    SubtitleArr = [[NSMutableArray alloc]init];
                    
                    //这地方时title
                    tArr =[[NSMutableArray alloc]init];
                    SummaryArr =[[NSMutableArray alloc]init];
                    UrlArr =[[NSMutableArray alloc]init];
                    
                    HcoverUrlArr =[[NSMutableArray alloc]init];
                    if (dataArr.count>3) {
                        
                        for (int i=0; i<dataArr.count; i++) {
                            
                            OWTexploreModel *model =[[OWTexploreModel alloc]init];
                            
                            model =dataArr[i];
                            
                            [coverUrlArr addObject:model.CoverUrl];
                            
                            [SubtitleArr addObject:model.Subtitle];
                            
                            [tArr addObject:model.Caption];
                            
                            [SummaryArr addObject:model.Summary];
                            
                            [UrlArr addObject:model.Url];
                            [HcoverUrlArr addObject:model.HCoverUrl];
                            
                            
                            
                        }
                        
                        
                        UIImageView *imageV1 = [[UIImageView alloc]init];
                        imageV1.image = [UIImage imageNamed:@"首页1.jpg"];
                        //    imageV.frame = CGRectMake(0, 0, 320, 1197);
                        UIImageView *imageV11 = [[UIImageView alloc]init];
                        imageV11.image = [UIImage imageNamed:@"首页11.jpg"];
                        UIImageView *imageV2 = [[UIImageView alloc]init];
                        imageV2.image = [UIImage imageNamed:@"首页2.jpg"];//这个地方时是需要改变的数据流
                        
                        UIImageView *imageV3 = [[UIImageView alloc]init];
                        imageV3.image = [UIImage imageNamed:@"旅行.jpg"];
                        
                        //
                        [scrollV addSubview:imageV1];
                        [scrollV addSubview:imageV11];
                        [scrollV addSubview:imageV2];
                        [scrollV addSubview:imageV3];
                        //    scrollV.contentSize =CGSizeMake(320, 1197);
                        scrollV.showsHorizontalScrollIndicator = YES;
                       
                        
                        UIView *view1 =[[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 20)];
                        view1.backgroundColor = [UIColor whiteColor];
                        [scrollV addSubview:view1];
                        
                        
                        
                        
                       
                        imageV1.frame = CGRectMake(0, 20, 320, 150);
                        
                        
                        
                        imageV11.frame = CGRectMake(0, 170, 320, 52);
                        
                        
                        imageV2.frame = CGRectMake(0, 424-36, 320, 857);
                        
                        imageV3.frame = CGRectMake(8.5, 222, 303, 202-36);
                        
                        scrollV.contentSize =CGSizeMake(320, 1197+20+30+10+10+60-36+20-48);
                        
                        
                        //   图片的大小  80*60
                        _keywordTextField =[[UITextField alloc]init ];
                        _keywordTextField.frame =CGRectMake(25, 67+20, 240, 40);
                        _keywordTextField.returnKeyType =UIReturnKeySearch;
                        _keywordTextField.enablesReturnKeyAutomatically = YES;
                        
                        
                        [ _keywordTextField setDelegate:self];
                        
                        _searchButton = [[UIButton alloc]init];
                        _searchButton.frame=CGRectMake(260, 67+20, 40, 40);
                        
                        [[UITextField appearance] setTintColor:GetThemer().themeTintColor];//??
                        for (int i = 0; i<22; i++) {
                           // NSLog(@"@@@@@@@@@@@@@@@@@%d",i);
                            UIButton *btn = [[ UIButton alloc]init];
                            
                            if (i==21) {
                                btn.frame = CGRectMake(20+270/6*6-8, 120+20+4+5, 15, 15);
                                [btn setBackgroundImage:[UIImage imageNamed:@"ic_index_more.png"] forState:UIControlStateNormal];
                                [btn setBackgroundImage:[UIImage imageNamed:@"ic_index_less.png"] forState:UIControlStateSelected];
                                btn.backgroundColor = [UIColor whiteColor];
                                [btn setTitleColor:[UIColor colorWithWhite:0.3 alpha:1.0]forState:UIControlStateNormal];
                               
                            }
                            //
                            if (i<6) {
                                
                                UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(20+270/6*i-8, 120+20+4, 270/6, 25)];
                                NSArray *arr = @[@"旅游",@"家居",@"汽车",@"美食",@"时尚",@"壁纸"];
                                [btn setTitle: arr[i] forState: UIControlStateNormal];
                                btn.backgroundColor = [UIColor whiteColor];
                                [btn setTitleColor:[UIColor colorWithWhite:0.3 alpha:1.0]forState:UIControlStateNormal];
                                btn.titleLabel.font = [UIFont  systemFontOfSize:13];
                                btn.tag = i;
                                [scrollV addSubview:btn];
                                [btn addTarget:self action:@selector(btnclick:) forControlEvents:UIControlEventTouchUpInside];
                                
                                
                            }
                            
                            UILabel *label4 = [[UILabel alloc]initWithFrame:CGRectMake(16, 198+20-30, 293, 28)];
                            
                            label4.backgroundColor =[UIColor whiteColor];
                            
                            label4.text =@"每日一图";
                            
                            [scrollV addSubview:label4];
                            
                            
                            
                            
                            
                            UILabel *label5 = [[UILabel alloc]initWithFrame:CGRectMake(16, 730-10+60-36-30+0, 293, 28)];
                            
                            label5.backgroundColor =[UIColor whiteColor];
                            
                            label5.text =@"今日推荐";
                            
                            [scrollV addSubview:label5];
                            
                            
                            
                            if (i>5&&i<11) {
                                
                                //这个是要改的
                                
                                UIImageView *imagV = [[UIImageView alloc]init];
                                
                                imagV.backgroundColor = [UIColor whiteColor];
                                
                                
                                UILabel *label2 =[[UILabel alloc]init];
                                if (i==6) {
                                    
                                    btn.frame = CGRectMake(8.5-1-0.5, 198+20+0, 303+1+2, 202 -36);
                                    
                                    
                                    
                                    UIImageView * imV = [[UIImageView alloc]init];
                                    
                                    [imV setImageWithURL:[NSURL URLWithString:HcoverUrlArr[i-6]] placeholderImage:[UIImage imageNamed:@""]];
                                    
                                    imV.frame =CGRectMake(8.5-1-0.5, 198+20+0, 303+1+2, 202 -36);
                                    [scrollV addSubview:imV];
                                    
                                    
                                }
                                
                                if (i>6) {
                                    
                                    if(i==7)
                                        
                                    {
                                        
                                        label2.frame =CGRectMake(105, 342+76*(i-7)+40+2*(i-5)+5-10+5+60-36+0, 205, 76-10);
                                        
                                        imagV.frame = CGRectMake(16, 342+76*(i-7)+40-20-10+60-36+5+22-1+0, 80, 60);
                                  
                                        
                                    }
                                    
                                    if(i==8)
                                        
                                    {
                                        
                                        label2.frame =CGRectMake(105, 342+76*(i-7)+40+2*(i-5)+5-10+4+60-36-2+0, 205, 76-10);
                                        
                                        imagV.frame = CGRectMake(16, 342+76*(i-7)+40-20-10+60-36+5+22-2+0, 80, 60);
                                        
                                    }
                                    
                                    if(i==9)
                                        
                                    {
                                        
                                        label2.frame =CGRectMake(105, 342+76*(i-7)+40+2*(i-5)+5-10+2+60-36+0, 205, 76-10);
                                        
                                        imagV.frame = CGRectMake(16, 342+76*(i-7)+40-20-10+60-36+5+22+0, 80, 60);
                                    
                                        
                                    }
                                    
                                    if(i==10)
                                        
                                    {
                                        
                                        label2.frame =CGRectMake(105, 342+76*(i-7)+40+2*(i-5)+5-10+2+60-36+0, 205, 76-10);
                                        
                                        imagV.frame = CGRectMake(16, 342+76*(i-7)+40-20-10+60-36+5+22+2+0, 80, 60);
                                
                                    }
                                    
                                    [imagV setImageWithURL:[NSURL URLWithString:coverUrlArr[i-6]] placeholderImage:[UIImage imageNamed:@""]];
                                    
                                    label2.font = [UIFont  systemFontOfSize:12];
                                    
                                    
                                    label2.text =@"";
                                    
                                    
                                    NSAttributedString *attributedString =[[NSAttributedString alloc] initWithString:SummaryArr[i-6] attributes:@{NSForegroundColorAttributeName : [UIColor lightGrayColor],NSKernAttributeName : @(1.3f)}];
                                    
                                    UIView *view2 =[[UIView alloc]initWithFrame:CGRectMake(100, 342+76*(i-7)+40-10+60-36+0, 205, 76-10)];
                                    
                                    view2.backgroundColor = [UIColor whiteColor];
                                    
                                    [scrollV addSubview:view2];
                                    
                                    
                                    
                                    UILabel *label1 =[[UILabel alloc]init];
                                    
                                    label1.frame=CGRectMake(105, 342+76*(i-7)+40-20-10+60-36+5+0, 205, 76-10);
                                    
                                    
                                    
                                    label1.font = [UIFont  systemFontOfSize:15];
                                    
                                    
                                    label1.text =SubtitleArr[i-6];
                                    
                                    
                                    
                                    [scrollV addSubview:label1];
                                    
                                                             
                                    [label2 setAttributedText:attributedString];
                                    
                                    
                                    
                                    [label2 setNumberOfLines:3];
                                    
                                    [scrollV addSubview:label2];
                                    
                                    [scrollV addSubview:imagV];
                                    
                                    
                                    btn.frame = CGRectMake(0, 342+76*(i-7)+30-10+60-36+0, 320, 76);
                                    
                                }
                       
                            }
                            
                            if (i==11) {
                                NSDictionary*appList = [[NSDictionary alloc]init];
                                NSURL *url1 = [NSURL URLWithString:@"http://api.tiankong.com/qjapi/cdn1/daily"];
                                
                                
                                //利用三方解析json数据
                                
                                NSURLRequest *request1 =[NSURLRequest requestWithURL:url1];
                                
                                NSData *response1 = [NSURLConnection sendSynchronousRequest:request1 returningResponse:nil error:nil];
                                if (response1!=nil) {
                                    
                                    //NSJSONSerialization解析
                                    
                                    NSDictionary *dic1 =[NSJSONSerialization JSONObjectWithData:response1 options:NSJSONReadingMutableLeaves error:nil];
                                    
                                    //                    NSLog(@"\\\\\\\\\\\\\\dic0 =%@",dic1);
                                    
                                    appList=dic1[@"daily"];
                                    
                                    
                                    
                                    //                        NSLog(@"\\\\\\\\\\\\\%@",appList);
                                    
                                    
                                    
                                    assetStr = appList[@"originalid"];
                                    assetStr1 = appList[@"caption"];
                                    assetStr2 = appList[@"imageurl"];
                                    assetStr3 = appList[@"_class"];
                                    assetStr4 = appList[@"originalid"];
                                                                       //每日一图
                                    UIImageView *dailV = [[UIImageView alloc]initWithFrame:CGRectMake(8, 730-10+60-36+0, 304, 214)];
                                    [ dailV setImageWithURL:[NSURL URLWithString:appList[@"imageurl"]] placeholderImage:[UIImage imageNamed:@""]];
                                                                       btn.frame = CGRectMake(8, 730-10+60-36+0, 304, 214);
                                    
                                    //                    [btn setBackgroundColor:[UIColor yellowColor] ];
                                    UILabel *label3 = [[UILabel alloc]initWithFrame:CGRectMake(20, 730+202-10+4+4+60-36+0, 280, 36)];
                                    label3.font = [UIFont systemFontOfSize:14];
                                    label3.backgroundColor =[UIColor whiteColor];
                                    label3.text =appList[@"caption"];
                                    label3.textAlignment=0;
                                    [scrollV addSubview:label3];
                                    
                                    [scrollV addSubview:dailV];
                                }
                            }
                            
                            
                            
                            if (i>11&&i<20) {
                                
                                btn.frame = CGRectMake(5+155*(i%2), 994+37*((i-12)/2)+30-10+0-36+60, 155, 37);
                                
                                
                                UILabel *label3 = [[UILabel alloc]initWithFrame:CGRectMake(24+155*(i%2), 994+37*((i-12)/2)+30-10+60-36+8+0, 125, 35)];
                                //                        label3.backgroundColor = [UIColor redColor];
                                //                        label3.font = [UIFont fontWithName:@"Helvetica" size:16];
                                
                                
                                label3.textColor = [UIColor blackColor];;
                                label3.text =@"";
                                label3.font = [UIFont systemFontOfSize:14];
                                [scrollV addSubview:label3];
                                
                                //                        label3.backgroundColor = [UIColor redColor];
                                
                                [keyLabels addObject:label3];
                                
                                
                                for (int i=0; i<keyLabels.count; i++) {
                                    UILabel *lab =keyLabels[i];
                                    lab.backgroundColor = [UIColor whiteColor];
                                    lab.text =titleKeyArr[i];
                                    
                                }
                                
                                
                            }
                            if (i==20) {
                                
                                btn.frame = CGRectMake(5, 1137+30-10+60-36+10+10+0, 310, 45);
                                UILabel *label3 = [[UILabel alloc]initWithFrame:CGRectMake(24, 1137+30-10+60-36+10+10+0, 290, 35)];
                                label3.backgroundColor = [UIColor whiteColor];
                                //                        label3.font = [UIFont fontWithName:@"Helvetica" size:16];
                                
                                
                                label3.textColor = [UIColor colorWithHexString:@"#3399cc"];;
                                label3.text =@"换一批>>";
                                [scrollV addSubview:label3];
                                
                                
                            }
                            UILabel *label3 = [[UILabel alloc]initWithFrame:CGRectMake(16, 730+202-10+55+60+5-36+0, 290, 35)];
                            label3.backgroundColor =[UIColor whiteColor];
                            label3.text =@"热门标签";
                            [scrollV addSubview:label3];
                            
                            btn.tag =i;
                            //            btn.tintColor = [UIColor rColor];
                            //        [btn se forState:UIControlStateSelected];
                            //        seArr = @[arr1,arr2,arr3,arr4,arr5,arr6,@"http://m.quanjing.com/topic/l01.html",
                            //                  @"http://m.quanjing.com/topic/l01.html",
                            //                  @"http://m.quanjing.com/topic/l01.html",@"http://m.quanjing.com/topic/l01.html",@"http://m.quanjing.com/topic/l01.html",
                            //                  @"美女",@"马尔代夫",@"美食",@"九寨沟",@"法拉利",@"宝宝",@"家居",@"美女",@"动物",@"壁纸"];
                            seArr = @[@"旅游",@"家居",@"汽车",@"美食",@"时尚",@"美图",@"http://m.quanjing.com/topic/l01.html",
                                      @"http://m.quanjing.com/topic/l01.html",
                                      @"http://m.quanjing.com/topic/l01.html",@"http://m.quanjing.com/topic/l01.html",@"http://m.quanjing.com/topic/l01.html",
                                      @"",@"马尔代夫",@"美食",@"九寨沟",@"法拉利",@"宝宝",@"家居",@"美女",@"动物",@"壁纸"];
                            
                            
                            [btn addTarget:self action:@selector(btnclick:) forControlEvents:UIControlEventTouchUpInside];
                            [_searchButton addTarget:self action:@selector(onSearchButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
                            
                            [scrollV addSubview:btn];
                            [scrollV addSubview:_searchButton];
                            [scrollV addSubview:_keywordTextField];
                            
                            for (UIView* subView in self.view.subviews)
                                
                            {
                                if (![subView isKindOfClass:[UITextField class]])
                                {
                                    UITapGestureRecognizer* singleRecognizer;
                                    singleRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(SingleTap)];
                                    //点击的次数
                                    singleRecognizer.numberOfTapsRequired = 1; // 单击
                                    
                                    //给self.view添加一个手势监测；
                                    
                                    subView.userInteractionEnabled =YES;
                                    [subView addGestureRecognizer:singleRecognizer];
                                }
                                
                            }
                            
                            
                            
                            
                        }
                    }
                }
            }
            
            [button setSelected:NO];
        }
    }

   
    
}

-(void)updadekeyLabel
{
//    NSLog(@"kkkkkkkkk%d",keyLabels.count);
    for (int i=0; i<keyLabels.count; i++) {
        UILabel *lab =keyLabels[i];

        lab.text =titleKeyArr[i];

    }
    
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    _keywordTextField.text=@"";
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    
}

- (BOOL)prefersStatusBarHidden
{
    return NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)onSearchButtonPressed:(UIButton *)sender
{
    [self performSearch];
    [_keywordTextField resignFirstResponder];
}

- (IBAction)onBackgroundTapped:(id)sender
{
    [_keywordTextField resignFirstResponder];
}

#pragma -mark 搜索的代理方法
- (void)performSearch
{
    NSString* keyword = _keywordTextField.text;
    if (keyword == nil || keyword.length == 0)
    {
        [_keywordTextField resignFirstResponder];
        return;
    }
    
    
    OWTSearchResultsViewCon* searchResultsViewCon = [[OWTSearchResultsViewCon alloc] initWithNibName:nil bundle:nil];
    //
    [searchResultsViewCon setKeyword:keyword ];
    [self.navigationController pushViewController:searchResultsViewCon animated:YES];
    
}

#pragma mark - TextField delegate


- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (_keywordTextField == textField) {
        [self performSearch];
        [_keywordTextField resignFirstResponder];
    }
    return YES;
}

-(void)SingleTap
{
    [_keywordTextField resignFirstResponder];
}
@end
