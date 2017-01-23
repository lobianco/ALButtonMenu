//
//  ALAnimationTransition.m
//  ALButtonMenu
//
//  Copyright © 2016 Anthony Lobianco. All rights reserved.
//

#import "ALAnimationTransitionDelegate.h"

#import "ALAnimationController.h"
#import "ALUtils.h"

@interface ALAnimationTransitionDelegate () <ALAnimationControllerDelegate>

@property (nonatomic, weak) id<UINavigationControllerDelegate> navigationControllerDelegate;
@property (nonatomic) Class navigationControllerDelegateClass;

@end

@implementation ALAnimationTransitionDelegate

- (instancetype)init
{
    return [self initWithNavigationControllerDelegate:nil];
}

- (instancetype)initWithNavigationControllerDelegate:(id<UINavigationControllerDelegate>)navigationControllerDelegate
{
    AL_INIT([super init]);

    _navigationControllerDelegate = navigationControllerDelegate;
    _navigationControllerDelegateClass = [navigationControllerDelegate class];

    return self;
}

#pragma mark - UINavigationControllerDelegate

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC
{
    Class classForCustomAnimations = self.viewControllerClassForCustomAnimations;

    if ([toVC isKindOfClass:classForCustomAnimations] == NO && [fromVC isKindOfClass:classForCustomAnimations] == NO)
    {
        return nil;
    }

    NSParameterAssert(self.initialShapeLayer != nil);
    ALAnimationController *animationController = [[ALAnimationController alloc] init];

    // animationController will live long enough to provide us delegate callbacks
    animationController.delegate = self;
    
    animationController.presenting = operation == UINavigationControllerOperationPush;
    animationController.initialShapeLayer = self.initialShapeLayer;
    animationController.appearingAnimation = self.appearingAnimation;
    animationController.disappearingAnimation = self.disappearingAnimation;
    
    return animationController;
}

#pragma mark - ALAnimationControllerDelegate

- (void)animationController:(ALAnimationController *)animationController didShowViewController:(UIViewController *)viewController
{
    if ([self.delegate respondsToSelector:@selector(transitionDelegate:didShowViewController:)])
    {
        [self.delegate transitionDelegate:self didShowViewController:viewController];
    }
}

- (void)animationController:(ALAnimationController *)animationController didHideViewController:(UIViewController *)viewController
{
    if ([self.delegate respondsToSelector:@selector(transitionDelegate:didHideViewController:)])
    {
        [self.delegate transitionDelegate:self didHideViewController:viewController];
    }
}

#pragma mark - Message forwarding

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
    return [self.navigationControllerDelegateClass instanceMethodSignatureForSelector:aSelector];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation
{
    if ([self.navigationControllerDelegate respondsToSelector:anInvocation.selector] == NO)
    {
        return;
    }

    [anInvocation invokeWithTarget:self.navigationControllerDelegate];
}

@end
