//
//  OCalloutView.m
//  TaxiRadar
//
//  Created by Bing SU on 5/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "OCalloutView.h"
#import "UIColor+Ext.h"

#pragma mark - Private Interface

@interface OCalloutView()
{
    CGMutablePathRef _bubblePath;
    CGMutablePathRef _glossPath;
    
    CGGradientRef _gradient1;
    CGGradientRef _gradient2;
    
    CGPoint _glossStartPoint;
    CGPoint _glossEndPoint;
    
    BOOL _isGeometryDirty;
    BOOL _isColorDirty;
    
    float _horizontalShadowBufferLength;
    float _verticalShadowBufferLength;
}

@property (nonatomic, assign) CGSize bubbleSize;

@end

#pragma mark -
#pragma mark Implementation

@implementation OCalloutView

@synthesize contentSize     = _contentSize;
@synthesize bubbleSize      = _bubbleSize;
@synthesize arrowSize       = _arrowSize;
@synthesize arrowOffset     = _arrowOffset;
@synthesize strokeWidth     = _strokeWidth;
@synthesize strokeColor     = _strokeColor;
@synthesize cornerRadius    = _cornerRadius;
@synthesize fillColor       = _fillColor;
@synthesize glossColor      = _glossColor;
@synthesize shadowRadius    = _shadowRadius;
@synthesize shadowOffset    = _shadowOffset;
@synthesize bubbleContentFrame = _bubbleContentFrame;
@synthesize arrowHeadOffset = _arrowHeadOffset;
@synthesize bubbleContentMargin = _bubbleContentMargin;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.opaque = NO;
        
        // Initialization code
        _strokeWidth = 1.0;
        _cornerRadius = 6.0;
        _arrowSize = CGSizeMake(30.f, 15.f);
        _contentSize = CGSizeMake(200.f, 100.f);
        _shadowRadius = 6.0;
        _shadowOffset = CGSizeMake(0.0, 6.0);
        _fillColor = [[UIColor blackColor] colorWithAlphaComponent:.6];
        _strokeColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];
        _glossColor = [UIColor whiteColor];
        _bubblePath = nil;
        _glossPath = nil;
        _isGeometryDirty = YES;
        _isColorDirty = YES;
        _arrowHeadOffset = 5.f;
        _bubbleContentMargin = UIEdgeInsetsMake(0, 0, 0, 0);
        [self markGeometryDirty];
        [self markGradientDirty];
        [self markColorDirty];
        [self updateGeometry];
    }

    return self;
}

- (void)dealloc
{
    if (_bubblePath != 0)
    {
        CGPathRelease(_bubblePath);
        _bubblePath = 0;
    }
    
    if (_glossPath != 0)
    {
        CGPathRelease(_glossPath);
        _glossPath = 0;
    }
    
    if (_gradient1 != 0)
    {
        CGGradientRelease(_gradient1);
    }
    
    if (_gradient2 != 0)
    {
        CGGradientRelease(_gradient2);
    }
}

- (void)markGeometryDirty
{
    _isGeometryDirty = YES;
    [self setNeedsDisplay];
    [self setNeedsLayout];
}

- (void)markColorDirty
{
    [self setNeedsDisplay];
}

- (void)markGradientDirty
{
    _isColorDirty = YES; // TODO should be isGradientDirty
    [self setNeedsDisplay];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self updateGeometry];
}

#pragma mark -
#pragma mark Accessors

- (void)setContentSize:(CGSize)contentSize
{
    if (!CGSizeEqualToSize(_contentSize, contentSize))
    {
        _contentSize = contentSize;
        [self markGeometryDirty];
    }
}

- (void)setArrowSize:(CGSize)arrowSize
{
    if (!CGSizeEqualToSize(_arrowSize, arrowSize))
    {
        _arrowSize = arrowSize;
        [self markGeometryDirty];
    }
}

- (void)setArrowOffset:(float)arrowOffset
{
    if (arrowOffset != _arrowOffset)
    {
        _arrowOffset = arrowOffset;
        [self markGeometryDirty];
    }
}

- (void)setCornerRadius:(float)cornerRadius
{
    if (_cornerRadius != cornerRadius)
    {
        _cornerRadius = cornerRadius;
        [self markGeometryDirty];
    }
}

- (void)setStrokeWidth:(float)strokeWidth
{
    if (_strokeWidth != strokeWidth)
    {
        _strokeWidth = strokeWidth;
        [self markGeometryDirty];
    }
}

- (void)setStrokeColor:(UIColor *)strokeColor
{
    if (_strokeColor != strokeColor)
    {
        _strokeColor = strokeColor;
        [self markColorDirty];
    }
}

- (void)setFillColor:(UIColor *)fillColor
{
    if (_fillColor != fillColor)
    {
        _fillColor = fillColor;
        [self markColorDirty];
    }
}

- (void)setGlossColor:(UIColor *)glossColor
{
    if (_glossColor != glossColor)
    {
        _glossColor = glossColor;
        [self markGradientDirty];
    }
}

- (void)setShadowRadius:(float)shadowRadius
{
    if (_shadowRadius != shadowRadius)
    {
        _shadowRadius = shadowRadius;
        [self markGeometryDirty];
    }
}

- (void)setShadowOffset:(CGSize)shadowOffset
{
    if (!CGSizeEqualToSize(_shadowOffset, shadowOffset))
    {
        _shadowOffset = shadowOffset;
        [self markGeometryDirty];
    }
}

- (void)setArrowHeadOffset:(float)arrowHeadOffset
{
    if (arrowHeadOffset != _arrowHeadOffset)
    {
        _arrowHeadOffset = arrowHeadOffset;
        [self markGeometryDirty];
    }
}

- (void)setBubbleContentMargin:(UIEdgeInsets)bubbleContentMargin
{
    if (!UIEdgeInsetsEqualToEdgeInsets(_bubbleContentMargin, bubbleContentMargin))
    {
        _bubbleContentMargin = bubbleContentMargin;
        [self markGeometryDirty];
    }
}

- (CGRect)bubbleContentFrame
{
    [self updateGeometry];
    return _bubbleContentFrame;
}

#pragma mark -
#pragma mark Update

- (void)updateGeometry
{
    if (_isGeometryDirty)
    {
        _bubbleSize.width = _contentSize.width + _bubbleContentMargin.left + _bubbleContentMargin.right + _cornerRadius * 2.0;
        _bubbleSize.height = _contentSize.height + _bubbleContentMargin.top + _bubbleContentMargin.bottom + _cornerRadius * 2.0;

        [self updateBubblePath];
        [self updateGlossPath];

        float width = _bubbleSize.width + _strokeWidth + _horizontalShadowBufferLength * 2.0;
        float height = _bubbleSize.height  + _arrowSize.height + _strokeWidth + _verticalShadowBufferLength * 2.0;

        self.bounds = CGRectMake(0, 0, width, height);
        float arrowHeadX = _bubbleSize.width * 0.5 + _arrowOffset;
        float arrowHeadY = _bubbleSize.height - _verticalShadowBufferLength + _arrowHeadOffset;
        float centerX = arrowHeadX / _bubbleSize.width;
        float centerY = arrowHeadY / _bubbleSize.height;
        self.layer.anchorPoint = CGPointMake(centerX, centerY);

        float contentOriginX = _horizontalShadowBufferLength + _strokeWidth * 0.5 + _cornerRadius + _bubbleContentMargin.left;
        float contentOriginY = _verticalShadowBufferLength + _strokeWidth * 0.5 + _cornerRadius + _bubbleContentMargin.top;
        _bubbleContentFrame = CGRectMake(contentOriginX, contentOriginY, _contentSize.width, _contentSize.height);

        _isGeometryDirty = NO;
    }
}

- (void)updateGradients
{
    if (_gradient1 != 0)
    {
        CGGradientRelease(_gradient1);
    }

    if (_gradient2 != 0)
    {
        CGGradientRelease(_gradient2);
    }

    CGColorRef color1 = CGColorCreateCopyWithAlpha([_glossColor CGColor], 0.3);
    CGColorRef color2 = CGColorCreateCopyWithAlpha([_glossColor CGColor], 0.1);
    CGColorRef color3 = CGColorCreateCopyWithAlpha([_glossColor CGColor], 0.0);

    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();

	CGFloat locations1[] = { 0, 1.0 };
    CGColorRef data1[] = {color1, color2};
    CFArrayRef colors1 = CFArrayCreate(0, (const void**)data1, 2, nil);
    _gradient1 = CGGradientCreateWithColors(space, colors1, locations1);

	CGFloat locations2[] = { 0, .1, 1.0 };
    CGColorRef data2[] = {color1, color2, color3};
    CFArrayRef colors2 = CFArrayCreate(0, (const void**)data2, 3, nil);
	_gradient2 = CGGradientCreateWithColors(space, colors2, locations2);

    CGColorSpaceRelease(space);
    CFRelease(colors1);
    CFRelease(colors2);
}

- (void)updateBubblePath
{
    /*     Vertices for the callout
     *
     *      x0 x1                x2  x3   x4                 x5 x6
     *  y0    .+(10)--------------------------------------(9)+.
     *       /                                                 \
     *  y1  +                                                   +
     *     (0)                                                 (8) 
     *      |                                                   |
     *      |                                                   |
     *     (1)                                                 (7)
     *  y2  +                                                   +
     *       \                                                 /
     *  y3    '+(2)------------(3)+       +(5)------------(6)+'
     *                             \     /
     *                              \   /
     *                               \ /
     *                                +
     *  y4                           (4)
     *
     */

    _horizontalShadowBufferLength = _shadowRadius + fabs(_shadowOffset.width);
    _verticalShadowBufferLength = _shadowRadius + fabs(_shadowOffset.height);

    if (_bubblePath != 0)
    {
        CGPathRelease(_bubblePath);
        _bubblePath = 0;
    }

    float x0 = _strokeWidth / 2.0 + _horizontalShadowBufferLength; // xmargin is 7
    float x1 = x0 + _cornerRadius;
    float x3 = x0 + _bubbleSize.width * 0.5 + _arrowOffset;
    float x2 = x3 - _arrowSize.width * 0.5;
    float x4 = x3 + _arrowSize.width * 0.5;
    float x6 = x0 + _bubbleSize.width;
    float x5 = x6 - _cornerRadius;

    float y0 = _strokeWidth / 2.0 + _verticalShadowBufferLength; // ymargin is 0
    float y1 = y0 + _cornerRadius;
    float y3 = y0 + _bubbleSize.height;
    float y2 = y3 - _cornerRadius;
    float y4 = y3 + _arrowSize.height;

	//Create Path For Callout Bubble
    _bubblePath = CGPathCreateMutable();
	CGPathMoveToPoint(_bubblePath, 0, x0, y1); // To V0
	CGPathAddLineToPoint(_bubblePath, 0, x0, y2); // 0-1
	CGPathAddArc(_bubblePath, 0, x1, y2, _cornerRadius, M_PI, M_PI / 2, 1); // 1-2
	CGPathAddLineToPoint(_bubblePath, 0, x2, y3); // 2-3
	CGPathAddLineToPoint(_bubblePath, 0, x3, y4); // 3-4
	CGPathAddLineToPoint(_bubblePath, 0, x4, y3); // 4-5
	CGPathAddLineToPoint(_bubblePath, 0, x5, y3); // 5-6
	CGPathAddArc(_bubblePath, 0, x5, y2, _cornerRadius, M_PI / 2, 0.0f, 1); // 6-7
	CGPathAddLineToPoint(_bubblePath, 0, x6, y1); // 7-8
	CGPathAddArc(_bubblePath, 0, x5, y1, _cornerRadius, 0.0f, -M_PI / 2, 1); // 8-9
	CGPathAddLineToPoint(_bubblePath, 0, x1, y0); // 9-10
	CGPathAddArc(_bubblePath, 0, x1, y1, _cornerRadius, -M_PI / 2, M_PI, 1); //10-0
	CGPathCloseSubpath(_bubblePath);
}

- (void)updateGlossPath
{
    /*     Vertices for the callout
     *      x0  x1                                          x2  x3
     *  y0    .-+(7)-------------------------------------(6)+-.
     *       /                                                 \
     *  y1  +(0)                                             (5)+
     *      |                                                   |
     *      |                                                   |
     *      |                                                   |
     *      |                                                   |
     *  y2  +(1)                                             (4)+
     *       \                                                 /
     *  y3    +(2)-----------------------------------------(3)+
     *        x4                                             x5
     */
    
    if (_glossPath != 0)
    {
        CGPathRelease(_glossPath);
        _glossPath = 0;
    }

    CGFloat topRadius = _cornerRadius - _strokeWidth / 2;
	CGFloat bottomRadius = fmin(_cornerRadius / 1.5, 7.0);

    float x0 = _strokeWidth + _horizontalShadowBufferLength; // xmargin is 7
    float x1 = x0 + topRadius;
    float x3 = x0 + _bubbleSize.width - _strokeWidth;
    float x2 = x3 - topRadius;
    float x4 = x0 + bottomRadius;
    float x5 = x3 - bottomRadius;

    float y0 = _strokeWidth + _verticalShadowBufferLength; // ymargin is 0
    float y1 = y0 + topRadius;
    float y3 = y0 + (_bubbleSize.height - _strokeWidth) * 0.5;
    float y2 = y3 - bottomRadius;

	// 5. Create Path For Gloss
    _glossPath = CGPathCreateMutable();

	CGPathMoveToPoint(_glossPath, 0, x0, y1); // To 0
	CGPathAddLineToPoint(_glossPath, 0, x0, y2); // 0-1
	CGPathAddArc(_glossPath, 0, x4, y2, bottomRadius, M_PI, M_PI / 2, 1); // 1-2
	CGPathAddLineToPoint(_glossPath, 0, x5, y3); // 2-3
	CGPathAddArc(_glossPath, 0, x5, y2, bottomRadius, M_PI / 2, 0.0f, 1); // 3-4
	CGPathAddLineToPoint(_glossPath, 0, x3, y1); // 4-5
	CGPathAddArc(_glossPath, 0, x2, y1, topRadius, 0.0f, -M_PI / 2, 1); // 5-6
	CGPathAddLineToPoint(_glossPath, 0, x1, y0); // 6-7
	CGPathAddArc(_glossPath, 0, x1, y1, topRadius, -M_PI / 2, M_PI, 1); // 7-0
	CGPathCloseSubpath(_glossPath);

    _glossStartPoint = CGPointMake(x0, y0);
    _glossEndPoint   = CGPointMake(x0, y3);
}

- (void)drawRect:(CGRect)rect
{
    if (_isColorDirty)
    {
        [self updateGradients];
        _isColorDirty = NO;
    }

	CGContextRef ctx = UIGraphicsGetCurrentContext();

	// 1. Fill Callout Bubble & Add Shadow
    [_fillColor setFill];
	CGContextAddPath(ctx, _bubblePath);
	CGContextSaveGState(ctx);
	CGContextSetShadowWithColor(ctx, _shadowOffset, _shadowRadius, [UIColor colorWithWhite:0 alpha:1.0].CGColor);
	CGContextFillPath(ctx);
	CGContextRestoreGState(ctx);

	// 2. Stroke Callout Bubble
    [_strokeColor setStroke];
	CGContextSetLineWidth(ctx, _strokeWidth);
	CGContextSetLineCap(ctx, kCGLineCapSquare);
	CGContextAddPath(ctx, _bubblePath);
	CGContextStrokePath(ctx);

	// 3. Draw gradient in gloss path area.
	CGContextAddPath(ctx, _glossPath);
	CGContextClip(ctx);
	CGContextDrawLinearGradient(ctx, _gradient1, _glossStartPoint, _glossEndPoint, 0);

	// 4. Draw gradient on stroked gloss path.
	CGContextAddPath(ctx, _glossPath);
	CGContextSetLineWidth(ctx, _strokeWidth * 2.0);
	CGContextReplacePathWithStrokedPath(ctx);
	CGContextClip(ctx);
	CGContextDrawLinearGradient(ctx, _gradient2, _glossStartPoint, _glossEndPoint, 0);
}

@end
