//
//  OWTPhotoUploadInfoViewCon.m
//  Weitu
//
//  Created by Su on 5/31/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import "OWTPhotoUploadInfoViewCon.h"
#import "OThumbnailListTableViewCell.h"
#import "OThumbnailListTableViewItem.h"
#import "UIViewController+WTExt.h"
#import "OWTAssetManager.h"
#import "SVProgressHUD+WTError.h"
#import "OWTImageInfo.h"
#import "OWTUserManager.h"
#import "OWTAsset.h"
#import "OWTAlbumInfoEditViewCon.h"
#import <AssetsLibrary/AssetsLibrary.h>

#import <RETableViewManager/RETableViewManager.h>
#import <SDWebImage/SDWebImageManager.h>
#import "SVProgressHUD+WTError.h"
#import "UIImage+Resize.h"
#import "CoreLocationExt.h"
#import "LJCoreData.h"

#import "SvImageInfoEditUtils.h"


#import "OWTimageData.h"



#import "LJCaptionModel.h"
#import "FSBasicImage.h"
#import "FSBasicImageSource.h"

#import <MapKit/MapKit.h>
#import "OWTImageView.h"
#import <CoreLocation/CoreLocation.h>
#import "LJPickerViewController.h"
@interface OWTPhotoUploadInfoViewCon ()
{
    RETableViewManager* _tableViewManager;
    
    RETableViewSection* _thumbnailListSection;
    OThumbnailListTableViewItem* _thumbnailListItem;
    
    RETableViewSection* _captionInputSection;
    RELongTextItem* _captionInputItem;
    RETableViewSection* _captionInputSection1;
    RELongTextItem* _captionInputItem1;
    RETableViewSection* _captionInputSection2;
    RELongTextItem* _captionInputItem2;
    
    RETableViewSection* _settingsSection;
    REBoolItem* _isPrivateItem;
    REBoolItem* _isOriginalSizeItem;
    
    RETableViewSection* _albumsSection;
    NSMutableDictionary* _albumItemsByAlbum;
    
    NSMutableSet* _belongingAlbums;
    
    dispatch_queue_t _workingQueue;
    
    NSInteger i;
    NSString *_caption;
    UITextView *_captionView;
    UITextView *_captionView1;
    UITextView *_captionView2;
    UIView *_captionView3;
    UIView *_captionView4;
    UISwitch *_switch1;
    UISwitch *_switch2;
    UILabel *_gameName;
    CLGeocoder *geocoder;
    CLGeocoderInternal *geocoderInternal;
}

@end

@implementation OWTPhotoUploadInfoViewCon

- (id)initWithDefaultStyle
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self)
    {
        [self setup];
    }
    return self;
}

- (void)setup
{
    _belongingAlbums = [NSMutableSet set];
    
    self.title = @"编辑图片";
    
    UIBarButtonItem* cancelButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消"
                                                                         style:UIBarButtonItemStyleDone
                                                                        target:self
                                                                        action:@selector(cancel1)];
    self.navigationItem.hidesBackButton = TRUE;
    self.navigationItem.leftBarButtonItem = cancelButtonItem;
    
    UIBarButtonItem* subscribeButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"上传"
                                                                            style:UIBarButtonItemStyleDone
                                                                           target:self
                                                                           action:@selector(upload)];
    self.navigationItem.rightBarButtonItem = subscribeButtonItem;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //    if ([MySingletonClass shareMySingleton].singletonString !=10) {
    //        [MySingletonClass shareMySingleton].singletonString = 10;
    //    }
    //
    //    NSLog(@",,,,,,,,,,,,,,,,%d",[MySingletonClass shareMySingleton].singletonString );
    geocoder=[[CLGeocoder alloc]init];
    _tableViewManager = [[RETableViewManager alloc] initWithTableView:self.tableView];
    _tableViewManager[@"OThumbnailListTableViewItem"] = @"OThumbnailListTableViewCell";
    [self setupThumbnailListSection];
    [self setupCaptionInputSection];
    [self setupCaptionInputSection1];
    [self setupCaptionInputSection2];
    [self setupSettingsSection];
    [self setupAlbumsSection];
    [self setupCaptionView];
    // self.tableView.delegate=self;
    // self.tableView.dataSource=self;
    UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap)];
    [self.view addGestureRecognizer:tap];
}
//kvo
-(void)tap
{
    
    [self.view endEditing:YES];
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    NSMutableArray *FSArr = [[NSMutableArray alloc]init];
    for (int j=0; j<_pendingUploadImageInfos.count; j++) {
        
        OWTImageInfo *imageInfo = [[OWTImageInfo alloc]init];
        imageInfo = _pendingUploadImageInfos[j];
        
        OWTImageView *imV = [[OWTImageView alloc]init];
        
        [imV setImageWithInfo:imageInfo];
        
        
        
        FSBasicImage *firstPhoto = [[FSBasicImage alloc]initWithImage:imV.image];
        [FSArr addObject:firstPhoto];
        
    }
    FSBasicImageSource *photoSource = [[FSBasicImageSource alloc] initWithImages:FSArr];
    self.imageViewController.navigationController.navigationBarHidden =YES;
    [self.navigationController pushViewController:_imageViewController animated:YES];
}
-(void)setupCaptionView
{
    UIView *view=[[UIView alloc]initWithFrame:CGRectMake(0, 150, SCREENWIT, 1000)];
    view.backgroundColor=GetThemer().themeColorBackground;
    [self.view addSubview:view];
    UILabel *label=[LJUIController createLabelWithFrame:CGRectMake(10, 150, 30, 25) Font:15 Text:@"标题"];
    [self.view addSubview:label];
    _captionView=[[UITextView alloc]initWithFrame:CGRectMake(0, 180, SCREENWIT, 100)];
    _captionView.backgroundColor=[UIColor whiteColor];
    _captionView.font=[UIFont systemFontOfSize:17];
    //_captionView.placeholder=@"请输入标题";
    [self.view addSubview:_captionView];
    UILabel *label1=[LJUIController createLabelWithFrame:CGRectMake(10, 300, 30, 25) Font:15 Text:@"标签"] ;
    [self.view addSubview:label1];
    _captionView1=[[UITextView alloc]initWithFrame:CGRectMake(0, 330, SCREENWIT, 100)];
    
    _captionView1.backgroundColor=[UIColor whiteColor];
    //_captionView1.placeholder=@"请输入标签";
    _captionView1.font=[UIFont systemFontOfSize:17];
    _captionView1.text=_caption;
    [self.view addSubview:_captionView1];
    UILabel *label2=[LJUIController createLabelWithFrame:CGRectMake(10, 450, 30, 25) Font:15 Text:@"位置"];
    [self.view addSubview:label2];
    _captionView2=[[UITextView alloc]initWithFrame:CGRectMake(0, 480, SCREENWIT, 60)];
    _captionView2.backgroundColor=[UIColor whiteColor];
    //_captionView2.placeholder=@"请输入位置";
    _captionView2.font=[UIFont systemFontOfSize:17];
    [self.view addSubview:_captionView2];
    UILabel *label3=[LJUIController createLabelWithFrame:CGRectMake(10, 560, 30, 25) Font:15 Text:@"选项"];
    [self.view addSubview:label3];
    _captionView3=[[UIView alloc]initWithFrame:CGRectMake(0, 710, SCREENWIT, 50)];
    
    UILabel *label4=[LJUIController createLabelWithFrame:CGRectMake(10, 5, 100, 40) Font:17 Text:@"私有图片"];
    [_captionView3 addSubview:label4];
    _captionView3.backgroundColor=[UIColor whiteColor];
    _switch1=[[UISwitch alloc]initWithFrame:CGRectMake(SCREENWIT-60, 10, 30, 20)];
    [_captionView3 addSubview:_switch1];
    _captionView4=[[UIView alloc]initWithFrame:CGRectMake(0, 650, SCREENWIT, 50)];
    UILabel *label5=[LJUIController createLabelWithFrame:CGRectMake(10, 5, 100, 40) Font:17 Text:@"上传原图"];
    [_captionView4 addSubview:label5];
    _captionView4.backgroundColor=[UIColor whiteColor];
    _switch2=[[UISwitch alloc]initWithFrame:CGRectMake(SCREENWIT-60, 10, 30, 20)];
    [_captionView4 addSubview:_switch2];
    [self.view addSubview:_captionView4];
    [self.view addSubview:_captionView3];
    UIImageView *gameImage=[LJUIController createImageViewWithFrame:CGRectMake(0, 590, SCREENWIT, 50) imageName:nil];
    gameImage.userInteractionEnabled=YES;
    gameImage.backgroundColor=[UIColor whiteColor];
    [self.view addSubview:gameImage];
    UILabel *gameLabel=[LJUIController createLabelWithFrame:CGRectMake(10, 5, 100, 40) Font:17 Text:@"选择活动"];
    [gameImage addSubview:gameLabel];
    gameLabel.userInteractionEnabled=YES;
    UITapGestureRecognizer *gameTap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapGame)];
    [gameImage addGestureRecognizer:gameTap];
    _gameName=[LJUIController createLabelWithFrame:CGRectMake(SCREENWIT-150, 5, 100, 40) Font:17 Text:nil];
    [gameImage addSubview:_gameName];
    UIImageView *imageVIEW1=[LJUIController createImageViewWithFrame:CGRectMake(SCREENWIT-30, 15, 10, 20) imageName:@"首页18-1_05.png"];
    [gameImage addSubview:imageVIEW1];
}
-(void)tapGame
{
    LJPickerViewController *lvc=[[LJPickerViewController alloc]init];
    lvc.backgroundImage=[self ScreenShot];
    NSArray *arr=@[[self getSaveData]];
    lvc.dataArray=arr;
    lvc.doneFunc=^{
        _gameName.text=lvc.backString1;
    };
    lvc.hidesBottomBarWhenPushed=YES;
    
    [self.navigationController pushViewController:lvc animated:YES];
}
#pragma mark 得到game数据
-(NSArray *)getSaveData
{
    NSString *homeDictionary = NSHomeDirectory();//获取根目录
    NSString *homePath  = [homeDictionary stringByAppendingString:@"/Documents/game.archiver"];//添加储存的文件名
    NSArray *Arr=[NSKeyedUnarchiver unarchiveObjectWithFile:homePath];
    if (Arr==nil) {
        return nil;
    }
    NSMutableArray *tempArr=[[NSMutableArray alloc]init];
    for (NSDictionary*appdict in Arr) {
        [tempArr addObject:appdict[@"GameTitle"]];
    }
    [tempArr insertObject:@"不选" atIndex:0];
    return tempArr;
}
-(NSString *)getGameId:(NSString *)gameTitle
{
    NSString *homeDictionary = NSHomeDirectory();//获取根目录
    NSString *homePath  = [homeDictionary stringByAppendingString:@"/Documents/game.archiver"];//添加储存的文件名
    NSArray *Arr=[NSKeyedUnarchiver unarchiveObjectWithFile:homePath];
    if (Arr==nil) {
        return nil;
    }
    for (NSDictionary*appdict in Arr) {
        if ([appdict[@"GameTitle"]isEqualToString:gameTitle]) {
            return appdict[@"GameId"];
        }
    }
    return nil;
}
#pragma mark 截图
-(UIImage*)ScreenShot{
    //这里因为我需要全屏接图所以直接改了，宏定义iPadWithd为1024，iPadHeight为768，
    //    UIGraphicsBeginImageContextWithOptions(CGSizeMake(640, 960), YES, 0);     //设置截屏大小
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(SCREENWIT, SCREENHEI), YES, 0);     //设置截屏大小
    [[self.navigationController.view layer] renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    return viewImage;
    //         UIGraphicsEndImageContext();
    //         CGImageRef imageRef = viewImage.CGImage;
    //     //    CGRect rect = CGRectMake(166, 211, 426, 320);//这里可以设置想要截图的区域
    //         CGRect rect = CGRectMake(0, 0, iPadWidth, iPadHeight);//这里可以设置想要截图的区域
    //         CGImageRef imageRefRect =CGImageCreateWithImageInRect(imageRef, rect);
    //         UIImage *sendImage = [[UIImage alloc] initWithCGImage:imageRefRect];
    
}

- (void)setupThumbnailListSection
{
    
    //这里添加图片点击事件
    
    _thumbnailListSection = [[RETableViewSection alloc] init];
    _thumbnailListItem = [OThumbnailListTableViewItem item];
    if (_pendingUploadImages != nil)
    {
        _thumbnailListItem.images = _pendingUploadImages;
    }
    if (_pendingUploadImageInfos != nil)
    {
        _thumbnailListItem.imageInfos = _pendingUploadImageInfos;
    }
    [self updateThumbnailListSectionHeader];
    [_thumbnailListSection addItem:_thumbnailListItem];
    [_tableViewManager addSection:_thumbnailListSection];
}

- (void)updateThumbnailListSectionHeader
{
    if (_thumbnailListSection != nil)
    {
        NSUInteger imageNum = (_pendingUploadImages != nil) ? _pendingUploadImages.count : _pendingUploadImageInfos.count;
        _thumbnailListSection.headerTitle = [NSString stringWithFormat:@"%lu张待上传图片", (unsigned long)imageNum];
        [_thumbnailListSection reloadSectionWithAnimation:UITableViewRowAnimationNone];
    }
}

- (void)setupCaptionInputSection
{
    _captionInputSection = [[RETableViewSection alloc] initWithHeaderTitle:nil];
    _captionInputItem = [[RELongTextItem alloc] initWithValue:@"" placeholder:@"请输入图片标题"];
    _captionInputItem.cellHeight = 88;
    _captionInputItem.charactersLimit = 160;
    [_captionInputSection addItem:_captionInputItem];
    [_tableViewManager addSection:_captionInputSection];
}
- (void)setupCaptionInputSection1
{
    _captionInputSection1 = [[RETableViewSection alloc] initWithHeaderTitle:nil];
    _captionInputItem1 = [[RELongTextItem alloc] initWithValue:_caption placeholder:@"请输入图片标签"];
    _captionInputItem1.cellHeight = 88;
    _captionInputItem1.charactersLimit = 160;
    [_captionInputSection1 addItem:_captionInputItem1];
    [_tableViewManager addSection:_captionInputSection1];
}
- (void)setupCaptionInputSection2
{
    _captionInputSection2 = [[RETableViewSection alloc] initWithHeaderTitle:nil];
    _captionInputItem2 = [[RELongTextItem alloc] initWithValue:@"" placeholder:@"请输入图片位置"];
    _captionInputItem2.cellHeight = 200;
    _captionInputItem2.charactersLimit = 160;
    [_captionInputSection2 addItem:_captionInputItem2];
    [_tableViewManager addSection:_captionInputSection2];
    
}
- (void)setupAlbumsSection
{
    //    _albumsSection = [[RETableViewSection alloc] initWithHeaderTitle:@"所属相册"];
    //    [_tableViewManager addSection:_albumsSection];
}

- (void)setupSettingsSection
{
    _settingsSection = [[RETableViewSection alloc] initWithHeaderTitle:nil];
    
    _isPrivateItem = [[REBoolItem alloc] initWithTitle:@"私有图片"];
    [_settingsSection addItem:_isPrivateItem];
    //
    
    _isOriginalSizeItem = [[ REBoolItem alloc]initWithTitle:@"上传原图" value:0];
    [_settingsSection addItem:_isOriginalSizeItem];
    
    [_tableViewManager addSection:_settingsSection];
}

- (void)reloadBelongingAlbumsItems
{
    OWTUser* currentUser = GetUserManager().currentUser;
    OWTUserAlbumsInfo* albumsInfo = currentUser.albumsInfo;
    
    [_albumsSection removeAllItems];
    
    if (albumsInfo != nil)
    {
        for (OWTAlbum* album in albumsInfo.albums)
        {
            BOOL isBelongingToThisAlbum = [_belongingAlbums containsObject:album];
            RETableViewItem* albumItem = [RETableViewItem itemWithTitle:album.albumName
                                                          accessoryType:(isBelongingToThisAlbum ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone)
                                                       selectionHandler:^(RETableViewItem* item) {
                                                           album.refreshNeeded = YES;
                                                           if ([_belongingAlbums containsObject:album])
                                                           {
                                                               [_belongingAlbums removeObject:album];
                                                               item.accessoryType = UITableViewCellAccessoryNone;
                                                           }
                                                           else
                                                           {
                                                               [_belongingAlbums addObject:album];
                                                               item.accessoryType = UITableViewCellAccessoryCheckmark;
                                                           }
                                                           [item deselectRowAnimated:YES];
                                                           [_albumsSection reloadSectionWithAnimation:UITableViewRowAnimationFade];
                                                       }];
            OWTAsset* coverAsset = [GetAssetManager() getAssetWithID:album.albumCoverAssetID];
            if (coverAsset != nil)
            {
                [[SDWebImageManager sharedManager] downloadWithURL:[NSURL URLWithString:coverAsset.imageInfo.url]
                                                           options:SDWebImageHighPriority
                                                          progress:nil
                                                         completed:^(UIImage* image, NSError* error, SDImageCacheType cacheType, BOOL finished) {
                                                             if (image != nil)
                                                             {
                                                                 UIImage* thumbImage = [image thumbnailImage:64
                                                                                        interpolationQuality:kCGInterpolationDefault];
                                                                 thumbImage = [[UIImage alloc] initWithCGImage:thumbImage.CGImage scale:2.0 orientation:thumbImage.imageOrientation];
                                                                 albumItem.image = thumbImage;
                                                             }
                                                         }];
            }
            [_albumsSection addItem:albumItem];
        }
        
        __weak typeof(self) wself = self;
        RETableViewItem* addItem = [RETableViewItem itemWithTitle:@"添加相册"
                                                    accessoryType:UITableViewCellAccessoryNone
                                                 selectionHandler:^(RETableViewItem *item) {
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
                                                                     [wself reloadBelongingAlbumsItems];
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
                                                 }];
        addItem.textAlignment = NSTextAlignmentCenter;
        [_albumsSection addItem:addItem];
    }
    [_albumsSection reloadSectionWithAnimation:UITableViewRowAnimationFade];
}

- (void)queryUserPublicInfo
{
    OWTUserManager* um = GetUserManager();
    OWTUser* currentUser = GetUserManager().currentUser;
    if (currentUser.albumsInfo == nil)
    {
        [um refreshCurrentUserSuccess:^{
            [self reloadBelongingAlbumsItems];
        }
                              failure:^(NSError* error) {
                                  [SVProgressHUD showError:error];
                              }];
    }
    else
    {
        [self reloadBelongingAlbumsItems];
    }
}

#pragma mark -

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] postNotificationName:kWTHideMainTabBarNotification object:@(NO)];
//    [geocoder geocodeAddressString:@"美国" completionHandler:^(NSArray *placemarks, NSError *error) {
//        CLPlacemark *firstPlacemark=[placemarks firstObject];
//        NSLog(@"%@",firstPlacemark.location);
//        [geocoder reverseGeocodeLocation:firstPlacemark.location completionHandler:^(NSArray *placemarks, NSError *error) {
//            if (error||placemarks.count==0) {
//                NSLog(@"%@",error);
//            }else//编码成功
//            {
//                NSLog(@"%@",placemarks);
//                CLPlacemark *firstPlacemark=[placemarks firstObject];
//                _captionView2.text=firstPlacemark.name;
//            }
//        }];
//    }];
    if (_location) {
        [geocoder reverseGeocodeLocation:_location completionHandler:^(NSArray *placemarks, NSError *error) {
            if (error||placemarks.count==0) {
                NSLog(@"%@",error);
                
            }else//编码成功
            {
                NSLog(@"%@",placemarks);
                CLPlacemark *firstPlacemark=[placemarks firstObject];
                _captionView2.text=firstPlacemark.name;
            }
        }];}

}
-(void)mapSearch
{
    if (_location) {
        [geocoder reverseGeocodeLocation:_location completionHandler:^(NSArray *placemarks, NSError *error) {
            if (error||placemarks.count==0) {
                NSLog(@"%@",error);
                
            }else//编码成功
            {
                NSLog(@"%@",placemarks);
                CLPlacemark *firstPlacemark=[placemarks firstObject];
                _captionView2.text=firstPlacemark.name;
            }
        }];}
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self queryUserPublicInfo];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
//    [[NSNotificationCenter defaultCenter] postNotificationName:kWTShowMainTabBarNotification object:@(NO)];
}

- (void)setPendingUploadImages:(NSArray *)pendingUploadImages
{
    _pendingUploadImageInfos = nil;
        _gameName.text=_Name;
    _pendingUploadImages = [pendingUploadImages copy];
    if (_thumbnailListItem != nil)
    {
        [self updateThumbnailListSectionHeader];
        _thumbnailListItem.images = _pendingUploadImages;
        
        
        
        
        
        _thumbnailListItem.imageInfos = nil;
        [[NSNotificationCenter defaultCenter] postNotificationName:kThumbnailListImagesUpdatedNotification object:nil];
    }
}

- (void)setPendingUploadImageInfos:(NSArray *)pendingUploadImageInfos
{
    [self mapSearch];
    _pendingUploadImages = nil;
        _gameName.text=_Name;
    _pendingUploadImageInfos = pendingUploadImageInfos;
    
    OWTImageInfo *imageInfo=pendingUploadImageInfos[0];
    LJCaptionModel *model =[[LJCoreData shareIntance]check:imageInfo.url];
    _caption=model.caption;
    _captionView1.text=_caption;
    NSLog(@"baaaaaaaaaaaaaaaaa%@",_pendingUploadImageInfos);
    if (_thumbnailListItem != nil)
    {
        [self updateThumbnailListSectionHeader];
        _thumbnailListItem.images = nil;
        _thumbnailListItem.imageInfos = _pendingUploadImageInfos;
        
        
        
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kThumbnailListImagesUpdatedNotification object:nil];
    }
}

- (dispatch_queue_t)wokingQueue
{
    if (_workingQueue == nil)
    {
        _workingQueue = dispatch_queue_create("com.quanjing.weitu.PendingUploadImageLoadingQueue", 0);
    }
    
    return _workingQueue;
}

- (CGSize)fixedUploadSizeForImage:(UIImage*)image withorientation:(NSInteger)orientation
{
    if (orientation ==8||orientation ==7||orientation ==6||orientation ==5) {
        CGSize originalSize = image.size;
        if (originalSize.height < 640)
        {
            return originalSize;
            
            
        }
        NSLog(@"11111111111111111%f,%f",originalSize.height,originalSize.width);
        return CGSizeMake(640/originalSize.height*originalSize.width, 640);
        
    }
    else{
        CGSize originalSize = image.size;
        if (originalSize.width < 640)
        {
            return originalSize;
            
            
        }
        NSLog(@"11111111111111111%f,%f",originalSize.height,originalSize.width);
        return CGSizeMake(640, originalSize.height * 640 / originalSize.width);
    }
}

- (void)upload
{
    [self.view endEditing:YES];
    
    BOOL isOriginalSize = _isOriginalSizeItem.value;
    
    
    if (_pendingUploadImages != nil && _pendingUploadImages.count > 0)
    {
        dispatch_queue_t dq = [self wokingQueue];
        
        //        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
        dispatch_async(dq, ^{
            
            NSMutableArray* imageDatas = [NSMutableArray arrayWithCapacity:_pendingUploadImages.count];
            for (UIImage* image in _pendingUploadImages)
            {
                UIImage* uploadImage = image;
                if (!isOriginalSize)
                {
                    //                    uploadImage = [image resizedImage:[self fixedUploadSizeForImage:image] interpolationQuality:kCGInterpolationHigh];
                    //拍照闪退
                    uploadImage = [image resizedImage:[self fixedUploadSizeForImage:image withorientation:1] interpolationQuality:kCGInterpolationHigh];
                    //                    uploadImage = [image fixOrientation:[self fixedUploadSizeForImage:image] interpolationQuality:kCGInterpolationHigh];
                }
                
                NSData* imageData = UIImageJPEGRepresentation(uploadImage, 0.8);
                i=1;
                
                //
                
                
                [imageDatas addObject:imageData];
            }
            [self uploadByImageDatas:imageDatas];
        });
    }
    else if (_pendingUploadImageInfos != nil && _pendingUploadImageInfos.count > 0)
    {
        ALAssetsLibrary* assetslibrary = [[ALAssetsLibrary alloc] init];
        
        NSMutableArray* imageDatas = [NSMutableArray arrayWithCapacity:_pendingUploadImageInfos.count];
        
        dispatch_queue_t dq = [self wokingQueue];
        
        __block NSUInteger pendingImageNum = _pendingUploadImageInfos.count;
        
        //        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
        
        ALAssetsLibraryAssetForURLResultBlock resultblock = ^(ALAsset* asset)
        {
            ALAssetRepresentation* rep = [asset defaultRepresentation];
            
            NSError* error;
            NSData* imageData;
            
            
            OWTimageData *imgData = [[OWTimageData alloc]init];
            if (isOriginalSize)
            {
                NSMutableData* mutableImageData = [NSMutableData dataWithCapacity:(NSUInteger)rep.size];
                [mutableImageData setLength:(NSUInteger)rep.size];
                NSUInteger buffered = [rep getBytes:[mutableImageData mutableBytes]
                                         fromOffset:0.0
                                             length:(NSUInteger)rep.size
                                              error:&error];
                [mutableImageData setLength:buffered];
                imageData = mutableImageData;
                //创建一个字典
                //                ALAssetRepresentation *representation = mediaInfo.defaultRepresentation;
                CGImageRef cImage = [rep fullScreenImage];
                uint8_t *buffer = (uint8_t *)malloc(rep.size);
                NSError *error;
                NSUInteger length = [rep getBytes:buffer fromOffset:0 length:rep.size error:&error];
                NSData *data = [NSData dataWithBytes:buffer length:length];
                //                        5. 构造 CGImageSource :
                CGImageSourceRef cImageSource = CGImageSourceCreateWithData((__bridge CFDataRef)data, NULL);
                
                CFDictionaryRef imageInfo1 = CGImageSourceCopyPropertiesAtIndex(cImageSource, 0,NULL);
                
                NSInteger orientation = [(__bridge NSNumber *)CFDictionaryGetValue(imageInfo1, kCGImagePropertyOrientation) integerValue];
                
                
                NSLog(@"aaaaaaaaaaaaaaaaaaaaal%d",orientation);
                
                imgData.imageData =imageData;
                imgData.orientation =orientation;
                
                
            }
            else
            {
                CGImageRef iref = [rep fullResolutionImage];
                UIImage* image = [UIImage imageWithCGImage:iref];
                //上传的image
                
                
                //修改压缩 角度
                
                
                //
                CGImageRef cImage = [rep fullScreenImage];
                uint8_t *buffer = (uint8_t *)malloc(rep.size);
                NSError *error;
                NSUInteger length = [rep getBytes:buffer fromOffset:0 length:rep.size error:&error];
                NSData *data = [NSData dataWithBytes:buffer length:length];
                //                        5. 构造 CGImageSource :
                CGImageSourceRef cImageSource = CGImageSourceCreateWithData((__bridge CFDataRef)data, NULL);
                
                CFDictionaryRef imageInfo1 = CGImageSourceCopyPropertiesAtIndex(cImageSource, 0,NULL);
                
                NSInteger orientation = [(__bridge NSNumber *)CFDictionaryGetValue(imageInfo1, kCGImagePropertyOrientation) integerValue];
                
                
                NSLog(@"aaaaaaaaaaaaaaaaaaaaal%d",orientation);
                
                image = [image resizedImage:[self fixedUploadSizeForImage:image withorientation:orientation] interpolationQuality:kCGInterpolationHigh];
                imageData = UIImageJPEGRepresentation(image, 0.8);
                
                imgData.imageData =imageData;
                imgData.orientation =orientation;
                
            }
            
            if (imageData != nil && error == nil)
            {
                dispatch_async(dq, ^{
                    [imageDatas addObject:imgData];
                    pendingImageNum--;
                    if (pendingImageNum == 0)
                    {
                        dispatch_async(dispatch_get_main_queue(), ^{ [self uploadByImageDatas:imageDatas]; });
                    }
                    else
                    {
                        DDLogDebug(@"pendingImageNum is %lu", (unsigned long)pendingImageNum);
                    }
                });
            }
            else
            {
                dispatch_async(dq, ^{
                    pendingImageNum--;
                    if (pendingImageNum == 0)
                    {
                        dispatch_async(dispatch_get_main_queue(), ^{ [self uploadByImageDatas:imageDatas]; });
                    }
                    else
                    {
                        DDLogDebug(@"pendingImageNum is %lu", (unsigned long)pendingImageNum);
                    }
                });
            }
        };
        
        ALAssetsLibraryAccessFailureBlock failureblock  = ^(NSError *myerror)
        {
            dispatch_async(dq, ^{
                DDLogDebug (@"booya, cant get image - %@",[myerror localizedDescription]);
                pendingImageNum--;
                if (pendingImageNum == 0)
                {
                    dispatch_async(dispatch_get_main_queue(), ^{ [self uploadByImageDatas:imageDatas]; });
                }
                else
                {
                    DDLogDebug(@"pendingImageNum is %lu", (unsigned long)pendingImageNum);
                }
            });
        };
        
        for (OWTImageInfo* imageInfo in _pendingUploadImageInfos)
        {
            NSURL* url = [NSURL URLWithString:imageInfo.url];
            [assetslibrary assetForURL:url
                           resultBlock:resultblock
                          failureBlock:failureblock];
        }
    }
    else
    {
        [SVProgressHUD showSuccessWithStatus:@"上传完毕。"];
        [self.navigationController popViewControllerAnimated:YES];
        if (_doneAction != nil)
        {
            _doneAction();
        }
    }
}

- (void)uploadByImageDatas:(NSArray*)imageDatas
{
    if (imageDatas == nil || imageDatas.count == 0)
    {
        [SVProgressHUD showSuccessWithStatus:@"上传完毕。"];
        [self.navigationController popViewControllerAnimated:YES];
        if (_doneAction != nil)
        {
            _doneAction();
        }
        return;
    }
    if (imageDatas.count==1) {
        [SVProgressHUD showWithStatus:@"上传中" maskType:SVProgressHUDMaskTypeGradient];
    }else{
        [SVProgressHUD showProgress:0.1 status:@"正在上传1张" maskType:SVProgressHUDMaskTypeGradient];
    }
    OWTAssetManager* am = GetAssetManager();
    am.gameId=[self getGameId:_gameName.text];
    if (i==0) {
        [am uploadImageDatas:imageDatas
                     caption:_captionView.text
                   isPrivate:_switch1.on
                  islocation:_captionView2.text
                  iskeywords:_captionView1.text
             belongingAlbums:_belongingAlbums
                    progress:^(NSInteger uploadedImageNum, NSInteger totalImageNum) {
                        float progress = ((float)uploadedImageNum) / (float)totalImageNum;
                        [SVProgressHUD showProgress:progress status:[NSString stringWithFormat:@"正在上传%d张",uploadedImageNum+1] maskType:SVProgressHUDMaskTypeGradient];
                    }
                     success:^{
                         [SVProgressHUD showSuccessWithStatus:@"上传完毕。"];
                         [self.navigationController popViewControllerAnimated:YES];
                         if (_doneAction != nil)
                         {
                             _doneAction();
                         }
                         
                         // XXX this is a hack, should mark need update and update from server
                         OWTUserAssetsInfo* assetsInfo = GetUserManager().currentUser.assetsInfo;
                         assetsInfo.publicAssetNum = assetsInfo.publicAssetNum + imageDatas.count;
                     }
                     failure:^(NSError* error) {
                         [SVProgressHUD showError:error];
                         [self.navigationController popViewControllerAnimated:YES];
                         if (_doneAction != nil)
                         {
                             _doneAction();
                         }
                     }];
    }
    else{
        [am uploadImageDatas1:imageDatas
                      caption:_captionInputItem.value
                    isPrivate:_isPrivateItem.value
              belongingAlbums:_belongingAlbums
                     progress:^(NSInteger uploadedImageNum, NSInteger totalImageNum) {
                         float progress = ((float)uploadedImageNum  + 0.5) / (float)totalImageNum;
                         [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
                     }
                      success:^{
                          [SVProgressHUD showSuccessWithStatus:@"上传完毕。"];
                          [self.navigationController popViewControllerAnimated:YES];
                          if (_doneAction != nil)
                          {
                              _doneAction();
                          }
                          
                          // XXX this is a hack, should mark need update and update from server
                          OWTUserAssetsInfo* assetsInfo = GetUserManager().currentUser.assetsInfo;
                          assetsInfo.publicAssetNum = assetsInfo.publicAssetNum + imageDatas.count;
                      }
                      failure:^(NSError* error) {
                          [SVProgressHUD showError:error];
                          [self.navigationController popViewControllerAnimated:YES];
                          if (_doneAction != nil)
                          {
                              _doneAction();
                          }
                      }];
    }
}

- (void)cancel1
{
    [self.navigationController popViewControllerAnimated:YES];
    if (_doneAction != nil)
    {
        _doneAction();
    }
}
//
//图片旋转
- (UIImage *)fixOrientation:(UIImage *)aImage {
    
    // No-op if the orientation is already correct
    if (aImage.imageOrientation == UIImageOrientationUp)
        return aImage;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, aImage.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, aImage.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, aImage.size.width, aImage.size.height,
                                             CGImageGetBitsPerComponent(aImage.CGImage), 0,
                                             CGImageGetColorSpace(aImage.CGImage),
                                             CGImageGetBitmapInfo(aImage.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (aImage.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.height,aImage.size.width), aImage.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.width,aImage.size.height), aImage.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}
@end
