//
//  OWTAssetPageView.h
//  WhiteCloud
//
//  Created by Su on 3/6/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OWTAsset.h"
#import <NIPagingScrollViewPage.h>

@interface OWTAssetPageView : UIView<NIPagingScrollViewPage>

@property (nonatomic, assign) NSInteger pageIndex;
@property (nonatomic, strong) OWTAsset* asset;


@property (nonatomic, strong) NSString* imageUrl;

- (void)pageWillBeginSlide;
- (void)pageWillSlideOut;
- (void)pageDidSlideOut;

@end
