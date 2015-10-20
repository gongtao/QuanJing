//
//  LJCollectionViewLayout.m
//  Weitu
//
//  Created by qj-app on 15/6/24.
//  Copyright (c) 2015年 SparkingSoft Co., Ltd. All rights reserved.
//

#import "LJCollectionViewLayout.h"
#define COLUMNCOUNT 2
#define ITEMWIDTH  (SCREENWIT-15)/2
@implementation LJCollectionViewLayout
- (instancetype)init
{
    self = [super init];
    if (self) {
        [self commonInit];
    }
    return self;
}
-(void)commonInit
{
    _columnCount=COLUMNCOUNT;
    _itemWidth=ITEMWIDTH;
    _sectionInset=UIEdgeInsetsZero;
}
-(void)prepareLayout
{
    [super prepareLayout];
    _itemCount=[[self collectionView]numberOfItemsInSection:0];
    CGFloat width=self.collectionView.frame.size.width-_sectionInset.left-_sectionInset.right;
    //计算每个Item之间的间隔（不包括外部的间隔）
    _interitemSpacing=floorf(width-_columnCount*_itemWidth)/(_columnCount-1);
    //存储布局属性，一个item对应一个布局属性
    _itemAttributes=[[NSMutableArray alloc]initWithCapacity:_itemCount];
    //存储高度
    _columnHeights=[[NSMutableArray alloc]initWithCapacity:_columnCount];
    for (NSInteger idx=0; idx<_columnCount; idx++) {
        [_columnHeights addObject:@(_sectionInset.top)];
    }
    for (NSInteger idx=0; idx<_itemCount; idx++) {
        NSIndexPath *indexPath=[NSIndexPath indexPathForItem:idx inSection:0];
        //返回每一个item的高度
        CGFloat itemHeight=[_delegate collectionView:self.collectionView layout:self heightForItemAtIndexPath:indexPath];
        NSUInteger columnIndex=[self shortestColumnIndex];
        CGFloat xOffset=_sectionInset.left+(_itemWidth+_interitemSpacing)*columnIndex;
        CGFloat yOffset=[(_columnHeights[columnIndex])floatValue];
        //布局对应的属性
        UICollectionViewLayoutAttributes *attributes=[UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
        attributes.frame=CGRectMake(xOffset, yOffset, self.itemWidth, itemHeight);
        [_itemAttributes addObject:attributes];
        _columnHeights[columnIndex]=@(yOffset +itemHeight +_interitemSpacing);
    }

}
-(CGSize)collectionViewContentSize
{
    if (self.itemCount == 0)
    {
        return CGSizeZero;
    }
    
    CGSize contentSize = self.collectionView.frame.size;
    NSUInteger columnIndex = [self longestColumnIndex];
    
    CGFloat height = [self.columnHeights[columnIndex] floatValue];
    contentSize.height = height - self.interitemSpacing + self.sectionInset.bottom;
    return contentSize;
}
-(UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return _itemAttributes[indexPath.item];
}
-(NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    return [_itemAttributes filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(UICollectionViewLayoutAttributes *evaluatedObject, NSDictionary *bindings) {
        return CGRectIntersectsRect(rect, [evaluatedObject frame]);
    }]];
}
- (NSUInteger)shortestColumnIndex
{
    //想在block中修改基本数据类型，前面用__block
    __block NSUInteger index = 0;
    __block CGFloat shortestHeight = MAXFLOAT;
    
    [self.columnHeights enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        CGFloat height = [obj floatValue];
        if (height < shortestHeight) {
            shortestHeight = height;
            index = idx;
        }
    }];
    return index;
}
- (NSUInteger)longestColumnIndex
{
    __block NSUInteger index = 0;
    __block CGFloat longestHeight = 0;
    
    [self.columnHeights enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        CGFloat height = [obj floatValue];
        if (height > longestHeight) {
            longestHeight = height;
            index = idx;
        }
    }];
    return index;
}



@end
