//
//  OWTUserAlbumsInfo.m
//  Weitu
//
//  Created by Su on 6/27/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import "OWTUserAlbumsInfo.h"
#import "OWTAlbum.h"

@interface OWTUserAlbumsInfo()
{
    NSMutableDictionary* _albumsByID;
}

@end

@implementation OWTUserAlbumsInfo

- (void)mergeWithData:(OWTUserAlbumsInfoData*)albumsInfoData
{
    if (albumsInfoData.albumDatas != nil)
    {
        if (_albumsByID == nil)
        {
            _albumsByID = [NSMutableDictionary dictionaryWithCapacity:albumsInfoData.albumDatas.count];
        }

        NSMutableArray* currentAlbums = [NSMutableArray array];

        for (OWTAlbumData* albumData in albumsInfoData.albumDatas)
        {
            OWTAlbum* album = [_albumsByID objectForKey:albumData.albumID];
            if (album == nil)
            {
                album = [OWTAlbum new];
                album.userID = self.userID;
            }

            [album mergeWithData:albumData];
            [currentAlbums addObject:album];
        }

        if (_albums == nil)
        {
            _albums = [NSMutableArray arrayWithCapacity:currentAlbums.count];
        }
        [_albums removeAllObjects];
        [_albums addObjectsFromArray:currentAlbums];

        [_albumsByID removeAllObjects];
        for (OWTAlbum* album in _albums)
        {
            _albumsByID[album.albumID] = album;
        }
    }
}

- (OWTAlbum*)albumWithID:(NSString*)albumID
{
    if (_albums == nil)
    {
        return nil;
    }
    
    for (OWTAlbum* album in _albums)
    {
        if ([album.albumID isEqualToString:albumID])
        {
            return album;
        }
    }

    return nil;
}

@end
