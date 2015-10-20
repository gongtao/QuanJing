//
//  LJPickerViewController.m
//  Weitu
//
//  Created by qj-app on 15/6/4.
//  Copyright (c) 2015年 SparkingSoft Co., Ltd. All rights reserved.
//

#import "LJPickerViewController.h"
#import "LJUIController.h"
@interface LJPickerViewController ()<UIPickerViewDataSource,UIPickerViewDelegate>

@end

@implementation LJPickerViewController
{
    UIPickerView *_pickerView;
    NSInteger currentRow0;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        _dataArray=[[NSArray alloc]init];
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    }
-(void)viewWillAppear:(BOOL)animated
{
    [self setupPickerView];
    [self.navigationController setNavigationBarHidden:YES];
    if (_isArea==YES) {
         _backString1=_dataArray[0][0];
        _backString2= _dataArray[1][currentRow0][0];
    }
    else {
    
        _backString1=_dataArray[0][0];
    }
}
-(void)setupPickerView
{
    UIImageView *imageview=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, SCREENWIT, SCREENHEI)];
    imageview.tag=333;
    imageview.image=_backgroundImage;
    [self.view addSubview:imageview];
    UIView *backgroundView=[[UIView alloc]init];
    backgroundView.tag=333;
    backgroundView.frame=CGRectMake(0, 0, SCREENWIT, SCREENHEI);
    backgroundView.backgroundColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
    UIImageView *imageView=[LJUIController createImageViewWithFrame:CGRectMake(0, SCREENHEI-250, SCREENWIT, 50) imageName:nil];
    imageview.tag=333;
    imageView.backgroundColor=GetThemer().themeColorBackground;
    UIButton *cancel=[LJUIController createButtonWithFrame:CGRectMake(10, 10, 50, 30) imageName:nil title:@"取消" target:self action:@selector(cancelClick)];
    UIButton *certain=[LJUIController createButtonWithFrame:CGRectMake(SCREENWIT-60, 10, 50, 30) imageName:nil title:@"确定" target:self action:@selector(certainClick)];
    certain.tag=333;
    [cancel setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [certain setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [imageView addSubview:cancel];
    [imageView addSubview:certain];
    [backgroundView addSubview:imageView];
    _pickerView=[[UIPickerView alloc]initWithFrame:CGRectMake(0, SCREENHEI-200, SCREENWIT, 240)];
    _pickerView.tag=333;
    _pickerView.delegate=self;
    _pickerView.dataSource=self;
    _pickerView.backgroundColor=[UIColor whiteColor];
    [backgroundView addSubview:_pickerView];
    [self.view addSubview:backgroundView];
    currentRow0=0;
}
-(void)cancelClick
{
    
//    [self dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)certainClick
{
    _doneFunc();
    [self.navigationController popViewControllerAnimated:YES];}
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (component==0) {
        _backString1=_dataArray[component][row];
        currentRow0=row;
        if (_isArea==YES) {
            [pickerView reloadComponent:1];
            _backString2= _dataArray[1][currentRow0][0];
        }
    }else
    {
        _backString2= _dataArray[component][currentRow0][row];
    }

}
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    NSArray *arr=_dataArray[component];
    if (component==0) {
     return arr.count;
    }else{
                return [ _dataArray[1][currentRow0] count];
    }
}
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    if (_dataArray) {
        return _dataArray.count;
    }else
    {
        return 0;
    }
}
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (component==0) {
     return _dataArray[component][row];
        currentRow0=row;
    }else
    {
        return _dataArray[component][currentRow0][row];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewWillDisappear:(BOOL)animated
{
    _isArea=NO;
    for (UIView *view in self.view.subviews) {
        if (view.tag==333) {
            [view removeFromSuperview];
            
        }
    }
    [self.navigationController setNavigationBarHidden:NO];
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
