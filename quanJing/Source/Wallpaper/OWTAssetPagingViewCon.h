//
//  OWTWallpaperPagingViewCon.h
//  Weitu
//
//  Created by Su on 8/28/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <NIPagingScrollView.h>

@interface OWTAssetPagingViewCon : UIViewController<NIPagingScrollViewDataSource,
                                                        NIPagingScrollViewDelegate,
                                                        UIGestureRecognizerDelegate>

- (id)initWithFeed:(OWTFeed*)feed;
- (void)reloadData;
@property (nonatomic,assign)NSInteger indexnow;
- (void)setInitialPageIndex:(NSInteger)pageIndex;
- (void)moveToPageAtIndex:(NSInteger)pageIndex animated:(BOOL)animated;


@end
