//
//  advertisetionViewController.m
//  Weitu
//
//  Created by qj-app on 15/10/19.
//  Copyright © 2015年 SparkingSoft Co., Ltd. All rights reserved.
//

#import "advertisetionViewController.h"
#import "OWTMainViewCon.h"
#import "WTCommon.h"
#import "OWTAppDelegate.h"
#import "StartViewController.h"
@interface advertisetionViewController ()<NSURLConnectionDataDelegate>

@end

@implementation advertisetionViewController
{
    NSMutableData *_data;
    UIImageView *advertisetion;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _data=[[NSMutableData alloc]init];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    [self setUpView];
}
- (void)showInWindow:(UIWindow *)window {
    [window addSubview:self.view];
}

-(void)setUpView
{

    UIImageView *imageView=[LJUIController createImageViewWithFrame:CGRectMake(0, 0, SCREENWIT, SCREENHEI) imageName:@"开机画面6s.png"];
//    imageView.backgroundColor=[UIColor whiteColor];
    [self.view addSubview:imageView];
    advertisetion=[LJUIController createImageViewWithFrame:CGRectMake(0, 0, SCREENWIT, SCREENHEI-120) imageName:@""];
//    advertisetion.backgroundColor=[UIColor whiteColor];
    [imageView addSubview:advertisetion];
    NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
    NSString *imgUrl=[userDefaults objectForKey:@"ImgUrl"];
    if (imgUrl!=nil) {
        [advertisetion setImageWithURL:[NSURL URLWithString:imgUrl]];
    }

    NSURLConnection *connection=[[NSURLConnection alloc]initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://api.tiankong.com/qjapi/homead"]] delegate:self];
}
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [_data setLength:0];
}
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [_data appendData:data];
}
-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
NSArray *arr=[NSJSONSerialization JSONObjectWithData:_data options:NSJSONReadingMutableContainers error:nil];
    NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
    NSDictionary *dict=arr[0];
    NSString *str=[userDefaults objectForKey:@"id"];
    NSString *imgUrl=[userDefaults objectForKey:@"ImgUrl"];
    if (imgUrl==nil) {
        [advertisetion setImageWithURL:[NSURL URLWithString:dict[@"ImgUrl"]]];
    }
    if ([str isEqualToString:@"0"]) {
        [userDefaults removeObjectForKey:@"ImgUrl"];
        [userDefaults removeObjectForKey:@"id"];
    }else {
    if (![str isEqualToString:dict[@"id"]]) {
        [userDefaults setValue:dict[@"id"] forKey:@"id"];
        [userDefaults setValue:dict[@"ImgUrl"] forKey:@"ImgUrl"];
    }}
    [userDefaults synchronize];
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    [self performSelector:@selector(putIn) withObject:nil afterDelay:3];
}
-(void)putIn
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
    NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
    NSString *str=[userDefaults objectForKey:@"version"];
    NSString *str1= [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString*)kCFBundleVersionKey];
    if ([str isEqualToString:str1]) {
        OWTMainViewCon *mainView=[[OWTMainViewCon alloc]initWithNibName:nil bundle:nil];
        mainView.tabBar.hidden=YES;
        GetAppDelegate().window.rootViewController=mainView;
        [self presentViewController:mainView animated:NO completion:nil];
    }else
    {
        StartViewController *svc=[[StartViewController alloc]init];
                GetAppDelegate().window.rootViewController=svc;
        [userDefaults setObject:str1 forKey:@"version"];
        [self presentViewController:svc animated:NO completion:nil];

    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
