//
//  AlbumPhotosListView.m
//  SimpleCollectionViewAPI
//
//  Created by Simple Shi on 7/18/14.
//  Copyright (c) 2014 Microthink Inc,. All rights reserved.
//
#import "AlbumPhotosListView1.h"
#import "PhotoCell.h"

#import "OWTUserInfoView.h"
#import <SHBarButtonItemBlocks/SHBarButtonItemBlocks.h>
#import <FontAwesomeKit/FontAwesomeKit.h>
#import <KHFlatButton/KHFlatButton.h>
#import <UIActionSheet-Blocks/UIActionSheet+Blocks.h>

#import "OWTUserManager.h"
#import "OWTFont.h"

#import "SVProgressHUD+WTError.h"

#import "OWTUserInfoEditViewCon.h"

#import "OWTUserLikedAssetsViewCon.h"

#import "OWTFollowerUsersViewCon.h"
#import "OWTFollowingUsersViewCon.h"

#import "UIView+EasyAutoLayout.h"
#import "UIViewController+WTExt.h"

#import "OWTPhotoUploadInfoViewCon.h"


#import "SvImageInfoEditUtils.h"
#pragma mark -





//






#define MAXIMAGE 9

@interface AlbumPhotosListView1 ()<ImageSelectedDelegate>
{
    
  
    
//    OWTTabBarHider* _tabBarHider;
//    
//    
//    WYPopoverController* _popoverViewCon;
    
   
        UIToolbar *toolBar;
   
}



@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) UILabel *selectCount;
@end

@implementation AlbumPhotosListView1
@synthesize dataSource,assetGroup,selectCount,selectImages;


-(void)viewDidAppear:(BOOL)animated
{
    [self hideTabBar];
}

- (void)hideTabBar {    if (self.tabBarController.tabBar.hidden == YES) {        return;    }    UIView *contentView;    if ( [[self.tabBarController.view.subviews objectAtIndex:0] isKindOfClass:[UITabBar class]] )        contentView = [self.tabBarController.view.subviews objectAtIndex:1];    else        contentView = [self.tabBarController.view.subviews objectAtIndex:0];        contentView.frame = CGRectMake(contentView.bounds.origin.x,  contentView.bounds.origin.y,  contentView.bounds.size.width, contentView.bounds.size.height + self.tabBarController.tabBar.frame.size.height);                self.tabBarController.tabBar.hidden = YES;    }

- (void)setup
{
    self.title = @"本地相册";
          

    
    
    [self substituteNavigationBarBackItem];
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem SH_barButtonItemWithTitle:@"上传" style:UIBarButtonItemStylePlain   withBlock:^(UIBarButtonItem* sender) {
        //        [self socialAddAction];
        
        //直接进入 图片发布页
        //上传图片页面
//        [self uploadPhotosWithFilteredGroupNames:[NSSet setWithObject:@"全景"]];
        [self upload_Compeleted];
        
    }];
   
    
    
    
    
  
    [self.navigationController  setToolbarHidden:YES animated:NO];
//    toolBar=[[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-160, 320, 44)];
//    [toolBar setBarStyle:UIBarStyleDefault];
//    
//    toolBar.backgroundColor = [UIColor whiteColor];
//     UIBarButtonItem *leftItem=[[UIBarButtonItem alloc] initWithCustomView:[self creatbtn:@"分享" withFrame:CGRectMake(10, 5, 100, 30) withAction:@selector(shareCompeleted)]];
//    UIBarButtonItem *rightItem=[[UIBarButtonItem alloc] initWithCustomView:[self creatbtn:@"上传到云" withFrame:CGRectMake(10, 5, 100, 30) withAction:@selector(upload_Compeleted)]];
//    
//    
//     UIBarButtonItem *fixedSpace=[[UIBarButtonItem alloc] initWithCustomView:[self creatbtn:@"取消" withFrame:CGRectMake(10, 5, 50, 30) withAction:@selector(preView_Action)]];
////    UIBarButtonItem* fixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
//    [toolBar setItems:@[leftItem,fixedSpace,rightItem] animated:YES];
//    toolBar.userInteractionEnabled =YES;
//   [self.view addSubview:toolBar];
//[ self.view bringSubviewToFront: toolBar ];
    
    
   
}
//分享
-(void)shareCompeleted
{
    NSLog(@"222222222222222222");
}

//上传到云
-(void)upload_Compeleted
{
    OWTPhotoUploadInfoViewCon* photoUploadInfoViewCon = [[OWTPhotoUploadInfoViewCon alloc] initWithDefaultStyle];
    //
    //
    [self.navigationController pushViewController:photoUploadInfoViewCon animated:NO];
    [photoUploadInfoViewCon setPendingUploadImageInfos:selectImages];
    
    
    photoUploadInfoViewCon.doneAction = ^{
        
        NSLog(@"llllllllllllllllllll");
        [self dismissModalViewControllerAnimated:YES];
    };
    
//    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];

}


-(void) preView_Action{
    [self dismissViewControllerAnimated:YES completion:nil];
    NSLog(@"222222222222222222");

}
-(void) select_Compeleted{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RETURN_IMAGE_SELECT" object:nil userInfo:@{@"images":selectImages}];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setup];
    
    

    
    [self.view setBackgroundColor:[UIColor colorWithWhite:0.9 alpha:1]];
    dataSource=[NSMutableArray array];
    selectImages=[NSMutableArray array];
    CGRect viewFrame=self.view.frame;
    self.maintableview=[[UITableView alloc] initWithFrame:CGRectMake(0, 0, viewFrame.size.width, viewFrame.size.height-64) style:UITableViewStylePlain];
    [self.maintableview setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    self.maintableview.backgroundColor=[UIColor colorWithWhite:0.9 alpha:1];
    [self.maintableview setDelegate:self];
    [self.maintableview setDataSource:self];
    [self.view addSubview:self.maintableview];
    
    
    
    [self getImgsWithGroup:assetGroup];
    

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


#pragma mark - Table view data source

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80.0f;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rowcount=(dataSource.count%4)>0?(dataSource.count/4+1):dataSource.count/4;
    return rowcount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier=@"cell";
    PhotoCell *cell=[tableView dequeueReusableCellWithIdentifier:identifier];
    if(!cell){
        cell=[[NSBundle mainBundle] loadNibNamed:@"PhotoCell" owner:self options:nil][0];
    }
    if(dataSource.count>indexPath.row*4){
        cell.image1.image=dataSource[indexPath.row*4][@"image"];
        cell.image1.tag=indexPath.row*4;
        [cell.image1.gestureRecognizers[0] setEnabled:YES];
        if([dataSource[indexPath.row*4][@"selected"] boolValue]){
            cell.selected1.hidden=NO;
        }else{
            cell.selected1.hidden=YES;
        }
    }
    if(dataSource.count>indexPath.row*4+1) {
        cell.image2.image=dataSource[indexPath.row*4+1][@"image"];
        cell.image2.tag=indexPath.row*4+1;
        [cell.image2.gestureRecognizers[0] setEnabled:YES];
        if([dataSource[indexPath.row*4+1][@"selected"] boolValue]){
            cell.selected2.hidden=NO;
        }else{
            cell.selected2.hidden=YES;
        }
    }
    if(dataSource.count>indexPath.row*4+2){
        cell.image3.image=dataSource[indexPath.row*4+2][@"image"];
        cell.image3.tag=indexPath.row*4+2;
        [cell.image3.gestureRecognizers[0] setEnabled:YES];
        if([dataSource[indexPath.row*4+2][@"selected"] boolValue]){
            cell.selected3.hidden=NO;
        }else{
            cell.selected3.hidden=YES;
        }
    }
//    if(dataSource.count>indexPath.row*4+3){
////        cell.image4.image=dataSource[indexPath.row*4+3][@"image"];
////        cell.image4.tag=indexPath.row*4+3;
////        [cell.image4.gestureRecognizers[0] setEnabled:YES];
////        if([dataSource[indexPath.row*4+3][@"selected"] boolValue]){
////            cell.selected4.hidden=NO;
////        }else{
////            cell.selected4.hidden=YES;
////        }
//    }
    cell.indexPath=indexPath;
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    cell.backgroundColor=[UIColor clearColor];
    cell.delegate=self;
    return cell;
}

//选中image之后的回调方法 图片

-(void) imagecellSelected:(PhotoCell *)cell andImgTag:(NSInteger)tag andIndexPath:(NSIndexPath *)indexPath{
    [self caculateSelectImage:tag andIndexPath:indexPath];



}
-(void) caculateSelectImage:(NSInteger) index andIndexPath:(NSIndexPath *)indexPath{
    
    NSMutableDictionary *mdic=[dataSource[index] mutableCopy];
//    if(selectImages.count<MAXIMAGE){
//        [mdic setValue:@"YES" forKey:@"selected"];
//        [selectImages addObject:mdic[@"image"]];
//    }else{
//        UIAlertView *alertView=[[UIAlertView alloc] initWithTitle:@"提示" message:[NSString stringWithFormat:@"最多只能选择%d张图片",MAXIMAGE] delegate:nil cancelButtonTitle:@"我知道了" otherButtonTitles:nil, nil];
//        [alertView show];
//    }
//       OWTPhotoUploadInfoViewCon* photoUploadInfoViewCon = [[OWTPhotoUploadInfoViewCon alloc] initWithDefaultStyle];
//        [self.navigationController pushViewController:photoUploadInfoViewCon animated:NO];
//        [photoUploadInfoViewCon setPendingUploadImages:selectImages];
//        photoUploadInfoViewCon.doneAction = ^{
//        };

    
    if([mdic[@"selected"] boolValue]){
        [mdic setValue:@"NO" forKey:@"selected"];
        [selectImages removeObject:mdic[@"imageInfo"]];
        
    }else{
        if(selectImages.count<MAXIMAGE){
            [mdic setValue:@"YES" forKey:@"selected"];
            [selectImages addObject:mdic[@"imageInfo"]];
        }else{
            UIAlertView *alertView=[[UIAlertView alloc] initWithTitle:@"提示" message:[NSString stringWithFormat:@"最多只能选择%d张图片",MAXIMAGE] delegate:nil cancelButtonTitle:@"我知道了" otherButtonTitles:nil, nil];
            [alertView show];
        }
    }
    if(selectImages.count>0){
        selectCount.hidden=NO;
        selectCount.text=[NSString stringWithFormat:@"%d",selectImages.count];
    }else{
        selectCount.hidden=YES;
    }
    [dataSource setObject:mdic atIndexedSubscript:index];
    [self.maintableview reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    NSLog(@"1111111111111%d",selectImages.count);
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
    [ptotoGroup enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
        if (result) {
            if ([[result valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypePhoto]) {
                
                OWTImageInfo* imageInfo = [[OWTImageInfo alloc] init];
                
                imageInfo.url =[[result valueForProperty:ALAssetPropertyAssetURL] absoluteString];
                NSLog(@"11111111111%@",imageInfo.url);
                imageInfo.primaryColorHex = @"DDDDDD";
                imageInfo.width = 64;
                imageInfo.height = 64;
//                ALAssetRepresentation *representation = result.defaultRepresentation;
//                CGImageRef cImage = [representation fullScreenImage];
//                uint8_t *buffer = (uint8_t *)malloc(representation.size);
//                NSError *error;
//                NSUInteger length = [representation getBytes:buffer fromOffset:0 length:representation.size error:&error];
//                NSData *data = [NSData dataWithBytes:buffer length:length];
//                //                        5. 构造 CGImageSource :
//                CGImageSourceRef cImageSource = CGImageSourceCreateWithData((__bridge CFDataRef)data, NULL);
//                
//                CFDictionaryRef imageInfo1 = CGImageSourceCopyPropertiesAtIndex(cImageSource, 0,NULL);
//                NSNumber *pixelWidthObj = (__bridge NSNumber *)CFDictionaryGetValue(imageInfo1, kCGImagePropertyPixelWidth);
//                NSNumber *pixelHeightObj = (__bridge NSNumber *)CFDictionaryGetValue(imageInfo1, kCGImagePropertyPixelHeight);
//                NSInteger orientation = [(__bridge NSNumber *)CFDictionaryGetValue(imageInfo1, kCGImagePropertyOrientation) integerValue];
//                
//                
//                NSLog(@"aaaaaaaaaaaaaaaaaaaaal%d",orientation);
//                
//                if (orientation ==1) {
//                    imageInfo.degree =0;
//                }
//                if (orientation ==8) {
//                    imageInfo.degree =270;
//                }
//                if (orientation ==3) {
//                    imageInfo.degree =180;
//                }
//                if (orientation ==6) {
//                    imageInfo.degree =90;
//                }
//                if (orientation ==2) {
//                    imageInfo.degree =0;
//                }
//                if (orientation ==4) {
//                    imageInfo.degree =180;
//                }
//                if (orientation ==5) {
//                    imageInfo.degree =270;
//                }
//                if (orientation ==7) {
//                    imageInfo.degree =90;
//                }
//                
//                NSLog(@"11111111111%@",imageInfo.url);
                //
                
                
                NSDictionary *dic=@{@"image":[UIImage imageWithCGImage:result.thumbnail],@"selected":@"NO",@"imageInfo":imageInfo};
                [array addObject:dic];
            }
            //            NSLog(@"========================%@",dataSource);
            singleton *oneS = [singleton shareData];
            //    oneS.value.text = self.qqTextfield.text;
            oneS.value = array.count;
        }
    }];
    
    
    dataSource = (NSMutableArray *)[[array reverseObjectEnumerator] allObjects];
    [self.maintableview reloadData];

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

//
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    

}




- (void)updateRightNavBarItem
{
//            self.navigationItem.title = @"本地图片";
//        self.navigationItem.titleView = nil;
//        
//        self.navigationItem.rightBarButtonItem = nil;
   
}
//

-(void)viewWillDisappear:(BOOL)animated
{
    [self showTabBar];
}
- (void)showTabBar{    if (self.tabBarController.tabBar.hidden == NO)    {        return;    }    UIView *contentView;    if ([[self.tabBarController.view.subviews objectAtIndex:0] isKindOfClass:[UITabBar class]])                contentView = [self.tabBarController.view.subviews objectAtIndex:1];    else                contentView = [self.tabBarController.view.subviews objectAtIndex:0];              contentView.frame = CGRectMake(contentView.bounds.origin.x, contentView.bounds.origin.y,  contentView.bounds.size.width, contentView.bounds.size.height - self.tabBarController.tabBar.frame.size.height);        self.tabBarController.tabBar.hidden = NO;}
@end
