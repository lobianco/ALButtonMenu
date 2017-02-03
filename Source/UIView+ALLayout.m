//
//  UIView+ALLayout.m
//  ALButtonMenu
//
//  Copyright © 2016 Anthony Lobianco. All rights reserved.
//

#import "UIView+ALLayout.h"

@implementation UIView (ALLayout)

#pragma mark - Positioning

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

#pragma mark - Auto Layout

- (void)al_pinToSuperview
{
    [self al_pinToView:self.superview];
}

- (void)al_pinToView:(UIView *)view
{
    NSParameterAssert(view != nil);
    
    // forgetting to set this is the bane of my professional career
    self.translatesAutoresizingMaskIntoConstraints = NO;

    // then constrain
    [self.leadingAnchor constraintEqualToAnchor:view.leadingAnchor].active = YES;
    [self.trailingAnchor constraintEqualToAnchor:view.trailingAnchor].active = YES;
    [self.topAnchor constraintEqualToAnchor:view.topAnchor].active = YES;
    [self.bottomAnchor constraintEqualToAnchor:view.bottomAnchor].active = YES;
}

@end
