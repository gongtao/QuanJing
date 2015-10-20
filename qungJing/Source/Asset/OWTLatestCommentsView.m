//
//  OWTBriefCommentsView.m
//  Weitu
//
//  Created by Su on 4/23/14.
//  Copyright (c) 2014 SparkingSoft Co., Ltd. All rights reserved.
//

#import "OWTLatestCommentsView.h"
#import "OWTComment.h"
#import "OWTUserManager.h"

@interface OWTLatestCommentsView()
{
    NSMutableArray* _subviews;
    NSMutableArray* _constraints;

    UIView* _lastViewForLayout;
}

@property (nonatomic, strong) TTTAttributedLabel* noCommentLabel;
@property (nonatomic, copy) NSArray* comments;
@property (nonatomic, assign) NSInteger commentNum;

@end

@implementation OWTLatestCommentsView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self setup];
    }
    return self;
}

- (void)setup
{
    _subviews = [NSMutableArray array];
    _constraints = [NSMutableArray array];
    self.translatesAutoresizingMaskIntoConstraints = NO;
}

- (void)setComments:(NSArray *)comments commentNum:(NSInteger)commentNum
{
    _comments = comments;
    _commentNum = commentNum;
    [self regenerateLabels];
}

- (void)regenerateLabels
{
    [self removeAllViews];

    if (_comments != nil)
    {
        if (_comments.count != 0)
        {
            if (_commentNum > 0)
            {
                [self generateCommentNumButton:_commentNum];
            }
            
            for (OWTComment* comment in _comments)
            {
                [self generateLabelsForComment:comment];
            }
            
            if (_lastViewForLayout != nil)
            {
                NSDictionary* parameters = @{ @"label" : _lastViewForLayout };
                NSLayoutConstraint* constraint;
                constraint = [NSLayoutConstraint constraintWithExpressionFormat:@"label.bottom = superview.bottom" parameters:parameters];
                [self addConstraint:constraint];
                [_constraints addObject:constraint];
            }
        }
        else
        {
            [self generateNoCommentLabel];
        }
    }

    [self setNeedsLayout];
}

- (void)removeAllViews
{
    for (UIView* view in _subviews)
    {
        [view removeFromSuperview];
    }
    [_subviews removeAllObjects];

    [self removeConstraints:_constraints];
    [_constraints removeAllObjects];
}

- (void)generateCommentNumButton:(NSInteger)commentNum
{
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    [button.titleLabel setFont:[UIFont systemFontOfSize:14]];
    button.translatesAutoresizingMaskIntoConstraints = NO;
    [button setTitle:[NSString stringWithFormat:@"查看所有%ld条评论", (long)commentNum]
            forState:UIControlStateNormal];
    button.titleLabel.textAlignment = NSTextAlignmentLeft;
    
    [button addTarget:self action:@selector(showAllCommentsPressed) forControlEvents:UIControlEventTouchUpInside];

    [self addSubview:button];
    [_subviews addObject:button];

    NSDictionary* parameters = @{ @"view" : button };
    NSLayoutConstraint* constraint;
    constraint = [NSLayoutConstraint constraintWithExpressionFormat:@"view.left = superview.left" parameters:parameters];
    [self addConstraint:constraint];
    [_constraints addObject:constraint];
    
    constraint = [NSLayoutConstraint constraintWithExpressionFormat:@"view.top = superview.top" parameters:parameters];
    [self addConstraint:constraint];
    [_constraints addObject:constraint];

    _lastViewForLayout = button;
}

- (void)showAllCommentsPressed
{
    if (_showAllCommentsAction != nil)
    {
        _showAllCommentsAction();
    }
}

- (void)generateLabelsForComment:(OWTComment*)comment
{
    OWTUserManager* um = GetUserManager();
    OWTUser* user = [um userForID:comment.userID];

    if (user == nil)
    {
        DDLogError(@"Unable to find user %@ for comment %@", comment.userID, comment.commentID);
        return;
    }

    NSString* username = user.nickname;
    NSString* content = comment.content;

    TTTAttributedLabel* label = [self createLabelWithUsername:username
                                                       userID:user.userID
                                                      content:content];
    [self addSubview:label];
    [_subviews addObject:label];

    if (_lastViewForLayout == nil)
    {
        NSDictionary* parameters = @{ @"label" : label };
        NSLayoutConstraint* constraint;
        constraint = [NSLayoutConstraint constraintWithExpressionFormat:@"label.left = superview.left" parameters:parameters];
        [self addConstraint:constraint];
        [_constraints addObject:constraint];
        
        constraint = [NSLayoutConstraint constraintWithExpressionFormat:@"label.right = superview.right" parameters:parameters];
        [self addConstraint:constraint];
        [_constraints addObject:constraint];

        constraint = [NSLayoutConstraint constraintWithExpressionFormat:@"label.top = superview.top" parameters:parameters];
        [self addConstraint:constraint];
        [_constraints addObject:constraint];
    }
    else
    {
        NSDictionary* parameters = @{ @"prevView" : _lastViewForLayout, @"label" : label };
        NSLayoutConstraint* constraint;
        constraint = [NSLayoutConstraint constraintWithExpressionFormat:@"label.left = superview.left" parameters:parameters];
        [self addConstraint:constraint];
        [_constraints addObject:constraint];
        
        constraint = [NSLayoutConstraint constraintWithExpressionFormat:@"label.right = superview.right" parameters:parameters];
        [self addConstraint:constraint];
        [_constraints addObject:constraint];

        constraint = [NSLayoutConstraint constraintWithExpressionFormat:@"label.top = prevView.bottom" parameters:parameters];
        [self addConstraint:constraint];
        [_constraints addObject:constraint];
    }

    _lastViewForLayout = label;
}

- (TTTAttributedLabel*)createLabelWithUsername:(NSString*)username userID:(NSString*)userID content:(NSString*)content
{
    TTTAttributedLabel* label = [[TTTAttributedLabel alloc] initWithFrame:CGRectZero];
    label.translatesAutoresizingMaskIntoConstraints = NO;
    label.font = [UIFont systemFontOfSize:14];
    label.textColor = [UIColor darkGrayColor];
    label.lineBreakMode = NSLineBreakByWordWrapping;
    label.numberOfLines = 0;
    label.linkAttributes = @{ NSForegroundColorAttributeName: GetThemer().themeColor };
    label.delegate = self;
    label.text = [NSString stringWithFormat:@"%@ %@", username, content];

    NSRange range = NSMakeRange(0, username.length);
    [label addLinkToURL:[NSURL URLWithString:[NSString stringWithFormat:@"show-user://%@", userID]]
              withRange:range];

    return label;
}

- (void)generateNoCommentLabel
{
    TTTAttributedLabel* label = self.noCommentLabel;
    [self addSubview:label];
    [_subviews addObject:label];

    NSDictionary* parameters = @{ @"label" : label };
    NSLayoutConstraint* constraint;
    constraint = [NSLayoutConstraint constraintWithExpressionFormat:@"label.left = superview.left" parameters:parameters];
    [self addConstraint:constraint];
    [_constraints addObject:constraint];

    constraint = [NSLayoutConstraint constraintWithExpressionFormat:@"label.right = superview.right" parameters:parameters];
    [self addConstraint:constraint];
    [_constraints addObject:constraint];

    constraint = [NSLayoutConstraint constraintWithExpressionFormat:@"label.top = superview.top" parameters:parameters];
    [self addConstraint:constraint];
    [_constraints addObject:constraint];

    constraint = [NSLayoutConstraint constraintWithExpressionFormat:@"label.bottom = superview.bottom" parameters:parameters];
    [self addConstraint:constraint];
    [_constraints addObject:constraint];
}

- (TTTAttributedLabel*)noCommentLabel
{
    if (_noCommentLabel == nil)
    {
        TTTAttributedLabel* label = [[TTTAttributedLabel alloc] initWithFrame:CGRectZero];
        label.translatesAutoresizingMaskIntoConstraints = NO;
        label.font = [UIFont systemFontOfSize:14];
        label.textColor = [UIColor darkGrayColor];
        label.lineBreakMode = NSLineBreakByWordWrapping;
        label.numberOfLines = 0;
        label.text = @"目前没有任何评论";
        _noCommentLabel = label;
    }

    return _noCommentLabel;
}

@end
