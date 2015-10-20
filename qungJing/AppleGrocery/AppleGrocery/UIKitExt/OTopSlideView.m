#import "OTopSlideView.h"
#import "OTimingFunctionFactory.h"

@implementation OTopSlideView

@synthesize headView, bodyView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self construct];
    }

    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self construct];
    }

    return self;
}

- (void)construct
{
    _headHeight = 0.f;
    _bodyHeight = 0.f;
    _isDetailPanelHidden = true;

    self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.clipsToBounds = NO;

    _clipView = [[OGradientView alloc] initWithFrame:self.frame];
    _clipView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _clipView.backgroundColor = [UIColor colorWithWhite:0.96 alpha:1.0];
    _clipView.clipsToBounds = YES;
    _clipView.userInteractionEnabled = YES;
    _clipView.opaque = YES;
    [self addSubview:_clipView];
}

- (UIView*)headView
{
    return _headView;
}

- (void)setHeadView:(UIView *)view animated:(BOOL)animated reversed:(BOOL)reversed
{
    if (view == _headView)
    {
        return;
    }
    
    float duration = animated ? 0.3 : 0.0;

    if (_headView != nil)
    {
        UIView* prevHeadView = _headView;
        [UIView animateWithDuration:duration
                         animations:^(void) {
                             prevHeadView.alpha = 0.0;
                             CGRect frame = prevHeadView.frame;
                             frame.origin.y = reversed ? frame.size.height : -frame.size.height;
                             prevHeadView.frame = frame;
                         }
                         completion:^(BOOL isFinished) {
                             [prevHeadView removeFromSuperview];
                         }];
    }

    _headView = view;
    CGRect frame = view.bounds;
    frame.origin.x = 0;
    frame.origin.y = reversed ? -self.frame.size.height : self.frame.size.height;
    _headView.frame = frame;

    [UIView animateWithDuration:duration
                     animations:^(void) {
                         _headView.alpha = 1.0;
                     }];

    if (_headView != nil)
    {
        [_clipView addSubview:_headView];
        _headHeight = _headView.frame.size.height;
    }
    else
    {
        _headHeight = 0.f;
    }

    [self positionSubviewsWithAnimation:animated];
}

- (void)setHeadView:(UIView *)view
{
    [self setHeadView:view animated:NO reversed:NO];
}

- (UIView*)bodyView
{
    return _bodyView;
}

- (void)setBodyView:(UIView *)view
{
    [self setBodyView:view animated:NO];
}

- (void)setBodyView:(UIView *)view animated:(BOOL)animated
{
    if (_bodyView == view)
    {
        return;
    }

    if (_bodyView != nil)
    {
        [_bodyView removeFromSuperview];
    }

    _bodyView = view;

    if (_bodyView != nil)
    {
        [_clipView addSubview:_bodyView];
        [_clipView sendSubviewToBack:_bodyView];
        _bodyHeight = _bodyView.frame.size.height;
    }
    else
    {
        _bodyHeight = 0.f;
    }
    
    [self positionSubviewsWithAnimation:animated];
}

- (void)positionSubviewsWithAnimation:(BOOL)animated
{
    float width = _clipView.frame.size.width;
    float startHeight = _clipView.frame.size.height;
    float endHeight;

    float duration = (animated ? 0.3 : 0.0);

    if (_headView != nil)
    {
        [UIView animateWithDuration:duration
                         animations:^(void) {
                             _headView.frame = CGRectMake(0.0, 0.0, width, _headHeight);
                         }];
    }

    if (_bodyView != nil)
    {
        [UIView animateWithDuration:duration
                         animations:^(void) {
                             _bodyView.frame = CGRectMake(0.f, _headHeight, width, _bodyHeight);
                         }];
    }

    if (_isDetailPanelHidden)
    {
        endHeight = _headHeight;
        [UIView animateWithDuration:duration
                         animations:^(void) {
                             CGRect frame = CGRectMake(0.f, 0.f, width, _headHeight);
                             _clipView.frame = frame;
                             self.frame = frame;
                         }];
    }
    else
    {
        endHeight = _headHeight + _bodyHeight;
        [UIView animateWithDuration:duration
                         animations:^(void) {
                             CGRect frame = CGRectMake(0.f, 0.f, width, _headHeight + _bodyHeight);
                             _clipView.frame = frame;
                             self.frame = frame;
                         }];
    }

    CGPathRef startPath = CGPathCreateWithRect(CGRectMake(0, 0, width, startHeight), nil);
    CGPathRef endPath = CGPathCreateWithRect(CGRectMake(0, 0, width, endHeight), nil);
    self.layer.shadowPath = endPath;
    CABasicAnimation* animShadow = [CABasicAnimation animationWithKeyPath:@"shadowPath"];
    animShadow.fromValue = CFBridgingRelease(startPath);
    animShadow.toValue = CFBridgingRelease(endPath);
    animShadow.duration = 0.3;
    [self.layer addAnimation:animShadow forKey:nil];
}

-(void)showDetailViewAnimated:(BOOL)animated
{
    if (_isDetailPanelHidden)
    {
        [self animateDetailsArea:(_headHeight + _bodyHeight) isHide:NO];
        _isDetailPanelHidden = false;
    }
}

-(void)hideDetailViewAnimated:(BOOL)animated
{
    if (!_isDetailPanelHidden)
    {
        [self animateDetailsArea:_headHeight isHide:YES];
        _isDetailPanelHidden = true;
    }
}

- (void)animateDetailsArea:(float)newHeight
                    isHide:(BOOL)isHide
{
    double duration = 0.3;

    CALayer* layer = _clipView.layer;
    CAMediaTimingFunction* timing = [OTimingFunctionFactory functionWithType:EaseTypeExpoOut];

    CGFloat width = layer.bounds.size.width;

    CGFloat startHeight = layer.bounds.size.height;
    CGFloat endHeight = newHeight;
    CGFloat delta = endHeight - startHeight;

    CGFloat startY = layer.position.y;
    CGFloat endY = startY + delta * 0.5;

    [layer setValue:[NSNumber numberWithFloat:endY] forKey:@"position.y"];
    layer.position = CGPointMake(width * 0.5, endHeight * 0.5);
    layer.bounds = CGRectMake(0, 0, width, endHeight);

    CGSize size = _clipView.frame.size;
    CGPoint origin = self.frame.origin;
    self.frame = CGRectMake(origin.x, origin.y, size.width, size.height);

    CABasicAnimation* animPosY = [CABasicAnimation animationWithKeyPath:@"position.y"];
    animPosY.fromValue = [NSNumber numberWithFloat:startY];
    animPosY.toValue = [NSNumber numberWithFloat:endY];

    CABasicAnimation* animHeight = [CABasicAnimation animationWithKeyPath:@"bounds.size.height"];
    animHeight.fromValue = [NSNumber numberWithFloat:startHeight];
    animHeight.toValue = [NSNumber numberWithFloat:endHeight];

    CAAnimationGroup* animGroup = [[CAAnimationGroup alloc] init];
    animGroup.animations = [NSArray arrayWithObjects:animPosY, animHeight, nil];
    animGroup.timingFunction = timing;
    animGroup.duration = duration;
    [layer addAnimation:animGroup forKey:nil];

    CGPathRef startPath = CGPathCreateWithRect(CGRectMake(0, 0, layer.bounds.size.width, startHeight), nil);
    CGPathRef endPath = CGPathCreateWithRect(CGRectMake(0, 0, layer.bounds.size.width, endHeight), nil);
    self.layer.shadowPath = endPath;
    CABasicAnimation* animShadow = [CABasicAnimation animationWithKeyPath:@"shadowPath"];
    animShadow.fromValue = CFBridgingRelease(startPath);
    animShadow.toValue = CFBridgingRelease(endPath);
    animShadow.timingFunction = timing;
    animShadow.duration = duration;
    [self.layer addAnimation:animShadow forKey:nil];

    if (_bodyView != nil)
    {
        float fromOpacity;
        float toOpacity;
        if (isHide)
        {
            fromOpacity = 1.0;
            toOpacity = 0.0;
        }
        else
        {
            fromOpacity = 0.0;
            toOpacity = 1.0;
        }

        _bodyView.layer.opacity = toOpacity;
        CABasicAnimation* alphaAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        alphaAnimation.fromValue = [NSNumber numberWithFloat:fromOpacity];
        alphaAnimation.toValue = [NSNumber numberWithFloat:toOpacity];
        alphaAnimation.duration = duration;
        alphaAnimation.timingFunction = [OTimingFunctionFactory functionWithType:EaseTypeEaseIn];;
        [_bodyView.layer addAnimation:alphaAnimation forKey:nil];
    }
}

@end
