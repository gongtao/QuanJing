//
//  OThumbListViewCon.m
//  Weitu
//
//  Created by Su on 5/31/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import "OThumbnailListViewCon.h"
#import "OThumbnailCell.h"


#import "FSBasicImage.h"
#import "FSBasicImageSource.h"



static NSString* kWaterFlowCellID = @"kWaterFlowCellID";

@interface OThumbnailListViewCon ()
{
}

@property (nonatomic, strong) UICollectionViewFlowLayout* flowLayout;

@end

@implementation OThumbnailListViewCon

- (id)initWithDefaultLayout
{
    UICollectionViewFlowLayout* flowLayout = [[UICollectionViewFlowLayout alloc] init];
    self = [super initWithCollectionViewLayout:flowLayout];
    if (self)
    {
        _flowLayout = flowLayout;
        [self setup];
    }
    return self;
}

- (void)setup
{
    _flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    _flowLayout.itemSize = CGSizeMake(75, 75);
    _flowLayout.sectionInset = UIEdgeInsetsMake(4, 4, 4, 4);
    _flowLayout.minimumInteritemSpacing = 4;
    _flowLayout.minimumLineSpacing = 4;

    [self.collectionView registerClass:OThumbnailCell.class forCellWithReuseIdentifier:kWaterFlowCellID];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.opaque = NO;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.alwaysBounceHorizontal = YES;
    self.collectionView.delegate =self;
    self.collectionView.dataSource =self;
}

- (void)setThumbImages:(NSArray *)thumbImages
{
    _thumbImages = [thumbImages copy];
    _thumbImageInfos = nil;
    [self.collectionView reloadData];
}

- (void)setThumbImageInfos:(NSArray *)thumbImageInfos
{
    _thumbImages = nil;
    _thumbImageInfos = [thumbImageInfos copy];
    [self.collectionView reloadData];
}

#pragma mark - Delegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (_thumbImages != nil)
    {
        return _thumbImages.count;
    }
    else if (_thumbImageInfos != nil)
    {
        return _thumbImageInfos.count;
    }
    else
    {
        return 0;
    }
}

- (UICollectionViewCell*)collectionView:(UICollectionView*)collectionView cellForItemAtIndexPath:(NSIndexPath*)indexPath
{
    OThumbnailCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:kWaterFlowCellID forIndexPath:indexPath];

    if (_thumbImages != nil)
    {
        UIImage* image = [_thumbImages objectAtIndex:indexPath.row];
        if (image != nil)
        {
            [cell setThumbnailWithImage:image];
        }
    }
    else if (_thumbImageInfos != nil)
    {
//        OWTImageInfo* imageInfo = [_thumbImageInfos objectAtIndex:indexPath.row];
//        if (imageInfo != nil)
//        {
            [cell setThumbnailWithImageInfo:_thumbImageInfos index:indexPath.row];
        
        
        
        
        
        __weak OThumbnailListViewCon* wself = self;
       
        
        
        
        cell.showImage =  ^{ [wself showImageViewwithindex:indexPath.row]; };
        
//        }
    }

    return cell;
}
//-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    UICollectionViewCell * cell = (UICollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
//    cell.backgroundColor = [UIColor whiteColor];
//}
////返回这个UICollectionView是否可以被选择
//-(BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    return YES;
//}

-(void)showImageViewwithindex:(NSInteger)index
{
    NSLog(@"ddddddddddddddd%d",index);
    
    
    
    
    

//    
//    
//    
//    
//    
//    
//   
//    
//    
//    
//    NSMutableArray *FSArr = [[NSMutableArray alloc]init];
//    
//   
//        
//    
//        
//        
//       
//        
//        
//        
//        
//        for (int i=0; i<_thumbImageInfos.count; i++) {
//            
//            OWTImageInfo *imageInfo = [[OWTImageInfo alloc]init];
//            imageInfo = _thumbImageInfos[i];
//            FSBasicImage *firstPhoto = [[FSBasicImage alloc]initWithImageURL:[NSURL URLWithString:imageInfo.thumbnailURL]];
//            [FSArr addObject:firstPhoto];
//            
//        }
//        
//        
//        NSLog(@"sssssssssssssssss%@",FSArr);
//    
//        
//    
//    
//    FSBasicImageSource *photoSource = [[FSBasicImageSource alloc] initWithImages:FSArr];
//    
//    self.imageViewController = [[FSImageViewerViewController alloc] initWithImageSource:photoSource imageIndex:index];
//    //    [self.imageViewController moveToImageAtIndex:0 animated:NO];
//    
//    
//    self.imageViewController.navigationController.navigationBarHidden =YES;
//    
//        [self.parentViewController presentViewController:_imageViewController animated:YES completion:nil];
//    
////    self.view.hidden =YES;
}

@end
