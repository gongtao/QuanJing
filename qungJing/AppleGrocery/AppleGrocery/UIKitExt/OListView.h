//
//  OListView.h
//  TaxiRadar
//
//  Created by Su on 04/15/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "OShadowView.h"

@interface OListView : UIView
{
    NSMutableArray* _listSubviews;
}

@property (readonly) NSMutableArray* listSubviews;

- (BOOL)containsListSubview:(UIView*)view;
- (void)addListSubview:(UIView*)view;
- (void)insertListSubview:(UIView *)view atIndex:(NSUInteger)index;
- (void)removeListSubview:(UIView*)view;
- (void)removeListSubviewAtIndex:(NSUInteger)index;

@end
