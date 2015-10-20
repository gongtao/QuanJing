//
//  OThumbnailListTableViewCell.m
//  Weitu
//
//  Created by Su on 6/2/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import "OThumbnailListTableViewCell.h"

@interface OThumbnailListTableViewCell()

@end

@implementation OThumbnailListTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(imagesUpdated)
                                                     name:kThumbnailListImagesUpdatedNotification
                                                   object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _thumbnailListViewCon.view.frame = self.contentView.bounds;
}

+ (CGFloat)heightWithItem:(RETableViewItem *)item tableViewManager:(RETableViewManager *)tableViewManager
{
    return 88;
}

- (void)cellDidLoad
{
    [super cellDidLoad];
    _thumbnailListViewCon = [[OThumbnailListViewCon alloc] initWithDefaultLayout];
    [self.contentView addSubview:_thumbnailListViewCon.view];
}

- (void)cellWillAppear
{
    [super cellWillAppear];

    if (self.item.images != nil)
    {
        [_thumbnailListViewCon setThumbImages:self.item.images];
    }
    else
    {
        [_thumbnailListViewCon setThumbImageInfos:self.item.imageInfos];
    }
}

- (void)imagesUpdated
{
    if (self.item.images != nil)
    {
        [_thumbnailListViewCon setThumbImages:self.item.images];
    }
    else
    {
        [_thumbnailListViewCon setThumbImageInfos:self.item.imageInfos];
    }
}

@end
