//
//  OListView.m
//  TaxiRadar
//
//  Created by Su on 04/15/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "OListView.h"

@implementation OListView

@synthesize listSubviews = _listSubviews;

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
    _listSubviews = [[NSMutableArray alloc] init];
    self.clipsToBounds = YES;
}

- (void)dealloc
{
    for (UIView* view in _listSubviews)
    {
        [view removeObserver:self forKeyPath:@"layer.bounds"];
    }
}

- (BOOL)containsListSubview:(UIView*)view
{
    return [_listSubviews containsObject:view];
}

- (void)addListSubview:(UIView*)view
{
    [self insertListSubview:view atIndex:_listSubviews.count];
}

- (void)insertListSubview:(UIView *)view atIndex:(NSUInteger)index
{
    if (view == nil)
    {
        return;
    }

    if ([_listSubviews containsObject:view])
    {
        // TODO assert
        return;
    }

    UIView* prevView = nil;
    NSInteger prevIndex = index - 1;
    if (prevIndex >= 0 && prevIndex < self.subviews.count)
    {
        prevView = [_listSubviews objectAtIndex:(index - 1)];
    }

    float endY = 0.0;
    if (prevView != nil)
    {
        CGRect frame = prevView.frame;
        endY = frame.origin.y + frame.size.height;
    }

    float height = view.frame.size.height;
    float startY = endY - height;

    CGRect startFrame = CGRectMake(0, startY, self.bounds.size.width, height);
    CGRect endFrame = CGRectMake(0, endY, self.bounds.size.width, height);

    view.frame = startFrame;
    view.alpha = 1.0;

    [_listSubviews insertObject:view atIndex:index];
    [self insertSubview:view atIndex:(self.subviews.count - index)];
    [view addObserver:self forKeyPath:@"layer.bounds" options:NSKeyValueObservingOptionOld context:NULL];

    [UIView animateWithDuration:0.3
                     animations:^(void) {
                         view.frame = endFrame;
                         view.alpha = 1.0;

                         CGRect frame = self.frame;
                         frame.size.height += height;
                         self.frame = frame;

                         for (NSInteger i = index + 1; i < _listSubviews.count; ++i)
                         {
                             UIView* decendentView = [_listSubviews objectAtIndex:i];
                             CGRect newFrame = decendentView.frame;
                             newFrame.origin.y += height;
                             decendentView.frame = newFrame;
                         }
                     }];
}

- (void)removeListSubview:(UIView*)view
{
    if (view == nil)
    {
        return;
    }

    NSUInteger index = [_listSubviews indexOfObject:view];
    [self removeListSubviewAtIndex:index];
}

- (void)removeListSubviewAtIndex:(NSUInteger)index
{
    if (index >= _listSubviews.count)
    {
        return;
    }
    
    UIView* view = [_listSubviews objectAtIndex:index];
    [_listSubviews removeObject:view];
    [view removeObserver:self forKeyPath:@"layer.bounds"];

    float height = view.frame.size.height;
    
    CGRect endFrame = view.frame;
    endFrame.origin.y -= height;

    [UIView animateWithDuration:0.3
                     animations:^(void) {
                         view.frame = endFrame;
                         view.alpha = 1.0;

                         CGRect frame = self.frame;
                         frame.size.height -= height;
                         self.frame = frame;

                         for (NSUInteger i = index; i < _listSubviews.count; ++i)
                         {
                             UIView* decendentView = [_listSubviews objectAtIndex:i];
                             CGRect newFrame = decendentView.frame;
                             newFrame.origin.y -= height;
                             decendentView.frame = newFrame;
                         }
                     }
                     completion:^(BOOL isFinished) {
                         [view removeFromSuperview];
                     }
     ];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary*)change
                       context:(void *)context
{
    if ([keyPath isEqualToString:@"layer.bounds"])
    {
        UIView* view = object;
        NSUInteger index = [_listSubviews indexOfObject:view];

        CGRect oldFrame = [[change objectForKey:@"old"] CGRectValue];
        CGRect newFrame = view.frame;

        float heightDiff = newFrame.size.height - oldFrame.size.height;
        if (heightDiff == 0.0)
        {
            return;
        }

        [UIView animateWithDuration:0.3
                         animations:^(void) {
                             CGRect frame = self.frame;
                             frame.size.height += heightDiff;
                             self.frame = frame;

                             for (NSUInteger i = index; i < _listSubviews.count; ++i)
                             {
                                 NSInteger prevIndex = i - 1;
                                 float y = 0.0;
                                 if (prevIndex >= 0)
                                 {
                                     UIView* prevView = [_listSubviews objectAtIndex:prevIndex];
                                     CGRect frame = prevView.frame;
                                     y = frame.origin.y + frame.size.height;
                                 }
                                 UIView* decendentView = [_listSubviews objectAtIndex:i];
                                 CGRect frame = decendentView.frame;
                                 frame.origin.y = y;
                                 decendentView.frame = frame;
                             }
                         }];
    }
}

@end
