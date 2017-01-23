//
//  UIButton+ALBounce.m
//  ALButtonMenu
//
//  Copyright © 2016 Anthony Lobianco. All rights reserved.
//

#import "UIButton+ALBounce.h"

#import <objc/runtime.h>

static void * kSpringyPropertyKey = &kSpringyPropertyKey;

static CGFloat const kButtonAnimationDamping = 0.6f;
static CGFloat const kButtonAnimationVelocity = 0.2f;
static UIViewAnimationOptions kButtonAnimationOptions = UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionBeginFromCurrentState;

@implementation UIButton (ALBounce)

#pragma mark - Properties

- (BOOL)isSpringy
{
    id obj = objc_getAssociatedObject(self, kSpringyPropertyKey);
    return obj != nil ? [obj boolValue] : YES;
}

- (void)setSpringy:(BOOL)springy
{
    objc_setAssociatedObject(self, kSpringyPropertyKey, @(springy), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - Public methods

- (void)al_transformToSize:(CGFloat)size duration:(NSTimeInterval)duration
{
    [self al_transformToSize:size duration:duration alongsideAnimations:nil];
}

- (void)al_transformToSize:(CGFloat)size duration:(NSTimeInterval)duration alongsideAnimations:(void (^)(void))animations
{
    [self al_transformToSize:size duration:duration alongsideAnimations:animations completion:nil];
}

- (void)al_transformToSize:(CGFloat)size duration:(NSTimeInterval)duration alongsideAnimations:(void (^)(void))animations completion:(void (^)(BOOL))completion
{
    void (^actualAnimations)(void) = ^{
        self.transform = CGAffineTransformScale(CGAffineTransformIdentity, size, size);
        if (animations)
        {
            animations();
        }
    };

    [self animateWithAnimations:actualAnimations
                       duration:duration
                     completion:completion];
}

- (void)al_restoreWithDuration:(NSTimeInterval)duration
{
    [self al_restoreWithDuration:duration alongsideAnimations:nil];
}

- (void)al_restoreWithDuration:(NSTimeInterval)duration alongsideAnimations:(void (^)(void))animations
{
    [self al_restoreWithDuration:duration alongsideAnimations:animations completion:nil];
}

- (void)al_restoreWithDuration:(NSTimeInterval)duration alongsideAnimations:(void (^)(void))animations completion:(void (^)(BOOL))completion
{
    void (^actualAnimations)(void) = ^{
        self.transform = CGAffineTransformIdentity;
        if (animations)
        {
            animations();
        }
    };

    [self animateWithAnimations:actualAnimations duration:duration completion:completion];
}

#pragma mark - Internal methods

- (void)animateWithAnimations:(void (^) (void))animations duration:(NSTimeInterval)duration completion:(void (^) (BOOL))completion
{
    if ([self isSpringy])
    {
        [UIView animateWithDuration:duration
                              delay:0.
             usingSpringWithDamping:kButtonAnimationDamping
              initialSpringVelocity:kButtonAnimationVelocity
                            options:kButtonAnimationOptions
                         animations:animations
                         completion:completion];
    }
    else
    {
        [UIView animateWithDuration:duration
                              delay:0.
                            options:kButtonAnimationOptions
                         animations:animations
                         completion:completion];
    }
}

@end
