//
//  OWTAssetCollectViewCon.m
//  Weitu
//
//  Created by Su on 7/1/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import "OWTAssetCollectViewCon.h"
#import "OWTAsset.h"
#import "OWTAssetManager.h"
#import <RETableViewManager/RETableViewManager.h>
#import <SIAlertView/SIAlertView.h>
#import <SDWebImage/SDWebImageManager.h>
#import "SVProgressHUD+WTError.h"
#import "UIImage+Resize.h"
#import "OWTUserManager.h"
#import "OWTAlbumInfoEditViewCon.h"

@interface OWTAssetCollectViewCon ()
{
    RETableViewManager* _tableViewManager;
    
    RETableViewSection* _albumsSection;
    NSMutableDictionary* _albumItemsByAlbum;
    
    NSMutableSet* _belongingAlbums;
}

@property (nonatomic, strong) OWTAsset* asset;

@end

@implementation OWTAssetCollectViewCon

- (id)initWithAsset:(OWTAsset*)asset
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self)
    {
        [self setupWithAsset:asset];
    }
    return self;
}

- (void)setupWithAsset:(OWTAsset*)asset
{
    _asset = asset;
    
    self.title = @"收藏";
    
    UIBarButtonItem* cancelButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消"
                                                                         style:UIBarButtonItemStyleDone
                                                                        target:self
                                                                        action:@selector(cancel)];
    self.navigationItem.hidesBackButton = TRUE;
    self.navigationItem.leftBarButtonItem = cancelButtonItem;
    
    UIBarButtonItem* saveButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"保存"
                                                                       style:UIBarButtonItemStyleDone
                                                                      target:self
                                                                      action:@selector(save)];
    self.navigationItem.rightBarButtonItem = saveButtonItem;
    
    _tableViewManager = [[RETableViewManager alloc] initWithTableView:self.tableView];
    [self setupAlbumsSection];
}

- (void)setupAlbumsSection
{
    _albumsSection = [[RETableViewSection alloc] initWithHeaderTitle:@"请选择该图片所属相册"];
    [_tableViewManager addSection:_albumsSection];
}

- (void)reloadBelongingAlbumsItems
{
    OWTUser* currentUser = GetUserManager().currentUser;
    OWTUserAlbumsInfo* albumsInfo = currentUser.albumsInfo;
    
    [_albumsSection removeAllItems];
    
    if (albumsInfo != nil && _belongingAlbums != nil)
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

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self queryAssetBelongingAlbums];
}

- (void)queryAssetBelongingAlbums
{
    if (_belongingAlbums == nil)
    {
        [SVProgressHUD show];
        [GetAssetManager() queryBelongingAlbumsForAsset:_asset
                                                success:^(NSArray* albums) {
                                                    [SVProgressHUD dismiss];
                                                    _belongingAlbums = [NSMutableSet setWithArray:albums];
                                                    [self reloadBelongingAlbumsItems];
                                                }
                                                failure:^(NSError* error) {
                                                    [SVProgressHUD showError:error];
                                                }];
    }
}

- (void)cancel
{
    if (_doneAction != nil)
    {
        _doneAction(nWTDoneTypeCancelled);
    }
}
//保存 图片
- (void)save
{
    OWTAssetManager* am = GetAssetManager();
    
    [SVProgressHUD show];
    [am updateAsset:_asset
    belongingAlbums:_belongingAlbums
            success:^{
                [SVProgressHUD dismiss];
                if (_doneAction != nil)
                {
                    _doneAction(nWTDoneTypeUpdated);
                }
            }
            failure:^(NSError* error) {
                [SVProgressHUD showError:error];
            }];
}

@end
