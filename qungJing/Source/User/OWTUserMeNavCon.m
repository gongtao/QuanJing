
//
//  OWTUserViewCon.m
//  Weitu
//
//  Created by Su on 4/22/14.j
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import "OWTUserMeNavCon.h"
#import "OWTFont.h"
#import "OWTSettingsViewCon.h"
#import <SHBarButtonItemBlocks/SHBarButtonItemBlocks.h>
#import <SHBarButtonItemBlocks/SHBarButtonItemBlocks.h>
#import <FontAwesomeKit/FontAwesomeKit.h>
#import <KHFlatButton/KHFlatButton.h>
#import <UIActionSheet-Blocks/UIActionSheet+Blocks.h>
#import <NBUImagePicker/NBUImagePicker.h>
#import "LJCoreData.h"

#import "OWTPhotoUploadInfoViewCon.h"

#import "WYPopoverController.h"

#import "OWTAlbumInfoEditViewCon.h"

#import "OWTImageInfo.h"

//
#import "AlbumPhotosListView.h"
#import "AlbumCell.h"
#import "AlbumPhotosListView1.h"
#import "LJCoreData.h"
#import "LJCaptionModel.h"
#import "LJCoreData2.h"
#import "PostFormData.h"
#import "LJCoreData3.h"
@interface OWTUserMeNavCon ()<NSURLConnectionDelegate,NSURLConnectionDataDelegate>
{
    WYPopoverController* _popoverViewCon;
    NSMutableArray *_array;
    NSString *_url;
    NSString *_enabel;
    NSString *_isSI;
    NSString *_caption;
    NSMutableData *_data;
    BOOL _ifNotEmpty;
    NSDictionary *_dict;
    NSURLConnection *_connection;
    NSMutableArray *_imageSource;
    NSMutableURLRequest *_request;

}
@property (nonatomic, strong) ALAssetsLibrary *assetsLibrary;
@property (nonatomic, strong) NSMutableArray *dataSource;

@end

@implementation OWTUserMeNavCon
@synthesize assetsLibrary,photolistview;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        _dataSource=[NSMutableArray array];
        [self setup];
        self.view.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];
        _data=[[NSMutableData alloc]init];
        [self loadAlbums];
        _dict=[[NSDictionary alloc]init];
        _imageSource=[[NSMutableArray alloc]init];
    }
    return self;
}

- (void)setup
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(reloadImage:) name:@"imagereload" object:nil];
}
-(void)reloadImage:(NSNotification *)sender
{
    [_imageSource removeAllObjects];
    [_imageSource addObject:sender.object];
    [self getCaptionData];
}

#pragma mark - Table view data source

//加载相册
-(void) loadAlbums{
    assetsLibrary=[[ALAssetsLibrary alloc] init];
    void (^assetsGroupsEnumerationBlock)(ALAssetsGroup *, BOOL *) = ^(ALAssetsGroup *assetsGroup, BOOL *stop) {
        [assetsGroup setAssetsFilter:[ALAssetsFilter allPhotos]];
        if(assetsGroup.numberOfAssets > 0) {
            [self.dataSource addObject:assetsGroup];
            [_imageSource addObjectsFromArray:_dataSource];
            
            _ifNotEmpty = YES;
            
            ALAssetsGroup *group=[_dataSource firstObject];
            photolistview=[[AlbumPhotosListView alloc]initWithNibName:nil bundle:nil];
            photolistview.assetGroup=group;
            //photolistview.title=[self getAlbumName:[group valueForProperty:ALAssetsGroupPropertyName]];
            [self pushViewController:photolistview animated:NO];
            photolistview.navigationItem.hidesBackButton =YES;
            photolistview.view.frame = self.view.bounds;
            [self getCaptionData];
        }
        if (!_ifNotEmpty) {
            photolistview=[[AlbumPhotosListView alloc]initWithNibName:nil bundle:nil];
            //photolistview.title=[self getAlbumName:[group valueForProperty:ALAssetsGroupPropertyName]];
            [self pushViewController:photolistview animated:NO];
            photolistview.navigationItem.hidesBackButton =YES;
            photolistview.view.frame = self.view.bounds;
        }
        
    };
    //
    void (^assetsGroupsFailureBlock)(NSError *) = ^(NSError *error) {
        NSLog(@"Error: %@", [error localizedDescription]);
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"无照片访问权限，请设置" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
        photolistview=[[AlbumPhotosListView alloc]initWithNibName:nil bundle:nil];
        //photolistview.title=[self getAlbumName:[group valueForProperty:ALAssetsGroupPropertyName]];
        [self pushViewController:photolistview animated:NO];
    };
    // Enumerate Camera Roll
    [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:assetsGroupsEnumerationBlock failureBlock:assetsGroupsFailureBlock];
}
-(void)getCaptionData
{
    /**
     *  根据相册组。获取每组的图片
     *
     *  @param result 含有每张照片的信息
     *  @param index  当前遍历的下标
     *  @param stop   是否停止遍历
     *
     *  @return
     */
    
    if ( [_imageSource count]<1) {
        return;
    }
    ALAssetsGroup *photoGroup=_imageSource[0];
    _array = [[NSMutableArray alloc] init] ;
    [photoGroup enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
        if (result) {
            if ([[result valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypePhoto]) {
                NSString *imageurl=[[result valueForProperty:ALAssetPropertyAssetURL] absoluteString];
                UIImage *image = [UIImage imageWithCGImage:result.thumbnail];
                if (image == nil) {
                    return ;
                }
                NSDictionary *dic=@{@"image":image,@"selected":@"NO",@"imageurl":imageurl};
                [_array addObject:dic];
            }
        }
    }];
    NSUserDefaults *user=[NSUserDefaults standardUserDefaults];
    NSString *str=[user objectForKey:@"version1"];
    NSString *str1= [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString*)kCFBundleVersionKey];
    if (![str isEqualToString:str1]) {
        [[LJCoreData3 shareIntance]deleteAll];
        [self getSimilarCaption];
    
    }
    if (![user objectForKey:@"firstCaption"]) {
        [self getUpCaptions];
        [user setObject:@"dd" forKey:@"firstCaption"];
    }
    NSDictionary *dict=_array[0];
    NSDictionary *dict1=_array.lastObject;
    LJCaptionModel *model=[[LJCoreData shareIntance]check:dict[@"imageurl"]];
    LJCaptionModel *model1=[[LJCoreData shareIntance]check:dict1[@"imageurl"]];
    NSArray *ARR=[[LJCoreData2 shareIntance]checkAll2];
    if ((model!=nil||model1!=nil)&&ARR==nil) {
        [[LJCoreData shareIntance]checkAllAndUpdate];
    }

    //通过通知中心发送通知
    [[NSNotificationCenter defaultCenter] postNotificationName:@"recogNizePhoto" object:nil userInfo:(NSDictionary*)_array];
}

-(void)getSimilarCaption
{
    NSString *str=@"http://api.tiankong.com/qjapi/cdn1/phoneSearch";
    NSURL *url=[NSURL URLWithString:str];
    NSURLRequest *request=[NSURLRequest requestWithURL:url];
    _connection=[[NSURLConnection alloc]initWithRequest:request delegate:self];

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
    if (_connection==connection) {
        NSUserDefaults *user=[NSUserDefaults standardUserDefaults];
        NSString *str1= [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString*)kCFBundleVersionKey];

        [user setObject:str1 forKey:@"version1"];

    }
    NSDictionary *dict=[NSJSONSerialization JSONObjectWithData:_data options:NSJSONReadingMutableContainers error:nil];
 
    NSArray *arr=dict[@"Words"];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        for (NSDictionary *dict1 in arr) {
            
            [[LJCoreData3 shareIntance]insertCaptionSimilar:dict1[@"word"] withDetail:dict1[@"detailed"]];
        }
    });
}

-(void)getUpCaptions
{
    NSInteger count = _array.count;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        if (count>0) {
            for (NSInteger i=count-1;i>=0;i--) {
                NSDictionary *dict=_array[i];
                LJCaptionModel *model=[[LJCoreData shareIntance]check:dict[@"imageurl"]];
                UIImage *image=dict[@"image"];
                NSString *imageurl=dict[@"imageurl"];
                NSData *data=UIImageJPEGRepresentation(image, 1.0f);
                NSArray *arr=[model.caption componentsSeparatedByString:@" "];
                for (NSString *caption in arr) {
                    BOOL ret=[[LJCoreData2 shareIntance]check2:caption];
                    if (ret==NO) {
                        [[LJCoreData2 shareIntance]insert2:imageurl withCaption:caption with:@"1" withData:data];
                    }else
                    {
                        [[LJCoreData2 shareIntance]update2:data with:caption];
                    }
                }
            }
        }

    });
}



@end
