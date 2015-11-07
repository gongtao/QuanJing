//
//  LJAssetEditView.m
//  Weitu
//
//  Created by qj-app on 15/5/27.
//  Copyright (c) 2015年 SparkingSoft Co., Ltd. All rights reserved.
//

#import "LJAssetEditView.h"
#import "LJUIController.h"
#import "WTCommon.h"
#import "OWTAssetManager.h"
#import "SVProgressHUD+WTError.h"
#import "OWTUserManager.h"
#import "OWTAssetData.h"
@interface LJAssetEditView () <NSURLConnectionDataDelegate, UIAlertViewDelegate, UITextViewDelegate>

@end

@implementation LJAssetEditView

{
	UIScrollView * _scroll;
	UILabel * _label1;
	UILabel * _label2;
	UILabel * _label3;
	//    UITextField *_text1;
	UITextView * _text1;
	UILabel * _placeholderLabel1;
	//    UITextField *_text2;
	UILabel * _placeholderLabel2;
	UITextView * _text2;
	//    UITextField *_text3;
	UITextView * _text3;
	UILabel * _placeholderLabel3;
	UIView * _bool;
	UIButton * _delete;
	UISwitch * _switch;
	NSMutableData * _data;
}
- (id)initWithAsset:(OWTAsset *)asset deletionAllowed:(BOOL)deletionAllowed
{
	self = [super init];
	
	if (self) {
		_deletionAllowed = deletionAllowed;
		[self setupWithAsset:asset];
	}
	return self;
}

- (void)setupWithAsset:(OWTAsset *)asset
{
	_asset = asset;
	
	self.title = @"编辑图片";
	
	UIBarButtonItem * cancelButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消"
		style:UIBarButtonItemStyleDone
		target:self
		action:@selector(canceled)];
	self.navigationItem.hidesBackButton = TRUE;
	self.navigationItem.leftBarButtonItem = cancelButtonItem;
	
	UIBarButtonItem * saveButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"保存"
		style:UIBarButtonItemStyleDone
		target:self
		action:@selector(saved)];
	self.navigationItem.rightBarButtonItem = saveButtonItem;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	// Do any additional setup after loading the view from its nib.
	_data = [[NSMutableData alloc]init];
	
	[self customUI];
	[self getResouceData1];
}

- (void)getResouceData1
{
	RKObjectManager * um = [RKObjectManager sharedManager];
	
	[um getObject:nil path:[NSString stringWithFormat:@"assets/%@/edit", _asset.assetID] parameters:nil success:^(RKObjectRequestOperation * operation, RKMappingResult * mappingResult) {
		NSDictionary * dict = mappingResult.dictionary;
		OWTAssetData * asset = dict[@"asset"];
		_text1.text = asset.caption;
		
		if (asset.caption.length > 0)
			_placeholderLabel1.hidden = YES;
		_text2.text = asset.keywords;
		
		if (asset.keywords.length > 0)
			_placeholderLabel2.hidden = YES;
		_text3.text = asset.position;
		
		if (asset.position.length > 0)
			_placeholderLabel3.hidden = YES;
		NSNumber * ret = asset.isPrivate;
		NSInteger i = ret.intValue;
		
		if (i == 1)
			_switch.on = 0;
		else
			_switch.on = 1;
	} failure:^(RKObjectRequestOperation * operation, NSError * error) {}];
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (void)customUI
{
	_scroll = [[UIScrollView alloc]initWithFrame:self.view.frame];
	_scroll.backgroundColor = GetThemer().themeColorBackground;
	_scroll.contentSize = CGSizeMake(SCREENWIT, 500);
	[self.view addSubview:_scroll];
	UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onTapClick)];
	[_scroll addGestureRecognizer:tap];
	_label1 = [LJUIController createLabelWithFrame:CGRectMake(5, 0, 60, 30) Font:12 Text:@"标题"];
	[_scroll addSubview:_label1];
	_label2 = [LJUIController createLabelWithFrame:CGRectMake(5, 110, 60, 30) Font:12 Text:@"标签"];
	[_scroll addSubview:_label2];
	_label3 = [LJUIController createLabelWithFrame:CGRectMake(5, 220, 60, 30) Font:12 Text:@"位置"];
	[_scroll addSubview:_label3];
	
	_text1 = [[UITextView alloc]initWithFrame:CGRectMake(0, 30, SCREENWIT, 80) textContainer:nil];
	_text1.delegate = self;
	_text1.font = [UIFont systemFontOfSize:15];
	[_scroll addSubview:_text1];
	_placeholderLabel1 = [[UILabel alloc]initWithFrame:CGRectMake(0, 30, 80, 20)];
	_placeholderLabel1.font = [UIFont systemFontOfSize:14];
	_placeholderLabel1.text = @"请输入标题";
	_placeholderLabel1.textColor = [UIColor grayColor];
	[_text1 addSubview:_placeholderLabel1];
	_text2 = [[UITextView alloc]initWithFrame:CGRectMake(0, 140, SCREENWIT, 80) textContainer:nil];
	_text2.delegate = self;
	_text2.font = [UIFont systemFontOfSize:15];
	[_scroll addSubview:_text2];
	_text3 = [[UITextView alloc]initWithFrame:CGRectMake(0, 250, SCREENWIT, 80) textContainer:nil];
	_text3.delegate = self;
	_text3.font = [UIFont systemFontOfSize:15];
	[_scroll addSubview:_text3];
	_placeholderLabel3 = [[UILabel alloc]initWithFrame:CGRectMake(0, 30, 80, 20)];
	_placeholderLabel3.font = [UIFont systemFontOfSize:14];
	_placeholderLabel3.text = @"请输入位置";
	_placeholderLabel3.textColor = [UIColor grayColor];
	[_text3 addSubview:_placeholderLabel3];
	
	_bool = [[UIView alloc]initWithFrame:CGRectMake(0, 355, SCREENWIT, 40)];
	_bool.backgroundColor = [UIColor whiteColor]; [_scroll addSubview:_bool];
	UILabel * label = [LJUIController createLabelWithFrame:CGRectMake(10, 10, 40, 20) Font:14 Text:@"私有图片"];
	[_bool addSubview:label];
	_switch = [[UISwitch alloc]initWithFrame:CGRectMake(SCREENWIT - 60, 5, 30, 20)];
	[_bool addSubview:_switch];
	
	_delete = [UIButton buttonWithType:UIButtonTypeSystem];
	[_delete setFrame:CGRectMake(0, 410, SCREENWIT, 50)];
	[_delete setTitle:@"删除" forState:UIControlStateNormal];
	[_delete setBackgroundColor:[UIColor whiteColor]];
	[_delete setTintColor:[UIColor blackColor]];
	[_delete addTarget:self action:@selector(delete) forControlEvents:UIControlEventTouchUpInside];
	[_scroll addSubview:_delete];
}

#pragma textViewDelegate
- (void)textViewDidChange:(UITextView *)textView
{}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
	if (textView == _text2) {
		if (![text isEqualToString:@""])
			_placeholderLabel2.hidden = YES;
			
		if ([text isEqualToString:@""] && (range.location == 0) && (range.length == 1))
			_placeholderLabel2.hidden = NO;
			
	}
	else if (textView == _text1) {
		if (![text isEqualToString:@""])
			_placeholderLabel1.hidden = YES;
			
		if ([text isEqualToString:@""] && (range.location == 0) && (range.length == 1))
			_placeholderLabel1.hidden = NO;
			
			
	}
	else {
		if (![text isEqualToString:@""])
			_placeholderLabel3.hidden = YES;
			
		if ([text isEqualToString:@""] && (range.location == 0) && (range.length == 1))
			_placeholderLabel3.hidden = NO;
			
			
	}
	return YES;
}

- (void)onTapClick
{
	[self.view endEditing:YES];
}

- (void)canceled
{
	if (_doneAction != nil)
		_doneAction(nWTDoneTypeCancelled);
}

- (void)saved
{
	[self.view endEditing:YES];
	NSString * updatedCaption = _text1.text;
	
	if ((updatedCaption == nil) || (updatedCaption.length == 0)) {
		[SVProgressHUD showErrorWithStatus:@"请输入图片标题"];
		return;
	}
	
	BOOL isPrivate;
	
	if (_switch.on == YES)
		isPrivate = YES;
	else
		isPrivate = NO;
	OWTAssetManager * am = GetAssetManager();
	
	[SVProgressHUD show];
	[am updateAsset:_asset withCaption:_text1.text isPrivate:isPrivate islocation:_text3.text iskeywords:_text2.text albums:nil
	success:^{
		[SVProgressHUD dismiss];
		
		if (_doneAction != nil)
			_doneAction(nWTDoneTypeUpdated);
	}
	failure:^(NSError * error) {
		[SVProgressHUD dismiss];
		
		if (_doneAction != nil)
			_doneAction(nWTDoneTypeUpdated);
			
	}];
}

- (void)delete
{
	UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"确定要删除这张照片吗？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
	
	[alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 1) {
		[SVProgressHUD showWithStatus:@"正在删除图片"];
		OWTAssetManager * am = GetAssetManager();
		[am deleteAsset:_asset
		success:^{
			[SVProgressHUD showSuccessWithStatus:@"删除成功"];
			
			if (_doneAction != nil)
				_doneAction(nWTDoneTypeDeleted);
		}
		failure:^(NSError * error) {
			[SVProgressHUD showError:error];
		}];
	}
}

@end
