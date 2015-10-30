//
//  OWTUserInfoEditViewCon.m
//  Weitu
//
//  Created by Su on 4/13/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import "OWTUserInfoEditViewCon.h"
#import "OWTUserManager.h"
#import "OWTTextEditViewCon.h"
#import "OWTRoundImageView.h"
#import "SVProgressHUD+WTError.h"
#import <JMStaticContentTableViewController/JMStaticContentTableViewController.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <SHBarButtonItemBlocks/SHBarButtonItemBlocks.h>
#import <NBUImagePicker/NBUImagePickerController.h>

#import <UIImage+Dummy/UIImage+Dummy.h>
#import "LJUserInformation.h"
#import "LJUIController.h"
#import "LJPickerViewController.h"
#import "LJFavorite.h"
#import "UIColor+HexString.m"
#import "QJPassport.h"
#import "QJInterfaceManager.h"
@interface OWTUserInfoEditViewCon ()
{
    NSMutableData *_data;
    LJUserInformation *_ljuser;
    NSURLConnection *_connection;
    NSMutableData *_areaData;
    NSMutableArray *_citys;
    NSMutableArray *_province;
    NSArray *_dictDecade;
    NSArray *_dictOccupation;
    NSArray *_dictConstellation;
    NSArray *_dictMarriage;
    NSArray *_dictArea;
    NSString *_birthLocation;
    NSString *_city;
    NSString *_homeCity;
    BOOL _updatedAvatarAcion;

}

@property (nonatomic, strong) JMStaticContentTableViewController* tableViewCon;
@property (nonatomic, strong) OWTTextEditViewCon* textEditViewCon;
@property(nonatomic,strong)LJPickerViewController *ljPickerView;
@property(nonatomic,strong)LJFavorite *favorite;
@property (nonatomic, strong) UIImage* updatedAvatar;
@property (nonatomic, strong) NSString* updatedNickname;
@property (nonatomic, strong) NSString* updatedSignature;

//
//@property(nonatomic, strong) UIImageView *img;
@property(nonatomic, strong) NSData *fileData;
@property(nonatomic, strong)OWTRoundImageView* img;
@end

@implementation OWTUserInfoEditViewCon

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        
        [self setup];
    }
    return self;
}
-(void)getResouceData
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[QJPassport sharedPassport] requestUserInfo :^(QJUser * user, NSDictionary * userDic, NSError * error){
            if (error == nil) {
                //适配数据到model LJUserInformation
                [_ljuser userAdaptInformation:user];
                [_tableViewCon.tableView reloadData];
            }
            else{
                [SVProgressHUD showError:error];
            }
        }];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            
        });
    });

}

-(void)getAreaData
{
    NSURL *url= [NSURL URLWithString:[NSString stringWithFormat:@"http://api.tiankong.com/qjapi/cdn1/users/reginfo"]];
    NSURLRequest *request=[NSURLRequest requestWithURL:url];
    NSURLConnection *connection=[[NSURLConnection alloc]initWithRequest:request delegate:self];
}
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if (connection==_connection) {
        [_data appendData:data];
    }else
    {
        [_areaData appendData:data];
    }
}
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    if (connection==_connection) {
        [_data setLength:0];
    }else
    {
        [_areaData setLength:0];
    }
}
-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if (connection==_connection) {
        NSDictionary *dict=[NSJSONSerialization JSONObjectWithData:_data options:NSJSONReadingMutableContainers error:nil];
        NSDictionary *dict1=dict[@"user"];
        [_ljuser setValuesForKeysWithDictionary:dict1];
        [_tableViewCon.tableView reloadData];
    }else{
        NSDictionary *dict=[NSJSONSerialization JSONObjectWithData:_areaData options:NSJSONReadingMutableContainers error:nil];
        _dictArea=[[NSArray alloc]initWithArray:dict[@"DictArea"]];
        _dictDecade=[[NSArray alloc]initWithArray:dict[@"DictDecade"]];
        _dictOccupation=[[NSArray alloc]initWithArray:dict[@"DictOccupation"]];
        _dictConstellation=[[NSArray alloc]initWithArray:dict[@"DictConstellation"]];
        _dictMarriage=[[NSArray alloc]initWithArray:dict[@"DictMarriage"]];
        
        NSString *homeDictionary = NSHomeDirectory();//获取根目录
        NSString *homePath  = [homeDictionary stringByAppendingString:@"/Documents/cityDode2Name.archiver"];//添加储存的文件名
        [NSKeyedArchiver archiveRootObject:_dictArea toFile:homePath];
        
        NSArray *arr=dict[@"DictArea"];
        for (NSDictionary *dict1 in arr) {
            if ([dict1[@"ParentID"]isEqualToString:@"0"]) {
                NSString *str=dict1[@"DictName"];
                [_province addObject:str];
            }
        }
        for (NSInteger i=1; i<36; i++) {
            NSMutableArray *citys=[[NSMutableArray alloc]init];
            for (NSDictionary *dict2 in arr) {
                if ([dict2[@"ParentID"]isEqualToString:[NSString stringWithFormat:@"%ld",i]]) {
                    [citys addObject:dict2[@"DictName"]];
                }
            }
            [_citys addObject:citys];
        }
    }
}

- (void)setup
{
    _textEditViewCon = [[OWTTextEditViewCon alloc] initWithNibName:nil bundle:nil];
    _ljPickerView=[[LJPickerViewController alloc]init];
    _tableViewCon = [[JMStaticContentTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    _favorite=[[LJFavorite alloc]init];
    [self addChildViewController:_tableViewCon];
    
    self.navigationItem.title = @"编辑个人信息";
    
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem SH_barButtonItemWithTitle:@"取消" style:UIBarButtonItemStyleDone
                                                                             withBlock:^(UIBarButtonItem* sender){
                                                                                 [self.navigationController popViewControllerAnimated:YES];
                                                                                 if (_cancelAction != nil){
                                                                                     _cancelAction(nil);}}];
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem SH_barButtonItemWithTitle:@"保存"style:UIBarButtonItemStyleDone withBlock:^(UIBarButtonItem* sender) {
        //昵称
        if ([self truename]==nil||[self truename].length==0||[self truename].length>=10){
            [SVProgressHUD showErrorWithStatus:@"昵称过长或者没有填写昵称"];
            return;
        }
        
        [SVProgressHUD showWithStatus:NSLocalizedString(@"PLEASE_WAIT", @"Please wait.")
                             maskType:SVProgressHUDMaskTypeBlack];
        NSMutableDictionary* params = [NSMutableDictionary dictionary];
        //性别
        if ([self Sex]==nil) {
            params[@"gender"]= [NSNumber numberWithInt:0];
        }else{
            if ([[self Sex]isEqualToString:@"男"]) {
                params[@"gender"] = [NSNumber numberWithInt:0];
            }else{
                params[@"gender"] = [NSNumber numberWithInt:1];
            }
        }
        
        //年龄
        if ([self decade]==nil) {
            params[@"age"]=@"保密";
        }else{
            params[@"age"]=[self decade];
        }
        
        //星座
        if ([self Constellation]==nil) {
            params[@"starSign"] = @"保密";
        }else {
            params[@"starSign"] = [self Constellation];
        }
        //情感状态
        if ([self Marrige]==nil) {
            params[@"maritalStatus"]=@"保密";
        }else {
            params[@"maritalStatus"]=[self Marrige];
        }
        //出生地
        if ([self BirthLocation]==nil||[[self BirthLocation]isEqualToString:@"保密"]) {
            params[@"bornArea"] =  nil;
        }else {
            params[@"bornArea"] = [_ljuser cityName2CityCode: [self BirthLocation]];
        }
        //居住城市
        if ([self HomeCity]==nil||[[self HomeCity]isEqualToString:@"保密"]) {
            params[@"residence"] = nil;
        }else{
            params[@"residence"] = [_ljuser cityName2CityCode: [self HomeCity]];
        }
        //出没地
        if ([self City]==nil||[[self City]isEqualToString:@"保密"]) {
            params[@"stayArea"] = nil;
        }else{
            params[@"stayArea"] = [_ljuser cityName2CityCode: [self City]];
        }
        //职业
        if ([self Occupation]==nil) {
            params[@"job"]=@"保密";
        }else {
            for (NSDictionary *dict in _dictOccupation) {
                if ([dict[@"DictName"]isEqualToString:[self Occupation]]) {
                    params[@"job"]= [self Occupation];
                    break;
                }
            }}
        if ([self Favority]==nil) {
            params[@"interest"]=@"";
        }else {
            params[@"interest"]=[self Favority];
        }
        if ([self truename]==nil) {
            params[@"nickname"]=@"";
        }else{
            params[@"nickname"]=[self truename];
        }
        //签名档
        if ([self userinfo]==nil) {
            params[@"introduce"]=@"";
        }else{
            params[@"introduce"]=[self userinfo];
        }
        params[@"PhoneType"]=@"iphone";
        
        params[@"id"] = [[QJPassport sharedPassport]currentUser].uid ;
        QJUser *user = [[QJUser alloc]initWithJson:params];
        
        //若头像改动，先上传头像
        if(_updatedAvatarAcion && _updatedAvatar != nil){
            QJInterfaceManager *fm=[QJInterfaceManager sharedManager];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSData *imageData = UIImageJPEGRepresentation(_updatedAvatar,0.5);
                [fm requestUserAvatarTempData:imageData  extension:@"jpg" finished:^(NSString * imageUrl, NSDictionary * imageDic, NSError * error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (error == nil) {
                            user.avatar = imageUrl;
                            [self updateAvatarByURL:user];
                            _updatedAvatarAcion = false;
                            NSLog(@"头像上传成功");
                            
                        }else{
                            [SVProgressHUD showErrorWithStatus:@"头像上传失败"];
                            NSLog(@"头像上传失败");
                        }
                    });
                }];
            });
        }else{
            [self updateAvatarByURL:user];
            
        }

  }];
}


-(void)updateAvatarByURL:(QJUser*)user
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[QJPassport sharedPassport] requestModifyUserInfo:user finished:^(QJUser * user, NSDictionary * userDic, NSError * error){
            dispatch_async(dispatch_get_main_queue(), ^{
                if (error == nil) {
                    NSLog(@"修改成功,修改全局user");
                    [SVProgressHUD dismiss];
                    QJUser *updataUser = [[QJPassport sharedPassport] currentUser];
                    updataUser = user;
                    [self.navigationController popViewControllerAnimated:YES];
                    if (_doneFunc != nil){
                        _doneFunc();
                    }
                }else{
                    [SVProgressHUD showError:error];
                }
            });
        }];
        
    });
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    _ljuser=[[LJUserInformation alloc]init];
    _data=[[NSMutableData alloc]init];
    _areaData=[[NSMutableData alloc]init];
    _citys=[[NSMutableArray alloc]init];
    _province=[[NSMutableArray alloc]init];
    _user1 = [[QJPassport sharedPassport] currentUser];
    [_ljuser userAdaptInformation:_user1];
    [self getcitybyCode];
    [_tableViewCon.tableView reloadData ];
   // [self getResouceData];
    [self getAreaData];
    [_textEditViewCon loadView];
    [_ljPickerView loadView];
    [self.view addSubview:_tableViewCon.view];
    _tableViewCon.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height+49);
    
    [self setupAvatarSection];
    [self setupNicknameSignatureSection];
    [self setupSection1];
    [self setupSection2];
    [self setupSection3];
}

-(void)getcitybyCode
{
    if (_user1 != nil) {
        //解析出生城市
        _ljuser.BirthLocation = [_ljuser cityCode2CityName: _user1.bornArea];
        //解析居住城市
        _ljuser.HomeCity = [_ljuser cityCode2CityName: _user1.residence];
        //解析出没地城市
        _ljuser.City = [_ljuser cityCode2CityName: _user1.stayArea];
    }

}

//设定头像
- (void)setupAvatarSection
{
    _img = [[OWTRoundImageView alloc] initWithFrame:CGRectMake(0, 0, 64, 64)];
    __weak OWTUserInfoEditViewCon* wself = self;
    [_tableViewCon addSection:^(JMStaticContentTableViewSection *section, NSUInteger sectionIndex) {
        [section addCell:^(JMStaticContentTableViewCell* staticContentCell, UITableViewCell* cell, NSIndexPath* indexPath) {
            staticContentCell.cellStyle = UITableViewCellStyleDefault;
            staticContentCell.reuseIdentifier = @"DetailTextImageCell";
            staticContentCell.cellHeight = 88;
            
            if (cell != nil)
            {
                cell.textLabel.text = @"头像";
                cell.accessoryView = wself.img;
                if (wself.updatedAvatar != nil)
                {
                    [wself.img setImage:wself.updatedAvatar];
                }
                else
                {
                   wself.user1.avatar = [QJInterfaceManager thumbnailUrlFromImageUrl:wself.user1.avatar size:CGSizeMake(wself.img.bounds.size.width, wself.img.bounds.size.height)];
                    [wself.img setImageWithURLString:wself.user1.avatar primaryColorHex:nil];
                    
                }
            }
        }
            whenSelected:^(NSIndexPath* indexPath) {
                [wself.tableViewCon.tableView deselectRowAtIndexPath:indexPath animated:YES];
                [wself takePictureClick];
                [wself.tableViewCon.tableView reloadData];
                
            }];
    }];
}
//
//从相册获取图片
-(void)takePictureClick
{
    //    /*注：使用，需要实现以下协议：UIImagePickerControllerDelegate,
    //     UINavigationControllerDelegate
    //     */
    //    UIImagePickerController *picker = [[UIImagePickerController alloc]init];
    //    //设置图片源(相簿)
    //    picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    //    //设置代理
    //    picker.delegate = self;
    //    //设置可以编辑
    //    picker.allowsEditing = YES;
    //    //打开拾取器界面
    //    [self presentViewController:picker animated:YES completion:nil];
    UIActionSheet* actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:@"请选择文件来源"
                                  delegate:self
                                  cancelButtonTitle:@"取消"
                                  destructiveButtonTitle:nil
                                  otherButtonTitles:@"本地相簿",nil];
    [actionSheet showInView:self.view];
    
}
#pragma mark -
#pragma UIActionSheet Delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"buttonIndex = [%ld]",buttonIndex);
    switch (buttonIndex) {
            //        case 0://照相机
            //        {
            //            UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
            //            imagePicker.delegate = self;
            //            imagePicker.allowsEditing = YES;
            //            imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            //            //            [self presentModalViewController:imagePicker animated:YES];
            //            [self presentViewController:imagePicker animated:YES completion:nil];
            //        }
            //            break;
            //        case 1://摄像机
            //        {
            //            UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
            //            imagePicker.delegate = self;
            //            imagePicker.allowsEditing = YES;
            //            imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            //            imagePicker.videoQuality = UIImagePickerControllerQualityTypeLow;
            //            //            [self presentModalViewController:imagePicker animated:YES];
            //            [self presentViewController:imagePicker animated:YES completion:nil];
            //        }
            //            break;
        case 0://本地相簿
        {
            UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
            imagePicker.delegate = self;
            imagePicker.allowsEditing = YES;
            //            imagePicker.allowsImageEditing=YES;
            imagePicker.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIColor colorWithHexString:@"f6f6f6"] forKey:UITextAttributeTextColor];
            imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            imagePicker.navigationBar.barTintColor=[UIColor blackColor];
            //            [self presentModalViewController:imagePicker animated:YES];
            [self presentViewController:imagePicker animated:YES completion:nil];
        }
            //            break;
            //        case 3://本地视频
            //        {
            //            UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
            //            imagePicker.delegate = self;
            //            imagePicker.allowsEditing = YES;
            //            imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            //            //            [self presentModalViewController:imagePicker animated:YES];
            //            [self presentViewController:imagePicker animated:YES completion:nil];
            //        }
            break;
        default:
            break;
    }
}

#pragma mark -
#pragma UIImagePickerController Delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    if ([[info objectForKey:UIImagePickerControllerMediaType] isEqualToString:(__bridge NSString *)kUTTypeImage]) {
        UIImage *img = [info objectForKey:UIImagePickerControllerEditedImage];
        [self performSelector:@selector(saveImage:)  withObject:img afterDelay:0.5];
    }
    else if ([[info objectForKey:UIImagePickerControllerMediaType] isEqualToString:(__bridge NSString *)kUTTypeMovie]) {
        NSString *videoPath = [[info objectForKey:UIImagePickerControllerMediaURL] path];
        self.fileData = [NSData dataWithContentsOfFile:videoPath];
    }
    //    [picker dismissModalViewControllerAnimated:YES];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    //    [picker dismissModalViewControllerAnimated:YES];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)saveImage:(UIImage *)image {
    //    NSLog(@"保存头像！");
    //    [userPhotoButton setImage:image forState:UIControlStateNormal];
    BOOL success;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *imageFilePath = [documentsDirectory stringByAppendingPathComponent:@"selfPhoto.jpg"];
    NSLog(@"imageFile->>%@",imageFilePath);
    success = [fileManager fileExistsAtPath:imageFilePath];
    if(success) {
        success = [fileManager removeItemAtPath:imageFilePath error:&error];
        _updatedAvatarAcion = YES;

    }
    //    UIImage *smallImage=[self scaleFromImage:image toSize:CGSizeMake(80.0f, 80.0f)];//将图片尺寸改为80*80
    //    UIImage *smallImage = [self thumbnailWithImageWithoutScale:image size:CGSizeMake(93, 93)];
    [UIImageJPEGRepresentation(image, 1.0f) writeToFile:imageFilePath atomically:YES];//写入文件
    UIImage *selfPhoto = [UIImage imageWithContentsOfFile:imageFilePath];//读取图片文件
    //    [userPhotoButton setImage:selfPhoto forState:UIControlStateNormal];
    self.img.image = selfPhoto;
    self.updatedAvatar =selfPhoto;
}

// 改变图像的尺寸，方便上传服务器
- (UIImage *) scaleFromImage: (UIImage *) image toSize: (CGSize) size
{
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}


//#pragma mark -
//#pragma mark UIImagePickerControllerDelegate methods
////完成选择图片
//-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
//{
//    //加载图片
//    self.img.image = image;
//    //选择框消失
//    [picker dismissViewControllerAnimated:YES completion:nil];
//}
////取消选择图片
//-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
//{
//    [picker dismissViewControllerAnimated:YES completion:nil];
//}
//
//- (IBAction)cameraBtn:(id)sender
//
//{
//
//    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
//
//    imagePicker.delegate = self;
//
//    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;//获取类型是摄像头，还可以是相册
//
//    imagePicker.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
//
//    imagePicker.allowsEditing = NO;//如果为NO照出来的照片是原图，比如4s和5的iPhone出来的尺寸应该是（2000+）*（3000+），差不多800W像素，如果是YES会有个选择区域的方形方框
//
//    //    imagePicker.showsCameraControls = NO;//默认是打开的这样才有拍照键，前后摄像头切换的控制，一半设置为NO的时候用于自定义ovelay
//
////    UIImageView *overLayImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 640)];
////    overLayImg.image = [UIImage imageNamed:@"overlay.png"];
//
////    imagePicker.cameraOverlayView = overLayImg;//3.0以后可以直接设置cameraOverlayView为overlay
////    imagePicker.wantsFullScreenLayout = YES;
//
//    [self presentModalViewController:imagePicker animated:YES];
//
//}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//
//- (UIImage *)thumbnailWithImage:(UIImage *)image size:(CGSize)asize
//{
//    UIImage *newimage;
//    if (nil == image) {
//        newimage = nil;
//    }
//    else{
//        UIGraphicsBeginImageContext(asize);
//        [image drawInRect:CGRectMake(0, 0, asize.width, asize.height)];
//        newimage = UIGraphicsGetImageFromCurrentImageContext();
//        UIGraphicsEndImageContext();
//    }
//    return newimage;
//}
//
//2.保持原来的长宽比，生成一个缩略图
- (UIImage *)thumbnailWithImageWithoutScale:(UIImage *)image size:(CGSize)asize
{
    UIImage *newimage;
    if (nil == image) {
        newimage = nil;
    }
    else{
        CGSize oldsize = image.size;
        CGRect rect;
        if (asize.width/asize.height > oldsize.width/oldsize.height) {
            rect.size.width = asize.height*oldsize.width/oldsize.height;
            rect.size.height = asize.height;
            rect.origin.x = (asize.width - rect.size.width)/2;
            rect.origin.y = 0;
        }
        else{
            rect.size.width = asize.width;
            rect.size.height = asize.width*oldsize.height/oldsize.width;
            rect.origin.x = 0;
            rect.origin.y = (asize.height - rect.size.height)/2;
        }
        UIGraphicsBeginImageContext(asize);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(context, [[UIColor clearColor] CGColor]);
        UIRectFill(CGRectMake(0, 0, asize.width, asize.height));//clear background
        [image drawInRect:rect];
        newimage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    return newimage;
}
//


- (void)setupNicknameSignatureSection
{
    __weak OWTUserInfoEditViewCon* wself = self;
    __weak LJUserInformation *wlj=_ljuser;
    [_tableViewCon addSection:^(JMStaticContentTableViewSection *section, NSUInteger sectionIndex) {
        [section addCell:^(JMStaticContentTableViewCell* staticContentCell, UITableViewCell* cell, NSIndexPath* indexPath) {
            staticContentCell.cellStyle = UITableViewCellStyleValue1;
            staticContentCell.reuseIdentifier = @"DetailTextCell";
            if (cell != nil)
            {
                cell.textLabel.text = @"昵称";
                cell.detailTextLabel.text =[wself truename];
            }
        }
            whenSelected:^(NSIndexPath* indexPath) {
                __weak OWTTextEditViewCon* textEditViewCon = wself.textEditViewCon;
                textEditViewCon.title = @"修改昵称";
                if (wself.truename) {
                    textEditViewCon.text = wself.truename;
                }else{
                    textEditViewCon.text = wlj.truename;}
                textEditViewCon.doneFunc = ^{
                    _truename = textEditViewCon.text;
                    if ([self truename]==nil||[self truename].length==0||[self truename].length>=10){
                        [SVProgressHUD showErrorWithStatus:@"昵称过长(最长十个字符)或者没有填写昵称"];
                        return;
                    }else{
                        [wself.navigationController popViewControllerAnimated:YES];
                        [wself.tableViewCon.tableView reloadData];
                    }
                };
                [wself.navigationController pushViewController:wself.textEditViewCon animated:YES];
            }];
        
        [section addCell:^(JMStaticContentTableViewCell* staticContentCell, UITableViewCell* cell, NSIndexPath* indexPath) {
            staticContentCell.cellStyle = UITableViewCellStyleValue1;
            staticContentCell.reuseIdentifier = @"DetailTextCell";
            if (cell != nil)
            {
                cell.textLabel.text = @"签名档";
                cell.detailTextLabel.text = [wself userinfo];
            }
        } whenSelected:^(NSIndexPath* indexPath) {
            __weak OWTTextEditViewCon* textEditViewCon = wself.textEditViewCon;
            textEditViewCon.title = @"修改签名档";
            if (wself.userinfo) {
                textEditViewCon.text = wself.userinfo;
            }else{
                textEditViewCon.text = wlj.Userinfo;}
            textEditViewCon.doneFunc = ^{
                _userinfo = textEditViewCon.text;
                [wself.navigationController popViewControllerAnimated:YES];
                [wself.tableViewCon.tableView reloadData];
            };
            [wself.navigationController pushViewController:wself.textEditViewCon animated:YES];
        }];
        [section addCell:^(JMStaticContentTableViewCell* staticContentCell, UITableViewCell* cell, NSIndexPath* indexPath) {
            staticContentCell.cellStyle = UITableViewCellStyleDefault;
            staticContentCell.highlightable = NO;
            staticContentCell.reuseIdentifier = @"DetailTextCell";
            if (cell != nil)
            {
                cell.textLabel.text = @"手机号码";
                //cell.accessoryType = UITableViewCellAccessoryNone;
                cell.detailTextLabel.text = wself.user1.phone;
                for (UIView *view  in cell.subviews) {
                    for (UIView *view1 in view.subviews) {
                        if ([view1 isKindOfClass:[UIImageView class]]) {
                            [view1 removeFromSuperview];
                        }
                    }
                }
            }
        } whenSelected:nil];
    }];
}

- (void)setupSection1
{
    __weak OWTUserInfoEditViewCon* wself = self;
    __weak LJUserInformation *wlj=_ljuser;
    [_tableViewCon addSection:^(JMStaticContentTableViewSection *section, NSUInteger sectionIndex) {
        [section addCell:^(JMStaticContentTableViewCell* staticContentCell, UITableViewCell* cell, NSIndexPath* indexPath) {
            staticContentCell.cellStyle = UITableViewCellStyleValue1;
            //staticContentCell.highlightable = YES;
            staticContentCell.reuseIdentifier = @"DetailTextCell";
            if (cell != nil)
            {
                cell.textLabel.text = @"性别";
                //cell.accessoryType = UITableViewCellAccessoryNone;
                cell.detailTextLabel.text = [wself Sex];
            } } whenSelected:^(NSIndexPath *indexPath){
                __weak LJPickerViewController *ljpicker=wself.ljPickerView;
                NSArray *arr=@[@"男",@"女"];
                NSArray *arr1=@[arr];
                ljpicker.dataArray=arr1;
                ljpicker.backgroundImage=[wself ScreenShot];
                ljpicker.doneFunc=^{
                    _sex=ljpicker.backString1;
                    [wself.tableViewCon.tableView reloadData];
                };
                //                [wself.navigationController presentViewController:ljpicker animated:YES completion:nil ];
                [wself.navigationController pushViewController:ljpicker animated:YES];
                
            }];
        [section addCell:^(JMStaticContentTableViewCell* staticContentCell, UITableViewCell* cell, NSIndexPath* indexPath) {
            staticContentCell.cellStyle = UITableViewCellStyleValue1;
            staticContentCell.highlightable = YES;
            staticContentCell.reuseIdentifier = @"DetailTextCell";
            if (cell != nil)
            {
                cell.textLabel.text = @"年龄";
                //cell.accessoryType = UITableViewCellAccessoryNone;
                cell.detailTextLabel.text = [wself decade];
            }} whenSelected:^(NSIndexPath *indexPath){
                __weak LJPickerViewController *ljpicker=wself.ljPickerView;
                NSArray *arr=@[@"保密",@"60后",@"70后",@"80后",@"90后",@"00后"];
                NSArray *arr1=@[arr];
                ljpicker.dataArray=arr1;
                ljpicker.backgroundImage=[wself ScreenShot];
                ljpicker.doneFunc=^{
                    _decade=ljpicker.backString1;
                    [wself.tableViewCon.tableView reloadData];
                };
                [wself.navigationController pushViewController:ljpicker animated:YES];
                
            }];
        [section addCell:^(JMStaticContentTableViewCell* staticContentCell, UITableViewCell* cell, NSIndexPath* indexPath) {
            staticContentCell.cellStyle = UITableViewCellStyleValue1;
            staticContentCell.highlightable = YES;
            staticContentCell.reuseIdentifier = @"DetailTextCell";
            if (cell != nil)
            {
                cell.textLabel.text = @"星座";
                //cell.accessoryType = UITableViewCellAccessoryNone;
                cell.detailTextLabel.text = [wself Constellation];
            }} whenSelected:^(NSIndexPath *indexPath){
                __weak LJPickerViewController *ljpicker=wself.ljPickerView;
                NSArray *arr=@[@"白羊",@"金牛",@"双子",@"巨蟹",@"狮子",@"处女",@"天枰",@"天蝎",@"射手",@"魔蝎",@"水瓶",@"双鱼"];
                NSArray *arr1=@[arr];
                ljpicker.dataArray=arr1;
                ljpicker.backgroundImage=[wself ScreenShot];
                ljpicker.doneFunc=^{
                    _constellation=ljpicker.backString1;
                    [wself.tableViewCon.tableView reloadData];
                };
                [wself.navigationController pushViewController:ljpicker animated:YES];
                
            }];
        [section addCell:^(JMStaticContentTableViewCell* staticContentCell, UITableViewCell* cell, NSIndexPath* indexPath) {
            staticContentCell.cellStyle = UITableViewCellStyleValue1;
            staticContentCell.highlightable = YES;
            staticContentCell.reuseIdentifier = @"DetailTextCell";
            if (cell != nil)
            {
                cell.textLabel.text = @"情感状态";
                //cell.accessoryType = UITableViewCellAccessoryNone;
                cell.detailTextLabel.text =[wself Marrige];
            }} whenSelected:^(NSIndexPath *indexPath){
                __weak LJPickerViewController *ljpicker=wself.ljPickerView;
                NSArray *arr=@[@"保密",@"单身",@"恋爱中",@"订婚",@"已婚",@"离异"];
                NSArray *arr1=@[arr];
                ljpicker.dataArray=arr1;
                ljpicker.backgroundImage=[wself ScreenShot];
                ljpicker.doneFunc=^{
                    _marrige=ljpicker.backString1;
                    [wself.tableViewCon.tableView reloadData];
                };
                [wself.navigationController pushViewController:ljpicker animated:YES];
                
            }];
        
        
    }];
}
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
- (void)setupSection2
{
    __weak OWTUserInfoEditViewCon* wself = self;
    __weak LJUserInformation *wlj=_ljuser;
    __weak NSMutableArray *wcitys=_citys;
    __weak NSMutableArray *wprovice=_province;
    [_tableViewCon addSection:^(JMStaticContentTableViewSection *section, NSUInteger sectionIndex) {
        [section addCell:^(JMStaticContentTableViewCell* staticContentCell, UITableViewCell* cell, NSIndexPath* indexPath) {
            staticContentCell.cellStyle = UITableViewCellStyleValue1;
            staticContentCell.highlightable = YES;
            staticContentCell.reuseIdentifier = @"DetailTextCell";
            if (cell != nil)
            {
                cell.textLabel.text = @"出生地";
                //cell.accessoryType = UITableViewCellAccessoryNone;
                cell.detailTextLabel.text = [wself BirthLocation];
            } } whenSelected:^(NSIndexPath *indexPath){
                __weak LJPickerViewController *ljpicker=wself.ljPickerView;
                NSArray *arr1=@[wprovice,wcitys];
                if (wcitys.count==0) {
                    [SVProgressHUD showErrorWithStatus:@"请稍后再试"];
                    return ;
                }
                
                ljpicker.dataArray=arr1;
                ljpicker.isArea=YES;
                ljpicker.backgroundImage=[wself ScreenShot];
                ljpicker.doneFunc=^{
                    _birthLocation=[NSString stringWithFormat:@"%@ - %@",ljpicker.backString1,ljpicker.backString2];
                    [wself.tableViewCon.tableView reloadData];
                };
                [wself.navigationController pushViewController:ljpicker animated:YES];
                
            }];
        [section addCell:^(JMStaticContentTableViewCell* staticContentCell, UITableViewCell* cell, NSIndexPath* indexPath) {
            staticContentCell.cellStyle = UITableViewCellStyleValue1;
            staticContentCell.highlightable = YES;
            staticContentCell.reuseIdentifier = @"DetailTextCell";
            if (cell != nil)
            {
                cell.textLabel.text = @"居住地";
                //cell.accessoryType = UITableViewCellAccessoryNone;
                cell.detailTextLabel.text = [wself HomeCity];
            }} whenSelected:^(NSIndexPath *indexPath){
                __weak LJPickerViewController *ljpicker=wself.ljPickerView;
                if (wcitys.count==0) {
                    [SVProgressHUD showErrorWithStatus:@"请稍后再试"];
                    return ;
                }
                NSArray *arr1=@[wprovice,wcitys];
                ljpicker.dataArray=arr1;
                ljpicker.isArea=YES;
                ljpicker.backgroundImage=[wself ScreenShot];
                ljpicker.doneFunc=^{
                    _homeCity=[NSString stringWithFormat:@"%@ - %@",ljpicker.backString1,ljpicker.backString2];
                    [wself.tableViewCon.tableView reloadData];
                };
                [wself.navigationController pushViewController:ljpicker animated:YES];
                
            }];
        [section addCell:^(JMStaticContentTableViewCell* staticContentCell, UITableViewCell* cell, NSIndexPath* indexPath) {
            staticContentCell.cellStyle = UITableViewCellStyleValue1;
            staticContentCell.highlightable = YES;
            staticContentCell.reuseIdentifier = @"DetailTextCell";
            if (cell != nil)
            {
                cell.textLabel.text = @"出没地";
                //cell.accessoryType = UITableViewCellAccessoryNone;
                cell.detailTextLabel.text = [wself City];
            }} whenSelected:^(NSIndexPath *indexPath){
                __weak LJPickerViewController *ljpicker=wself.ljPickerView;
                NSArray *arr1=@[wprovice,wcitys];
                if (wcitys.count==0) {
                    [SVProgressHUD showErrorWithStatus:@"请稍后再试"];
                    return ;
                }
                
                ljpicker.dataArray=arr1;
                ljpicker.isArea=YES;
                ljpicker.backgroundImage=[wself ScreenShot];
                ljpicker.doneFunc=^{
                    _city=[NSString stringWithFormat:@"%@ - %@",ljpicker.backString1,ljpicker.backString2];
                    [wself.tableViewCon.tableView reloadData];
                };
                [wself.navigationController pushViewController:ljpicker animated:YES];
                
            }];}];
}
- (void)setupSection3
{
    __weak OWTUserInfoEditViewCon* wself = self;
    __weak LJUserInformation *wlj=_ljuser;
    
    [_tableViewCon addSection:^(JMStaticContentTableViewSection *section, NSUInteger sectionIndex) {
        [section addCell:^(JMStaticContentTableViewCell* staticContentCell, UITableViewCell* cell, NSIndexPath* indexPath) {
            staticContentCell.cellStyle = UITableViewCellStyleValue1;
            staticContentCell.highlightable = YES;
            staticContentCell.reuseIdentifier = @"DetailTextCell";
            if (cell != nil)
            {
                cell.textLabel.text = @"职业";
                //cell.accessoryType = UITableViewCellAccessoryNone;
                cell.detailTextLabel.text = [wself Occupation];
            } } whenSelected:^(NSIndexPath *indexPath){
                NSArray *arr=@[@"保密",@"计算机/互联网类",@"通信/电子类",@"销售类",@"客服类",@"技术支持类",@"生产/运营类",@"采购/物流类",@"生物/制药类",@"医疗/护理类",@"市场/房地产类",@"人事/行政类",@"资讯类",@"法律类",@"教育/科研类",@"服务业类",@"公务员类",@"翻译类",@"体育类",@"其他"];
                __weak LJPickerViewController *ljpicker=wself.ljPickerView;
                NSArray *arr1=@[arr];
                ljpicker.dataArray=arr1;
                ljpicker.backgroundImage=[wself ScreenShot];
                ljpicker.doneFunc=^{
                    _occupation=ljpicker.backString1;
                    [wself.tableViewCon.tableView reloadData];
                };
                [wself.navigationController pushViewController:ljpicker animated:YES];
                
            }];
        [section addCell:^(JMStaticContentTableViewCell* staticContentCell, UITableViewCell* cell, NSIndexPath* indexPath) {
            staticContentCell.cellStyle = UITableViewCellStyleValue1;
            staticContentCell.highlightable = YES;
            staticContentCell.reuseIdentifier = @"DetailTextCell";
            if (cell != nil)
            {
                cell.textLabel.text = @"兴趣爱好";
                //cell.accessoryType = UITableViewCellAccessoryNone;
                cell.detailTextLabel.text = [wself Favority];
            }} whenSelected:^(NSIndexPath *indexPath){
                NSArray *arr=@[@"网络",@"手工艺",@"汽车",@"园艺",@"动物",@"舞蹈",@"摄影",@"展览",@"影视",@"烹饪",@"音乐",@"读书",@"写作",@"绘画",@"购物",@"计算机",@"体育运动",@"旅游",@"电子游戏",@"其他"];
                __weak LJFavorite *ljfavc=wself.favorite;
                NSMutableString *str=(NSMutableString *)[wself Favority];
                if (![str isEqualToString:@""]) {
                    NSArray *arr1=[str componentsSeparatedByString:@","];
                    [ljfavc.hobbies removeAllObjects];
                    [ljfavc.hobbies addObjectsFromArray:arr1];
                }
                
                ljfavc.DataArr=arr;
                ljfavc.doneFunc=^{
                    _favourite=[ljfavc.hobbies componentsJoinedByString:@","];
                    [wself.tableViewCon.tableView reloadData];
                };
                [wself.navigationController presentViewController:ljfavc animated:YES completion:nil];
                //[wself.navigationController presentViewController:ljfavc animated:YES completion:nil];
                
            }];
    }];
}

- (void)setUser:(QJUser *)user
{
    _user1 = user;
    [self.tableViewCon.tableView reloadData];
}

- (NSString*)currentNickname
{
    if (_updatedNickname != nil)
    {
        return _updatedNickname;
    }
    else
    {
        return _user1.nickName;
    }
}

- (NSString*)Marrige
{
    if (_marrige != nil)
    {
        return _marrige;
    }
    else
    {
        return _ljuser.Marriage;
    }
}
-(NSString *)Sex
{   //如果有改动  返回改动指
     if (_sex!=nil) {
        return _sex;
    }
    else
    {   //没后改动 返回当前值
        return _ljuser.Sex;
    }
}
-(NSString *)decade
{
    if (_decade!=nil) {
        return _decade;
    }
    else
    {
        return _ljuser.decade;
    }
}
-(NSString *)Constellation
{
    if (_constellation!=nil) {
        return _constellation;
    }
    else
    {
        return _ljuser.Constellation;
    }
}
-(NSString *)BirthLocation{
    if (_birthLocation != nil) {
    return _birthLocation;
}
else
{
    return _ljuser.BirthLocation;
}}
-(NSString *)City
{
    if (_city!=nil) {
        return _city;
    }
    else
    {
        return _ljuser.City;
    }
}
-(NSString *)HomeCity
{
    if (_homeCity!=nil) {
        return _homeCity;
    }
    else
    {
        return _ljuser.HomeCity;
    }
}
-(NSString *)Occupation
{
    if (_occupation!=nil) {
        return _occupation;
    }
    else
    {
        return _ljuser.Occupation;
    }
}
-(NSString *)Favority
{
    if (_favourite!=nil) {
        return _favourite;
    }
    else
    {
        return _ljuser.Favourite;
    }
}

-(NSString *)truename
{
    if (_truename!=nil) {
        return _truename;
    }
    else
    {
        return _ljuser.truename;
    }
}
-(NSString *)userinfo
{
    if (_userinfo!=nil) {
        return _userinfo;
    }
    else
    {
        return _ljuser.Userinfo;
    }
}
@end
