//
//  AGIPCAssetsController.m
//  AGImagePickerController
//
//  Created by Artur Grigor on 17.02.2012.
//  Copyright (c) 2012 - 2013 Artur Grigor. All rights reserved.
//
//  For the full copyright and license information, please view the LICENSE
//  file that was distributed with this source code.
//

#import "AGIPCAssetsController.h"

#import "AGImagePickerController+Helper.h"

#import "AGIPCGridCell.h"
#import "AGIPCToolbarItem.h"

#import "AGImagePreviewController.h"
#import "AGIPCPreviewController.h"
#import "FSBasicImageSource.h"
#import "FSImageViewerViewController.h"
#import "FSBasicImage.h"

#import "captionCell.h"
#import <UIColor-HexString/UIColor+HexString.h>
#import "MJRefresh.h"
#import "QJDatabaseManager.h"
@interface AGIPCAssetsController () <AGIPCPreviewControllerDelegate, UISearchBarDelegate>
{
	ALAssetsGroup * _assetsGroup;
	NSMutableArray * _assets;
	__ag_weak AGImagePickerController * _imagePickerController;
	
	UIInterfaceOrientation lastOrientation;
	UISearchBar * _searchBar;
	BOOL isSearching;
	NSMutableArray * _allCaptions;
	NSMutableArray * _allAssets;
	NSString * _captions;
	ALAssetsLibrary * lib;
}

@property (nonatomic, strong) NSMutableArray * assets;

@end

@interface AGIPCAssetsController (Private)

- (void)changeSelectionInformation;

- (void)registerForNotifications;
- (void)unregisterFromNotifications;

- (void)didChangeLibrary:(NSNotification *)notification;
- (void)didChangeToolbarItemsForManagingTheSelection:(NSNotification *)notification;

- (BOOL)toolbarHidden;

- (void)loadAssets;
- (void)reloadData;

- (void)setupToolbarItems;

- (NSArray *)itemsForRowAtIndexPath:(NSIndexPath *)indexPath;

- (void)doneAction:(id)sender;
- (void)selectAllAction:(id)sender;
- (void)deselectAllAction:(id)sender;
- (void)customBarButtonItemAction:(id)sender;

@end

@implementation AGIPCAssetsController

#pragma mark - Properties

@synthesize assetsGroup = _assetsGroup, assets = _assets, imagePickerController = _imagePickerController;
// 修改toolbar

- (BOOL)toolbarHidden
{
	if (!self.imagePickerController.shouldShowToolbarForManagingTheSelection) {
		return NO;
	}
	else {
		if (self.imagePickerController.toolbarItemsForManagingTheSelection != nil)
			return !(self.imagePickerController.toolbarItemsForManagingTheSelection.count > 0);
		else
			return YES;
	}
}

- (void)setAssetsGroup:(ALAssetsGroup *)theAssetsGroup
{
	@synchronized(self)
	{
		if (_assetsGroup != theAssetsGroup) {
			_assetsGroup = theAssetsGroup;
			[_assetsGroup setAssetsFilter:[ALAssetsFilter allPhotos]];
			
			// modified by springox(20140510)
			// [self reloadData];
		}
	}
}

- (ALAssetsGroup *)assetsGroup
{
	ALAssetsGroup * ret = nil;
	
	@synchronized(self)
	{
		ret = _assetsGroup;
	}
	
	return ret;
}

- (NSArray *)selectedAssets
{
	NSMutableArray * selectedAssets = [NSMutableArray array];
	
	for (AGIPCGridItem * gridItem in self.assets)
		if (gridItem.selected)
			[selectedAssets addObject:gridItem.asset];
			
	return selectedAssets;
}

#pragma mark - Object Lifecycle

- (id)initWithImagePickerController:(AGImagePickerController *)imagePickerController andAssetsGroup:(ALAssetsGroup *)assetsGroup
{
	self = [super init];
	
	if (self) {
		_assets = [[NSMutableArray alloc] init];
		_allAssets = [[NSMutableArray alloc]init];
		self.assetsGroup = assetsGroup;
		self.imagePickerController = imagePickerController;
		self.title = NSLocalizedStringWithDefaultValue(@"AGIPC.Loading", nil, [NSBundle mainBundle], @"Loading...", nil);
		self.title = [self.assetsGroup valueForProperty:ALAssetsGroupPropertyName];
		
		// Setup toolbar items
		[self setupToolbarItems];
		
		// Start loading the assets
		[self loadAssets];
	}
	
	return self;
}

- (void)dealloc
{
	[self unregisterFromNotifications];
}

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
	[super viewDidLoad];
	self.view.backgroundColor = [UIColor colorWithHexString:@"#f0f1f3"];
	[self setUpTableView];
	
	// Fullscreen
	if (self.imagePickerController.shouldChangeStatusBarStyle)
		self.wantsFullScreenLayout = YES;
	_captions = [[NSString alloc]init];
	__weak AGIPCAssetsController * wself = self;
	__weak NSMutableArray * arr = _allAssets;
	[self.tableView addHeaderWithCallback:^{
		[wself.assets removeAllObjects];
		[wself.assets addObjectsFromArray:arr];
		_searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0, 0, SCREENWIT, 40)];
		_searchBar.delegate = wself;
		_searchBar.placeholder = @"搜索";
		[wself changeSearchBarBackcolor:_searchBar];
		isSearching = NO;
		_captions = nil;
		[wself reloadData];
		[wself performSelector:@selector(stopRun) withObject:nil afterDelay:1];
	}];
	// Navigation Bar Items
	UIBarButtonItem * doneButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneAction:)];
	doneButtonItem.enabled = NO;
	self.navigationItem.rightBarButtonItem = doneButtonItem;
	
	UIBarButtonItem * backButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(backAction)];
	self.navigationItem.leftBarButtonItem = backButtonItem;
	lastOrientation = self.interfaceOrientation;
	
	// modified by springox(20140510)
	[self reloadData];
	
	// Setup Notifications
	[self registerForNotifications];
	
	// add by springox(20141105)
	[AGIPCGridItem performSelector:@selector(resetNumberOfSelections)];
	_searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0, 0, SCREENWIT, 40)];
	_searchBar.delegate = self;
	_searchBar.placeholder = @"搜索";
	isSearching = NO;
	[self changeSearchBarBackcolor:_searchBar];
	_allCaptions = [[NSMutableArray alloc]init];
	[self getCaptionsResouce];
}

- (void)setUpTableView
{
	self.tableView = [[UITableView alloc]initWithFrame:self.view.bounds];
	_tableView.delegate = self;
	_tableView.dataSource = self;
	self.tableView.allowsMultipleSelection = NO;
	self.tableView.allowsSelection = NO;
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	self.tableView.headerPullToRefreshText = @"";
	self.tableView.headerRefreshingText = @"";
	self.tableView.headerReleaseToRefreshText = @"";
	[self.view addSubview:self.tableView];
}

- (void)getCaptionsResouce
{
	NSArray * arr1 = [[QJDatabaseManager sharedManager] getAllAdviseCaptions:nil];
	NSMutableArray * arr2 = [[NSMutableArray alloc]initWithArray:arr1];
	
	if (arr2.count > 10)
		for (NSInteger i = 0; i < 10; i++) {
			NSInteger y = arc4random() % arr2.count;
			QJAdviseCaption * model = arr2[y];
			NSDictionary * dict = @{@"imageurl":model.imageUrl, @"caption":model.caption};
			[_allCaptions addObject:dict];
			[arr2 removeObjectAtIndex:y];
		}
		
	else
		for (QJAdviseCaption * model in arr2) {
			NSDictionary * dict = @{@"imageurl":model.imageUrl, @"caption":model.caption};
			[_allCaptions addObject:dict];
		}
}

- (void)stopRun
{
	[self.tableView headerEndRefreshing];
}

- (void)backAction
{
	[self dismissViewControllerAnimated:NO completion:nil];
	
	// _blockPopRootView();
}

- (void)viewDidUnload
{
	[super viewDidUnload];
	
	// Destroy Notifications
	[self unregisterFromNotifications];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	// modified by springox(20141105)
	//// Reset the number of selections
	// [AGIPCGridItem performSelector:@selector(resetNumberOfSelections)];
	[self reloadData];
	
	if (lastOrientation != self.interfaceOrientation)
		[self reloadData];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (BOOL)shouldAutorotate
{
	return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	[super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
	
	[self reloadData];
}

// add by springox(20141024)
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	[super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
	
	[self reloadData];
}

#pragma mark - Private

- (void)setupToolbarItems
{
	if (self.imagePickerController.toolbarItemsForManagingTheSelection != nil) {
		NSMutableArray * items = [NSMutableArray array];
		
		// Custom Toolbar Items
		for (id item in self.imagePickerController.toolbarItemsForManagingTheSelection) {
			NSAssert([item isKindOfClass:[AGIPCToolbarItem class]], @"Item is not a instance of AGIPCToolbarItem.");
			
			((AGIPCToolbarItem *)item).barButtonItem.target = self;
			((AGIPCToolbarItem *)item).barButtonItem.action = @selector(customBarButtonItemAction:);
			
			[items addObject:((AGIPCToolbarItem *)item).barButtonItem];
		}
		
		self.toolbarItems = items;
	}
	else {
		// Standard Toolbar Items
		UIBarButtonItem * selectAll = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringWithDefaultValue(@"AGIPC.SelectAll", nil, [NSBundle mainBundle], @"Select All", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(selectAllAction:)];
		UIBarButtonItem * flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
		UIBarButtonItem * deselectAll = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringWithDefaultValue(@"AGIPC.DeselectAll", nil, [NSBundle mainBundle], @"Deselect All", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(deselectAllAction:)];
		
		NSArray * toolbarItemsForManagingTheSelection = @[selectAll, flexibleSpace, deselectAll];
		self.toolbarItems = toolbarItemsForManagingTheSelection;
	}
}

- (void)reloadData
{
	// Don't display the select button until all the assets are loaded.
	[self.navigationController setToolbarHidden:[self toolbarHidden] animated:YES];
	
	[self.tableView reloadData];
	
	// [self setTitle:[self.assetsGroup valueForProperty:ALAssetsGroupPropertyName]];
	[self changeSelectionInformation];
	
	//    取消 自动滚动到底部
	//    NSInteger totalRows = [self.tableView numberOfRowsInSection:0];
	//    //Prevents crash if totalRows = 0 (when the album is empty).
	//    if (totalRows > 0) {
	//        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:totalRows-1 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
	//    }
}

- (void)doneAction:(id)sender
{
	[self.imagePickerController performSelector:@selector(didFinishPickingAssets:) withObject:self.selectedAssets];
}

- (void)selectAllAction:(id)sender
{
	for (AGIPCGridItem * gridItem in self.assets)
		gridItem.selected = YES;
}

- (void)deselectAllAction:(id)sender
{
	for (AGIPCGridItem * gridItem in self.assets)
		gridItem.selected = NO;
}

- (void)customBarButtonItemAction:(id)sender
{
	for (id item in self.imagePickerController.toolbarItemsForManagingTheSelection) {
		NSAssert([item isKindOfClass:[AGIPCToolbarItem class]], @"Item is not a instance of AGIPCToolbarItem.");
		
		if (((AGIPCToolbarItem *)item).barButtonItem == sender)
			if (((AGIPCToolbarItem *)item).assetIsSelectedBlock) {
				NSUInteger idx = 0;
				
				for (AGIPCGridItem * obj in self.assets) {
					obj.selected = ((AGIPCToolbarItem *)item).assetIsSelectedBlock(idx, ((AGIPCGridItem *)obj).asset);
					idx++;
				}
			}
	}
}

- (void)changeSelectionInformation
{
	if (self.imagePickerController.shouldDisplaySelectionInformation) {
		if (0 == [AGIPCGridItem numberOfSelections]) {
			self.navigationController.navigationBar.topItem.prompt = nil;
		}
		else {
			// self.navigationController.navigationBar.topItem.prompt = [NSString stringWithFormat:@"(%d/%d)", [AGIPCGridItem numberOfSelections], self.assets.count];
			// Display supports up to select several photos at the same time, springox(20131220)
			NSInteger maxNumber = _imagePickerController.maximumNumberOfPhotosToBeSelected;
			
			if (0 < maxNumber)
				self.navigationController.navigationBar.topItem.prompt = [NSString stringWithFormat:@"(%d/%d)", [AGIPCGridItem numberOfSelections], maxNumber];
			else
				self.navigationController.navigationBar.topItem.prompt = [NSString stringWithFormat:@"(%d/%d)", [AGIPCGridItem numberOfSelections], self.assets.count];
		}
	}
}

#pragma mark - AGGridItemDelegate Methods

- (void)agGridItem:(AGIPCGridItem *)gridItem didChangeNumberOfSelections:(NSNumber *)numberOfSelections
{
	self.navigationItem.rightBarButtonItem.enabled = (numberOfSelections.unsignedIntegerValue > 0);
	[self changeSelectionInformation];
}

- (BOOL)agGridItemCanSelect:(AGIPCGridItem *)gridItem
{
	if ((self.imagePickerController.selectionMode == AGImagePickerControllerSelectionModeSingle) && (self.imagePickerController.selectionBehaviorInSingleSelectionMode == AGImagePickerControllerSelectionBehaviorTypeRadio)) {
		for (AGIPCGridItem * item in self.assets)
			if (item.selected)
				item.selected = NO;
				
		return YES;
	}
	else {
		if (self.imagePickerController.maximumNumberOfPhotosToBeSelected > 0)
			return [AGIPCGridItem numberOfSelections] < self.imagePickerController.maximumNumberOfPhotosToBeSelected;
		else
			return YES;
	}
}

// 图片点击效果
// add by springox(20141023)
- (void)agGridItemDidTapAction:(AGIPCGridItem *)gridItem
{
	NSMutableArray * FSArr = [NSMutableArray array];
	
	for (AGIPCGridItem * gridItem in _assets) {
		FSBasicImage * firstPhoto = [[FSBasicImage alloc]initWithAssertAndGridItem:gridItem assert:gridItem.asset];
		
		[FSArr addObject:firstPhoto];
	}
	
	NSInteger index = [_assets indexOfObject:gridItem];
	FSBasicImageSource * photoSource = [[FSBasicImageSource alloc] initWithImages:FSArr];
	
	FSImageViewerViewController * imageViewController = [[FSImageViewerViewController alloc] initWithAssestImageSource:photoSource imageIndex:index withViewController:self];
	imageViewController.ifGridImage = YES;
	imageViewController.isLocal = YES;
	imageViewController.navigationController.navigationBarHidden = YES;
	
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
	
		[self.navigationController presentViewController:imageViewController animated:YES completion:nil];
	else
	
		[self.navigationController pushViewController:imageViewController animated:YES];
}

- (void)showAdaptBigImageMode:(NSInteger)index andIndexPath:(NSIndexPath *)indexPath
{}

- (void)loadAssets
{
	[self.assets removeAllObjects];
	
	__ag_weak AGIPCAssetsController * weakSelf = self;
	
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
		__strong AGIPCAssetsController * strongSelf = weakSelf;
		
		@autoreleasepool {
			[strongSelf.assetsGroup enumerateAssetsUsingBlock:^(ALAsset * result, NSUInteger index, BOOL * stop) {
				if (result == nil)
					return;
					
				if (strongSelf.imagePickerController.shouldShowPhotosWithLocationOnly) {
					CLLocation * assetLocation = [result valueForProperty:ALAssetPropertyLocation];
					
					if (!assetLocation || !CLLocationCoordinate2DIsValid([assetLocation coordinate]))
						return;
				}
				
				AGIPCGridItem * gridItem = [[AGIPCGridItem alloc] initWithImagePickerController:self.imagePickerController asset:result andDelegate:self];
				
				// Descending photos, springox(20131225)
				[strongSelf.assets addObject:gridItem];
				// [strongSelf.assets insertObject:gridItem atIndex:0];
			}];
		}
		
		dispatch_async(dispatch_get_main_queue(), ^{
			strongSelf.assets = (NSMutableArray *)[[strongSelf.assets reverseObjectEnumerator]allObjects];
			[_allAssets addObjectsFromArray:strongSelf.assets];
			[strongSelf reloadData];
		});
	});
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (isSearching == NO) {
		static NSString * CellIdentifier = @"Cell";
		
		AGIPCGridCell * cell = (AGIPCGridCell *)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		
		if (cell == nil)// 把图片和事件绑定后 放在每一个cell中
			cell = [[AGIPCGridCell alloc] initWithImagePickerController:self.imagePickerController items:[self itemsForRowAtIndexPath:indexPath] andReuseIdentifier:CellIdentifier];
		else
			cell.items = [self itemsForRowAtIndexPath:indexPath];
			
		return cell;
	}
	else {
		static NSString * cellIdentifier = @"captionCellID";
		captionCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
		cell = [[[NSBundle mainBundle]loadNibNamed:@"captionCell" owner:self options:Nil]lastObject];
		NSDictionary * dict = _allCaptions[indexPath.row];
		cell.label.text = dict[@"caption"];
		cell.image.tag = indexPath.row;
		__block NSInteger number = indexPath.row;
		ALAssetsLibrary * assetLibrary = [[ALAssetsLibrary alloc]init];
		[assetLibrary assetForURL:[NSURL URLWithString:dict[@"imageurl"]] resultBlock:^(ALAsset * asset) {
			if (number == cell.image.tag)
				cell.image.image = [UIImage imageWithCGImage:asset.thumbnail];
		} failureBlock:^(NSError * error) {}];
		
		return cell;
	}
}

#pragma mark - UISearchBar  Delegate
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
	_captions = nil;
	_searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0, 0, SCREENWIT, 40)];
	_searchBar.delegate = self;
	_searchBar.placeholder = @"搜索";
	isSearching = NO;
	[self changeSearchBarBackcolor:_searchBar];
	[_assets removeAllObjects];
	[_assets addObjectsFromArray:_allAssets];
	[self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
	[self.tableView reloadData];
	[self.view endEditing:YES];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
	if ([searchBar.text hasSuffix:@" "])
		_captions = searchBar.text;
	else
		_captions = [NSString stringWithFormat:@"%@ ", searchBar.text]; NSArray * someCaptions = [searchBar.text componentsSeparatedByString:@" "];
	[self getUpCaption:someCaptions];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
	isSearching = YES;
	searchBar.text = _captions;
	
	for (UIView * view in searchBar.subviews)
		for (UIView * view1 in view.subviews)
			if ([view1 isKindOfClass:[UIButton class]])
				if ((view1.tag >= 1000) && (view.tag < 1010))
					[view1 removeFromSuperview];
					
	UITextField * txfSearchField = [_searchBar valueForKey:@"_searchField"];
	[txfSearchField setLeftViewMode:UITextFieldViewModeAlways];
	txfSearchField.textColor = [UIColor blackColor];
	txfSearchField.clearButtonMode = UITextFieldViewModeWhileEditing;
	
	[txfSearchField setLeftViewMode:UITextFieldViewModeAlways];
	
	self.tableView.allowsSelection = YES;
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
	[self reloadData];
	searchBar.showsCancelButton = YES;
	UIButton * btn = [_searchBar valueForKey:@"_cancelButton"];
	
	if (btn)
		[btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
	isSearching = NO;
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	self.tableView.allowsSelection = NO;
	[self reloadData];
	searchBar.showsCancelButton = NO;
}

#pragma mark - UITableViewDataSource Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (!self.imagePickerController) return 0;
	
	if (isSearching == NO) {
		double numberOfAssets = (double)self.assets.count;
		NSInteger nr = ceil(numberOfAssets / self.imagePickerController.numberOfItemsPerRow);
		
		return nr;
	}
	else {
		return _allCaptions.count;
	}
}

- (NSArray *)itemsForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSMutableArray * items = [NSMutableArray arrayWithCapacity:self.imagePickerController.numberOfItemsPerRow];
	
	NSUInteger startIndex = indexPath.row * self.imagePickerController.numberOfItemsPerRow,
		endIndex = startIndex + self.imagePickerController.numberOfItemsPerRow - 1;
		
	if (startIndex < self.assets.count) {
		if (endIndex > self.assets.count - 1)
			endIndex = self.assets.count - 1;
			
		for (NSUInteger i = startIndex; i <= endIndex; i++)
			[items addObject:(self.assets)[i]];
	}
	
	return items;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForHeaderInSection:(NSInteger)section
{
	return 40;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return 38;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	return _searchBar;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
	return self.imagePickerController.itemRect.origin.y;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
	UIView * view = [[UIView alloc] init];
	
	// modified by springox(20141010)
	//    view.backgroundColor = [UIColor whiteColor];
	view.backgroundColor = [UIColor clearColor];
	return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (isSearching == NO) {
		CGRect itemRect = self.imagePickerController.itemRect;
		return itemRect.size.height + itemRect.origin.y;
	}
	else {
		return 62;
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (isSearching == YES) {
		NSDictionary * dict = _allCaptions[indexPath.row];
		
		if ([_searchBar.text hasSuffix:@" "] || (_searchBar.text == nil))
			_captions = [NSString stringWithFormat:@"%@%@ ", _searchBar.text, dict[@"caption"]];
		else
			_captions = [NSString stringWithFormat:@"%@ %@ ", _searchBar.text, dict[@"caption"]]; NSArray * someCaptions = [_captions componentsSeparatedByString:@" "];
		[self getUpCaption:someCaptions];
	}
}

- (void)getUpCaption:(NSArray *)someCaptions
{
	__block NSMutableArray * imageUrls = [[NSMutableArray alloc] init];
	
	lib = [[ALAssetsLibrary alloc]init];
	
	__block BOOL ret = NO;
	QJDatabaseManager * manager = [QJDatabaseManager sharedManager];
	__weak QJDatabaseManager * wmanager = manager;
	[manager performDatabaseUpdateBlock:^(NSManagedObjectContext * _Nonnull concurrencyContext) {
		for (NSString * str in someCaptions)
			if (![str isEqualToString:@""])
				ret = YES;
				
		NSArray * someCaptionModel;
		
		if (ret == YES)
			someCaptionModel = [wmanager getImageCaptions:concurrencyContext captions:someCaptions];
			
		for (QJImageCaption * model in someCaptionModel)
			[imageUrls addObject:model.imageUrl];
	} finished:^(NSManagedObjectContext * _Nonnull mainContext) {
		[self.assets removeAllObjects];
		__block NSUInteger number = imageUrls.count;
		
		for (NSString * imageurl in imageUrls) {
			[lib assetForURL:[NSURL URLWithString:imageurl] resultBlock:^(ALAsset * asset) {
				if ([[asset valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypePhoto]) {
					AGIPCGridItem * gridItem = [[AGIPCGridItem alloc] initWithImagePickerController:self.imagePickerController asset:asset andDelegate:self];
					[self.assets addObject:gridItem];
					
					if (self.assets.count == number)
						dispatch_async(dispatch_get_main_queue(), ^{
							[self reloadData];
						});
				}
				else {
					number = number - 1;
				}
			} failureBlock:^(NSError * error) {
				number = number - 1;
			}];
		}
		
		if (ret == NO)
			[self.assets addObjectsFromArray:_allAssets];
		isSearching = NO;
		
		_searchBar.delegate = self;
		_searchBar.text = nil;
		_searchBar.placeholder = @"搜索";
		[_searchBar endEditing:YES];
		_searchBar.showsCancelButton = NO;
		
		[self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
		float x = 13;
		NSInteger i = 0;
		
		for (UIView * view in _searchBar.subviews)
			for (UIView * view1 in view.subviews)
				if ([view1 isKindOfClass:[UIButton class]])
					if ((view1.tag >= 1000) && (view.tag < 1010))
						[view1 removeFromSuperview];
						
		for (NSString * cap in someCaptions) {
			if (cap.length > 0) {
				CGSize size = [cap sizeWithFont:[UIFont systemFontOfSize:15]];
				
				if (x + size.width + 50 > SCREENWIT)
					break;
				UITextField * txfSearchField = [_searchBar valueForKey:@"_searchField"];
				[txfSearchField setLeftViewMode:UITextFieldViewModeNever];
				_searchBar.placeholder = nil;
				UIButton * button = [LJUIController createButtonWithFrame:CGRectMake(x, 10, size.width + 25, size.height) imageName:@"1_03.png" title:cap target:nil action:nil];
				button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
				UIButton * deleteButton = [LJUIController createButtonWithFrame:CGRectMake(x + size.width + 10, 11, 15, 15) imageName:@"未标题-1_10.png" title:nil target:self action:@selector(deleteCaption:)];
				deleteButton.tag = 1000 + i;
				button.tag = 1000 + i;
				[_searchBar addSubview:button];
				[_searchBar addSubview:deleteButton];
				x += (30 + size.width);
			}
			i++;
		}
		
		[self.tableView reloadData];
	}];
}

- (void)changeSearchBarBackcolor:(UISearchBar *)mySearchBar
{
	float version = [[[UIDevice currentDevice] systemVersion] floatValue];
	
	if ([mySearchBar respondsToSelector:@selector(barTintColor)]) {
		float iosversion7_1 = 7.1;
		
		if (version >= iosversion7_1) {
			[[[[mySearchBar.subviews objectAtIndex:0] subviews] objectAtIndex:0] removeFromSuperview];
			[mySearchBar setBackgroundColor:[UIColor colorWithHexString:@"#f0f1f3"]];
		}
		else {
			[mySearchBar setBarTintColor:[UIColor clearColor]];
			[mySearchBar setBackgroundColor:[UIColor colorWithHexString:@"#f0f1f3"]];
		}
	}
	else {
		[[mySearchBar.subviews objectAtIndex:0] removeFromSuperview];
		[mySearchBar setBackgroundColor:[UIColor colorWithHexString:@"#f0f1f3"]];
	}
}

- (void)deleteCaption:(UIButton *)sender
{
	NSArray * arr = [_captions componentsSeparatedByString:@" "];
	NSMutableArray * arr1 = [[NSMutableArray alloc]initWithArray:arr];
	
	[arr1 removeObjectAtIndex:sender.tag - 1000];
	[self getUpCaption:arr1];
	[arr1 removeObject:@""];
	_captions = [arr1 componentsJoinedByString:@" "];
}

#pragma mark - AGIPCPreviewControllerDelegate Methods

- (void)previewController:(AGIPCPreviewController *)pVC didRotateFromOrientation:(UIInterfaceOrientation)fromOrientation
{
	// do noting
}

#pragma mark - Notifications

- (void)registerForNotifications
{
	[[NSNotificationCenter defaultCenter] addObserver:self
	selector:@selector(didChangeLibrary:)
	name:ALAssetsLibraryChangedNotification
	object:[AGImagePickerController defaultAssetsLibrary]];
}

- (void)unregisterFromNotifications
{
	[[NSNotificationCenter defaultCenter] removeObserver:self
	name:ALAssetsLibraryChangedNotification
	object:[AGImagePickerController defaultAssetsLibrary]];
}

- (void)didChangeLibrary:(NSNotification *)notification
{
	[self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)didChangeToolbarItemsForManagingTheSelection:(NSNotification *)notification
{
	NSLog(@"here.");
}

@end
