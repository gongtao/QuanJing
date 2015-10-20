//
//  FSPhotoView.h
//  FSPhotoView
//
//  Created by Stephen Jin on 7/26/13.
//  Copyright (c) 2013 Stephen Jin. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^DisappearBlcok)();

@interface FSPhotoView : UIScrollView<UIGestureRecognizerDelegate>

+ (FSPhotoView *)showImageWithSenderView:(UIImageView*)senderView;
+ (FSPhotoView *)showImageWithSenderView:(UIImageView*)senderView completion:(DisappearBlcok)completed;
+ (FSPhotoView *)showImageWithSenderViewWithUrl:(NSString*)url;

@end