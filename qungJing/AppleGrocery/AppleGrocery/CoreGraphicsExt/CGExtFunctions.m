#import "CGExtFunctions.h"

CGAffineTransform CGAffineTransformMakeScaleWithAnchor(CGFloat sx, CGFloat sy, CGFloat ax, CGFloat ay)
{
    CGAffineTransform transform = CGAffineTransformMakeTranslation(ax, ay);
    transform = CGAffineTransformConcat(transform, CGAffineTransformMakeScale(sx, sy));
    transform = CGAffineTransformConcat(transform, CGAffineTransformMakeTranslation(-ax, -ay));
    return transform;
}
