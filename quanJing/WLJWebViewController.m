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
#import "QuanJingSDK.h"
#import <NBUAdditions.h>

@interface WLJWebViewController () <UIGestureRecognizerDelegate, UIScrollViewDelegate, UIWebViewDelegate>{
	NSString * _articleTitle;
	TFHpple * _xpathParser;
	DealErrorPageViewController * _vc;
	CGRect _viewRect;
	BOOL _ifCustom;
	
	UIActivityIndicatorView * _activityIndicator;
}

@property (nonatomic, strong) UIWebView * webView;
@property (nonatomic, strong) UIScrollView * imgScrollView;

@end

@implementation WLJWebViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	
	if (self) {
		// Custom initialization
	}
	return self;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	[UIWebView setDefaultUserAgent:[[QJInterfaceManager sharedManager] userAgent]];
	
	self.view.backgroundColor = [UIColor whiteColor];
	_viewRect = self.view.frame;
	self.title = @"全景图片";
	
	if (![NetStatusMonitor isExistenceNetwork]) {
		_vc = [[DealErrorPageViewController alloc]init];
		[self addChildViewController:_vc];
		_vc.view.frame = CGRectMake(_vc.view.frame.origin.x, _vc.view.frame.origin.y, _vc.view.frame.size.width, _vc.view.frame.size.height + 20);
		__weak WLJWebViewController * weakSelf = self;
		[self.view addSubview:_vc.view];
		_vc.getRefreshAction = ^{
			_ifCustom = YES;
			[weakSelf goRefresh];
		};
	}
	else {
		[self goRefresh];
	}
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated
{
	[SVProgressHUD dismiss];
}

- (void)viewWillAppear:(BOOL)animated
{
	OWTTabBarHider * tabHider = [[OWTTabBarHider alloc]init];
	
	[tabHider showTabBar];
}

#pragma mark - Private

- (void)goRefresh
{
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		NSError * error = nil;
		// html解析
		NSURL * url = [NSURL URLWithString:_urlString];
		NSString * htmlString = [NSString stringWithContentsOfURL:url
		encoding:NSUTF8StringEncoding
		error:&error];
		
		if (error)
            return;
		
		NSLog(@"%@", htmlString);
		
		NSData * htmlData = [htmlString dataUsingEncoding:NSUTF8StringEncoding];
		_xpathParser = [[TFHpple alloc] initWithHTMLData:htmlData];
		NSArray * elements = [_xpathParser searchWithXPathQuery:@"//title"];	// get the
		
		// 网络异常的时候，处理指针异常
		if (elements.count < 1)
			return;
		
		TFHppleElement * element = [elements objectAtIndex:0];
		NSString * title = [element content];
		_articleTitle = [title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		NSLog(@"result = %@", _articleTitle);
	});
    
	self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, _ifCustom ? 10 : 0, self.view.bounds.size.width, _ifCustom ? self.view.bounds.size.height : self.view.bounds.size.height)];
	_webView.delegate = self;
	[self.view addSubview:self.webView];
	[self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_urlString]]];
	
	UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
	[button setBackgroundImage:[UIImage imageNamed:@"webShare1.png"]
	forState:UIControlStateNormal];
	[button addTarget:self action:@selector(shareAsset)
	forControlEvents:UIControlEventTouchUpInside];
	button.frame = CGRectMake(0, 0, 20, 20);
	
	UIBarButtonItem * menuButton = [[UIBarButtonItem alloc] initWithCustomView:button];
	self.navigationItem.rightBarButtonItem = menuButton;
}

- (void)touchUpImageIndex:(NSInteger)index
{
	NSMutableArray * imagesUrl = [[NSMutableArray alloc]init];
	
	NSMutableArray * FSArr = [[NSMutableArray alloc]init];
	
	NSArray * imgUrlArray = [_xpathParser searchWithXPathQuery:@"//@src"];
	
	for (int i = 1; i < imgUrlArray.count - 2; i++) {
		[imagesUrl addObject:[[imgUrlArray objectAtIndex:i] content]];
		
		FSBasicImage * firstPhoto = [[FSBasicImage alloc] initWithImageURL:[NSURL URLWithString:[[imgUrlArray objectAtIndex:i]content]] name:_titleS];
		[FSArr addObject:firstPhoto];
	}
	
	FSBasicImageSource * photoSource = [[FSBasicImageSource alloc] initWithImages:FSArr];
	
	self.imageViewController = [[FSImageViewerViewController alloc] initWithImageSource:photoSource imageIndex:index withViewController:nil];
	
	self.imageViewController.navigationController.navigationBarHidden = YES;
	
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
		[self.navigationController presentViewController:_imageViewController animated:YES completion:nil];
	else
		[self.navigationController pushViewController:_imageViewController animated:YES];
}

- (void)shareAsset
{
	[SVProgressHUD showWithStatus:@"准备图片中..." maskType:SVProgressHUDMaskTypeBlack];
	
	SDWebImageManager * manager = [SDWebImageManager sharedManager];
	NSURL * url = [NSURL URLWithString:self.assetUrl];
	[manager downloadWithURL:url
	options:SDWebImageHighPriority
	progress:nil
	completed:^(UIImage * image, NSError * error, SDImageCacheType cacheType, BOOL finished) {
		[SVProgressHUD dismiss];
		[UMSocialData defaultData].extConfig.wxMessageType = UMSocialWXMessageTypeNone;
		[UMSocialData defaultData].extConfig.qqData.qqMessageType = UMSocialQQMessageTypeDefault;
		[UMSocialData defaultData].extConfig.wechatSessionData.url = [NSString stringWithFormat:@"%@&d=1", self.urlString];
		[UMSocialData defaultData].extConfig.wechatTimelineData.url = [NSString stringWithFormat:@"%@&d=1", self.urlString];
		[UMSocialData defaultData].extConfig.qqData.url = [NSString stringWithFormat:@"%@&d=1", self.urlString];
		[UMSocialData defaultData].extConfig.qzoneData.url = [NSString stringWithFormat:@"%@&d=1", self.urlString];
		[UMSocialData defaultData].extConfig.qqData.title = _articleTitle;
		[UMSocialData defaultData].extConfig.qzoneData.title = _articleTitle;
		[UMSocialData defaultData].extConfig.wechatSessionData.title = _articleTitle;
		[UMSocialData defaultData].extConfig.wechatTimelineData.title = _articleTitle;
		[UMSocialSnsService presentSnsIconSheetView:self
		appKey:nil
		shareText:nil
		shareImage:image
		shareToSnsNames:[NSArray arrayWithObjects:UMShareToWechatSession, UMShareToWechatTimeline, UMShareToSina, UMShareToWechatFavorite, UMShareToQzone, UMShareToQQ, UMShareToSms, nil]
		delegate:nil];
	}];
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	[SVProgressHUD dismiss];
	
	NSString * js = @"\
    var elements = document.getElementsByTagName('img');\
    for (var i = 0; i < elements.length - 1; i++)\
    {\
        var img = elements[i];\
        img.value = i;\
        img.onclick = function() {\
            var url = this.src + '_imageIndex_' + this.value;\
            window.open(url);\
        };\
    }";
    
	NSString * result = [webView stringByEvaluatingJavaScriptFromString:js];
	
	NSLog(@"%@", result);
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [SVProgressHUD showWithStatus:@"正在加载"];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [SVProgressHUD showErrorWithStatus:@"加载失败"];
	NSLog(@"didFailLoadWithError");
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
	if (navigationType == UIWebViewNavigationTypeOther) {
		NSString * indexUrl = request.URL.absoluteString;
		
		// 点击图片
		if ([indexUrl rangeOfString:@"_imageIndex_"].location != NSNotFound) {
			NSArray * array = [indexUrl componentsSeparatedByString:@"_imageIndex_"];
			
			if (array && (array.count == 2)) {
				NSInteger index = [(NSString *)array[1] integerValue];
				[self touchUpImageIndex:index];
				return NO;
			}
		}
		return YES;
	}
	
	return YES;
}

@end
