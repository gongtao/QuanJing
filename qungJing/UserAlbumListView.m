//
//  UserAlbumListView.m
//  SimpleCollectionViewAPI
//
//  Created by Simple Shi on 7/18/14.
//  Copyright (c) 2014 Microthink Inc,. All rights reserved.
//

#import "UserAlbumListView.h"
#import "AlbumPhotosListView.h"
#import "AlbumCell.h"
#import "AlbumPhotosListView1.h"
@interface UserAlbumListView ()
@property (nonatomic, strong) ALAssetsLibrary *assetsLibrary;
@property (nonatomic, strong) NSMutableArray *dataSource;

@end

@implementation UserAlbumListView
@synthesize assetsLibrary,photolistview;
-(void)viewDidAppear:(BOOL)animated
{
    _dataSource=[NSMutableArray array];
    [self loadAlbums];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];
    
}
-(void) cancel:(id) sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

//加载相册
-(void) loadAlbums{
    assetsLibrary=[[ALAssetsLibrary alloc] init];
    
    void (^assetsGroupsEnumerationBlock)(ALAssetsGroup *, BOOL *) = ^(ALAssetsGroup *assetsGroup, BOOL *stop) {
        [assetsGroup setAssetsFilter:[ALAssetsFilter allPhotos]];
        if(assetsGroup.numberOfAssets > 0) {
            [self.dataSource addObject:assetsGroup];
            
            ALAssetsGroup *group=_dataSource[0];
            photolistview=[[AlbumPhotosListView alloc] init];
            photolistview.assetGroup=_dataSource[0];
            [self.navigationController pushViewController:photolistview animated:NO];
            photolistview.navigationItem.hidesBackButton =YES;

        }
    };
    void (^assetsGroupsFailureBlock)(NSError *) = ^(NSError *error) {
        NSLog(@"Error: %@", [error localizedDescription]);
    };
    // Enumerate Camera Roll
    [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:assetsGroupsEnumerationBlock failureBlock:assetsGroupsFailureBlock];
    
}

-(NSString *) getAlbumName:(NSString *) albumName{
    NSString *name=@"";
    if([albumName isEqualToString:@"My Photo Stream"]){
        name=@"我的照片流";
    }else if([albumName isEqualToString:@"Camera Roll"]){
        name=@"相机照片";
    }else{
        name=albumName;
    }
    return name;
}
@end
