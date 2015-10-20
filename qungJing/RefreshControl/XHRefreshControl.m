//
// XHRefreshControl.m
// MessageDisplayExample
//
// Created by 曾 宪华 on 14-6-6.
// Copyright (c) 2014年 曾宪华 开发团队(http://iyilunba.com ) 本人QQ:543413507 本人QQ群（142557668）. All rights reserved.
//

#import "XHRefreshControl.h"

#import "XHRefreshCircleContainerView.h"
#import "XHRefreshActivityIndicatorContainerView.h"
#import "XHLoadMoreView.h"
#define fequal(a,b) (fabs((a) - (b)) < FLT_EPSILON)
#define fequalzero(a) (fabs(a) < FLT_EPSILON)

#define kXHDefaultRefreshTotalPixels 60

typedef NS_ENUM (NSInteger, XHRefreshState) {
    XHRefreshStateRefreshPending   = 0,
    XHRefreshStateNormal    = 1,
    XHRefreshStateLoading   = 2,
    XHRefreshStateStopped   = 3,
};

@interface XHRefreshControl ()

@property (nonatomic, weak) id <XHRefreshControlDelegate> delegate;

// getter
@property (nonatomic, strong) XHRefreshCircleContainerView* refreshCircleContainerView;
@property (nonatomic, strong) XHRefreshActivityIndicatorContainerView* refreshActivityIndicatorContainerView;
@property (nonatomic, strong) UIView* customRefreshView;
@property (nonatomic, strong) XHLoadMoreView *loadMoreView;
@property (nonatomic, assign) BOOL isPullDownRefreshEnabled;
@property (nonatomic, assign) BOOL isLoadMoreRefreshed;
@property (nonatomic, assign) CGFloat refreshTotalPixels;
@property (nonatomic, assign) XHRefreshViewLayerType refreshViewLayerType;
@property (nonatomic, assign) XHPullDownRefreshViewType pullDownRefreshViewType;
@property (nonatomic, assign) NSInteger loadMoreRefreshedCount;
@property (nonatomic, assign) NSInteger autoLoadMoreRefreshedCount;
// target scrollview
@property (nonatomic, strong) UIScrollView* scrollView;

// target state
@property (nonatomic, assign) XHRefreshState refreshState;

// controll the loading and auto loading
@property (nonatomic, assign) BOOL pullDownRefreshing;
@property (nonatomic, assign) BOOL loadMoreRefreshing;

@property (nonatomic, assign) BOOL noMoreDataForLoaded;
@end

@implementation XHRefreshControl

#pragma mark - Pull Down Refreshing Method

- (void)startPullDownRefreshing
{
    if (self.isPullDownRefreshEnabled)
    {
        self.pullDownRefreshing = YES;

        [self setupRefreshTime];

        self.refreshState = XHRefreshStateRefreshPending;

        self.refreshState = XHRefreshStateLoading;
    }
}

- (void)animationRefreshCircleView
{
    switch (self.pullDownRefreshViewType)
    {
        case XHPullDownRefreshViewTypeCircle:
        {
            if (self.refreshCircleContainerView.circleView.offsetY != kXHDefaultRefreshTotalPixels - kXHRefreshCircleViewHeight)
            {
                self.refreshCircleContainerView.circleView.offsetY = kXHDefaultRefreshTotalPixels - kXHRefreshCircleViewHeight;
                [self.refreshCircleContainerView.circleView setNeedsDisplay];
            }

            // 先去除所有动画
            [self.refreshCircleContainerView.circleView.layer removeAllAnimations];

            // 添加旋转的动画
            [self.refreshCircleContainerView.circleView.layer addAnimation:[XHCircleView1 repeatRotateAnimation] forKey:@"rotateAnimation"];
            break;
        }
        case XHPullDownRefreshViewTypeActivityIndicator:
        {
            [self.refreshActivityIndicatorContainerView.activityIndicatorView beginRefreshing];
            break;
        }
        case XHPullDownRefreshViewTypeCustom:
        {
            if ([self.delegate respondsToSelector:@selector(customPullDownRefreshViewWillStartRefresh:)])
            {
                [self.delegate customPullDownRefreshViewWillStartRefresh:[self pullDownCustomRefreshView]];
            }
            break;
        }
        default:
            break;
    }

    [self callBeginPullDownRefreshing];
}

- (void)callBeginPullDownRefreshing
{
    
    [self setScrollViewContentInsetForNoLoadMore];
    
    self.loadMoreRefreshedCount = 0;
    self.noMoreDataForLoaded = NO;
    [self.delegate beginPullDownRefreshing];
}
- (void)setScrollViewContentInsetForNoLoadMore {
    UIEdgeInsets a = self.scrollView.contentInset;
    UIEdgeInsets currentInsets = self.scrollView.contentInset;
    if(_ifCustom)
    {
        currentInsets = UIEdgeInsetsMake(a.top, a.left, 50, a.right);
        
    }
    //currentInsets.bottom = 0;
    [self setScrollViewContentInset:currentInsets];
}
- (void)endPullDownRefreshing
{
    if (self.isPullDownRefreshEnabled)
    {
        [self setupRefreshTime];

        self.pullDownRefreshing = NO;
        self.refreshState = XHRefreshStateStopped;

        [self resetScrollViewContentInset];
    }

    if (self.pullDownRefreshViewType == XHPullDownRefreshViewTypeCustom)
    {
        if ([self.delegate respondsToSelector:@selector(customPullDownRefreshViewWillEndRefresh:)])
        {
            [self.delegate customPullDownRefreshViewWillEndRefresh:[self pullDownCustomRefreshView]];
        }
    }
}

#pragma mark - Refresh Time Helper Method

- (void)setupRefreshTime
{
    if ([self.delegate respondsToSelector:@selector(lastUpdateTimeString)])
    {
        NSString* dateString = [self.delegate lastUpdateTimeString];
        if ([dateString isKindOfClass:[NSString class]] || dateString)
        {
            self.refreshCircleContainerView.timeLabel.text = dateString;
        }
    }
}
#pragma mark - Load More Refreshing Method

- (void)startLoadMoreRefreshing {
    if (self.isLoadMoreRefreshed) {
        if (self.loadMoreRefreshedCount < self.autoLoadMoreRefreshedCount) {
            [self callBeginLoadMoreRefreshing];
        } else {
            [self.loadMoreView configuraManualState];
        }
    }
}

- (void)callBeginLoadMoreRefreshing {
    if (self.loadMoreRefreshing)
        return;
    self.loadMoreRefreshing = YES;
    self.loadMoreRefreshedCount ++;
    self.refreshState = XHRefreshStateLoading;
    [self.loadMoreView startLoading];
    [self.delegate beginLoadMoreRefreshing];
}

- (void)endLoadMoreRefresing {
    if (self.isLoadMoreRefreshed) {
        self.loadMoreRefreshing = NO;
        self.refreshState = XHRefreshStateNormal;
        [self.loadMoreView endLoading];
    }
}

- (void)loadMoreButtonClciked:(UIButton *)sender {
    [self callBeginLoadMoreRefreshing];
}

- (void)endMoreOverWithMessage:(NSString *)message {
    self.noMoreDataForLoaded = YES;
    [self.loadMoreView configuraNothingMoreWithMessage:message];
}


#pragma mark - Scroll View

- (void)resetScrollViewContentInset
{
    UIEdgeInsets contentInset = self.scrollView.contentInset;
    contentInset.top = self.originalTopInset;
    [UIView animateWithDuration:0.3f
     animations:^{
         [self.scrollView setContentInset:contentInset];
     }

     completion:^(BOOL finished) {

         self.refreshState = XHRefreshStateNormal;

         switch (self.pullDownRefreshViewType)
         {
             case XHPullDownRefreshViewTypeCircle:
                 {
                     self.refreshCircleContainerView.circleView.offsetY = 0;
                     [self.refreshCircleContainerView.circleView setNeedsDisplay];

                     if (self.refreshCircleContainerView.circleView)
                     {
                         [self.refreshCircleContainerView.circleView.layer removeAllAnimations];
                     }
                     break;
                 }
             case XHPullDownRefreshViewTypeActivityIndicator:
                 {
                     [self.refreshActivityIndicatorContainerView.activityIndicatorView endRefreshing];
                     break;
                 }
             default:
                 break;
         }
     }

    ];
}

- (void)setScrollViewContentInset:(UIEdgeInsets)contentInset
{
    [UIView animateWithDuration:0.3
     delay:0
     options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState
     animations:^{
         self.scrollView.contentInset = contentInset;
     }

     completion:^(BOOL finished) {
#if 1
         if (self.refreshState == XHRefreshStateStopped)
         {
             self.refreshState = XHRefreshStateNormal;
             if (self.refreshCircleContainerView.circleView)
             {
                 [self.refreshCircleContainerView.circleView.layer removeAllAnimations];
             }
         }
#endif
     }

    ];
}

- (void)setScrollViewContentInsetForLoading
{
    UIEdgeInsets currentInsets = self.scrollView.contentInset;
    currentInsets.top = self.refreshTotalPixels;
    [self setScrollViewContentInset:currentInsets];
}

#pragma mark - Propertys

- (XHRefreshCircleContainerView*)refreshCircleContainerView
{
    if (!_refreshCircleContainerView)
    {
        _refreshCircleContainerView =
            [[XHRefreshCircleContainerView alloc] initWithFrame:CGRectMake(0, (self.refreshViewLayerType == XHRefreshViewLayerTypeOnScrollViews ? -kXHDefaultRefreshTotalPixels : self.originalTopInset), CGRectGetWidth([[UIScreen mainScreen] bounds]), kXHDefaultRefreshTotalPixels)];
        _refreshCircleContainerView.backgroundColor = [UIColor clearColor];
        _refreshCircleContainerView.circleView.heightBeginToRefresh = kXHDefaultRefreshTotalPixels - kXHRefreshCircleViewHeight;
        _refreshCircleContainerView.circleView.offsetY = 0;
        _refreshCircleContainerView.circleView.refreshViewLayerType = self.refreshViewLayerType;
    }
    return _refreshCircleContainerView;
}

- (XHRefreshActivityIndicatorContainerView*)refreshActivityIndicatorContainerView
{
    if (!_refreshActivityIndicatorContainerView)
    {
        _refreshActivityIndicatorContainerView =
            [[XHRefreshActivityIndicatorContainerView alloc] initWithFrame:CGRectMake(0, (self.refreshViewLayerType == XHRefreshViewLayerTypeOnScrollViews ? -kXHDefaultRefreshTotalPixels : self.originalTopInset), CGRectGetWidth([[UIScreen mainScreen] bounds]), kXHDefaultRefreshTotalPixels)];
        _refreshActivityIndicatorContainerView.backgroundColor = [UIColor clearColor];
        _refreshActivityIndicatorContainerView.refreshViewLayerType = self.refreshViewLayerType;
    }
    return _refreshActivityIndicatorContainerView;
}

#pragma mark - Getter Method

- (BOOL)isPullDownRefreshEnabled
{
    BOOL pullDowned = YES;
    if ([self.delegate respondsToSelector:@selector(isPullDownRefreshEnabled)])
    {
        pullDowned = [self.delegate isPullDownRefreshEnabled];
        return pullDowned;
    }
    return YES;
}

- (CGFloat)refreshTotalPixels
{
    return kXHDefaultRefreshTotalPixels + [self adaptorHeight];
}

- (CGFloat)adaptorHeight
{
    if ([self.delegate respondsToSelector:@selector(keepiOS7NewApiCharacter)])
    {
        return [self.delegate keepiOS7NewApiCharacter] ? 64 : 0;
    }
    else
    {
        return 0;
    }
}

- (XHRefreshViewLayerType)refreshViewLayerType
{
    XHRefreshViewLayerType currentRefreshViewLayerType = XHRefreshViewLayerTypeOnScrollViews;
    if ([self.delegate respondsToSelector:@selector(refreshViewLayerType)])
    {
        currentRefreshViewLayerType = [self.delegate refreshViewLayerType];
    }
    return currentRefreshViewLayerType;
}

- (XHPullDownRefreshViewType)pullDownRefreshViewType
{
    XHPullDownRefreshViewType currentPullDownRefreshViewType = XHPullDownRefreshViewTypeCircle;
    if ([self.delegate respondsToSelector:@selector(pullDownRefreshViewType)])
    {
        currentPullDownRefreshViewType = [self.delegate pullDownRefreshViewType];
    }
    return currentPullDownRefreshViewType;
}

- (UIView*)pullDownCustomRefreshView
{
    if (self.customRefreshView)
    {
        return self.customRefreshView;
    }
    if ([self.delegate respondsToSelector:@selector(customPullDownRefreshView)])
    {
        self.customRefreshView = [self.delegate customPullDownRefreshView];
        return self.customRefreshView;
    }
    return nil;
}

#pragma mark - Setter Method

- (void)setRefreshState:(XHRefreshState)refreshState
{
    switch (refreshState)
    {
        case XHRefreshStateStopped:
            break;
        case XHRefreshStateNormal:
        {
            switch (self.pullDownRefreshViewType)
            {
                case XHPullDownRefreshViewTypeCircle:
                    self.refreshCircleContainerView.stateLabel.text = @"下拉刷新";
                    break;
                case XHPullDownRefreshViewTypeActivityIndicator:
                    break;
                case XHPullDownRefreshViewTypeCustom:
                    break;
                default:
                    break;
            }
            break;
        }
        case XHRefreshStateLoading:
        {
            if (self.pullDownRefreshing)
            {
                if (self.pullDownRefreshViewType == XHPullDownRefreshViewTypeCircle)
                {
                    self.refreshCircleContainerView.stateLabel.text = @"正在加载...";
                }

                [self setScrollViewContentInsetForLoading];

                if (_refreshState == XHRefreshStateRefreshPending)
                {
                    [self animationRefreshCircleView];
                }
            }
            break;
        }
        case XHRefreshStateRefreshPending:
            switch (self.pullDownRefreshViewType)
            {
                case XHPullDownRefreshViewTypeCircle:
                    self.refreshCircleContainerView.stateLabel.text = @"释放立即刷新";
                    break;
                case XHPullDownRefreshViewTypeActivityIndicator:
                    break;
                case XHPullDownRefreshViewTypeCustom:
                    break;
                default:
                    break;
            }
            break;
        default:
            break;
    }

    _refreshState = refreshState;
}

#pragma mark - Life Cycle

- (void)configuraObserverWithScrollView:(UIScrollView*)scrollView
{
    [scrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
    [scrollView addObserver:self forKeyPath:@"contentInset" options:NSKeyValueObservingOptionNew context:nil];
    [scrollView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)removeObserverWithScrollView:(UIScrollView*)scrollView
{
    [scrollView removeObserver:self forKeyPath:@"contentOffset" context:nil];
    [scrollView removeObserver:self forKeyPath:@"contentInset" context:nil];
    [scrollView removeObserver:self forKeyPath:@"contentSize" context:nil];
}

- (void)setup
{
    self.originalTopInset = self.scrollView.contentInset.top;

    self.refreshState = XHRefreshStateNormal;

    [self configuraObserverWithScrollView:self.scrollView];

    if (self.refreshViewLayerType == XHRefreshViewLayerTypeOnSuperView)
    {
        self.scrollView.backgroundColor = [UIColor clearColor];
        UIView* currentSuperView = self.scrollView.superview;

        if (self.isPullDownRefreshEnabled)
        {
            switch (self.pullDownRefreshViewType)
            {
                case XHPullDownRefreshViewTypeCircle:
                    [currentSuperView insertSubview:self.refreshCircleContainerView belowSubview:self.scrollView];
                    break;
                case XHPullDownRefreshViewTypeActivityIndicator:
                    [currentSuperView insertSubview:self.refreshActivityIndicatorContainerView belowSubview:self.scrollView];
                    break;
                case XHPullDownRefreshViewTypeCustom:
                {
                    UIView* customRefreshView = [self pullDownCustomRefreshView];
                    customRefreshView.frame = CGRectMake(0, (self.refreshViewLayerType == XHRefreshViewLayerTypeOnScrollViews ? -kXHDefaultRefreshTotalPixels : self.originalTopInset), CGRectGetWidth([[UIScreen mainScreen] bounds]), kXHDefaultRefreshTotalPixels);
                    if (customRefreshView)
                    {
                        [currentSuperView insertSubview:customRefreshView belowSubview:self.scrollView];
                    }
                    break;
                }
                default:
                    break;
            }
        }
    }
    else if (self.refreshViewLayerType == XHRefreshViewLayerTypeOnScrollViews)
    {
        if (self.isPullDownRefreshEnabled)
        {
            switch (self.pullDownRefreshViewType)
            {
                case XHPullDownRefreshViewTypeCircle:
                    [self.scrollView addSubview:self.refreshCircleContainerView];
                    break;
                case XHPullDownRefreshViewTypeActivityIndicator:
                    [self.scrollView addSubview:self.refreshActivityIndicatorContainerView];
                    break;
                case XHPullDownRefreshViewTypeCustom:
                {
                    [self.scrollView addSubview:[self pullDownCustomRefreshView]];
                    break;
                }
                default:
                    break;
            }
        }
    }
}

- (id)initWithScrollView:(UIScrollView*)scrollView delegate:(id <XHRefreshControlDelegate>)delegate
{
    self = [super init];
    if (self)
    {
        _delegate = delegate;
        _scrollView = scrollView;
        [self setup];
    }
    return self;
}

- (void)dealloc
{
    _delegate = nil;
    [self removeObserverWithScrollView:self.scrollView];
    _scrollView = nil;

    _refreshCircleContainerView = nil;

    _refreshActivityIndicatorContainerView = nil;
}

- (NSString*)descriptionForState:(XHRefreshState)refreshState
{
    switch (refreshState)
    {
        case XHRefreshStateRefreshPending: return @"XHRefreshStateRefreshPending";
        case XHRefreshStateNormal: return @"XHRefreshStateNormal";
        case XHRefreshStateLoading: return @"XHRefreshStateLoading";
        case XHRefreshStateStopped: return @"XHRefreshStateStopped";
        default:
            break;
    }
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object change:(NSDictionary*)change context:(void*)context
{
    if ([keyPath isEqualToString:@"contentOffset"])
    {
        CGPoint contentOffset = [[change valueForKey:NSKeyValueChangeNewKey] CGPointValue];

        // 拉刷新的逻辑方法
        if (self.isPullDownRefreshEnabled)
        {
            if (self.refreshState != XHRefreshStateLoading)
            {
                // 如果不是加载状态的时候

                CGFloat pullDownOffset = (MIN(ABS(self.scrollView.contentOffset.y + [self adaptorHeight]), kXHDefaultRefreshTotalPixels) - kXHRefreshCircleViewHeight);
                if (ABS(self.scrollView.contentOffset.y + [self adaptorHeight]) >= kXHRefreshCircleViewHeight)
                {
                    switch (self.pullDownRefreshViewType)
                    {
                        case XHPullDownRefreshViewTypeCircle:
                        {
                            self.refreshCircleContainerView.circleView.offsetY = pullDownOffset;
                            [self.refreshCircleContainerView.circleView setNeedsDisplay];
                            break;
                        }
                        case XHPullDownRefreshViewTypeActivityIndicator:
                        {
                            CGFloat timeOffset = pullDownOffset / 36.0;
                            self.refreshActivityIndicatorContainerView.activityIndicatorView.timeOffset = timeOffset;
                            break;
                        }
                        case XHPullDownRefreshViewTypeCustom:
                        {
                            if ([self.delegate respondsToSelector:@selector(customPullDownRefreshView:withPullDownOffset:)])
                            {
                                if ([self pullDownCustomRefreshView])
                                {
                                    [self.delegate customPullDownRefreshView:[self pullDownCustomRefreshView] withPullDownOffset:pullDownOffset];
                                }
                            }
                            break;
                        }
                        default:
                            break;
                    }
                }
                else
                {
                    if (self.pullDownRefreshViewType == XHPullDownRefreshViewTypeActivityIndicator)
                    {
                        self.refreshActivityIndicatorContainerView.activityIndicatorView.timeOffset = 0.0;
                    }
                }

                CGFloat scrollOffsetThreshold;
                scrollOffsetThreshold = -(kXHDefaultRefreshTotalPixels + self.originalTopInset);

                BOOL isScrollViewDragging = self.scrollView.isDragging;
                BOOL isStateRefreshPending = (self.refreshState == XHRefreshStateRefreshPending);
                BOOL isStateStopped = (self.refreshState == XHRefreshStateStopped);
                BOOL isThresholdExceeded = (contentOffset.y < scrollOffsetThreshold);

                if (isStateRefreshPending && !isScrollViewDragging)
                {
                    if (!self.pullDownRefreshing)
                    {
                        self.pullDownRefreshing = YES;
                        self.refreshState = XHRefreshStateLoading;
                    }
                }
                else if (isThresholdExceeded && isScrollViewDragging && isStateStopped)
                {
                    self.refreshState = XHRefreshStateRefreshPending;
                }
                else if (!isThresholdExceeded && !isStateStopped)
                {
                    self.refreshState = XHRefreshStateStopped;
                }
                else
                {
                }
            }
            else
            {
                CGFloat offset;
                UIEdgeInsets contentInset;
                offset = MAX(self.scrollView.contentOffset.y * -1, kXHDefaultRefreshTotalPixels);
                offset = MIN(offset, self.refreshTotalPixels);
                contentInset = self.scrollView.contentInset;
                self.scrollView.contentInset = UIEdgeInsetsMake(offset, contentInset.left, contentInset.bottom, contentInset.right);
            }
        }
    }
    else if ([keyPath isEqualToString:@"contentInset"])
    {
    }
    else if ([keyPath isEqualToString:@"contentSize"])
    {
    }
}

@end