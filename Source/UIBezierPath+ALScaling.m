//
//  UIBezierPath+ALScaling.m
//  ALButtonMenu
//
//  Copyright © 2016 Anthony Lobianco. All rights reserved.
//

#import "UIBezierPath+ALScaling.h"

@implementation UIBezierPath (ALScaling)

- (UIBezierPath *)al_scaledToRect:(CGRect)rect
{
    // with help from http://stackoverflow.com/a/15936794 - thanks David!

    CGRect boundingBox = CGPathGetBoundingBox(self.CGPath);

    CGFloat boundingBoxAspectRatio = CGRectGetWidth(boundingBox) / CGRectGetHeight(boundingBox);
    CGFloat viewAspectRatio = CGRectGetWidth(rect) / CGRectGetHeight(rect);

    CGFloat scale = boundingBoxAspectRatio > viewAspectRatio ? CGRectGetWidth(rect) / CGRectGetWidth(boundingBox) : CGRectGetHeight(rect) / CGRectGetHeight(boundingBox);

    // scale and translate the path
    CGAffineTransform transform = CGAffineTransformScale(CGAffineTransformIdentity, scale, scale);
    transform = CGAffineTransformTranslate(transform, -(CGRectGetMinX(boundingBox)), -(CGRectGetMinY(boundingBox)));

    // center the path in the rect
    CGSize scaledSize = CGSizeApplyAffineTransform(boundingBox.size, CGAffineTransformMakeScale(scale, scale));
    CGSize centerOffset = CGSizeMake((CGRectGetWidth(rect) - scaledSize.width) / (scale * 2.f), (CGRectGetHeight(rect) - scaledSize.height) / (scale * 2.f));
    transform = CGAffineTransformTranslate(transform, centerOffset.width, centerOffset.height);

    // apply the transformation
    CGPathRef transformedPath = CGPathCreateCopyByTransformingPath(self.CGPath, &transform);
    UIBezierPath *scaledPath = [UIBezierPath bezierPathWithCGPath:transformedPath];
    CGPathRelease(transformedPath);

    return scaledPath;
}

@end
