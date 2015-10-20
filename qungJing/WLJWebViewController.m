//
//  WLJWebViewController.m
//  Html_Hpple
//
//  Created by 王霖 on 14-5-27.
//  Copyright (c) 2014年 com.wangan. All rights reserved.
//

#import "WLJWebViewController.h"

#import "TFHpple.h"
#import "FSBasicImage.h"
#import "FSBasicImageSource.h"
#import "MBProgressHUD.h"
#import "UMSocial.h"
#import <SDWebImage/SDWebImageManager.h>
#import "DealErrorPageViewController.h"
#import "NetStatusMonitor.h"
#import "OWTTabBarHider.h"
@interface WLJWebViewController ()<UIGestureRecognizerDelegate, UIScrollViewDelegate,UIWebViewDelegate>{
    BOOL isOpen;
    
    NSString *Tstr;
    DealErrorPageViewController *_vc;
    CGRect _viewRect;
    BOOL _ifCustom;
    
}

@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) UIScrollView *imgScrollView;

@end

@implementation WLJWebViewController
{
    UIActivityIndicatorView *_activityIndicator;
    
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        //        self.view.backgroundColor=[UIColor whiteColor];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor whiteColor];
    _viewRect = self.view.frame;
    self.title=@"全景图片";
    if (![NetStatusMonitor isExistenceNetwork]) {
        _vc= [[DealErrorPageViewController alloc]init];
        [self addChildViewController:_vc];
        _vc.view.frame = CGRectMake(_vc.view.frame.origin.x, _vc.view.frame.origin.y, _vc.view.frame.size.width, _vc.view.frame.size.height+20);
        __weak WLJWebViewController *weakSelf = self;
        [self.view addSubview:_vc.view];
        _vc.getRefreshAction = ^{
            _ifCustom = YES;
            [weakSelf goRefresh];
        };
        
    }else{
        
        [self goRefresh];
    }
    
    
    
}

-(void)goRefresh
{
    if ([NetStatusMonitor isExistenceNetwork]) {
        [_vc removeFromParentViewController];
        [_vc.view removeFromSuperview];
        //self.view.frame = _viewRect;
    }
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:self.urlString]];
    
    NSURL *url =[NSURL URLWithString:_urlString];
    //
    //html解析
    NSString *htmlString=[NSString stringWithContentsOfURL:url encoding: NSUTF8StringEncoding error:nil];
    NSData *htmlData=[htmlString dataUsingEncoding:NSUTF8StringEncoding];
    TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:htmlData];
    NSArray *elements  = [xpathParser searchWithXPathQuery:@"//title"]; // get the
    //网络异常的时候，处理指针异常
    if (elements.count<1) {
        return;
    }
    TFHppleElement *element = [elements objectAtIndex:0];
    Tstr = [element content];
    NSLog(@"result = %@",Tstr);
    
    
    
    
    
    
    isOpen = NO;
    self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, _ifCustom?10:0, self.view.bounds.size.width, _ifCustom?self.view.bounds.size.height:self.view.bounds.size.height-64-42)];
    _webView.delegate=self;
    [self.view addSubview:self.webView];
    //3self.view.backgroundColor = [UIColor redColor];
    //    self.imgScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, _viewRect.origin.y, 320, 900)];
    //    self.imgScrollView.pagingEnabled = YES;
    //    self.imgScrollView.delegate = self;
    //    self.imgScrollView.backgroundColor = [UIColor colorWithRed:79.0/255.0 green:79.0/255.0 blue:79.0/255.0 alpha:0.7];
    //    self.imgScrollView.tag = 101;
    
    //    self.view.backgroundColor = [UIColor whiteColor];
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchUpImage:)];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    tapGestureRecognizer.numberOfTouchesRequired = 1;
    tapGestureRecognizer.delegate = self;
    
    [self.view addGestureRecognizer:tapGestureRecognizer];
    
    
    [self.webView loadRequest:request];
    
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setBackgroundImage:[UIImage imageNamed:@"webShare1.png"]
                      forState:UIControlStateNormal];
    [button addTarget:self action:@selector(shareAsset)
     forControlEvents:UIControlEventTouchUpInside];
    button.frame = CGRectMake(0, 0, 20, 20);
    
    UIBarButtonItem *menuButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.rightBarButtonItem = menuButton;
}
-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    [SVProgressHUD dismiss];
}
-(void)webViewDidStartLoad:(UIWebView *)webView
{
    //    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [SVProgressHUD show];
    [self performSelector:@selector(dis) withObject:nil afterDelay:3];
}

//-(void)viewDidAppear:(BOOL)animated
//{
//    if (![NetStatusMonitor isExistenceNetwork]) {
//        NSLog(@"到底有没有 王");
//    }
//}

-(void)dealloc
{
    
    
}
-(void)dis
{
    [SVProgressHUD dismiss];
}
-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [SVProgressHUD dismiss];
    NSLog(@"didFailLoadWithErrora");
}
//既然给view添加单指单击手势，webView的webBrowser也识别这手势，所以要两个手势同时识别，这样，view才能响应手势
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}
-(void)viewWillAppear:(BOOL)animated
{
    OWTTabBarHider *tabHider=[[OWTTabBarHider alloc]init];
    [tabHider showTabBar];
}
-(void)touchUpImage:(UITapGestureRecognizer *)gestureRecognizer{
    BOOL isLoad = NO;
    
    NSString *url = nil;
    NSData *data = nil;
    NSMutableArray *imagesUrl = [[NSMutableArray alloc]init];
    
    
    
    NSMutableArray *FSArr = [[NSMutableArray alloc]init];
    url = _urlString;
    if (!isLoad) {
        
        isLoad = YES;
        
        //        NSLog(@"获得数据");
        
        
        
        
        
        data = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
        
        
        
        
        
        
        //html解析
        NSString *htmlString=[NSString stringWithContentsOfURL:[NSURL URLWithString:url] encoding: NSUTF8StringEncoding error:nil];
        NSData *htmlData=[htmlString dataUsingEncoding:NSUTF8StringEncoding];
        TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:htmlData];
        
        NSArray *imgUrlArray = [xpathParser searchWithXPathQuery:@"//@src"]; // get the title
        
        
        
        
        
        
        
        
        
        
        for (int i=2; i<imgUrlArray.count-1; i++) {
            
            [imagesUrl addObject: [[imgUrlArray objectAtIndex:i]content]];
            
            FSBasicImage *firstPhoto = [[FSBasicImage alloc] initWithImageURL:[NSURL URLWithString:[[imgUrlArray objectAtIndex:i]content]] name:_titleS];
            [FSArr addObject:firstPhoto];
            
        }
        
        
        
        
        
    }
    
    FSBasicImageSource *photoSource = [[FSBasicImageSource alloc] initWithImages:FSArr];
    if (!isOpen) {
        if ([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]) {
            CGPoint touchPoint = [gestureRecognizer locationInView:self.view];
            NSString *imgURL  = [NSString stringWithFormat:@"document.elementFromPoint(%f, %f).src", touchPoint.x, touchPoint.y];
            NSString *urlTOstring = [(UIWebView *)self.webView stringByEvaluatingJavaScriptFromString:imgURL];
            
            //这个知道是什么图片，图片网址也知道了
            
            //            NSLog(@"脚本执行后：%@",urlTOstring);
            if ([urlTOstring hasSuffix:@"jpg"]) {
                
                
                NSInteger traceTag = -1;
                for (int i = 0; i < [imagesUrl count]; i++) {
                    //得到图片的相对位置
                    if ([[imagesUrl objectAtIndex:i] isEqualToString:urlTOstring]) {
                        traceTag = i;
                        
                        break;
                    }
                }
                self.imageViewController = [[FSImageViewerViewController alloc] initWithImageSource:photoSource imageIndex:traceTag withViewController:nil];
                //    [self.imageViewController moveToImageAtIndex:0 animated:NO];
                
                
                self.imageViewController.navigationController.navigationBarHidden =YES;
                if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                    [self.navigationController presentViewController:_imageViewController animated:YES completion:nil];
                }
                else {
                    [self.navigationController pushViewController:_imageViewController animated:YES];
                }
                
                
            }
        }
    }
}


- (void)shareAsset
{
    [SVProgressHUD showWithStatus:@"准备图片中..." maskType:SVProgressHUDMaskTypeBlack];
    
    SDWebImageManager* manager = [SDWebImageManager sharedManager];
    NSURL* url = [NSURL URLWithString:self.assetUrl];
    [manager downloadWithURL:url
                     options:SDWebImageHighPriority
                    progress:nil
                   completed:^(UIImage* image, NSError* error, SDImageCacheType cacheType, BOOL finished){
                       [SVProgressHUD dismiss];
                       [UMSocialData defaultData].extConfig.wxMessageType = UMSocialWXMessageTypeNone;
                       [UMSocialData defaultData].extConfig.qqData.qqMessageType = UMSocialQQMessageTypeDefault;
                       [UMSocialData defaultData].extConfig.wechatSessionData.url =  [NSString stringWithFormat:@"%@&d=1",self.urlString];
                       [UMSocialData defaultData].extConfig.wechatTimelineData.url =  [NSString stringWithFormat:@"%@&d=1",self.urlString];
                       [UMSocialData defaultData].extConfig.qqData.url =  [NSString stringWithFormat:@"%@&d=1",self.urlString];
                       [UMSocialData defaultData].extConfig.qzoneData.url =  [NSString stringWithFormat:@"%@&d=1",self.urlString];
                       [UMSocialData defaultData].extConfig.qqData.title = [Tstr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                       [UMSocialData defaultData].extConfig.qzoneData.title = [Tstr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                       [UMSocialData defaultData].extConfig.wechatSessionData.title = [Tstr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                       [UMSocialData defaultData].extConfig.wechatTimelineData.title = [Tstr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
//                       UMSocialUrlResource *urlResource = [[UMSocialUrlResource alloc] initWithSnsResourceType:UMSocialUrlResourceTypeImage url:
//                                                           [NSString stringWithFormat:@"%@&d=1",self.urlString]];
//                       [[UMSocialData defaultData].urlResource setResourceType:UMSocialUrlResourceTypeImage url:[NSString stringWithFormat:@"%@&d=1",self.urlString]];
                       //                       [UMSocialData defaultData].extConfig.sinaData.urlResource=urlResource;
                       //                       [UMSocialData defaultData].extConfig.sinaData.shareImage=image;
                       //                       [UMSocialData defaultData].extConfig.sinaData.shareText=[Tstr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                       [UMSocialSnsService presentSnsIconSheetView:self
                                                            appKey:nil
                                                         shareText:nil
                                                        shareImage:image
                                                   shareToSnsNames:[NSArray arrayWithObjects:UMShareToWechatSession,UMShareToWechatTimeline,UMShareToSina,UMShareToWechatFavorite,UMShareToQzone,UMShareToQQ,UMShareToSms,nil]
                                                          delegate:nil];

                       
                   }];
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillDisappear:(BOOL)animated
{
    [SVProgressHUD dismiss];
}
@end
