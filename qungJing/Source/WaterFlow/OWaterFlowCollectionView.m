//
//  OWaterFlowCollectionView.m
//  Weitu
//
//  Created by Su on 3/31/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import "OWaterFlowCollectionView.h"

@implementation OWaterFlowCollectionView

- (void)setContentInset:(UIEdgeInsets)contentInset
{
    if (self.tracking)
    {
        CGFloat diff = contentInset.top - self.contentInset.top;
        CGPoint translation = [self.panGestureRecognizer translationInView:self];
        translation.y -= diff * 3.0 / 2.0;
        [self.panGestureRecognizer setTranslation:translation inView:self];
    }

    [super setContentInset:contentInset];
}

@end
