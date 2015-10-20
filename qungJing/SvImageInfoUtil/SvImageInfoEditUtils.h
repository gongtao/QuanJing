//
//  SvImageInfoEditUtils.h
//  SvImgeInfo
//
//  Created by  maple on 6/19/13.
//  Copyright (c) 2013 maple. All rights reserved.
//
//  the util class to modify image info 

#import "SvImageInfoUtils.h"

@interface SvImageInfoEditUtils : SvImageInfoUtils


- (void)setImageOrientation:(ExifOrientation)newOrientation;

- (void)save;

@end
