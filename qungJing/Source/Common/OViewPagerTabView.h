#pragma once

#pragma mark - TabView
@class OViewPagerTabView;

@interface OViewPagerTabView : UIView

@property (nonatomic, getter = isSelected) BOOL selected;
@property (nonatomic) UIColor* indicatorColor;

@end
