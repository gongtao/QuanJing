//
//  OGradientLabel.h
//  TaxiRadar
//
//  Created by Su on 04/16/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OGradientView.h"

@interface OGradientLabel : UIView
{
    OGradientView* _gradientLayer;
}

@property(copy) NSArray* colors;

@end
