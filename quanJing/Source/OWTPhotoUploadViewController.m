//
//  OWTPhotoUploadViewController.m
//  Weitu
//
//  Created by Gongtao on 15/9/21.
//  Copyright © 2015年 SparkingSoft Co., Ltd. All rights reserved.
//

#import "OWTPhotoUploadViewController.h"

#import "OWTPhotoUploadDesCell.h"
#import "OWTPhotoUploadImagesCell.h"
#import "OWTPhotoUploadCustomCell.h"
#import "OWTPhotoUploadTagView.h"

#import "OWTimageData.h"
#import "OWTAssetManager.h"
#import "OWTImageInfo.h"
#import "OWTUserManager.h"

#import "AGImagePickerController.h"

#import <UIColor+HexString.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <ImageIO/ImageIO.h>
#import <RETableViewManager/RETableViewManager.h>
#import <UIActionSheet-Blocks/UIActionSheet+Blocks.h>
#import <NBUImagePicker/NBUImagePicker.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "UIImage+Resize.h"
#import "SVProgressHUD+WTError.h"
#import "FSBasicImage.h"
#import "FSBasicImageSource.h"
#import "FSImageViewerViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "OWTDefalutTagsViewController.h"
#import "QJDatabaseManager.h"
#define kPhotoUploadNavBarColor                 [UIColor colorWithHexString:@"#2b2b2b"]
#define kPhotoUploadNavButtonHighlightedColor   [UIColor colorWithHexString:@"#fb0c09"]
#define kPhotoUploadVCBackgroundColor           [UIColor colorWithHexString:@"#f2f4f5"]

@interface OWTPhotoUploadViewController () <UITextViewDelegate, OWTPhotoUploadImagesCellDelegate, UITextFieldDelegate, OWTPhotoUploadTagViewDelegate,UIImagePickerControllerDelegate> {
    BOOL _isPrivate;
    BOOL _isOriginal;
    
    dispatch_queue_t _workingQueue;
    
    NSMutableSet *_belongingAlbums;
    
    CLGeocoder *_geocoder;
    CLLocation *_location;
    
    NSString *_locationString;
    NSString *_caption;
    
    CGFloat _tagHeight;
    
    UITapGestureRecognizer *_tapGesture;
    UITapGestureRecognizer *_tapSelectedGesture;

    OWTDefalutTagsViewController *_defaultTagVC;
    
    UIView *_cotainSelectedView;
}

@property (nonatomic, strong) OWTPhotoUploadDesCell *addDesCell;
@property (nonatomic, strong) OWTPhotoUploadImagesCell *photosCell;
@property (nonatomic, strong) UITableViewCell *tagsCell;
@property (nonatomic, strong) OWTPhotoUploadTagView *uploadTagView;


@end

@implementation OWTPhotoUploadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    [self.navigationController.navigationBar setBarTintColor:kPhotoUploadNavBarColor];
    
    self.tableView.allowsSelection = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = kPhotoUploadVCBackgroundColor;
    _cotainSelectedView = [[UIView alloc]init];
    _isPrivate = NO;
    _isOriginal = NO;
    
    _tagHeight = kPhotoUploadTagViewDefaultHeight;
    _defaultTagVC = [[OWTDefalutTagsViewController alloc]init];
    __weak OWTPhotoUploadViewController *weakSelf = self;
    _defaultTagVC.tagSelectedAction = ^(NSString *str){
        [weakSelf selcetedComplete:str];
    };
    [self addChildViewController:_defaultTagVC];
    [self setupNavigation];
    [self.view addSubview:_cotainSelectedView];
}

-(void)selcetedComplete:(NSString*)str
{
    [self.view removeGestureRecognizer:_tapGesture];
    [_cotainSelectedView setHidden:YES];
    [_uploadTagView.selectedView setHidden:YES];
    [_defaultTagVC.view removeFromSuperview];
    [_uploadTagView addTagStr:str];

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] postNotificationName:kWTHideMainTabBarNotification object:@(NO)];
}

#pragma mark - Interface

- (void)setupNavigation {
    
    CGRect btnRect = CGRectMake(0.0, 0.0, 32.0, 32.0);
    // 取消按钮
    UIButton *leftButton = [[UIButton alloc] initWithFrame:btnRect];
    [leftButton setTitle:@"取消" forState:UIControlStateNormal];
    [leftButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [leftButton setTitleColor:kPhotoUploadNavButtonHighlightedColor forState:UIControlStateHighlighted];
    [leftButton addTarget:self action:@selector(cancelUploadImages:) forControlEvents:UIControlEventTouchUpInside];
    leftButton.titleLabel.font = [UIFont systemFontOfSize:15.0];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    
    // 完成按钮
    UIButton *rightButton = [[UIButton alloc] initWithFrame:btnRect];
    [rightButton setTitle:@"完成" forState:UIControlStateNormal];
    [rightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [rightButton setTitleColor:kPhotoUploadNavButtonHighlightedColor forState:UIControlStateHighlighted];
    [rightButton addTarget:self action:@selector(uploadImages:) forControlEvents:UIControlEventTouchUpInside];
    rightButton.titleLabel.font = [UIFont systemFontOfSize:15.0];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
}

#pragma mark - Property

- (void)setImageInfos:(NSMutableArray *)imageInfos {
    if (_imageInfos != imageInfos) {
        _imageInfos = imageInfos;
        
        if (_imageInfos && _imageInfos.count > 0 && !self.isCameraImages) {
            OWTImageInfo *imageInfo = _imageInfos[0];
            _caption = [self checkTheCaption:imageInfo.url];
            if (!_uploadTagView) {
                _uploadTagView = [[OWTPhotoUploadTagView alloc] initWithFrame:CGRectZero];
                _uploadTagView.tagStr = _caption;
                _uploadTagView.textField.delegate = self;
                _uploadTagView.delegate = self;
                __weak OWTPhotoUploadViewController *weakSelf = self;
                _uploadTagView.showDefaultList = ^{
                    [weakSelf showDefualtList];
                };
            }
            if (imageInfo.asset) {
                _location = [imageInfo.asset valueForProperty:ALAssetPropertyLocation];
                [self mapSearch];
            }
        }
        else {
            _caption = nil;
        }
        [self.tableView reloadData];
    }
}

-(void)showDefualtList
{

    _tapSelectedGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapSelected:)];
    [self.view addGestureRecognizer:_tapSelectedGesture];
    
    [self textFieldShouldReturn:nil];
    [_cotainSelectedView setHidden:NO];
    [_cotainSelectedView  setAlpha:0.9];
    [_cotainSelectedView addSubview:_defaultTagVC.view];

    CGRect rc = [_uploadTagView.textFieldBgView convertRect:_uploadTagView.textFieldBgView.frame toView:self.view];
    _cotainSelectedView.frame = CGRectMake(0, rc.origin.y+44-_uploadTagView.textFieldBgView.frame.size.height-5, SCREENWIT, SCREENHEI);

}

-(void)tapSelected:(UIGestureRecognizer*)sender
{
    [self selcetedComplete:nil];
}
#pragma mark -coredata
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

#pragma mark - Info

- (void)mapSearch {
    if (_location) {
        __weak __typeof(self) weakSelf = self;
        if (!_geocoder) {
            _geocoder = [[CLGeocoder alloc] init];
        }
        [_geocoder reverseGeocodeLocation:_location completionHandler:^(NSArray *placemarks, NSError *error) {
            if (error || placemarks.count==0) {
                NSLog(@"%@",error);
            }
            else {
                //编码成功
                NSLog(@"%@",placemarks);
                CLPlacemark *firstPlacemark=[placemarks firstObject];
                _locationString = firstPlacemark.name;
                [weakSelf.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:2 inSection:0]]
                                          withRowAnimation:UITableViewRowAnimationNone];
            }
        }];
    }
}

- (NSArray *)getSaveData {
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

- (NSString *)getGameId:(NSString *)gameTitle {
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

#pragma mark - Upload

- (dispatch_queue_t)workingQueue {
    if (_workingQueue == nil) {
        _workingQueue = dispatch_queue_create("com.quanjing.weitu.PendingUploadImageLoadingQueue", 0);
    }
    return _workingQueue;
}

- (CGSize)fixedUploadSizeForImage:(UIImage*)image withorientation:(NSInteger)orientation {
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

- (void)uploadByImageDatas:(NSArray*)imageDatas
{
    if (imageDatas == nil || imageDatas.count == 0) {
        [SVProgressHUD showSuccessWithStatus:@"上传完毕。"];
        [self.navigationController popViewControllerAnimated:YES];
        if (_doneAction != nil)
        {
            _doneAction();
        }
        return;
    }
//    if (imageDatas.count==1) {
        [SVProgressHUD showWithStatus:@"上传中" maskType:SVProgressHUDMaskTypeGradient];
//    }
//    else {
//        [SVProgressHUD showProgress:0.1 status:@"正在上传1张" maskType:SVProgressHUDMaskTypeGradient];
//    }
    OWTAssetManager* am = GetAssetManager();
    am.gameId = [self getGameId:@"不选"];
    [am uploadImageDatas:imageDatas
                 caption:_addDesCell.textView.text
               isPrivate:_isPrivate
              islocation:_locationString
              iskeywords:_caption
         belongingAlbums:_belongingAlbums
                progress:^(NSInteger uploadedImageNum, NSInteger totalImageNum) {
//                    float progress = ((float)uploadedImageNum) / (float)totalImageNum;
//                    [SVProgressHUD showProgress:progress
//                                         status:[NSString stringWithFormat:@"正在上传%li张",(long)(uploadedImageNum + 1)]
//                                       maskType:SVProgressHUDMaskTypeGradient];
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

#pragma mark - Action

-(void)tap {
    [self.view endEditing:YES];
}

- (void)uploadImages:(id)sender {
    [self.view endEditing:YES];
    
    NSArray *imageInfos = [_imageInfos copy];
    __weak __typeof(self) weakSelf = self;
    dispatch_queue_t dq = [self workingQueue];
    dispatch_async(dq, ^{
        __block NSMutableArray *imageDatas = [[NSMutableArray alloc] init];
        [imageInfos enumerateObjectsUsingBlock:^(OWTImageInfo *imageInfo, NSUInteger idx, BOOL *stop) {
            @autoreleasepool {
                if (imageInfo.image) {
                    // 拍照图片
                    UIImage *uploadImage = imageInfo.image;
                    if (!_isOriginal) {
                        // 拍照闪退
                        uploadImage = [imageInfo.image resizedImage:[weakSelf fixedUploadSizeForImage:imageInfo.image withorientation:1] interpolationQuality:kCGInterpolationHigh];
                    }
                    OWTimageData *imgData = [[OWTimageData alloc] init];
                    NSData* imageData = UIImageJPEGRepresentation(uploadImage, 0.8);
                    imgData.imageData=imageData;

                    [imageDatas addObject:imgData];
                }
                else {
                    // 相册图片
                    ALAssetRepresentation* rep = [imageInfo.asset defaultRepresentation];
                    NSError* error;
                    NSData* imageData;
                    
                    OWTimageData *imgData = [[OWTimageData alloc] init];
                    if (_isOriginal) {
                        NSMutableData* mutableImageData = [NSMutableData dataWithCapacity:(NSUInteger)rep.size];
                        [mutableImageData setLength:(NSUInteger)rep.size];
                        NSUInteger buffered = [rep getBytes:[mutableImageData mutableBytes]
                                                 fromOffset:0.0
                                                     length:(NSUInteger)rep.size
                                                      error:&error];
                        [mutableImageData setLength:buffered];
                        imageData = mutableImageData;
                        uint8_t *buffer = (uint8_t *)malloc(rep.size);
                        NSError *error;
                        NSUInteger length = [rep getBytes:buffer fromOffset:0 length:rep.size error:&error];
                        NSData *data = [NSData dataWithBytes:buffer length:length];
                        // 构造CGImageSource :
                        CGImageSourceRef cImageSource = CGImageSourceCreateWithData((__bridge CFDataRef)data, NULL);
                        
                        CFDictionaryRef imageInfo1 = CGImageSourceCopyPropertiesAtIndex(cImageSource, 0,NULL);
                        
                        NSInteger orientation = [(__bridge NSNumber *)CFDictionaryGetValue(imageInfo1, kCGImagePropertyOrientation) integerValue];
                        
                        imgData.imageData = imageData;
                        imgData.orientation = orientation;
                        [imageDatas addObject:imgData];
                    }
                    else {
                        CGImageRef iref = [rep fullResolutionImage];
                        UIImage* image = [UIImage imageWithCGImage:iref];
                        uint8_t *buffer = (uint8_t *)malloc(rep.size);
                        NSError *error;
                        NSUInteger length = [rep getBytes:buffer fromOffset:0 length:rep.size error:&error];
                        NSData *data = [NSData dataWithBytes:buffer length:length];
                        // 构造 CGImageSource :
                        CGImageSourceRef cImageSource = CGImageSourceCreateWithData((__bridge CFDataRef)data, NULL);
                        
                        CFDictionaryRef imageInfo1 = CGImageSourceCopyPropertiesAtIndex(cImageSource, 0,NULL);
                        
                        NSInteger orientation = [(__bridge NSNumber *)CFDictionaryGetValue(imageInfo1, kCGImagePropertyOrientation) integerValue];
                        
                        image = [image resizedImage:[self fixedUploadSizeForImage:image withorientation:orientation] interpolationQuality:kCGInterpolationHigh];
                        imageData = UIImageJPEGRepresentation(image, 0.8);
                        
                        imgData.imageData =imageData;
                        imgData.orientation =orientation;
                        [imageDatas addObject:imgData];
                    }
                }
            }
        }];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf uploadByImageDatas:imageDatas];
        });
    });
}

- (void)cancelUploadImages:(id)sender {
    if (self.cancelAction) {
        self.cancelAction();
        self.cancelAction=nil;
    }
}

- (void)createOrUploadImage {
    if (self.isCameraImages) {
        [self takePhontos];
    }
    else {
        [self uploadPhotos];
    }
//    NSArray *array = nil;
//    if (self.isCameraImages) {
//        array = @[@"拍照"];
//    }
//    else {
//        array = @[@"照片"];
//    }
//    
//    __weak __typeof(self) weakSelf = self;
//    [UIActionSheet presentOnView:[self.view window]
//                       withTitle:nil
//                    cancelButton:@"取消"
//               destructiveButton:nil
//                    otherButtons:array
//                        onCancel:nil
//                   onDestructive:nil
//                 onClickedButton:^(UIActionSheet* actionSheet, NSUInteger buttonIndex) {
//                     if (weakSelf.isCameraImages)
//                     {
//                         [self takePhotos];
//                     }
//                     else
//                     {
//                         [self uploadPhotos];
//                     }
//                 }];
}
-(void)takePhontos{
    UIImagePickerController *controller = [[UIImagePickerController alloc] init];
    [controller setSourceType:UIImagePickerControllerSourceTypeCamera];// 设置类型
    
    
    // 设置所支持的类型，设置只能拍照，或则只能录像，或者两者都可以
    NSString *requiredMediaType = ( NSString *)kUTTypeImage;
//    NSString *requiredMediaType1 = ( NSString *)kUTTypeMovie;
    NSArray *arrMediaTypes=[NSArray arrayWithObjects:requiredMediaType,nil];
    [controller setMediaTypes:arrMediaTypes];
    
    // 设置录制视频的质量
    [controller setVideoQuality:UIImagePickerControllerQualityTypeHigh];
    //设置最长摄像时间
    [controller setVideoMaximumDuration:10.f];
    
    
    //        [controller setAllowsEditing:YES];// 设置是否可以管理已经存在的图片或者视频
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
        NSMutableArray* imageInfos = [[NSMutableArray alloc] init];
        OWTImageInfo* imageInfo = [[OWTImageInfo alloc] init];
        imageInfo.primaryColorHex = @"DDDDDD";
        imageInfo.width = 64;
        imageInfo.height = 64;

        imageInfo.image = theImage;
        [imageInfos addObject:imageInfo];
        [_imageInfos addObject:imageInfo];
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:0]]
                                  withRowAnimation:UITableViewRowAnimationNone];

    }
    
    [picker dismissViewControllerAnimated:nil completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    
    [picker dismissViewControllerAnimated:nil completion:nil];
}

- (void)takePhotos {
    __weak __typeof(self) weakSelf = self;
    NBUImagePickerResultBlock resultBlock = ^(NSArray* images) {
        if (images == nil || images.count == 0)
        {
            return;
        }
        else
        {
            OWTImageInfo* imageInfo = [[OWTImageInfo alloc] init];
            imageInfo.primaryColorHex = @"DDDDDD";
            imageInfo.width = 64;
            imageInfo.height = 64;
            imageInfo.image = images[0];
            [_imageInfos addObject:imageInfo];
            [weakSelf.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:0]]
                                      withRowAnimation:UITableViewRowAnimationNone];
        }
    };
    
    NBUImagePickerOptions options = NBUImagePickerOptionSingleImage |
    NBUImagePickerOptionReturnImages |
    NBUImagePickerOptionStartWithCamera |
    NBUImagePickerOptionDisableEdition |
    NBUImagePickerOptionDisableLibrary |
    NBUImagePickerOptionDoNotSaveImages;
    
    [NBUImagePickerController startPickerWithTarget:self
                                            options:options
                                   customStoryboard:nil
                                        resultBlock:resultBlock];
}

- (void)uploadPhotos {
    __weak __typeof(self) weakSelf = self;
    __block NSMutableArray *selectedPhotos = [[NSMutableArray alloc] init];
    //拍照相片个数
    __block NSUInteger cameraNum = 0;
    
    [_imageInfos enumerateObjectsUsingBlock:^(OWTImageInfo *imageInfo, NSUInteger idx, BOOL *stop) {
        if (imageInfo.asset) {
            NSURL *assetURL = [imageInfo.asset valueForProperty:ALAssetPropertyAssetURL];
            [selectedPhotos addObject:[assetURL absoluteString]];
        }
        else if (imageInfo.image) {
            cameraNum++;
        }
    }];
    
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
        
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
        
    } andSuccessBlock:^(NSArray *info) {
        NSLog(@"Info: %@", info);
        for (ALAsset* mediaInfo in info)
        {
            OWTImageInfo* imageInfo = [[OWTImageInfo alloc] init];
            imageInfo.url =[[mediaInfo valueForProperty:ALAssetPropertyAssetURL] absoluteString];
            imageInfo.primaryColorHex = @"DDDDDD";
            imageInfo.width = 64;
            imageInfo.height = 64;
            imageInfo.asset = mediaInfo;
            [weakSelf.imageInfos addObject:imageInfo];
        }
        
        [weakSelf dismissViewControllerAnimated:YES completion:nil];
//        [weakSelf.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:0]]
//                                  withRowAnimation:UITableViewRowAnimationNone];
        [weakSelf.tableView reloadData];
    }];
    
    imagePickerController.selection = selectedPhotos;
    imagePickerController.shouldShowSavedPhotosOnTop = YES;
    imagePickerController.shouldChangeStatusBarStyle = YES;
    imagePickerController.maximumNumberOfPhotosToBeSelected = 9;
    [self presentViewController:imagePickerController animated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 6;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    switch (indexPath.row) {
        case 0: {
            if (!_addDesCell) {
                _addDesCell = [[OWTPhotoUploadDesCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
                _addDesCell.textView.delegate = self;
            }
            cell = _addDesCell;
            break;
        }
            
        case 1: {
            if (!_photosCell) {
                _photosCell = [[OWTPhotoUploadImagesCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
                _photosCell.delegate = self;
            }
            _photosCell.imageInfos = self.imageInfos;
            cell = _photosCell;
            break;
        }
            
        case 3: {
            if (!_tagsCell) {
                _tagsCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
                _tagsCell.backgroundColor = [UIColor clearColor];
                _tagsCell.contentView.backgroundColor = [UIColor clearColor];
                [_tagsCell.contentView addSubview:_uploadTagView];
            }
            // 标签界面
            CGRect frame = CGRectMake(0.0, 10.0, self.view.bounds.size.width, 0.0);
            _tagHeight = [OWTPhotoUploadTagView heightFromTagString:_caption width:frame.size.width - 20.0 font:[UIFont systemFontOfSize:13.0]];
            frame.size.height = _tagHeight;
            _uploadTagView.frame = frame;
            [_uploadTagView updateTagButtons];
            cell = _tagsCell;
            break;
        }
            
        default: {
            static NSString *identifier = @"OWTPhotoUploadCell";
            cell = [tableView dequeueReusableCellWithIdentifier:identifier];
            if (!cell) {
                cell = [[OWTPhotoUploadCustomCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                       reuseIdentifier:identifier];
                cell.textLabel.font = [UIFont systemFontOfSize:15.0];
            }
            OWTPhotoUploadCustomCell *customCell = (OWTPhotoUploadCustomCell *)cell;
            customCell.upLineView.hidden = YES;
            customCell.customSwitch.hidden = YES;
            if (indexPath.row == 2) {
                cell.textLabel.text = _locationString;
                cell.imageView.image = [UIImage imageNamed:@"上传图片位置icon.png"];
                customCell.upLineView.hidden = NO;
            }
            else if (indexPath.row == 4) {
                cell.textLabel.text = @"私有照片";
                cell.imageView.image = [UIImage imageNamed:@"上传图片私有照片icon.png"];
                // 开关
                customCell.accessoryView = customCell.customSwitch;
                customCell.customSwitch.hidden = NO;
                [customCell.customSwitch setOn:_isPrivate animated:NO];
                [customCell.customSwitch setDidChangeHandler:^(BOOL isOn) {
                    _isPrivate = isOn;
                }];
            }
            else if (indexPath.row == 5) {
                cell.textLabel.text = @"上传原图";
                cell.imageView.image = [UIImage imageNamed:@"上传原图icon.png"];
                customCell.upLineView.hidden = NO;
                // 开关
                customCell.accessoryView = customCell.customSwitch;
                customCell.customSwitch.hidden = NO;
                [customCell.customSwitch setOn:_isOriginal animated:NO];
                [customCell.customSwitch setDidChangeHandler:^(BOOL isOn) {
                    _isOriginal = isOn;
                }];
            }
            break;
        }
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = 0.0;
    switch (indexPath.row) {
        case 0: {
            height = 70.0;
            break;
        }
            
        case 1: {
            UIScreen *screen = [UIScreen mainScreen];
            CGFloat size = (screen.bounds.size.width - 35.0) / 4.0;
            NSUInteger count = (self.imageInfos && self.imageInfos.count > 0) ? self.imageInfos.count : 0;
            if (count < 9) {
                // Add按钮
                count++;
            }
            NSUInteger line = (count >= 9) ? 3 : (count / 4 + ((count % 4 == 0) ? 0 : 1));
            height = line * size + (line - 1) * 5.0 + 10.0;
            break;
        }
            
        case 3: {
            CGRect frame = CGRectMake(0.0, 10.0, self.view.bounds.size.width, 0.0);
            _tagHeight = [OWTPhotoUploadTagView heightFromTagString:_caption width:frame.size.width - 20.0 font:[UIFont systemFontOfSize:13.0]];
            height = _tagHeight + 20.0;
            break;
        }
            
        default: {
            height = 44.0;
            break;
        }
    }
    return height;
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap)];
    [self.view addGestureRecognizer:_tapGesture];
    
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]
                          atScrollPosition:UITableViewScrollPositionBottom
                                  animated:NO];

}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self.view removeGestureRecognizer:_tapGesture];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [_uploadTagView addTagStr:textField.text];
    textField.text = nil;
    [self.view endEditing:YES];
    return YES;
}

#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView {
    if (textView == _addDesCell.textView) {
        // 显示placeholder
        _addDesCell.placeHolderLabel.hidden = (_addDesCell.textView.text && _addDesCell.textView.text.length > 0);
    }
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    if (textView == _addDesCell.textView) {
        _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap)];
        [self.view addGestureRecognizer:_tapGesture];
        
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                              atScrollPosition:UITableViewScrollPositionTop
                                      animated:YES];
    }
    
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    if (textView == _addDesCell.textView) {
        [self.view removeGestureRecognizer:_tapGesture];
    }
}

#pragma mark - OWTPhotoUploadTagViewDelegate

- (void)didTagsValueChanged:(NSString *)tag {
    _caption = tag;
    if (_imageInfos && _imageInfos.count > 0 && !self.isCameraImages) {
        OWTImageInfo *imageInfo = _imageInfos[0];
        [self updataCaption:_caption withImage:imageInfo.url];
    }
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:3 inSection:0]]
                          withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - OWTPhotoUploadImagesCellDelegate

- (void)didSelectPhotoUploadImageIndex:(NSUInteger)index {
    NSMutableArray *FSArr = [NSMutableArray array];
    
    for (OWTImageInfo *imageInfo in _imageInfos) {
        FSBasicImage *firstPhoto = nil;
        if (self.isCameraImages) {
            firstPhoto = [[FSBasicImage alloc] initWithImage:imageInfo.image];
        }
        else {
            firstPhoto = [[FSBasicImage alloc] initWithAssert:imageInfo.asset];
        }
        [FSArr addObject:firstPhoto];
    }
    
    FSBasicImageSource *photoSource = [[FSBasicImageSource alloc] initWithImages:FSArr];
    FSImageViewerViewController *imageViewController = [[FSImageViewerViewController alloc] initWithAssestImageSource:photoSource imageIndex:index withViewController:self];
    imageViewController.ifGridImage = YES;
    imageViewController.isLocal = YES;
    imageViewController.navigationController.navigationBarHidden =YES;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [self.navigationController presentViewController:imageViewController animated:YES completion:nil];
    }
    else {
        [self.navigationController pushViewController:imageViewController animated:YES];
    }
}

- (void)didSelectPhotoUploadAddButton {
    [self createOrUploadImage];
}

@end
