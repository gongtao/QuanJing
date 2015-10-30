//
//  AlbumPhotosListView.m
//  SimpleCollectionViewAPI
//
//  Created by Simple Shi on 7/18/14.
//  Copyright (c) 2014 Microthink Inc,. All rights reserved.
//
#import "AlbumPhotosListView.h"
#import "PhotoCell.h"

#import "OWTUserInfoView.h"
#import <SHBarButtonItemBlocks/SHBarButtonItemBlocks.h>
#import <FontAwesomeKit/FontAwesomeKit.h>
#import <KHFlatButton/KHFlatButton.h>
#import <UIActionSheet-Blocks/UIActionSheet+Blocks.h>

#import "OWTUserManager.h"
#import "OWTFont.h"
#import <UIColor-HexString/UIColor+HexString.h>
#import "SVProgressHUD+WTError.h"

#import "OWTUserInfoEditViewCon.h"

#import "OWTUserLikedAssetsViewCon.h"

#import "OWTFollowerUsersViewCon.h"
#import "OWTFollowingUsersViewCon.h"

#import "OWTUserAssetsViewCon.h"

#import "OWTPhotoUploadInfoViewCon.h"
#import "OWTPhotoUploadViewController.h"
#pragma mark -
#import "AlbumPhotosListView1.h"


#import "UIViewController+WTExt.h"
#import "OWTTabBarHider.h"

#import "OWTAssetEditViewCon.h"

#import <SHBarButtonItemBlocks/SHBarButtonItemBlocks.h>
#import <FontAwesomeKit/FontAwesomeKit.h>
#import <KHFlatButton/KHFlatButton.h>
#import <UIActionSheet-Blocks/UIActionSheet+Blocks.h>
#import <NBUImagePicker/NBUImagePicker.h>


#import "OWTPhotoUploadInfoViewCon.h"

#import "WYPopoverController.h"


#import "OWTAlbumInfoEditViewCon.h"

#import "OWTImageInfo.h"


#import "OWTSettingsViewCon.h"



#import "OQJSelectedViewCon2.h"


#import "OWTUserSharedAssetsViewCon.h"


#import "singleton.h"

#import "AGImagePickerController.h"

#import "SvImageInfoEditUtils.h"
#import "FSBasicImageSource.h"
#import "FSImageViewerViewController.h"
#import "FSBasicImage.h"
#import "NetStatusMonitor.h"

#import "captionCell.h"
#import "OWTTabBarHider.h"
#import "MJRefresh.h"
#import "QJPassport.h"
#import "QJDatabaseManager.h"
#import "QJAdviseCaption.h"
@interface OWTUserInfoAlbumSectionHeaderView : UICollectionReusableView
{
    KHFlatButton* _uploadButton;
    
    XHRefreshControl* _refreshControl;
    OWTTabBarHider* _tabBarHider;
    
    
}

@property (nonatomic, assign) BOOL isPresentingCurrentUser;

@end



#define kAlbumPhotosListViewPlaceHolder             [UIColor colorWithHexString:@"#939298"]

#define MAXIMAGE 9

@interface AlbumPhotosListView ()<ImageSelectedDelegate,UISearchBarDelegate,UIImagePickerControllerDelegate>
{
    
    UIScrollView *scrollV;
    UICollectionViewFlowLayout* _collectionViewLayout;
    UICollectionViewController* _collectionViewCon;
    UICollectionView* _collectionView;
    NSString *_ai;
    OWTTabBarHider* _tabBarHider;
    //
    //
    //    WYPopoverController* _popoverViewCon;
    WYPopoverController* _popoverViewCon;
    FSImageViewerViewController *imageViewController;
    NSMutableArray *_assert;
    ALAssetsLibrary *_assetsLibrary;
    ALAssetsGroup *_reloadAssetGroup;
    UISearchBar *_searchBar;
    NSMutableArray *_captionsResouce;
    NSMutableArray *_allPhotos;
    NSMutableArray *_allAsserts;
    BOOL isSearching;
    NSString *_captions;
    CGFloat _photoCellSize;
}

@property (nonatomic, strong) XHRefreshControl* refreshControl;

@property (nonatomic, strong) UILabel *selectCount;
@end

@implementation AlbumPhotosListView
{
    NSInteger _count;
}
@synthesize dataSource,assetGroup,selectCount,selectImages;
- (void)setup
{
    //    _tabBarHider = [[OWTTabBarHider alloc] init];
    
    
    [self setupCollectionView];
    [self setupRefreshControl];
    
    
    UIImage* gearImage = [[OWTFont gearIconWithSize:32] imageWithSize:CGSizeMake(32, 32)];
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem SH_barButtonItemWithImage:[gearImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]
                                                                                 style:UIBarButtonItemStylePlain
                                                                             withBlock:^(UIBarButtonItem* sender){
                                                                                 [self showSettingsViewCon];
                                                                             }];
    
    
}
//
- (void)showSettingsViewCon
{
    OWTSettingsViewCon* settingsViewCon = [[OWTSettingsViewCon alloc] init];
    //    settingsViewCon.hidesBottomBarWhenPushed = YES;
    [_tabBarHider hideTabBar];
    [self.navigationController pushViewController:settingsViewCon animated:NO];
}//
- (void)createOrUpload
{
    [UIActionSheet presentOnView:[self.view window]
                       withTitle:nil
                    cancelButton:@"取消"
               destructiveButton:nil
                    otherButtons:@[@"拍照", @"发布图片"]
                        onCancel:nil
                   onDestructive:nil
                 onClickedButton:^(UIActionSheet* actionSheet, NSUInteger buttonIndex) {
                     if (buttonIndex == 0)
                     {
                         [self takePhontos];
                     }
                     else if (buttonIndex == 1)
                     {
                         [self uploadPhotos];
                     }
                 }];
}

-(void)takePhontos{
    UIImagePickerController *controller = [[UIImagePickerController alloc] init];
    [controller setSourceType:UIImagePickerControllerSourceTypeCamera];// 设置类型
    
    
    // 设置所支持的类型，设置只能拍照，或则只能录像，或者两者都可以
    NSString *requiredMediaType = ( NSString *)kUTTypeImage;
    NSString *requiredMediaType1 = ( NSString *)kUTTypeMovie;
    NSArray *arrMediaTypes=[NSArray arrayWithObjects:requiredMediaType,nil];
    [controller setMediaTypes:arrMediaTypes];
    
    // 设置录制视频的质量
//    [controller setVideoQuality:UIImagePickerControllerQualityTypeHigh];
    //设置最长摄像时间
//    [controller setVideoMaximumDuration:10.f];
    
    
//    [controller setAllowsEditing:YES];// 设置是否可以管理已经存在的图片或者视频
    [controller setDelegate:self];// 设置代理
    [self.navigationController presentViewController:controller animated:NO completion:^{
        
    }];
}
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    NSLog(@"Picker returned successfully.");
    NSLog(@"%@", info);
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    // 判断获取类型：图片
    if ([mediaType isEqualToString:( NSString *)kUTTypeImage]){
        UIImage *theImage = nil;
        // 判断，图片是否允许修改
        if ([picker allowsEditing]){
            //获取用户编辑之后的图像
            theImage = [info objectForKey:UIImagePickerControllerEditedImage];
        } else {
            // 照片的元数据参数
            theImage = [info objectForKey:UIImagePickerControllerOriginalImage];
            
        }
        UIImageWriteToSavedPhotosAlbum(theImage, self, nil, nil);
        NSMutableArray* imageInfos = [[NSMutableArray alloc] init];
        OWTImageInfo* imageInfo = [[OWTImageInfo alloc] init];
        imageInfo.image = theImage;
        [imageInfos addObject:imageInfo];
        OWTPhotoUploadViewController *photoUploadVC = [[OWTPhotoUploadViewController alloc] initWithNibName:nil bundle:nil];
        photoUploadVC.imageInfos = imageInfos;
        photoUploadVC.hidesBottomBarWhenPushed = YES;
        photoUploadVC.isCameraImages = YES;
        photoUploadVC.doneAction = ^{
            [self.navigationController popViewControllerAnimated:YES];
        };
        photoUploadVC.doneAction = ^{
            [self.navigationController popViewControllerAnimated:YES];
        };

        [self.navigationController pushViewController:photoUploadVC animated:NO];
        
        
        
    }
    
    [picker dismissViewControllerAnimated:nil completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    
    [picker dismissViewControllerAnimated:nil completion:nil];
}

//创建相册
- (void)createAlbum
{
    OWTAlbumInfoEditViewCon* albumInfoEditViewCon = [[OWTAlbumInfoEditViewCon alloc] initForCreation];
    albumInfoEditViewCon.doneAction = ^(EWTDoneType doneType) {
        switch (doneType)
        {
            case nWTDoneTypeCancelled:
            {
                [self dismissViewControllerAnimated:YES completion:nil];
                break;
            }
                
            case nWTDoneTypeCreated:
            {
                [self dismissViewControllerAnimated:YES completion:^{
                    //                    [_collectionView reloadData];
                }];
                break;
            }
                
            case nWTDoneTypeUpdated:
            case nWTDoneTypeDeleted:
            default:
            {
                AssertTR(false);
                break;
            }
        }
    };
    
    UINavigationController* navCon = [[UINavigationController alloc] initWithRootViewController:albumInfoEditViewCon];
    [self presentViewController:navCon animated:YES completion:nil];
}

//上传照片
- (void)uploadPhotos
{
    [self uploadPhotosWithFilteredGroupNames:nil];
}
//上传本地照片
- (void)uploadPhotosLocal
{
    [self uploadPhotosWithFilteredGroupNames:[NSSet setWithObject:@"全景"]];
}

- (void)uploadPhotosWithFilteredGroupNames:(NSSet*)filteredGroupNames
{
    __weak __typeof(self) weakSelf = self;
    AGImagePickerController *imagePickerController = [[AGImagePickerController alloc] initWithFailureBlock:^(NSError *error) {
        
        if (error == nil)
        {
            NSLog(@"User has cancelled.");
            [weakSelf dismissViewControllerAnimated:YES completion:nil];
        } else
        {
            NSLog(@"Error: %@", error);
            
            // Wait for the view controller to show first and hide it after that
            double delayInSeconds = 0.5;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [weakSelf dismissViewControllerAnimated:YES completion:nil];
            });
        }
        
//        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
        
    } andSuccessBlock:^(NSArray *info) {
        NSLog(@"Info: %@", info);
        NSMutableArray* imageInfos = [NSMutableArray arrayWithCapacity:info.count];
        
        
        for (ALAsset* mediaInfo in info)
        {
            //                        NSURL* url =[NSURL URLWithString:mediaInfo[@"URLs"]];
            NSLog(@"Info: %@", mediaInfo);
            //                        NSArray *array = [mediaInfo componentsSeparatedByString:@"URLs:"]; //从字符A中分隔成2个元素的数组
            //                        NSLog(@"array:%@",array); //结果是adfsfsfs和dfsdf
            OWTImageInfo* imageInfo = [[OWTImageInfo alloc] init];
            
            imageInfo.url =[[mediaInfo valueForProperty:ALAssetPropertyAssetURL] absoluteString];
            //            ALAssetRepresentation *representation = mediaInfo.defaultRepresentation;
            //            CGImageRef cImage = [representation fullScreenImage];
            //            uint8_t *buffer = (uint8_t *)malloc(representation.size);
            //            NSError *error;
            //            NSUInteger length = [representation getBytes:buffer fromOffset:0 length:representation.size error:&error];
            //            NSData *data = [NSData dataWithBytes:buffer length:length];
            //            //                        5. 构造 CGImageSource :
            //            CGImageSourceRef cImageSource = CGImageSourceCreateWithData((__bridge CFDataRef)data, NULL);
            //
            //            CFDictionaryRef imageInfo1 = CGImageSourceCopyPropertiesAtIndex(cImageSource, 0,NULL);
            //            NSNumber *pixelWidthObj = (__bridge NSNumber *)CFDictionaryGetValue(imageInfo1, kCGImagePropertyPixelWidth);
            //            NSNumber *pixelHeightObj = (__bridge NSNumber *)CFDictionaryGetValue(imageInfo1, kCGImagePropertyPixelHeight);
            //            NSInteger orientation = [(__bridge NSNumber *)CFDictionaryGetValue(imageInfo1, kCGImagePropertyOrientation) integerValue];
            //
            //
            //            NSLog(@"aaaaaaaaaaaaaaaaaaaaal%d",orientation);
            //
            //            if (orientation ==1) {
            //                imageInfo.degree =0;
            //            }
            //            if (orientation ==8) {
            //                imageInfo.degree =180;
            //            }
            //            if (orientation ==3) {
            //                imageInfo.degree =2700;
            //            }
            //            if (orientation ==6) {
            //                imageInfo.degree =90;
            //            }
            //            if (orientation ==2) {
            //                imageInfo.degree =0;
            //            }
            //            if (orientation ==4) {
            //                imageInfo.degree =270;
            //            }
            //            if (orientation ==5) {
            //                imageInfo.degree =90;
            //            }
            //            if (orientation ==7) {
            //                imageInfo.degree =180;
            //            }
            //
            //            NSLog(@"11111111111%@",imageInfo.url);
            imageInfo.primaryColorHex = @"DDDDDD";
            imageInfo.width = 64;
            imageInfo.height = 64;
            imageInfo.asset = mediaInfo;
            [imageInfos addObject:imageInfo];
        }
        
        [weakSelf dismissViewControllerAnimated:NO
                                     completion:^{
                                         OWTPhotoUploadViewController *photoUploadVC = [[OWTPhotoUploadViewController alloc] initWithNibName:nil bundle:nil];
                                         photoUploadVC.hidesBottomBarWhenPushed = YES;
                                         photoUploadVC.imageInfos = imageInfos;
                                         photoUploadVC.isCameraImages = NO;
                                         photoUploadVC.doneAction = ^{
                                             [weakSelf.navigationController popViewControllerAnimated:YES];
                                         };
                                         photoUploadVC.cancelAction=^{
                                         [weakSelf.navigationController popViewControllerAnimated:YES];
                                         };
                                         [weakSelf.navigationController pushViewController:photoUploadVC animated:YES];
                                     }];
    }];
    
    imagePickerController.shouldShowSavedPhotosOnTop = YES;
    imagePickerController.shouldChangeStatusBarStyle = YES;
    //    imagePickerController.selection = self.selectedPhotos;
    imagePickerController.maximumNumberOfPhotosToBeSelected = 9;
    
    
    [self presentViewController:imagePickerController animated:YES completion:nil];
    
    
    // modified by springox(20140503)
    [imagePickerController showFirstAssetsController];
    
    
    
    
    
    /*
     
     //上传图片页面
     OWTPhotoUploadInfoViewCon* photoUploadInfoViewCon = [[OWTPhotoUploadInfoViewCon alloc] initWithDefaultStyle];
     [self.navigationController pushViewController:photoUploadInfoViewCon animated:NO];
     
     NBUImagePickerResultBlock resultBlock = ^(NSArray* mediaInfos)
     {
     if (mediaInfos == nil || mediaInfos.count == 0)
     {
     [self.navigationController popViewControllerAnimated:YES];
     return;
     }
     else
     {
     NSMutableArray* imageInfos = [NSMutableArray arrayWithCapacity:mediaInfos.count];
     for (NBUMediaInfo* mediaInfo in mediaInfos)
     {
     NSURL* url = mediaInfo.attributes[NBUMediaInfoOriginalMediaURLKey];
     OWTImageInfo* imageInfo = [[OWTImageInfo alloc] init];
     imageInfo.url = [url absoluteString];
     
     
     NSLog(@"pppppppppppppp%@",imageInfo.url);
     imageInfo.primaryColorHex = @"DDDDDD";
     imageInfo.width = 64;
     imageInfo.height = 64;
     [imageInfos addObject:imageInfo];
     }
     [photoUploadInfoViewCon setPendingUploadImageInfos:imageInfos];
     photoUploadInfoViewCon.doneAction = ^{
     };
     }
     };
     
     NBUImagePickerOptions options = NBUImagePickerOptionMultipleImages |
     NBUImagePickerOptionReturnMediaInfo |
     NBUImagePickerOptionStartWithLibrary |
     NBUImagePickerOptionDisableEdition |
     NBUImagePickerOptionDisableCamera |
     NBUImagePickerOptionDisableConfirmation;
     
     NBUImagePickerController* viewCon = [NBUImagePickerController startPickerWithTarget:self
     options:options
     customStoryboard:nil
     resultBlock:resultBlock];
     viewCon.assetsGroupController.selectionCountLimit = 9;
     viewCon.libraryController.filteredGroupNames = filteredGroupNames;
     
     
     */
}

//
- (void)updateRightNavBarItem
{
    //    if (_user.isCurrentUser)
    //    {
    self.navigationItem.title =@"我";
    UIButton *right=[LJUIController createButtonWithFrame:CGRectMake(0, 0, 20, 15) imageName:@"_0008_加号.png" title:nil target:self action:@selector(createOrUpload)];
    UIBarButtonItem *btn2=[[UIBarButtonItem alloc]initWithCustomView:right];
    self.navigationItem.rightBarButtonItem=btn2;
    
    //    self.navigationItem.rightBarButtonItem = [UIBarButtonItem SH_barButtonItemWithImage:[circlePlusImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]
    //                                                                                  style:UIBarButtonItemStylePlain
    //                                                                              withBlock:^(UIBarButtonItem* sender) {
    //                                                                                  [self createOrUpload];
    //                                                                              }];
    //    }
    //    else
    //    {
    //        self.navigationItem.title = @"用户信息";
    //        self.navigationItem.titleView = nil;
    //
    //        self.navigationItem.rightBarButtonItem = nil;
    //    }
}
//

- (void)setupCollectionView
{
    _collectionViewLayout = [[UICollectionViewFlowLayout alloc] init];
    
    //        _collectionViewLayout.sectionInset = UIEdgeInsetsMake(10, 0, 0, 0);//????
    
    _collectionViewCon = [[UICollectionViewController alloc] initWithCollectionViewLayout:_collectionViewLayout];
    _collectionView = _collectionViewCon.collectionView;
    _collectionView.alwaysBounceVertical = YES;
    [self addChildViewController:_collectionViewCon];
    
    _collectionView.backgroundColor = GetThemer().themeColorBackground;
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    
    UINib* headerNib = [UINib nibWithNibName:@"OWTUserInfoView" bundle:nil];
    
    [_collectionView registerNib:headerNib
      forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
             withReuseIdentifier:@"UserInfoView"];
    
    
    _collectionViewCon.view.frame = CGRectMake(0, 100, 320, 212);
    [scrollV addSubview:_collectionViewCon.view];
    //    _collectionViewCon.view.userInteractionEnabled =NO;
    
    scrollV.showsHorizontalScrollIndicator = YES;
    _collectionView.bounces =NO;
    
}

- (void)setupRefreshControl
{
    
    _refreshControl = [[XHRefreshControl alloc] initWithScrollView:_collectionView delegate:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _tabBarHider=[[OWTTabBarHider alloc]init];
    self.user =GetUserManager().currentUser;

    self.view.backgroundColor=[UIColor colorWithHexString:@"#f6f6f6"];
    [self setup];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(inputKeyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(inputKeyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    isSearching=NO;
    OWTUserAssetsInfo* assetsInfo = _user.assetsInfo;
    NSInteger photoNum = assetsInfo.publicAssetNum;
    if (assetsInfo != nil)
    {
        if (_user.isCurrentUser)
        {
            photoNum += assetsInfo.privateAssetNum;
        }
        
        //        NSLog(@"000000000000000000%d",photoNum);
    }
    else
    {
        
    }
    
    
    _captionsResouce=[[NSMutableArray alloc]init];
    _assert = [[NSMutableArray alloc]init];
    _allAsserts=[[NSMutableArray alloc]init];
    dataSource=[NSMutableArray array];
    _allPhotos=[[NSMutableArray alloc]init];
    [self setUpTableView];
        }
-(void)setUpTableView
{
    CGRect viewFrame=self.view.frame;
    _photoCellSize = (viewFrame.size.width - 30.0) / 3;
    self.maintableview=[[UITableView alloc] initWithFrame:CGRectMake(0, 0, viewFrame.size.width, viewFrame.size.height-120+14) style:UITableViewStylePlain];
    [self.maintableview setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    self.maintableview.backgroundColor=[UIColor colorWithHexString:@"#f6f6f6"];
    [self.maintableview setDelegate:self];
    [self.maintableview setDataSource:self];
    [self.view addSubview:self.maintableview];
    [self.maintableview addHeaderWithTarget:self action:@selector(refresh)];
    self.maintableview.headerRefreshingText=@"";
    self.maintableview.headerPullToRefreshText=@"";
    self.maintableview.headerReleaseToRefreshText=@"";
    _searchBar=[[UISearchBar alloc]initWithFrame:CGRectMake(0, 0, SCREENWIT, 44.0)];
    _searchBar.delegate=self;
    _searchBar.placeholder=@"搜索";
    [self changeSearchBarBackcolor:_searchBar];
    [self getImgsWithGroup:assetGroup];
    
    _maintableview.tableHeaderView =_collectionView;
    [self getCaptionsResouce];
}
-(void)getCaptionsResouce
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        QJDatabaseManager *manager=[QJDatabaseManager sharedManager];
        dispatch_semaphore_t sem=dispatch_semaphore_create(0);
        __weak QJDatabaseManager *wmanager=manager;
        [manager performDatabaseUpdateBlock:^(NSManagedObjectContext * concurrencyContext) {
            NSArray *arr1=[wmanager getAllAdviseCaptions:concurrencyContext];
            NSMutableArray *arr2=[[NSMutableArray alloc]initWithArray:arr1];
            if (arr2.count>10) {
                for (NSInteger i=0;i<10;i++) {
                    NSInteger y=arc4random()%arr2.count;
                    QJAdviseCaption *model=arr2[y];
                    NSDictionary *dict=@{@"imageurl":model.imageUrl,@"caption":model.caption};
                    [_captionsResouce addObject:dict];
                    [arr2 removeObjectAtIndex:y];
                }
            }else
            {
                for (QJAdviseCaption *model in arr2) {
                    NSDictionary *dict=@{@"imageurl":model.imageUrl,@"caption":model.caption};
                    [_captionsResouce addObject:dict];
                }
            }
            
        } finished:^(NSManagedObjectContext * mainContext) {
            dispatch_semaphore_signal(sem);
        }];
        dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    });
    
}
-(void)changeSearchBarBackcolor:(UISearchBar *)mySearchBar
{
    UITextField *txfSearchField = [mySearchBar valueForKey:@"_searchField"];
    txfSearchField.textColor = kAlbumPhotosListViewPlaceHolder;
    txfSearchField.clearButtonMode = UITextFieldViewModeNever;
//    mySearchBar.text = @"搜索";
    mySearchBar.searchBarStyle = UISearchBarStyleMinimal;
    mySearchBar.backgroundColor = [UIColor whiteColor];
    [mySearchBar setImage:[UIImage imageNamed:@"我的页面搜索icon.png"] forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
    [mySearchBar setSearchFieldBackgroundImage:[UIImage imageNamed:@"我的页面搜索框.png"] forState:UIControlStateNormal];
    
    
    //    [mySearchBar setSearchFieldBackgroundImage:nil forState:UIControlStateNormal];
    //    float version = [[[ UIDevice currentDevice ] systemVersion ] floatValue ];
    //
    //    if ([ mySearchBar respondsToSelector : @selector (barTintColor)]) {
    //
    //        float  iosversion7_1 = 7.1 ;
    //
    //        if (version >= iosversion7_1)
    //
    //        {
    //            [[[[ mySearchBar . subviews objectAtIndex : 0 ] subviews ] objectAtIndex : 0 ] removeFromSuperview ];
    //            //            [mySearchBar setBackgroundColor:[UIColor clearColor]];
    //            [ mySearchBar setBackgroundColor :[ UIColor colorWithHexString:@"#ffffff"]];
    //        }
    //        else
    //        {
    //            [ mySearchBar setBarTintColor :[ UIColor clearColor ]];
    //            //            [mySearchBar setBackgroundColor:[UIColor clearColor]];
    //            [ mySearchBar setBackgroundColor :[ UIColor colorWithHexString:@"#ffffff"]];
    //        }
    //    }
    //    else
    //    {
    //        [[ mySearchBar . subviews objectAtIndex : 0 ] removeFromSuperview ];
    //        //        [mySearchBar setBackgroundColor:[UIColor clearColor]];
    //        [ mySearchBar setBackgroundColor :[ UIColor colorWithHexString:@"#ffffff"]];
    //    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void) preView_Action{
    
}
//选中以后的操作
-(void) select_Compeleted{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RETURN_IMAGE_SELECT" object:nil userInfo:@{@"images":selectImages}];
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark -键盘的收起和出现
-(void)inputKeyboardWillShow:(NSNotification *)notification
{
    
}
-(void)inputKeyboardWillHide:(NSNotification *)notification
{
    //    _maintableview.frame=CGRectMake(0, 0, SCREENWIT,self.view.frame.size.height);
}
#pragma mark -UISearchBar delegate
-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    _captions=nil;
    _searchBar=[[UISearchBar alloc]initWithFrame:CGRectMake(0, 0, SCREENWIT, 44.0)];
    _searchBar.delegate=self;
    _searchBar.placeholder=@"搜索";
    [self changeSearchBarBackcolor:_searchBar];
    isSearching=NO;
    [dataSource removeAllObjects];
    [dataSource addObjectsFromArray:_allPhotos];
    [_assert removeAllObjects];
    _assert=(NSMutableArray *)[[_allAsserts reverseObjectEnumerator]allObjects];
    [_maintableview setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [_maintableview reloadData];
    [self.view endEditing:YES];
    
}
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    if ([searchBar.text hasSuffix:@" "]) {
        _captions=searchBar.text;
    }else{
        _captions=[NSString stringWithFormat:@"%@ ",searchBar.text];}
    NSArray *someCaptions=[searchBar.text componentsSeparatedByString:@" "];
    [self getUpCaption:someCaptions ];
    [self.view endEditing:YES];
}
-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    
}
-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    searchBar.text=_captions;
    for (UIView *view in searchBar.subviews) {
        for (UIView *view1 in view.subviews) {
            if ([view1 isKindOfClass:[UIButton class]]) {
                if (view1.tag>=1000&&view.tag<1010) {
                    [view1 removeFromSuperview];
                }}}
    }
    
    isSearching=YES;
    UITextField *txfSearchField = [_searchBar valueForKey:@"_searchField"];
    [txfSearchField setLeftViewMode:UITextFieldViewModeAlways];
    txfSearchField.textColor = [UIColor blackColor];
    txfSearchField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [_maintableview setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    if(_captionsResouce.count==0)
    {
        [self getCaptionsResouce];
    }
    [_maintableview reloadData];
    if (_captionsResouce.count>0) {
        [_maintableview scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
    _searchBar.showsCancelButton=YES;
    UIButton *btn=[_searchBar valueForKey:@"_cancelButton"];
    if (btn) {
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }

    //    [searchBar becomeFirstResponder];
}

-(void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    UITextField *txfSearchField = [searchBar valueForKey:@"_searchField"];
    txfSearchField.textColor = kAlbumPhotosListViewPlaceHolder;
    txfSearchField.clearButtonMode = UITextFieldViewModeNever;
    searchBar.text = @"搜索";
    
    isSearching=NO;
    searchBar.showsCancelButton=NO;
    [_maintableview setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [_maintableview reloadData];
}

#pragma mark - Table view data source
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (isSearching==NO) {
        return _searchBar;
    }else
    {
        return _searchBar;}
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 44.0;
}
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (isSearching==NO) {
        if (indexPath.row == 0) {
            return _photoCellSize + 15.0;
        }
        return _photoCellSize + 5.0;
        //        return 80.0f;
    }else {
        return 62;
    }
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (isSearching==NO) {
        NSInteger rowcount=(dataSource.count%3)>0?(dataSource.count/3+1):dataSource.count/3;
        return rowcount;}
    else {
        return _captionsResouce.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (isSearching==NO) {
        static NSString *identifier=@"cell";
        PhotoCell *cell=[tableView dequeueReusableCellWithIdentifier:identifier];
        if(!cell){
            cell=[[NSBundle mainBundle] loadNibNamed:@"PhotoCell" owner:self options:nil][0];
        }
        CGFloat offsetX = 10.0;
        CGFloat offsetY = 0.0;
        if (indexPath.row == 0.0) {
            offsetY = 10.0;
        }
        if(dataSource.count>indexPath.row*3){
            cell.image1.frame = CGRectMake(offsetX, offsetY, _photoCellSize, _photoCellSize);
            cell.image1.image=dataSource[indexPath.row*3][@"image"];
            cell.image1.tag=indexPath.row*3;
            [cell.image1.gestureRecognizers[0] setEnabled:YES];
            if([dataSource[indexPath.row*3][@"selected"] boolValue]){
                cell.selected1.hidden=NO;
            }else{
                cell.selected1.hidden=YES;
            }
            offsetX += 5.0 + _photoCellSize;
        }
        if(dataSource.count>indexPath.row*3+1) {
            cell.image2.frame = CGRectMake(offsetX, offsetY, _photoCellSize, _photoCellSize);
            cell.image2.image=dataSource[indexPath.row*3+1][@"image"];
            cell.image2.tag=indexPath.row*3+1;
            [cell.image2.gestureRecognizers[0] setEnabled:YES];
            if([dataSource[indexPath.row*3+1][@"selected"] boolValue]){
                cell.selected2.hidden=NO;
            }else{
                cell.selected2.hidden=YES;
            }
            offsetX += 5.0 + _photoCellSize;
        }
        if(dataSource.count>indexPath.row*3+2){
            cell.image3.frame = CGRectMake(offsetX, offsetY, _photoCellSize, _photoCellSize);
            cell.image3.image=dataSource[indexPath.row*3+2][@"image"];
            cell.image3.tag=indexPath.row*3+2;
            [cell.image3.gestureRecognizers[0] setEnabled:YES];
            if([dataSource[indexPath.row*3+2][@"selected"] boolValue]){
                cell.selected3.hidden=NO;
            }else{
                cell.selected3.hidden=YES;
            }
        }
        //        if(dataSource.count>indexPath.row*4+3){
        //            cell.image4.image=dataSource[indexPath.row*4+3][@"image"];
        //            cell.image4.tag=indexPath.row*4+3;
        //            [cell.image4.gestureRecognizers[0] setEnabled:YES];
        //            if([dataSource[indexPath.row*4+3][@"selected"] boolValue]){
        //                cell.selected4.hidden=NO;
        //            }else{
        //                cell.selected4.hidden=YES;
        //            }
        //        }
        cell.indexPath=indexPath;
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        cell.backgroundColor=[UIColor clearColor];
        cell.delegate=self;
        return cell;
    }
    else{
        static NSString *cellIdentifier=@"captionCellID";
        captionCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell=[[[NSBundle mainBundle]loadNibNamed:@"captionCell" owner:self options:Nil]lastObject];
        }
        if (indexPath.row>=_captionsResouce.count) {
            cell.image.image=nil;
            cell.label.text=nil;
            cell.number.titleLabel.text=nil;
            [cell.number setBackgroundImage:nil forState:UIControlStateNormal];
            return cell;
        }
        NSDictionary *dict=_captionsResouce[indexPath.row];
        cell.label.text=dict[@"caption"];
        cell.image.tag=indexPath.row;
        __block NSInteger number=indexPath.row;
        ALAssetsLibrary *assetLibrary=[[ALAssetsLibrary alloc]init];
[assetLibrary assetForURL:[NSURL URLWithString:dict[@"imageurl"]]resultBlock:^(ALAsset *asset) {
    if (number==cell.image.tag) {
        cell.image.image=[UIImage imageWithCGImage:asset.thumbnail];
    }
} failureBlock:^(NSError *error) {
    
}];
        UIImage *image1=[UIImage imageNamed:@"未标题-2.png"];
        image1=[image1 stretchableImageWithLeftCapWidth:16 topCapHeight:0];
        return cell;
    }
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (isSearching==YES&&indexPath.row<_captionsResouce.count) {
        NSDictionary *dict=_captionsResouce[indexPath.row];
        if ([_searchBar.text hasSuffix:@" " ]||_searchBar.text==nil) {
            _captions=[NSString stringWithFormat:@"%@%@ ",_searchBar.text,dict[@"caption"]];
        }else{
            _captions=[NSString stringWithFormat:@"%@ %@ ",_searchBar.text,dict[@"caption"]];}
        NSArray *someCaptions=[_captions componentsSeparatedByString:@" "];
        [_searchBar resignFirstResponder];
        [self getUpCaption:someCaptions ];
    }
}
-(void)getUpCaption:(NSArray *)someCaptions
{
    _assetsLibrary=[[ALAssetsLibrary alloc] init];
    [_assert removeAllObjects];
    [dataSource removeAllObjects];
    
    NSMutableArray *imageUrls=[[NSMutableArray alloc]init];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        QJDatabaseManager *manager=[QJDatabaseManager sharedManager];
        dispatch_semaphore_t sem=dispatch_semaphore_create(0);
        __weak QJDatabaseManager *wmanager=manager;
    [manager performDatabaseUpdateBlock:^(NSManagedObjectContext *  concurrencyContext) {
        BOOL ret=NO;
        for (NSString *str in someCaptions) {
            if (![str isEqualToString:@""]) {
                ret=YES;
            }
        }
        NSArray *someCaptionModel;
        if (ret==YES) {
            someCaptionModel=[wmanager getImageCaptions:concurrencyContext captions:someCaptions];
        }
        
        for (QJImageCaption *model in someCaptionModel) {
            [imageUrls addObject:model.imageUrl];
        }
        __block NSUInteger number=imageUrls.count;
        for (NSString *imageurl in imageUrls) {
            [_assetsLibrary assetForURL:[NSURL URLWithString:imageurl] resultBlock:^(ALAsset *asset) {
                if ([[asset valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypePhoto]) {
                    OWTImageInfo* imageInfo = [[OWTImageInfo alloc] init];
                    imageInfo.url =[[asset valueForProperty:ALAssetPropertyAssetURL] absoluteString];
                    imageInfo.primaryColorHex = @"DDDDDD";
                    imageInfo.width = 64;
                    imageInfo.height = 64;
                    NSDictionary *dic=@{@"image":[UIImage imageWithCGImage:asset.thumbnail],@"selected":@"NO",@"imageInfo":imageInfo};
                    
                    [dataSource addObject:dic];
                    [_assert addObject:asset];
                    if (dataSource.count==number) {
                        _assert=(NSMutableArray *)[[_assert reverseObjectEnumerator]allObjects];
                        //                        dataSource=(NSMutableArray *)[[dataSource reverseObjectEnumerator]allObjects];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [_maintableview reloadData];
                        });
                    }
                }
                else{
                    number=number-1;
                }
            } failureBlock:^(NSError *error) {
                number=number-1;
            }];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            isSearching=NO;
            if (ret==NO) {
                [dataSource addObjectsFromArray:_allPhotos];
                _assert=(NSMutableArray *)[[_allAsserts reverseObjectEnumerator]allObjects];
            }
            _searchBar=[[UISearchBar alloc]initWithFrame:CGRectMake(0, 0, SCREENWIT, 44.0)];
            _searchBar.delegate=self;
            _searchBar.placeholder=@"搜索";
            _searchBar.translucent=YES;
            [self changeSearchBarBackcolor:_searchBar];
            [_maintableview setSeparatorStyle:UITableViewCellSeparatorStyleNone];
            float x=16;
            NSInteger i=0;
            for (NSString *cap in someCaptions) {
                if (cap.length>0) {
                    CGSize size=[cap sizeWithFont:[UIFont systemFontOfSize:15]];
                    if (x+size.width+50>SCREENWIT) {
                        break;
                    }
                    UITextField *txfSearchField = [_searchBar valueForKey:@"_searchField"];
                    [txfSearchField setLeftViewMode:UITextFieldViewModeNever];
                    _searchBar.placeholder=nil;
                    UIButton *button=[LJUIController createButtonWithFrame:CGRectMake(x, 13, size.width+25, size.height) imageName:@"1_03.png" title:cap target:nil action:nil];
                    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
                    UIButton *deleteButton=[LJUIController createButtonWithFrame:CGRectMake(x+size.width+10, 14, 15, 15) imageName:@"未标题-1_10.png" title:nil target:self action:@selector(deleteCaption:)];
                    deleteButton.tag=1000+i;
                    button.tag=1000+i;
                    [_searchBar addSubview:button];
                    [_searchBar addSubview:deleteButton];
                    x+=(30+size.width);
                }
                i++;
            }
            if (imageUrls.count==0) {
                [_maintableview reloadData];
            }
        });
    } finished:^(NSManagedObjectContext *  mainContext) {
        dispatch_semaphore_signal(sem);
    }];
                dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    });
    
}

-(void)deleteCaption:(UIButton *)sender
{
    NSArray *arr=[_captions componentsSeparatedByString:@" "];
    NSMutableArray *arr1=[[NSMutableArray alloc]initWithArray:arr];
    [arr1 removeObjectAtIndex:sender.tag-1000];
    [self getUpCaption:arr1 ];
    
    [arr1 removeObject:@""];
    _captions=[arr1 componentsJoinedByString:@" "];
    
}
//选中image之后的回调方法 图片
-(void) imagecellSelected:(PhotoCell *)cell andImgTag:(NSInteger)tag andIndexPath:(NSIndexPath *)indexPath{
    [_tabBarHider hideTabBar];
    [self showAdaptBigImageMode:tag andIndexPath:indexPath];
}

-(void)showAdaptBigImageMode:(NSInteger)index andIndexPath:(NSIndexPath*)indexPath
{
    NSDictionary *dict=dataSource[0];
    OWTImageInfo *imageInfo=dict[@"imageInfo"];
    ALAsset *assert1=_assert.lastObject;
    if (![imageInfo.url isEqualToString:[[assert1 valueForProperty:ALAssetPropertyAssetURL] absoluteString]]) {
        _assert=(NSMutableArray *)[[_assert reverseObjectEnumerator]allObjects];
    }
    NSMutableArray *FSArr = [NSMutableArray array];
    for(ALAsset *assert in _assert)
    {
        NSLog(@"%@",assert.description);
        FSBasicImage *firstPhoto = [[FSBasicImage alloc] initWithAssert:assert];
        [FSArr addObject:firstPhoto];
    }
    NSLog(@"%d",FSArr.count);
    NSArray *fsImages = [[FSArr reverseObjectEnumerator]allObjects];
    FSBasicImageSource *photoSource = [[FSBasicImageSource alloc] initWithImages:fsImages];
    
    imageViewController = [[FSImageViewerViewController alloc] initWithAssestImageSource:photoSource imageIndex:index withViewController:self];
    imageViewController.ifCetainPage = YES;
    imageViewController.assetData=dataSource;
    imageViewController.isLocal=YES;
    imageViewController.navigationController.navigationBarHidden =YES;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        
        [self.navigationController presentViewController:imageViewController animated:YES completion:nil];
    }
    else {
        
        [self.navigationController pushViewController:imageViewController animated:YES];
    }
}
-(void) caculateSelectImage:(NSInteger) index andIndexPath:(NSIndexPath *)indexPath{
    
    //这里被压缩的原因是 我们上传的是owtimageimfo
    NSMutableDictionary *mdic=[dataSource[index] mutableCopy];
    NSLog(@"baaaaaaaaaaaaaaaaa%@",mdic[@"imageInfo"]);
    if(selectImages.count<MAXIMAGE){
        [mdic setValue:@"YES" forKey:@"selected"];
        [selectImages addObject:mdic[@"imageInfo"]];
        
    }else{
        UIAlertView *alertView=[[UIAlertView alloc] initWithTitle:@"提示" message:[NSString stringWithFormat:@"最多只能选择%d张图片",MAXIMAGE] delegate:nil cancelButtonTitle:@"我知道了" otherButtonTitles:nil, nil];
        [alertView show];
    }
    
    OWTPhotoUploadInfoViewCon* photoUploadInfoViewCon = [[OWTPhotoUploadInfoViewCon alloc] initWithDefaultStyle];
    //
    [self.navigationController pushViewController:photoUploadInfoViewCon animated:NO];
    [photoUploadInfoViewCon setPendingUploadImageInfos:selectImages];
    
    
    photoUploadInfoViewCon.doneAction = ^{
        
        NSLog(@"llllllllllllllllllll");
        [self dismissModalViewControllerAnimated:YES];
    };
    
//    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    
}

//加载相册
-(void) loadAlbumsAgain{
    _assetsLibrary=[[ALAssetsLibrary alloc] init];
    void (^assetsGroupsEnumerationBlock)(ALAssetsGroup *, BOOL *) = ^(ALAssetsGroup *assetsGroup, BOOL *stop) {
        [assetsGroup setAssetsFilter:[ALAssetsFilter allPhotos]];
        if(assetsGroup.numberOfAssets > 0) {
            if (_count) {
                if (assetsGroup.numberOfAssets!=_count) {
                    [[NSNotificationCenter defaultCenter]postNotificationName:@"imagereload" object:assetsGroup];
                }
            }
            _count=assetsGroup.numberOfAssets;
            _reloadAssetGroup= assetGroup;
            _captions=nil;
            _searchBar=[[UISearchBar alloc]initWithFrame:CGRectMake(0, 0, SCREENWIT, 44.0)];
            _searchBar.delegate=self;
            _searchBar.placeholder=@"搜索";
            [self changeSearchBarBackcolor:_searchBar];
            isSearching=NO;
            [self getImgsWithGroup:_reloadAssetGroup];
            
        }
        
    };
    //
    void (^assetsGroupsFailureBlock)(NSError *) = ^(NSError *error) {
        NSLog(@"Error: %@", [error localizedDescription]);
    };
    // Enumerate Camera Roll
    [_assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:assetsGroupsEnumerationBlock failureBlock:assetsGroupsFailureBlock];
}

-(void)getImgsWithGroup:(ALAssetsGroup *) ptotoGroup{
    /**
     *  根据相册组。获取每组的图片
     *
     *  @param result 含有每张照片的信息
     *  @param index  当前遍历的下标
     *  @param stop   是否停止遍历
     *
     *  @return
     */
    NSMutableArray *array = [[NSMutableArray alloc] init] ;
    [_allAsserts removeAllObjects];
    [_assert removeAllObjects];
    [dataSource removeAllObjects];
    [_allPhotos removeAllObjects];
    if (ptotoGroup==nil) {
        return;
    }
    /*  [group enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) */
    [ptotoGroup enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
        if (result) {
            
            if (_assert.count>500) {
                return ;
            }
            if ([[result valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypePhoto]) {
                
                OWTImageInfo* imageInfo = [[OWTImageInfo alloc] init];
                
                imageInfo.url =[[result valueForProperty:ALAssetPropertyAssetURL] absoluteString];
                //                NSLog(@"11111111111%@",imageInfo.url);
                imageInfo.primaryColorHex = @"DDDDDD";
                imageInfo.width = 64;
                imageInfo.height = 64;
                UIImage *image = [UIImage imageWithCGImage:result.thumbnail];
                if(image == nil){
                    return;
                }
                NSDictionary *dic=@{@"image":image,@"selected":@"NO",@"imageInfo":imageInfo};
                [array addObject:dic];
                [_assert addObject:result];

                

                
            }
        }
    }];
    
    singleton *oneS = [singleton shareData];
    oneS.value = array.count;
    [dataSource addObjectsFromArray:array];
    _allAsserts= _assert ;
    [_allPhotos addObjectsFromArray:array];
    [self.maintableview reloadData];
    [_collectionView reloadData];
}
-(UIButton *) creatbtn:(NSString *)title withFrame:(CGRect) rect withAction:(SEL)action{
    UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
    [btn addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setFrame:rect];
    [btn.titleLabel setFont:[UIFont systemFontOfSize:13.0f]];
    [btn setBackgroundColor:[UIColor colorWithRed:0/255.0 green:127/255.0 blue:245/255.0 alpha:1.0f]];
    [btn.layer setCornerRadius:3.0f];
    return btn;
}


-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex==0&&alertView.tag==333) {
        OWTUserInfoEditViewCon* userInfoEditViewCon = [[OWTUserInfoEditViewCon alloc] initWithNibName:nil bundle:nil];
        userInfoEditViewCon.user = _user;
        
        userInfoEditViewCon.cancelAction = ^{
            [self dismissViewControllerAnimated:YES completion:nil];
        };
        
        userInfoEditViewCon.doneFunc = ^{
            [self dismissViewControllerAnimated:YES completion:^{
            }];
        };
        
        UINavigationController* navCon = [[UINavigationController alloc] initWithRootViewController:userInfoEditViewCon];
        [self presentViewController:navCon animated:YES completion:nil];
        //        [self.navigationController pushViewController:userInfoEditViewCon animated:YES];
    }
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //    [self showTabBar];
    //    [self.view setBackgroundColor:[UIColor colorWithWhite:0.9 alpha:1]];
    _count=dataSource.count;
    _user =GetUserManager().currentUser;
//    OWTUserManager* am = GetUserManager();
//    if (_user.nickname.length==0 && !am.ifLoginFail) {
//        if (_ai==nil) {
//            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"请先完善个人信息" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
//            alert.tag=333;
//            [alert show];}
//    }
//    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    [_tabBarHider showTabBar];
    [_collectionViewCon.collectionView reloadData];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [_tabBarHider showTabBar];
    
    [self.view setBackgroundColor:[UIColor colorWithWhite:0.9 alpha:1]];
    //    [self substituteNavigationBarBackItem];
    
    
    [self refreshIfNeeded];
    
    [self refreshUserAssetsIfNeeded];
    
}


- (void)refreshUserAssetsIfNeeded
{
    if (_user == nil)
    {
        return;
    }
    
    if (_user.assetsInfo != nil && _user.assetsInfo.assets != nil)
    {
        return;
    }
    
    [_assetViewCon1 manualRefresh];
}

- (void)setUser:(OWTUser *)user
{
    _user = user;
    [self updateRightNavBarItem];
    [_collectionView reloadData];
}


- (void)refreshIfNeeded
{
    if (_user == nil)
    {
        return;
    }
    
    if (_user.isPublicInfoAvailable)
    {
        return;
    }
    
    [self manualRefresh];
}

- (void)manualRefresh
{
    [_refreshControl startPullDownRefreshing];
}

- (void)refresh
{
    [self.maintableview headerEndRefreshing];
                                 [self loadAlbumsAgain];
                                 [self getImgsWithGroup:_reloadAssetGroup];
                                 [_collectionView reloadData];
   
//    OWTUserManager* um = GetUserManager();
//    
//    [um refreshPublicInfoForUser:_user
//                         success:^{
//                             [_refreshControl endPullDownRefreshing];
//                             [self loadAlbumsAgain];
//                             [self getImgsWithGroup:_reloadAssetGroup];
//                             [_collectionView reloadData];
//                             
//                         }
//                         failure:^(NSError* error) {
//                             [_refreshControl endPullDownRefreshing];
//                             [_collectionView reloadData];
//                             if (![NetStatusMonitor isExistenceNetwork]) {
//                                 [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"NETWORK_ERROR", @"Notify user network error.")];
//                             }
//                             else{
//                                 [SVProgressHUD showError:error];
//                             }
//                             
//                         }];
}

#pragma mark - Collection View Datasource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 4;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 0;
    }
    
    return 0;
}



// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    return nil;
}

// The view that is returned must be retrieved from a call to -dequeueReusableSupplementaryViewOfKind:withReuseIdentifier:forIndexPath:
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if (kind == UICollectionElementKindSectionHeader)
    {
        if (indexPath.section == 0)
        {
            OWTUserInfoView* userInfoView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                                               withReuseIdentifier:@"UserInfoView"
                                                                                      forIndexPath:indexPath];
            __weak AlbumPhotosListView* wself = self;
            userInfoView.selfNum=wself.dataSource.count;
            userInfoView.user = [QJPassport sharedPassport].currentUser;
            userInfoView.editUserInfoAction = ^{ [wself editUserInfo]; };
            userInfoView.showLikedAssetsAction = ^{ [wself showLikedAssets]; };//云相册
            userInfoView.showFollowingsAction = ^{ [wself showFollowings]; };
            userInfoView.showFollowersAction = ^{ [wself showFollowers]; };
            userInfoView.showAssetsAction = ^{ [wself showLocalAssets]; };//本地相册
            //            userInfoView.showLikedAssetsAction = ^{ [wself showAssets]; };//发布图片
            //            userInfoView.showFollowingsAction = ^{ [wself showCollectionAssets]; };//收藏
            //            userInfoView.showFollowersAction = ^{ [wself showFollowings]; };//圈子
            
            return userInfoView;
        }
    }
    
    return nil;
}
// 本机按钮触发
- (void)showLocalAssets
{
        __weak __typeof(self) weakSelf = self;
    //修改成后来的
    [_tabBarHider hideTabBar];
    AGImagePickerController *imagePickerController = [[AGImagePickerController alloc] initWithFailureBlock:^(NSError *error) {
        
        if (error == nil)
        {
            NSLog(@"User has cancelled.");
            [self dismissModalViewControllerAnimated:YES];
        } else
        {
            NSLog(@"Error: %@", error);
            
            // Wait for the view controller to show first and hide it after that
            double delayInSeconds = 0.5;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [self dismissModalViewControllerAnimated:YES];
            });
        }
        

        
    } andSuccessBlock:^(NSArray *info) {
        NSLog(@"Info: %@", info);
        NSMutableArray* imageInfos = [NSMutableArray arrayWithCapacity:info.count];
        
        ALAsset *asset=info[0];
        for (ALAsset* mediaInfo in info)
        {
            OWTImageInfo* imageInfo = [[OWTImageInfo alloc] init];
            imageInfo.url =[[mediaInfo valueForProperty:ALAssetPropertyAssetURL] absoluteString];
            imageInfo.primaryColorHex = @"DDDDDD";
            imageInfo.width = 64;
            imageInfo.height = 64;
            imageInfo.asset=mediaInfo;
            [imageInfos addObject:imageInfo];
        }
        [weakSelf dismissViewControllerAnimated:NO
                                     completion:^{
                                         OWTPhotoUploadViewController *photoUploadVC = [[OWTPhotoUploadViewController alloc] initWithNibName:nil bundle:nil];
                                         photoUploadVC.hidesBottomBarWhenPushed = YES;
                                         photoUploadVC.imageInfos = imageInfos;
                                         photoUploadVC.isCameraImages = NO;
                                         photoUploadVC.cancelAction=^{
                                         [weakSelf.navigationController popViewControllerAnimated:YES];
                                         };
                                         photoUploadVC.doneAction = ^{
                                             [weakSelf.navigationController popViewControllerAnimated:YES];
                                         };
                                         [weakSelf.navigationController pushViewController:photoUploadVC animated:YES];
                                     }];
        
//        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    }];
    
    imagePickerController.shouldShowSavedPhotosOnTop = YES;
    imagePickerController.shouldChangeStatusBarStyle = NO;
    //    imagePickerController.selection = self.selectedPhotos;
    imagePickerController.maximumNumberOfPhotosToBeSelected = 9;
    if ([_assert count]<1) {
        return;
    }
    [self presentModalViewController:imagePickerController animated:YES];
    [imagePickerController showFirstAssetsController];
    
}
- (void)hideTabBar {
    if (self.tabBarController.tabBar.hidden == YES) {        return;    }    UIView *contentView;    if ( [[self.tabBarController.view.subviews objectAtIndex:0] isKindOfClass:[UITabBar class]] )        contentView = [self.tabBarController.view.subviews objectAtIndex:1];    else        contentView = [self.tabBarController.view.subviews objectAtIndex:0];        contentView.frame = CGRectMake(contentView.bounds.origin.x,  contentView.bounds.origin.y,  contentView.bounds.size.width, contentView.bounds.size.height + self.tabBarController.tabBar.frame.size.height);                self.tabBarController.tabBar.hidden = YES;
}

//相册按钮触发
- (void)showLikedAssets
{
    //发布的照片
    OWTUserAssetsViewCon* likedAssetsViewCon = [[ OWTUserAssetsViewCon alloc] initWithNibName:nil bundle:nil];
    likedAssetsViewCon.user1 = [QJPassport sharedPassport].currentUser;
    [_tabBarHider hideTabBar];
    likedAssetsViewCon.hidesBottomBarWhenPushed=YES;
    [self.navigationController pushViewController:likedAssetsViewCon animated:YES];
}


//收藏
- (void)showFollowings
{
    _currentUser = [[QJPassport sharedPassport]currentUser];
    OWTUserSharedAssetsViewCon* likedAssetsViewCon = [[OWTUserSharedAssetsViewCon alloc] initWithUser:_currentUser ];
    likedAssetsViewCon.lightbox = [_currentUser.collectAmount intValue];
    likedAssetsViewCon.hidesBottomBarWhenPushed=YES;
    [_tabBarHider hideTabBar];
    [self.navigationController pushViewController:likedAssetsViewCon animated:YES];
    
}
//圈子按钮触发
- (void)showFollowers
{
    OQJSelectedViewCon2* followerUsersViewCon = [[OQJSelectedViewCon2 alloc] initWithNibName:nil bundle:nil];
    //    followerUsersViewCon.user = _user;
    followerUsersViewCon.hidesBottomBarWhenPushed=YES;
    [_tabBarHider hideTabBar];
    [self.navigationController pushViewController:followerUsersViewCon animated:YES];
}

//编辑按钮触发
- (void)editUserInfo
{
    OWTUserInfoEditViewCon* userInfoEditViewCon = [[OWTUserInfoEditViewCon alloc] initWithNibName:nil bundle:nil];
    _currentUser  = [QJPassport sharedPassport].currentUser;
    userInfoEditViewCon.user = _user;
    userInfoEditViewCon.cancelAction = ^{
        
    };
    
    userInfoEditViewCon.doneFunc = ^{
        _ai=@"dd";
        [self dismissViewControllerAnimated:YES completion:^{
            [self updateRightNavBarItem];
            [_collectionView reloadData];
        }];
    };
    [_tabBarHider hideTabBar];
    [self.navigationController pushViewController:userInfoEditViewCon  animated:YES];
}
//
#pragma mark - Collection view delegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    return CGSizeZero;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        return CGSizeMake(320, 212);
    }
    
    return CGSizeZero;
}


//点击事件
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
}

#pragma mark - ScrollView Delegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    //    [_tabBarHider notifyScrollViewWillBeginDraggin:scrollView];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //    [_tabBarHider notifyScrollViewDidScroll:scrollView];
}

#pragma mark - 3rdparty refresh control

- (void)beginPullDownRefreshing
{
    [self refresh];
    [self getCaptionsResouce];
}

- (BOOL)keepiOS7NewApiCharacter
{
    return NO;
}

- (XHRefreshViewLayerType)refreshViewLayerType
{
    return XHRefreshViewLayerTypeOnScrollViews;
}

- (BOOL)isPullUpLoadMoreEnabled
{
    return NO;
}

- (void)showTabBar{    if (self.tabBarController.tabBar.hidden == NO)    {        return;    }    UIView *contentView;    if ([[self.tabBarController.view.subviews objectAtIndex:0] isKindOfClass:[UITabBar class]])                contentView = [self.tabBarController.view.subviews objectAtIndex:1];    else                contentView = [self.tabBarController.view.subviews objectAtIndex:0];              contentView.frame = CGRectMake(contentView.bounds.origin.x, contentView.bounds.origin.y,  contentView.bounds.size.width, contentView.bounds.size.height - self.tabBarController.tabBar.frame.size.height);        self.tabBarController.tabBar.hidden = NO;}

@end
