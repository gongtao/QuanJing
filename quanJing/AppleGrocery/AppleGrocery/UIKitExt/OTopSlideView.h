#pragma once

#import <UIKit/UIKit.h>
#import "OShadowView.h"
#import "OGradientView.h"

@interface OTopSlideView : OShadowView
{
    OGradientView* _clipView;

    UIView* _headView;
    UIView* _bodyView;

    bool _isDetailPanelHidden;

    float _headHeight;
    float _bodyHeight;
}

@property (strong, nonatomic) UIView* headView;
@property (strong, nonatomic) UIView* bodyView;

- (void)setHeadView:(UIView *)view animated:(BOOL)animated reversed:(BOOL)reversed;
- (void)setBodyView:(UIView *)view animated:(BOOL)animated;

-(void)showDetailViewAnimated:(BOOL)animated;
-(void)hideDetailViewAnimated:(BOOL)animated;

@end
