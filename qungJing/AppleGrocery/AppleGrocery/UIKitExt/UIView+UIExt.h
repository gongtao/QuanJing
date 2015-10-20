//
//  UIView+UIExt.h
//  TaxiRadar
//
//  Created by Su on 04/25/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (UIExt)

- (CGSize)calcSizeToFitSubviews;
- (void)resizeToFitSubviews;

- (void)setShouldRasterize:(BOOL)shouldRasterize;

@end
