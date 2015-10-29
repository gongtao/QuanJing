
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


#import "OWTPhotoUploadInfoViewCon.h"

#import "WYPopoverController.h"

#import "OWTAlbumInfoEditViewCon.h"

#import "OWTImageInfo.h"

//
#import "AlbumPhotosListView.h"
#import "AlbumCell.h"
#import "AlbumPhotosListView1.h"

#import "PostFormData.h"

#import "QJDatabaseManager.h"
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
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            QJDatabaseManager *manager=[QJDatabaseManager sharedManager];
            __weak QJDatabaseManager *wmanager=manager;
        dispatch_semaphore_t sem=dispatch_semaphore_create(0);
            [manager performDatabaseUpdateBlock:^(NSManagedObjectContext * _Nonnull concurrencyContext) {
             NSArray *words=[manager getAllSearchWords:concurrencyContext];
                if (words==nil) {
                    NSString *str=@"http://api.tiankong.com/qjapi/cdn1/phoneSearch";
                    NSURL *url=[NSURL URLWithString:str];
                    NSURLRequest *request=[NSURLRequest requestWithURL:url];
                    NSData *recievie=[NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
                    NSDictionary *dict=[NSJSONSerialization JSONObjectWithData:recievie options:NSJSONReadingMutableContainers error:nil];
                    NSArray *arr=dict[@"Words"];
                    for (NSDictionary *dict1 in arr) {
                        NSString *detailStr=[NSString stringWithFormat:@"、%@、%@、",dict1[@"word"],dict1[@"detailed"]];
                        [manager setSearchWordByWord:dict1[@"word"] detailed:detailStr context:concurrencyContext];
                    }
                }
            } finished:^(NSManagedObjectContext * _Nonnull mainContext) {
                dispatch_semaphore_signal(sem);
            }];
        dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
        
            
        
    });
    //通过通知中心发送通知
    [[NSNotificationCenter defaultCenter] postNotificationName:@"recogNizePhoto" object:nil userInfo:(NSDictionary*)_array];
}


@end
