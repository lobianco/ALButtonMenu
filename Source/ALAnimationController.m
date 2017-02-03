//
//  ALAnimationController.m
//  ALButtonMenu
//
//  Copyright © 2016 Anthony Lobianco. All rights reserved.
//

#import "ALAnimationController.h"

#import "UIView+ALLayout.h"

static NSTimeInterval const kAnimationDuration = 0.3;
static CGFloat const kDimmingViewMaxAlpha = 0.5f;
static CGFloat const kExpandViewLayerScaleFactor = 1.5f;
static CGFloat const kCASpringAnimationDamping = 15.f;
static CGFloat const kCASpringAnimationStiffness = 115.f;
static CGFloat const kUIKSpringDamping = 0.53f;
static CGFloat const kUIKSpringVelocity = 0.f;

@interface ALAnimationController () <CAAnimationDelegate>

@property (nonatomic, weak) id<UIViewControllerContextTransitioning> transitionContext;

@end

@implementation ALAnimationController

#pragma mark - UIViewControllerAnimatedTransitioning

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    self.transitionContext = transitionContext;

    UIView *containerView = transitionContext.containerView;
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *toView = toViewController.view;
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIView *fromView = fromViewController.view;

    // make sure the frames are correct, in case a rotation event occurred
    CGRect finalToViewFrame = [transitionContext finalFrameForViewController:toViewController];
    toView.frame = finalToViewFrame;

    if ([self isPresenting])
    {
        [self animatePresentationWithContainerView:containerView fromView:fromView toView:toView];
    }
    else
    {
        [self animateDismissalWithContainerView:containerView fromView:fromView toView:toView];
    }
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return kAnimationDuration;
}

#pragma mark - Animation methods

- (void)animatePresentationWithContainerView:(UIView *)containerView fromView:(UIView *)fromView toView:(UIView *)toView
{
    // containerView already contains fromView
    [containerView addSubview:toView];

    // create a mask to gradually reveal the incoming view
    CAShapeLayer *maskLayer = self.initialShapeLayer;
    CATransform3D maskFromTransform = CATransform3DIdentity;
    CGFloat scale = [self scaleForView:toView];
    CATransform3D maskToTransform = CATransform3DScale(CATransform3DIdentity, scale, scale, 1.f);
    // set the final transform on the layer before the animation begins
    maskLayer.transform = maskToTransform;

    // mask the incoming view
    toView.layer.mask = maskLayer;

    // animate the mask
    CABasicAnimation *maskLayerAnimation = [self transformAnimationWithFromTransform:maskFromTransform toTransform:maskToTransform timingFunctionName:kCAMediaTimingFunctionEaseIn springy:NO];
    maskLayerAnimation.delegate = self;
    [maskLayer addAnimation:maskLayerAnimation forKey:@"maskLayer"];

    // create the dimming effect as the menu is shown
    UIView *dimmingView = [self addDimmingViewToContainerView:containerView belowView:toView];
    dimmingView.alpha = 0.f;

    // animate the outgoing view. we can animate these layer-backed views with
    // UIView animation methods.
    //

    BOOL shouldAnimateTransform = self.disappearingAnimation != ALNavigationCoordinatorAnimationNone;

    if (shouldAnimateTransform)
    {
        // set fromView's anchor point to be based on the location of the initial shape
        // layer, so the expansion animation will look like it's originating from the
        // location of the initial shape. note that since we're adjusting the anchor
        // point, we'll also have to adjust the position to keep the view from jumping
        // to a new location onscreen.
        //
        [self adjustAnchorPointAndPositionForView:fromView];
    }

    // no springs here (not needed, the view will be out of sight before the spring
    // effect would be noticed)
    //
    [UIView animateWithDuration:maskLayerAnimation.duration
                          delay:0.
                        options:UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         if (shouldAnimateTransform)
                         {
                             fromView.transform = CGAffineTransformScale(CGAffineTransformIdentity, kExpandViewLayerScaleFactor, kExpandViewLayerScaleFactor);
                         }
                         dimmingView.alpha = kDimmingViewMaxAlpha;
                     }
                     completion:nil];

    // no need to animate the incoming view, it will be our custom menu VC that
    // will perform its own animations. what's more, animating the incoming
    // view by scaling it up from a small size can potentially conflict with
    // the layer mask's revealing animation.
    //
}

- (void)animateDismissalWithContainerView:(UIView *)containerView fromView:(UIView *)fromView toView:(UIView *)toView
{
    // containerView already contains fromView
    [containerView insertSubview:toView belowSubview:fromView];

    // mask the outgoing view
    CAShapeLayer *maskLayer = self.initialShapeLayer;
    CGFloat scale = [self scaleForView:fromView];
    CATransform3D maskFromTransform = CATransform3DScale(CATransform3DIdentity, scale, scale, 1.f);
    CATransform3D maskToTransform = CATransform3DIdentity;
    maskLayer.transform = CATransform3DIdentity;
    fromView.layer.mask = maskLayer;

    // animate the mask
    CABasicAnimation *maskLayerAnimation = [self transformAnimationWithFromTransform:maskFromTransform toTransform:maskToTransform timingFunctionName:kCAMediaTimingFunctionEaseOut springy:YES];
    maskLayerAnimation.delegate = self;
    [maskLayer addAnimation:maskLayerAnimation forKey:@"maskLayer"];

    // create the dimming effect as the menu is hidden
    UIView *dimmingView = [self addDimmingViewToContainerView:containerView belowView:fromView];
    dimmingView.alpha = kDimmingViewMaxAlpha;

    BOOL shouldAnimateTransform = self.appearingAnimation != ALNavigationCoordinatorAnimationNone;

    if (shouldAnimateTransform)
    {
        // animate the incoming view
        [self adjustAnchorPointAndPositionForView:toView];

        toView.layer.transform = CATransform3DScale(CATransform3DIdentity, kExpandViewLayerScaleFactor, kExpandViewLayerScaleFactor, 1.f);
    }

    [UIView animateWithDuration:maskLayerAnimation.duration
                          delay:0.
         usingSpringWithDamping:kUIKSpringDamping
          initialSpringVelocity:kUIKSpringVelocity
                        options:UIViewAnimationOptionCurveEaseOut|UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         if (shouldAnimateTransform)
                         {
                             toView.transform = CGAffineTransformIdentity;
                         }
                         dimmingView.alpha = 0.f;
                     }
                     completion:nil];

    // don't animate the outgoing view, it interferes with the mask animation. let
    // the view's controller (our custom menu VC) do the animations.
    //
}

#pragma mark - Helper methods

- (UIView *)addDimmingViewToContainerView:(UIView *)containerView belowView:(UIView *)view
{
    // create the dimming view, which will fade in/out as the menu is shown/hidden
    UIView *dimmingView = [[UIView alloc] init];
    dimmingView.translatesAutoresizingMaskIntoConstraints = NO;
    dimmingView.backgroundColor = [UIColor blackColor];

    // then add and constrain
    [containerView insertSubview:dimmingView belowSubview:view];
    [dimmingView al_pinToSuperview];

    return dimmingView;
}

- (CGFloat)scaleForView:(UIView *)view
{
    CAShapeLayer *initialShapeLayer = self.initialShapeLayer;
    CGRect initialBounds = initialShapeLayer.bounds;

    // calculate a scale big enough for any convex shape to be able to expand
    // its size proportionally and still cover the entire view. inscribed values
    // refer to the dimensions of the largest rectangle that can be drawn
    // inside an ellipse with frame == intialBounds.
    //
    CGFloat width = CGRectGetWidth(initialBounds);
    CGFloat inscribedWidth = sqrt(2) * (width / 2.f);
    CGFloat height = CGRectGetHeight(initialBounds);
    CGFloat inscribedHeight = sqrt(2) * (height / 2.f);
    CGRect insetBounds = CGRectInset(initialBounds, (width - inscribedWidth) / 2.f, (height - inscribedHeight) / 2.f);
    CGFloat maxXDistance = MAX(CGRectGetMidX(insetBounds), CGRectGetWidth(view.frame) - CGRectGetMidX(insetBounds));
    CGFloat maxYDistance = MAX(CGRectGetMidY(insetBounds), CGRectGetHeight(view.frame) - CGRectGetMidY(insetBounds));
    CGFloat scale = MAX(((maxXDistance / CGRectGetWidth(insetBounds)) * 2.f), ((maxYDistance / CGRectGetHeight(insetBounds)) * 2.f));

    return scale;
}

- (CABasicAnimation *)transformAnimationWithFromTransform:(CATransform3D)fromTransform toTransform:(CATransform3D)toTransform timingFunctionName:(NSString *)timingFunction springy:(BOOL)springy
{
    //TODO: allow interrupting current animation from current state
    CABasicAnimation *animation = nil;
    static NSString * const transformKeyPath = @"transform";

    if (springy)
    {
        CASpringAnimation *springAnimation = [CASpringAnimation animationWithKeyPath:transformKeyPath];
        springAnimation.damping = kCASpringAnimationDamping;
        springAnimation.stiffness = kCASpringAnimationStiffness;
        springAnimation.duration = MAX(kAnimationDuration, springAnimation.settlingDuration);

        animation = springAnimation;
    }
    else
    {
        animation = [CABasicAnimation animationWithKeyPath:transformKeyPath];
        animation.duration = kAnimationDuration;
    }

    animation.fromValue = [NSValue valueWithCATransform3D:fromTransform];
    animation.toValue = [NSValue valueWithCATransform3D:toTransform];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:timingFunction];

    return animation;
}

- (void)adjustAnchorPointAndPositionForView:(UIView *)view
{
    CAShapeLayer *initialShapeLayer = self.initialShapeLayer;
    CGRect initialBounds = initialShapeLayer.bounds;

    CGFloat xAnchor = CGRectGetMidX(initialBounds) / CGRectGetWidth(view.frame);
    CGFloat yAnchor = CGRectGetMidY(initialBounds) / CGRectGetHeight(view.frame);
    CGPoint newAnchorPoint = CGPointMake(xAnchor, yAnchor);

    [view al_adjustPositionForNewAnchorPoint:newAnchorPoint];
}

#pragma mark - CAAnimationDelegate

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    [self cleanupAfterAnimation];
}

#pragma mark - Cleanup methods

- (void)cleanupAfterAnimation
{
    id<UIViewControllerContextTransitioning> transitionContext = self.transitionContext;

    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *toView = toViewController.view;
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIView *fromView = fromViewController.view;

    [transitionContext completeTransition:transitionContext.transitionWasCancelled == NO];

    fromView.layer.mask = nil;
    toView.layer.mask = nil;

    fromView.layer.transform = CATransform3DIdentity;
    toView.layer.transform = CATransform3DIdentity;

    fromView.transform = CGAffineTransformIdentity;
    toView.transform = CGAffineTransformIdentity;
}

- (void)animationEnded:(BOOL)transitionCompleted
{
    id<UIViewControllerContextTransitioning> transitionContext = self.transitionContext;

    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];

    if ([self isPresenting])
    {
        if ([self.delegate respondsToSelector:@selector(animationController:didShowViewController:)])
        {
            [self.delegate animationController:self didShowViewController:toViewController];
        }
    }
    else
    {
        if ([self.delegate respondsToSelector:@selector(animationController:didHideViewController:)])
        {
            [self.delegate animationController:self didHideViewController:fromViewController];
        }
    }

    self.transitionContext = nil;
}

@end
