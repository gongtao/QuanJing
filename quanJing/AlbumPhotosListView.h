//
//  AlbumPhotosListView.h
//  SimpleCollectionViewAPI
//
//  Created by Simple Shi on 7/18/14.
//  Copyright (c) 2014 Microthink Inc,. All rights reserved.
//

#import <UIKit/UIKit.h>


#import "XHRefreshControl.h"

#import "OWTAssetFlowViewCon.h"
#import <AssetsLibrary/AssetsLibrary.h>
@interface AlbumPhotosListView : UIViewController<UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, XHRefreshControlDelegate,UITableViewDataSource,UITableViewDelegate>



@property (nonatomic, strong) OWTUser* user;
@property (nonatomic, strong) OWTAssetFlowViewCon* assetViewCon1;
@property (nonatomic, copy) NSMutableOrderedSet* assets1;

@property (nonatomic, strong) NSMutableArray *selectImages;
@property (nonatomic, strong) UITableView *maintableview;
@property (nonatomic, strong) ALAssetsGroup *assetGroup;
@property (nonatomic, strong) NSMutableArray *dataSource;




@end
