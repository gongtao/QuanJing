//  FSImageViewer
//
//  Created by Felix Schulze on 8/26/2013.
//  Copyright 2013 Felix Schulze. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "FSImageViewerViewController.h"
#import "FSImageTitleView.h"

#import "OWTImageInfo.h"
#import "UIViewController+WTExt.h"
#import "OWTAssetViewCon.h"

#import "OWTPhotoUploadInfoViewCon.h"
#import "AGIPCGridItem.h"
#import "MBProgressHUD.h"
#import "FSBasicImage.h"
#import "UMSocial.h"
#import "OWTTabBarHider.h"
#import "OWTPhotoUploadViewController.h"
#import "QJDatabaseManager.h"
#define HEIGHT SCREENHEI - 35
@interface FSImageViewerViewController ()

@property(strong, nonatomic) FSImageTitleView * titleView;

@end

@implementation FSImageViewerViewController {
	NSInteger pageIndex;
	BOOL rotating;
	BOOL barsHidden;
	UIBarButtonItem * leftButton;
	UIBarButtonItem * rightButton;
	OWTAssetViewCon * _assetVC;
	BOOL ifCustom;
	BOOL ifAssert;
	UIView * _backgroundView;
	UIImageView * _imageView;
	UITextField * _textField;
	UIButton * _sendButton;
	NSInteger _page;
	NSMutableArray * assertArray;
	BOOL isUpload;
	OWTTabBarHider * _tabBarHider;
    NSMutableDictionary *_dictData;
}
- (id)initWithImageSource:(id <FSImageSource>)aImageSource
{
	return [self initWithImageSource:aImageSource imageIndex:0 withViewController:nil];
}

- (id)initWithImageSource:(id <FSImageSource>)aImageSource imageIndex:(NSInteger)imageIndex withViewController:(id)viewController
{
	if ((self = [super init])) {
		_assetData = [[NSArray alloc]init];
		
		if (viewController)
			_assetVC = viewController;
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleBarsNotification:) name:kFSImageViewerToogleBarsNotificationKey object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(imageViewDidFinishLoading:) name:kFSImageViewerDidFinishedLoadingNotificationKey object:nil];
		
		self.hidesBottomBarWhenPushed = YES;
		self.wantsFullScreenLayout = YES;
		
		_imageSource = aImageSource;
		pageIndex = imageIndex;
	}
	return self;
}

- (id)initWithCustomImageSource:(id <FSImageSource>)aImageSource imageIndex:(NSInteger)imageIndex withViewController:(id)viewController
{
	if ((self = [super init])) {
		if (viewController)
			_assetVC = viewController;
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleBarsNotification:) name:kFSImageViewerToogleBarsNotificationKey object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(imageViewDidFinishLoading:) name:kFSImageViewerDidFinishedLoadingNotificationKey object:nil];
		
		self.hidesBottomBarWhenPushed = YES;
		self.wantsFullScreenLayout = YES;
		
		_imageSource = aImageSource;
		pageIndex = imageIndex;
		ifCustom = YES;
	}
	return self;
}

- (id)initWithAssestImageSource:(id <FSImageSource>)aImageSource imageIndex:(NSInteger)imageIndex withViewController:(id)viewController
{
	if ((self = [super init])) {
		if (viewController)
			_assetVC = viewController;
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleBarsNotification:) name:kFSImageViewerToogleBarsNotificationKey object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(imageViewDidFinishLoading:) name:kFSImageViewerDidFinishedLoadingNotificationKey object:nil];
		
		self.hidesBottomBarWhenPushed = YES;
		self.wantsFullScreenLayout = YES;
		
		_imageSource = aImageSource;
		pageIndex = imageIndex;
		ifAssert = YES;
	}
	return self;
}

- (id)initWithGridImageSource:(id <FSImageSource>)aImageSource imageIndex:(NSInteger)imageIndex withViewController:(id)viewController gridItems:(NSMutableArray *)gridItems
{
	if ((self = [super init])) {
		if (viewController)
			_assetVC = viewController;
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleBarsNotification:) name:kFSImageViewerToogleBarsNotificationKey object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(imageViewDidFinishLoading:) name:kFSImageViewerDidFinishedLoadingNotificationKey object:nil];
		
		self.hidesBottomBarWhenPushed = YES;
		self.wantsFullScreenLayout = YES;
		
		_imageSource = aImageSource;
		pageIndex = imageIndex;
		_ifGridImage = YES;
		assertArray = gridItems;
		_isLocal = YES;
	}
	return self;
}

- (void)dealloc
{
	_scrollView.delegate = nil;
	[[FSImageLoader sharedInstance] cancelAllRequests];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
	self.imageViews = nil;
	_scrollView.delegate = nil;
	self.scrollView = nil;
	_titleView = nil;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
    _dictData=[[NSMutableDictionary alloc]init];
#ifdef __IPHONE_7_0
		if ([self respondsToSelector:@selector(setAutomaticallyAdjustsScrollViewInsets:)])
			self.automaticallyAdjustsScrollViewInsets = NO;
			
#endif

	self.view.backgroundColor = [UIColor blackColor];
	
	if (!ifAssert) {
		if (!_scrollView) {
			self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
			_scrollView.delegate = self;
			_scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
			_scrollView.scrollEnabled = YES;
			_scrollView.multipleTouchEnabled = YES;
			_scrollView.directionalLockEnabled = YES;
			_scrollView.canCancelContentTouches = YES;
			_scrollView.delaysContentTouches = YES;
			_scrollView.clipsToBounds = YES;
			_scrollView.bounces = YES;
			_scrollView.alwaysBounceHorizontal = YES;
			_scrollView.pagingEnabled = YES;
			_scrollView.showsVerticalScrollIndicator = NO;
			_scrollView.showsHorizontalScrollIndicator = NO;
			_scrollView.backgroundColor = self.view.backgroundColor;
			_scrollView.userInteractionEnabled = YES;
			[self.view addSubview:_scrollView];
			UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(backNav)];
			[_scrollView addGestureRecognizer:tap];
		}
	}
	// 在图像识别模块 如果需要修改scrollView 在下方自行修改
	else if (!_scrollView) {
		self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
		_scrollView.delegate = self;
		_scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
		_scrollView.scrollEnabled = YES;
		_scrollView.multipleTouchEnabled = YES;
		_scrollView.directionalLockEnabled = YES;
		_scrollView.canCancelContentTouches = YES;
		_scrollView.delaysContentTouches = YES;
		_scrollView.clipsToBounds = YES;
		_scrollView.bounces = YES;
		_scrollView.alwaysBounceHorizontal = YES;
		_scrollView.pagingEnabled = YES;
		_scrollView.showsVerticalScrollIndicator = NO;
		_scrollView.showsHorizontalScrollIndicator = NO;
		_scrollView.backgroundColor = self.view.backgroundColor;
		_scrollView.userInteractionEnabled = YES;
		[self.view addSubview:_scrollView];
		UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(backNav)];
		[_scrollView addGestureRecognizer:tap];
	}
	
	if (!_titleView)
		self.titleView = [[FSImageTitleView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 1)];
		
	//  load FSImageView lazy
	NSMutableArray * views = [[NSMutableArray alloc] init];
	
	for (NSUInteger i = 0; i < [_imageSource numberOfImages]; i++)
		[views addObject:[NSNull null]];
		
	self.imageViews = views;
	[self setUpInputView];
	_tabBarHider = [[OWTTabBarHider alloc]init];
}

- (void)setUpInputView
{
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(inputKeyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
	_backgroundView = [[UIView alloc]initWithFrame:self.view.frame];
	_backgroundView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
	[self.view addSubview:_backgroundView];
	[self.view sendSubviewToBack:_backgroundView];
	UITapGestureRecognizer * backTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onBackTap)];
	_imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, SCREENWIT, 45)];
	_imageView.userInteractionEnabled = YES;
	_imageView.backgroundColor = [UIColor whiteColor];
	[_backgroundView addSubview:_imageView];
	_textField = [[UITextField alloc]initWithFrame:CGRectMake(10, 2, SCREENWIT - 90, 40)];
	_textField.borderStyle = UITextBorderStyleRoundedRect;
	[_imageView addSubview:_textField];
	_sendButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[_sendButton setTitle:@"添加标签" forState:UIControlStateNormal];
    [_sendButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	[_sendButton setFrame:CGRectMake(SCREENWIT - 80, 2, 80, 40)];
	[_sendButton addTarget:self action:@selector(onSendBtn:) forControlEvents:UIControlEventTouchUpInside];
	[_imageView addSubview:_sendButton];
	[_backgroundView addGestureRecognizer:backTap];
}

- (void)onSendBtn:(UIButton *)sender
{
	NSArray * arr = [_textField.text componentsSeparatedByString:@" "];
	NSMutableArray * arr1 = [NSMutableArray arrayWithArray:arr];
	
	for (NSInteger i = 0; i < arr.count; i++) {
		NSString * str = arr[i];
		
		if (str.length == 0)
			[arr1 removeObject:@""];
			
	}
	
	NSString * str1 = [arr1 componentsJoinedByString:@" "];
	NSLog(@"%@", str1);
	NSString * imageurl;
	
	if (_ifGridImage == YES) {
		FSBasicImage * basic = _imageSource[_page];
		
		//            AGIPCGridItem *gridItem=assertArray[page];
		ALAsset * asset = basic.assert;
		imageurl = [[asset valueForProperty:ALAssetPropertyAssetURL] absoluteString];
	}
	else {
		NSDictionary * dict = _assetData[_page];
		OWTImageInfo * dd = dict[@"imageInfo"];
		imageurl = dd.url;
	}
    NSString * str =[self checkTheCaption:imageurl];

	NSArray * arr2 = [str componentsSeparatedByString:@" "];
	
	if (arr1.count + arr2.count >= 20) {
		[SVProgressHUD showSuccessWithStatus:@"标签过多"];
		return;
	}
	
	if (_dictData == nil) {
        [self insertCaptionToCoredata:imageurl caption:str1 isself:@"1"];

	}
	else {
		NSString * caption = [NSString stringWithFormat:@"%@ %@ ", str, str1];
        [self updataCaption:caption withImage:imageurl];
	}
	FSImageView * imageView;
	
	for (UIView * view in _scrollView.subviews)
		if (view.tag == _page)
			imageView = (FSImageView *)view;
			
	[self updateCaptionView:imageView withPage:_page with:YES];
	[self onBackTap];
}

- (void)inputKeyboardWillShow:(NSNotification *)notification
{
	CGFloat animationTime = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
	
	[UIView animateWithDuration:animationTime animations:^{
		CGRect keyBoardFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
		_imageView.frame = CGRectMake(0, SCREENHEI - keyBoardFrame.size.height - 45, SCREENWIT, 45);
	}];
}

- (void)onBackTap
{
	[self.view sendSubviewToBack:_backgroundView];
	_textField.placeholder = nil;
	_textField.text = nil;
	[_textField resignFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated
{
	if (isUpload == YES)
		[self setBarsHidden:NO animated:NO];
		
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[_tabBarHider hideTabBar];
	
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
		if (self.modalPresentationStyle == UIModalPresentationFullScreen) {
			UIBarButtonItem * doneButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", @"done") style:UIBarButtonItemStyleDone target:self action:@selector(done:)];
			self.navigationItem.rightBarButtonItem = doneButton;
		}
		
	[self setupScrollViewContentSize];
	[self moveToImageAtIndex:pageIndex animated:NO];
	[self setBarsHidden:YES animated:NO];
	
	if (!_isLocal) {
		[SVProgressHUD show];
		usleep(1000000);
		[SVProgressHUD dismiss];
	}
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
		return interfaceOrientation == UIInterfaceOrientationLandscapeRight || interfaceOrientation == UIInterfaceOrientationLandscapeLeft;
		
		
	return UIInterfaceOrientationIsLandscape(interfaceOrientation) || interfaceOrientation == UIInterfaceOrientationPortrait;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	rotating = YES;
	
	if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
		CGRect rect = [[UIScreen mainScreen] bounds];
		_scrollView.contentSize = CGSizeMake(rect.size.height * [_imageSource numberOfImages], rect.size.width);
	}
	
	NSInteger count = 0;
	
	for (FSImageView * view in _imageViews) {
		if ([view isKindOfClass:[FSImageView class]])
			if (count != pageIndex)
				[view setHidden:YES];
		count++;
	}
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	for (FSImageView * view in _imageViews)
	
		if ([view isKindOfClass:[FSImageView class]])
			[view rotateToOrientation:toInterfaceOrientation];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	[self setupScrollViewContentSize];
	[self moveToImageAtIndex:pageIndex animated:NO];
	[_scrollView scrollRectToVisible:((FSImageView *)[_imageViews objectAtIndex:(NSUInteger)pageIndex]).frame animated:YES];
	
	for (FSImageView * view in self.imageViews)
		if ([view isKindOfClass:[FSImageView class]])
		
			[view setHidden:NO];
			
	rotating = NO;
}

- (void)done:(id)sender
{
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (NSInteger)currentImageIndex
{
	return pageIndex;
}

#pragma mark - Bar/Caption Methods

- (void)setStatusBarHidden:(BOOL)hidden
{
	[[UIApplication sharedApplication] setStatusBarHidden:hidden withAnimation:UIStatusBarAnimationFade];
}

- (void)setBarsHidden:(BOOL)hidden animated:(BOOL)animated
{
	if (hidden && barsHidden)
		return;
		
		
	[self setStatusBarHidden:hidden];
	[self.navigationController setNavigationBarHidden:hidden animated:animated];
	
	[UIView animateWithDuration:0.3 animations:^{
		UIColor * backgroundColor = hidden ?[UIColor blackColor] :[UIColor blackColor];
		__weak FSImageViewerViewController * wself = self;
		
		for (FSImageView * imageView in _imageViews)
			if ([imageView isKindOfClass:[FSImageView class]]) {
				if (_ifCetainPage)
					imageView.identifyVC = self;
					
					
				[imageView changeBackgroundColor:backgroundColor];
				imageView.showBack = ^{[wself backNav]; };
			}
	}];
	
	[_titleView hideView:hidden];
	
	barsHidden = hidden;
}

// 后退按钮触发事件
- (void)backNav
{
	[self setBarsHidden:NO animated:YES];
	// [self.navigationController popToViewController:_assetVC animated:YES];
	[self.navigationController popViewControllerAnimated:NO];
}

- (void)toggleBarsNotification:(NSNotification *)notification {}

#pragma mark - Image View

- (void)imageViewDidFinishLoading:(NSNotification *)notification
{
	//    if (notification == nil) {
	////        return;
	//    }
	//
	//    if ([[notification object][@"image"] isEqual:_imageSource[[self centerImageIndex]]]) {
	//        if ([[notification object][@"failed"] boolValue]) {
	//            if (barsHidden) {
	//                [self setBarsHidden:NO animated:YES];
	//            }
	//        }
	//        [self setViewState];
	//    }
}

- (NSInteger)centerImageIndex
{
	CGFloat pageWidth = self.scrollView.frame.size.width;
	
	return (NSInteger)(floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1);
}

- (void)setViewState
{
	if (leftButton)
		leftButton.enabled = !(pageIndex - 1 < 0);
		
	if (rightButton)
		rightButton.enabled = !(pageIndex + 1 >= [_imageSource numberOfImages]);
		
	NSInteger numberOfImages = [_imageSource numberOfImages];
	
	if (numberOfImages > 1) {
		//        [self substituteNavigationBarBackItem];
		//        self.navigationController.navigationBar.backgroundColor = [UIColor blackColor];
		//        self.navigationItem.title = [NSString stringWithFormat:NSLocalizedString(@"%i of %i", @"imageCounter"), pageIndex + 1, numberOfImages];
	}
	else {
		self.title = @"";
	}
	
	if (_titleView)
	
		_titleView.text = _imageSource[pageIndex].title;
		
}

- (void)moveToImageAtIndex:(NSInteger)index animated:(BOOL)animated
{
	if ((index < [self.imageSource numberOfImages]) && (index >= 0)) {
		pageIndex = index;
		[self setViewState];
		
		[self enqueueImageViewAtIndex:index];
		
		[self loadScrollViewWithPage:index];
		
		[self.scrollView scrollRectToVisible:((FSImageView *)[_imageViews objectAtIndex:(NSUInteger)index]).frame animated:animated];
		
		if (_imageSource[pageIndex].failed)
			[self setBarsHidden:YES animated:NO];
			
		if ((index + 1 < [self.imageSource numberOfImages]) && ((NSNull *)[_imageViews objectAtIndex:(NSUInteger)(index + 1)] != [NSNull null]))
			[((FSImageView *)[self.imageViews objectAtIndex:(NSUInteger)(index + 1)]) killScrollViewZoom];
			
		if ((index - 1 >= 0) && ((NSNull *)[self.imageViews objectAtIndex:(NSUInteger)(index - 1)] != [NSNull null]))
			[((FSImageView *)[self.imageViews objectAtIndex:(NSUInteger)(index - 1)]) killScrollViewZoom];
	}
}

- (void)layoutScrollViewSubviews
{
	NSInteger index = [self currentImageIndex];
	
	for (NSInteger page = index - 1; page < index + 3; page++)
	
		if ((page >= 0) && (page < [_imageSource numberOfImages])) {
			CGFloat originX = _scrollView.bounds.size.width * page;
			
			if (page < index)
				originX -= kFSImageViewerImageGap;
				
			if (page > index)
				originX += kFSImageViewerImageGap;
				
			if (([_imageViews objectAtIndex:(NSUInteger)page] == [NSNull null]) || !((UIView *)[_imageViews objectAtIndex:(NSUInteger)page]).superview)
				[self loadScrollViewWithPage:page];
				
			FSImageView * imageView = [_imageViews objectAtIndex:(NSUInteger)page];
			CGRect newFrame = CGRectMake(originX, 0.0f, _scrollView.bounds.size.width, _scrollView.bounds.size.height);
			
			if (!CGRectEqualToRect(imageView.frame, newFrame))
				[UIView animateWithDuration:0.1 animations:^{
					imageView.frame = newFrame;
				}];
		}
}

- (void)setupScrollViewContentSize
{
	CGSize contentSize = self.view.bounds.size;
	
	contentSize.width = (contentSize.width * [_imageSource numberOfImages]);
	
	if (!CGSizeEqualToSize(contentSize, self.scrollView.contentSize))
		self.scrollView.contentSize = contentSize;
		
	_titleView.frame = CGRectMake(0.0f, self.view.bounds.size.height - 40.0f, self.view.bounds.size.width, 40.0f);
}

- (void)enqueueImageViewAtIndex:(NSInteger)theIndex
{
	NSInteger count = 0;
	
	for (FSImageView * view in _imageViews) {
		if ([view isKindOfClass:[FSImageView class]]) {
			if ((count > theIndex + 1) || (count < theIndex - 1)) {
				[view prepareForReuse];
				[view removeFromSuperview];
			}
			else {
				view.tag = 0;
			}
		}
		count++;
	}
}

- (FSImageView *)dequeueImageView
{
	NSInteger count = 0;
	
	for (FSImageView * view in self.imageViews) {
		if ([view isKindOfClass:[FSImageView class]])
			if (view.superview == nil) {
				view.tag = count;
				return view;
			}
		count++;
	}
	
	return nil;
}

- (void)loadScrollViewWithPage:(NSInteger)page
{
	if (page < 0)
		return;
		
	if (page >= [_imageSource numberOfImages])
		return;
		
		
	FSImageView * imageView = [_imageViews objectAtIndex:(NSUInteger)page];
	
	if ((NSNull *)imageView == [NSNull null]) {
		imageView = [self dequeueImageView];
		
		if (imageView != nil) {
			[_imageViews exchangeObjectAtIndex:(NSUInteger)imageView.tag withObjectAtIndex:(NSUInteger)page];
			imageView = [_imageViews objectAtIndex:(NSUInteger)page];
		}
	}
	
	if ((imageView == nil) || ((NSNull *)imageView == [NSNull null])) {
		if (!_ifGridImage) {
			imageView = [[FSImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, _scrollView.bounds.size.width, _scrollView.bounds.size.height) withViewcontroller:self];
			imageView.islocal = _isLocal;
			NSLog(@"%f", imageView.frame.size.height);
		}
		else {
			FSBasicImage * basic = _imageSource[page];
			imageView = [[FSImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, _scrollView.bounds.size.width, _scrollView.bounds.size.height) gridItem:basic.gridItem];
			imageView.islocal = _isLocal;
			NSLog(@"%f", imageView.frame.size.height);
		}
		UIColor * backgroundColor = barsHidden ?[UIColor blackColor] :[UIColor blackColor];
		[imageView changeBackgroundColor:backgroundColor];
		// _imageViews 一开始就是懒加载 为空  _imageSource才是真正的数据源
		[_imageViews replaceObjectAtIndex:(NSUInteger)page withObject:imageView];
	}
	
	if (_ifGridImage) {
		FSBasicImage * basic = _imageSource[page];
		imageView.gridItem = basic.gridItem;
		[imageView refreshTheSelectedBtn:basic.gridItem.selected];
	}
	imageView.tag = page;
	
	if (ifAssert) {
		FSBasicImage * basic = _imageSource[page];
		UIImage * image = [UIImage imageWithCGImage:basic.assert.defaultRepresentation.fullScreenImage];
		NSLog(@"%@", image);
		imageView.image = [[FSBasicImage alloc]initWithImage:image];
	}
	else {
		imageView.image = _imageSource[page];
		NSLog(@"%@", _imageSource[page]);
	}
	
	imageView.label.text = [NSString stringWithFormat:@"%li of %li", page + 1, [_imageSource numberOfImages]];
	imageView.showBack = ^{
		[self backNav];
	};
	
	if (_isLocal == YES) {
		NSString * str;
		
		if (_ifGridImage == YES) {
			FSBasicImage * basic = _imageSource[page];
			
			//            AGIPCGridItem *gridItem=assertArray[page];
			ALAsset * asset = basic.assert;
			NSString * imageurl = [[asset valueForProperty:ALAssetPropertyAssetURL] absoluteString];
          str=[self checkTheCaption:imageurl];
		}
		else {
			NSDictionary * dict = _assetData[page];
			OWTImageInfo * dd = dict[@"imageInfo"];
           str= [self checkTheCaption:dd.url];
        }
		
		for (UIView * view in imageView.subviews)
			if (view.tag >= 700)
				[view removeFromSuperview];
				
		NSArray * arr = [str componentsSeparatedByString:@" "];
		int a = 5;
		int height = 0;
		
		for (NSString * caption in arr) {
			CGSize size = [caption sizeWithFont:[UIFont systemFontOfSize:17]];
			
			if (a + size.width > SCREENWIT) {
				height += (size.height + 3);
				a = 5;
			}
			a += size.width + 3;
		}
		
		int x = 5;
		int y = SCREENHEI - 65 - height;
		int i = 0;
		
		for (NSString * caption in arr) {
			if (caption.length == 0)
				continue;
			CGSize size = [caption sizeWithFont:[UIFont systemFontOfSize:17]];
			
			if (x + size.width > SCREENWIT) {
				y += (size.height + 3);
				x = 5;
			}
			UIButton * button = [LJUIController createButtonWithFrame:CGRectMake(x, y, size.width, size.height) imageName:@"1_03.png" title:caption target:nil action:nil];
			UIButton * deleteButton = [LJUIController createButtonWithFrame:CGRectMake(x - 8, y - 8, 16, 16) imageName:@"未标题-1_10.png" title:nil target:self action:@selector(deleteCaption:)];
			deleteButton.tag = 900 + i;
			deleteButton.hidden = YES;
			// [button addSubview:deleteButton];
			button.tag = 777;
			button.titleLabel.font = [UIFont systemFontOfSize:14];
			[button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
			[imageView addSubview:button];
			[imageView addSubview:deleteButton];
			x += size.width + 3;
			i++;
		}
		
		if (x + 20 > SCREENWIT) {
			y += 30;
			x = 5;
		}
		UIButton * insertButton = [LJUIController createButtonWithFrame:CGRectMake(x, y, 20, 20) imageName:@"大图1_05_05.png" title:nil target:self action:@selector(insertCaption:)];
		insertButton.tag = 778;
		insertButton.hidden = YES;
		[imageView addSubview:insertButton];
		imageView.shareButton.hidden = YES;
		imageView.downloadButton.hidden = YES;
		imageView.label.hidden = YES;
		imageView.backButton.hidden = YES;
		
		if (_ifGridImage == YES) {
			UIButton * shareButton = [LJUIController createButtonWithFrame:CGRectMake(SCREENWIT - 50, HEIGHT, 30, 30) imageName:@"ic_pic_share2.png" title:nil target:self action:@selector(shareButton:)];
			shareButton.tag = 700 + page;
			[imageView addSubview:shareButton];
			UIButton * caption = [LJUIController createButtonWithFrame:CGRectMake(20, HEIGHT, 30, 30) imageName:@"大图1_11.png" title:nil target:self action:@selector(caption:)];
			caption.selected = NO;
			caption.tag = 700 + page;
			[imageView addSubview:caption];
			//            UIButton *backButton=[LJUIController createButtonWithFrame:CGRectMake(20, HEIGHT, 30, 30) imageName:@"大图1_03.png" title:nil target:self action:@selector(backNav)];
			//            backButton.tag=700+page;
			//            [imageView addSubview:backButton];
		}
		else {
			UIButton * updateButton = [LJUIController createButtonWithFrame:CGRectMake(SCREENWIT / 2 - 20, HEIGHT, 35, 25) imageName:@"ic_pic_upload.png" title:nil target:self action:@selector(update:)];
			updateButton.tag = 700 + page;
			[imageView addSubview:updateButton];
			UIButton * shareButton = [LJUIController createButtonWithFrame:CGRectMake(SCREENWIT - 50, HEIGHT, 30, 30) imageName:@"ic_pic_share2.png" title:nil target:self action:@selector(shareButton:)];
			shareButton.tag = 700 + page;
			[imageView addSubview:shareButton];
			UIButton * caption = [LJUIController createButtonWithFrame:CGRectMake(20, HEIGHT, 30, 30) imageName:@"大图1_11.png" title:nil target:self action:@selector(caption:)];
			caption.selected = NO;
			caption.tag = 700 + page;
			[imageView addSubview:caption];
		}
	}
	
	if (imageView.superview == nil)
		[_scrollView addSubview:imageView];
		
	CGRect frame = _scrollView.frame;
	NSInteger centerPageIndex = pageIndex;
	CGFloat xOrigin = (frame.size.width * page);
	
	if (page > centerPageIndex)
		xOrigin = (frame.size.width * page) + kFSImageViewerImageGap;
	else if (page < centerPageIndex)
		xOrigin = (frame.size.width * page) - kFSImageViewerImageGap;
		
	frame.origin.x = xOrigin;
	frame.origin.y = 0;
	imageView.frame = frame;
}

- (void)deleteCaption:(UIButton *)sender
{
	FSImageView * imageView = (FSImageView *)sender.superview;
	NSString * str;
	NSString * imageurl;
	
	if (_ifGridImage == YES) {
		FSBasicImage * basic = _imageSource[imageView.tag];
		
		//            AGIPCGridItem *gridItem=assertArray[page];
		ALAsset * asset = basic.assert;
		imageurl = [[asset valueForProperty:ALAssetPropertyAssetURL] absoluteString];
     str=[self checkTheCaption:imageurl];
	}
	else {
		NSDictionary * dict = _assetData[imageView.tag];
		OWTImageInfo * dd = dict[@"imageInfo"];
      str=[self checkTheCaption:dd.url];
		imageurl = dd.url;
	}
	NSArray * arr = [str componentsSeparatedByString:@" "];
	
	if (arr.count == 1)
		return;
		
	NSMutableArray * arr1 = [[NSMutableArray alloc]initWithArray:arr];
	[arr1 removeObjectAtIndex:sender.tag - 900];
	NSString * caption = [arr1 componentsJoinedByString:@" "];
    [self updataCaption:caption withImage:imageurl];
	[self updateCaptionView:imageView withPage:imageView.tag with:YES];
}

- (void)insertCaption:(UIButton *)sender
{
	FSImageView * imageview = (FSImageView *)sender.superview;
	
	_page = imageview.tag;
	NSString * str;
	
	if (_ifGridImage == YES) {
		FSBasicImage * basic = _imageSource[imageview.tag];
		
		//            AGIPCGridItem *gridItem=assertArray[page];
		ALAsset * asset = basic.assert;
		NSString * imageurl = [[asset valueForProperty:ALAssetPropertyAssetURL] absoluteString];
      str=[self checkTheCaption:imageurl];
	}
	else {
		NSDictionary * dict = _assetData[imageview.tag];
		OWTImageInfo * dd = dict[@"imageInfo"];
      str=[self checkTheCaption:dd.url];
	}
	
	NSArray * arr = [str componentsSeparatedByString:@" "];
	
	if (arr.count >= 20) {
		[SVProgressHUD showSuccessWithStatus:@"标签过多"];
		return;
	}
	[self.view bringSubviewToFront:_backgroundView];
	[_textField becomeFirstResponder];
}

- (void)updateCaptionView:(FSImageView *)imageView withPage:(NSInteger)page with:(BOOL)selected
{
	NSString * str;
	
	if (_ifGridImage == YES) {
		FSBasicImage * basic = _imageSource[page];
		
		//            AGIPCGridItem *gridItem=assertArray[page];
		ALAsset * asset = basic.assert;
		NSString * imageurl = [[asset valueForProperty:ALAssetPropertyAssetURL] absoluteString];
       str= [self checkTheCaption:imageurl];
	}
	else {
		NSDictionary * dict = _assetData[page];
		OWTImageInfo * dd = dict[@"imageInfo"];
       str= [self checkTheCaption:dd.url];

	}
	
	for (UIView * view in imageView.subviews)
		if (view.tag >= 700)
			[view removeFromSuperview];
			
	NSArray * arr = [str componentsSeparatedByString:@" "];
	int a = 5;
	int height = 0;
	
	for (NSString * caption in arr) {
		CGSize size = [caption sizeWithFont:[UIFont systemFontOfSize:17]];
		
		if (selected == YES)
			size.width += 20;
			
		if (a + size.width > SCREENWIT) {
			height += (size.height + 3);
			a = 5;
		}
		a += size.width + 3;
	}
	
	if (selected)
		if (a + 20 > SCREENWIT)
			height += 25;
	int x = 5;
	int y;
	y = SCREENHEI - 65 - height;
	int i = 0;
	
	for (NSString * caption in arr) {
		if (caption.length == 0)
			continue;
		CGSize size = [caption sizeWithFont:[UIFont systemFontOfSize:17]];
		
		if (selected == YES)
			size.width += 20;
			
		if (x + size.width > SCREENWIT) {
			y += (size.height + 3);
			x = 5;
		}
		UIButton * button = [LJUIController createButtonWithFrame:CGRectMake(x, y, size.width, size.height) imageName:@"1_03.png" title:caption target:nil action:nil];
		
		if (selected == YES)
			button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
		x += size.width + 3;
		UIButton * deleteButton = [LJUIController createButtonWithFrame:CGRectMake(x - 25, y + 2, 16, 16) imageName:@"未标题-1_10.png" title:nil target:self action:@selector(deleteCaption:)];
		
		if (selected == NO)
			deleteButton.hidden = YES;
		deleteButton.tag = 900 + i;
		// deleteButton.hidden=YES;
		// [button addSubview:deleteButton];
		button.tag = 777;
		button.titleLabel.font = [UIFont systemFontOfSize:14];
		[button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		[imageView addSubview:button];
		[imageView addSubview:deleteButton];
		i++;
	}
	
	if (x + 20 > SCREENWIT) {
		y += 25;
		x = 5;
	}
	UIButton * insertButton = [LJUIController createButtonWithFrame:CGRectMake(x, y, 20, 20) imageName:@"大图1_05_05.png" title:nil target:self action:@selector(insertCaption:)];
	
	if (selected == NO)
		insertButton.hidden = YES;
	insertButton.tag = 778;
	[imageView addSubview:insertButton];
	
	if (_ifGridImage == YES) {
		UIButton * shareButton = [LJUIController createButtonWithFrame:CGRectMake(SCREENWIT - 50, HEIGHT, 30, 30) imageName:@"ic_pic_share2.png" title:nil target:self action:@selector(shareButton:)];
		shareButton.tag = 700 + page;
		[imageView addSubview:shareButton];
		UIButton * caption = [LJUIController createButtonWithFrame:CGRectMake(20, HEIGHT, 30, 30) imageName:@"大图1_11.png" title:nil target:self action:@selector(caption:)];
		caption.tag = 700 + page;
		
		if (selected == NO)
			caption.selected = NO;
		else
			caption.selected = YES;
		[imageView addSubview:caption];
		//        UIButton *backButton=[LJUIController createButtonWithFrame:CGRectMake(20, HEIGHT, 30, 30) imageName:@"大图1_03.png" title:nil target:self action:@selector(backNav)];
		//        backButton.tag=700+page;
		//        [imageView addSubview:backButton];
	}
	else {
		UIButton * updateButton = [LJUIController createButtonWithFrame:CGRectMake(SCREENWIT / 2 - 20, HEIGHT, 35, 25) imageName:@"ic_pic_upload.png" title:nil target:self action:@selector(update:)];
		updateButton.tag = 700 + page;
		[imageView addSubview:updateButton];
		UIButton * shareButton = [LJUIController createButtonWithFrame:CGRectMake(SCREENWIT - 50, HEIGHT, 30, 30) imageName:@"ic_pic_share2.png" title:nil target:self action:@selector(shareButton:)];
		shareButton.tag = 700 + page;
		[imageView addSubview:shareButton];
		UIButton * caption = [LJUIController createButtonWithFrame:CGRectMake(20, HEIGHT, 30, 30) imageName:@"大图1_11.png" title:nil target:self action:@selector(caption:)];
		
		if (selected == NO)
			caption.selected = NO;
		else
			caption.selected = YES;
		caption.tag = 700 + page;
		[imageView addSubview:caption];
	}
}

- (void)caption:(UIButton *)sender
{
	FSImageView * imageView = (FSImageView *)sender.superview;
	
	if (sender.selected == NO)
		[self updateCaptionView:imageView withPage:imageView.tag with:YES];
	else
	
		[self updateCaptionView:imageView withPage:imageView.tag with:NO];
		
}

- (void)update:(UIButton *)sender
{
	OWTImageInfo * imageInfo = [[OWTImageInfo alloc] init];
	
	FSBasicImage * basic = _imageSource[sender.tag - 700];
	
	//            AGIPCGridItem *gridItem=assertArray[page];
	ALAsset * result = basic.assert;
	
	imageInfo.url = [[result valueForProperty:ALAssetPropertyAssetURL] absoluteString];
	//                NSLog(@"11111111111%@",imageInfo.url);
	imageInfo.primaryColorHex = @"DDDDDD";
	imageInfo.width = 64;
	imageInfo.height = 64;
	imageInfo.asset = result;
	NSMutableArray * selectImages = [[NSMutableArray alloc] initWithObjects:imageInfo, nil];
	OWTPhotoUploadViewController * photoUploadVC = [[OWTPhotoUploadViewController alloc] initWithNibName:nil bundle:nil];
	[self setStatusBarHidden:NO];
	self.navigationController.navigationBarHidden = NO;
	//    photoUploadVC.navigationController.navigationBar.hidden=NO;
	//                                     photoUploadVC.hidesBottomBarWhenPushed = YES;
	photoUploadVC.imageInfos = selectImages;
	photoUploadVC.isCameraImages = NO;
	photoUploadVC.cancelAction = ^{
		[self setStatusBarHidden:YES];
		self.navigationController.navigationBarHidden = YES;
		
		[self.navigationController popViewControllerAnimated:YES];
	};
	photoUploadVC.doneAction = ^{
		[self.navigationController popViewControllerAnimated:YES];
	};
	[self.navigationController pushViewController:photoUploadVC animated:NO];
}

- (void)shareButton:(UIButton *)sender
{
	isUpload = NO;
	FSBasicImage * basic = _imageSource[sender.tag - 700];
	UIImage * image = [UIImage imageWithCGImage:basic.assert.defaultRepresentation.fullScreenImage];
	[UMSocialData defaultData].extConfig.wxMessageType = UMSocialWXMessageTypeImage;
	[UMSocialData defaultData].extConfig.qqData.qqMessageType = UMSocialQQMessageTypeImage;
	[UMSocialSnsService presentSnsIconSheetView:self
	appKey:nil
	shareText:nil
	shareImage:image
	shareToSnsNames:[NSArray arrayWithObjects:UMShareToWechatSession, UMShareToWechatTimeline, UMShareToSina, UMShareToWechatFavorite, UMShareToQzone, UMShareToQQ, UMShareToSms, nil]
	delegate:nil];
}
#pragma mark -coreDataMothed
-(void)updataCaption:(NSString *)caption withImage:(NSString *)imageurl
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        QJDatabaseManager *manager=[QJDatabaseManager sharedManager];
        __weak QJDatabaseManager *wmanager=manager;
        dispatch_semaphore_t sem=dispatch_semaphore_create(0);
        [manager performDatabaseUpdateBlock:^(NSManagedObjectContext * _Nonnull concurrencyContext) {
            QJImageCaption *model= [wmanager getImageCaptionByUrl:imageurl context:concurrencyContext];
            model.caption=caption;
        } finished:^(NSManagedObjectContext * _Nonnull mainContext) {
            dispatch_semaphore_signal(sem);
        }];
        
        dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
        
    });

}
-(NSString *)checkTheCaption:(NSString *)imageurl
{
    [_dictData removeAllObjects];

    QJDatabaseManager *manager=[QJDatabaseManager sharedManager];
  QJImageCaption *model=[manager getImageCaptionByUrl:imageurl context:manager.managedObjectContext];
    return model.caption;
}
-(void)insertCaptionToCoredata:(NSString*)imageurl caption:(NSString *)caption isself:(NSString *)isself
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        QJDatabaseManager *manager=[QJDatabaseManager sharedManager];
        __weak QJDatabaseManager *wmanager=manager;
        dispatch_semaphore_t sem=dispatch_semaphore_create(0);
        [manager performDatabaseUpdateBlock:^(NSManagedObjectContext * _Nonnull concurrencyContext) {
            [wmanager setImageCaptionByImageUrl:imageurl caption:caption isSelfInsert:isself.boolValue context:concurrencyContext];
        } finished:^(NSManagedObjectContext * _Nonnull mainContext) {
            dispatch_semaphore_signal(sem);
        }];
        
        dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
        
    });

}
#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	NSInteger index = [self centerImageIndex];
	
	if ((index >= [_imageSource numberOfImages]) || (index < 0))
		return;
		
	if ((pageIndex != index) && !rotating) {
		pageIndex = index;
		[self setViewState];
		
		if (![scrollView isTracking])
			[self layoutScrollViewSubviews];
	}
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
	NSInteger index = [self centerImageIndex];
	
	if ((index >= [_imageSource numberOfImages]) || (index < 0))
		return;
		
		
	[self moveToImageAtIndex:index animated:YES];
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
	[self layoutScrollViewSubviews];
}

@end
