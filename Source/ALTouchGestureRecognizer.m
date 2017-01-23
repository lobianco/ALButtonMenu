//
//  ALTouchGestureRecognizer.m
//  ALButtonMenu
//
//  Copyright © 2016 Anthony Lobianco. All rights reserved.
//

#import "ALTouchGestureRecognizer.h"
#import <UIKit/UIGestureRecognizerSubclass.h>

static CGFloat const kMoveDistanceUntilFailure = 10.f;

@interface ALTouchGestureRecognizer ()

@property (nonatomic) CGPoint touchPoint;

@end

@implementation ALTouchGestureRecognizer

#pragma mark - UIControl

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];

    if (self.state != UIGestureRecognizerStatePossible)
    {
        return;
    }

    if (touches.count > 1)
    {
        self.state = UIGestureRecognizerStateFailed;
        return;
    }

    CGPoint touchPoint = [[touches anyObject] locationInView:self.view];
    self.touchPoint = touchPoint;

    self.state = UIGestureRecognizerStateBegan;
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];

    CGPoint touchPoint = [[touches anyObject] locationInView:self.view];
    CGFloat distance = hypot(self.touchPoint.x - touchPoint.x, self.touchPoint.y - touchPoint.y);

    self.state = distance > kMoveDistanceUntilFailure ? UIGestureRecognizerStateCancelled : UIGestureRecognizerStateChanged;
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];

    self.state = UIGestureRecognizerStateEnded;
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesCancelled:touches withEvent:event];

    self.state = UIGestureRecognizerStateCancelled;
}

- (void)reset
{
    [super reset];

    self.touchPoint = CGPointZero;
    self.state = UIGestureRecognizerStatePossible;
}

#pragma mark - Public methods

- (UIGestureRecognizerState)state
{
    UIGestureRecognizerState state = [super state];
    return state == UIGestureRecognizerStateChanged ? UIGestureRecognizerStateBegan : state;
}

- (void)cancel
{
    self.enabled = NO;
    self.enabled = YES;
}

#pragma mark - UIGestureRecognizerSubclass

- (BOOL)canBePreventedByGestureRecognizer:(UIGestureRecognizer *)preventingGestureRecognizer
{
    return YES;
}

- (BOOL)canPreventGestureRecognizer:(UIGestureRecognizer *)preventedGestureRecognizer
{
    return NO;
}

@end
