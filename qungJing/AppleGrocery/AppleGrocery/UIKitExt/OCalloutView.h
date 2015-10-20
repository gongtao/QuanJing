//
//  OCalloutView.h
//  TaxiRadar
//
//  Created by Bing SU on 5/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OCalloutView : UIView

@property (nonatomic, assign) CGSize contentSize;
@property (nonatomic, assign) CGSize arrowSize;
@property (nonatomic, assign) float arrowOffset;
@property (nonatomic, assign) float cornerRadius;
@property (nonatomic, assign) float strokeWidth;

@property (nonatomic, strong) UIColor* strokeColor;
@property (nonatomic, strong) UIColor* fillColor;
@property (nonatomic, strong) UIColor* glossColor;

@property (nonatomic, assign) float shadowRadius;
@property (nonatomic, assign) CGSize shadowOffset;

@property (nonatomic, assign) float arrowHeadOffset;

@property (nonatomic, assign, readonly) CGRect bubbleContentFrame;

@property (nonatomic, assign) UIEdgeInsets bubbleContentMargin;

@end
