//
//  UIView+ALPositioning.m
//  ALButtonMenu
//
//  Copyright © 2016 Anthony Lobianco. All rights reserved.
//

#import "UIView+ALPositioning.h"

@implementation UIView (ALPositioning)

- (void)al_adjustPositionForNewAnchorPoint:(CGPoint)anchorPoint
{
    CGPoint currentPosition = CGPointMake(CGRectGetWidth(self.bounds) * self.layer.anchorPoint.x, CGRectGetHeight(self.bounds) * self.layer.anchorPoint.y);
    currentPosition = CGPointApplyAffineTransform(currentPosition, self.transform);
    CGPoint newPosition = CGPointMake(CGRectGetWidth(self.bounds) * anchorPoint.x, CGRectGetHeight(self.bounds) * anchorPoint.y);
    newPosition = CGPointApplyAffineTransform(newPosition, self.transform);

    CGPoint translatedPosition = self.layer.position;

    translatedPosition.x -= currentPosition.x;
    translatedPosition.x += newPosition.x;

    translatedPosition.y -= currentPosition.y;
    translatedPosition.y += newPosition.y;

    self.layer.position = translatedPosition;
    self.layer.anchorPoint = anchorPoint;
}

@end
