//
//  ALNavigationCoordinator.m
//  ALButtonMenu
//
//  Copyright © 2016 Anthony Lobianco. All rights reserved.
//

#import "ALNavigationCoordinator.h"

#import "ALNavigationCoordinator+ALSnapping.h"
#import "UIButton+ALBounce.h"

#import "ALAnimationTransitionDelegate.h"
#import "ALMenuButton.h"
#import "ALButtonViewModel_ALPrivate.h"
#import "ALMenuViewController_ALPrivate.h"
#import "ALMenuViewControllerViewModel.h"
#import "ALNavigationCoordinatorViewModel.h"
#import "ALUtils.h"

static NSTimeInterval const kButtonDisappearAnimationDuration = 0.2;
static NSTimeInterval const kButtonReappearAnimationDuration = 0.3;
static NSTimeInterval const kButtonScaleAnimationDuration = 0.3;
static NSTimeInterval const kButtonScaleAndMoveAnimationDuration = 0.4;
static CGFloat const kButtonMinimumScaleFactor = 0.88f;
static CGFloat const kButtonExpandScaleFactor = 1.4f;
static CGFloat const kButtonMaximumShadowOffset = 5.f;

@interface ALNavigationCoordinator ()
<
ALMenuButtonDelegate,
ALAnimationTransitionDelegateDelegate,
ALMenuViewControllerDelegate
>

@property (nonatomic) ALMenuButton *button;
@property (nonatomic) ALNavigationCoordinatorSnapLocation currentButtonSnapLocation;
@property (nonatomic) CGPoint previousButtonMovePoint;
@property (nonatomic, getter=isShowingMenu) BOOL showingMenu;
@property (nonatomic) ALAnimationTransitionDelegate *transitionDelegate;
@property (nonatomic) BOOL wasNavigationBarShowing;

@end

@implementation ALNavigationCoordinator

- (instancetype)initWithViewModel:(ALNavigationCoordinatorViewModel *)viewModel menuViewController:(nonnull UIViewController<ALMenuViewController> *)menuViewController rootViewController:(nonnull UIViewController *)rootViewController
{
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:rootViewController];
    navigationController.navigationBarHidden = YES;

    AL_INIT([self initWithViewModel:viewModel menuViewController:menuViewController navigationController:navigationController]);

    return self;
}

- (instancetype)initWithViewModel:(ALNavigationCoordinatorViewModel *)viewModel menuViewController:(UIViewController<ALMenuViewController> *)menuViewController navigationController:(UINavigationController *)navigationController
{
    AL_INIT([super init]);

    _viewModel = viewModel;

    _menuViewController = menuViewController;
    _menuViewController.delegate = self;

    _navigationController = navigationController;

    return self;
}

- (void)viewDidLoad
{
    self.menuViewController.view.backgroundColor = self.viewModel.buttonDefaultColor;

    // i made the effort to use auto layout on this button (for the sizing and dragging)
    // but there's no point. sizing with AL works fine, but since the button can potentially
    // have a mask applied, any animations to the size constraints would not propogate
    // to the button's layer's mask. regular transform animations, on the other hand,
    // handle it perfectly. and positioning with AL works fine as well, but offers no
    // benefit over manual positioning (even during a screen rotation, which was the reason
    // i investigated AL in the first place. the button can be dragged around by the user,
    // and as such can never have constant positioning constraints applied to it [you may
    // be thinking "just update the .constant property" but that won't properly translate
    // to the new view dimensions after a screen rotation]).
    //
    ALButtonViewModel *buttonViewModel = [[ALButtonViewModel alloc] init];
    buttonViewModel.bouncesOnTouchUp = NO;
    buttonViewModel.color = self.viewModel.buttonDefaultColor;
    buttonViewModel.canReposition = self.viewModel.buttonCanBeRepositioned;
    buttonViewModel.maskPath = self.viewModel.buttonPath;
    buttonViewModel.touchArea = self.viewModel.buttonTouchArea;

    self.button = [[ALMenuButton alloc] initWithViewModel:buttonViewModel];
    self.button.frame = CGRectMake(0.f, 0.f, self.viewModel.buttonSize.width, self.viewModel.buttonSize.height);
    self.button.delegate = self;

    CGPoint buttonDefaultPosition = [self buttonDefaultPosition];
    self.currentButtonSnapLocation = self.viewModel.initialSnapLocation;

    CGPoint buttonCenter = CGPointZero;

    if (self.currentButtonSnapLocation == ALNavigationCoordinatorSnapLocationNone)
    {
        buttonCenter = buttonDefaultPosition;
    }
    else
    {
        buttonCenter = [self al_pointForSnapLocation:self.currentButtonSnapLocation];
    }

    [self updateButtonCenterWithPoint:buttonCenter];

    // add button
    [self.navigationController.view addSubview:self.button];

    // set an initial shape layer
    NSParameterAssert(self.transitionDelegate != nil);
    self.transitionDelegate.initialShapeLayer = [self initialShapeLayerForTransition];
}

#pragma mark - Setters

- (void)setDelegate:(id<ALNavigationCoordinatorDelegate>)delegate
{
    if (_delegate == delegate)
    {
        return;
    }

    _delegate = delegate;

    [self configureTransitionDelegateWithNavigationControllerDelegate:delegate];
}

#pragma mark - Delegate setup

- (void)configureTransitionDelegateWithNavigationControllerDelegate:(id<ALNavigationCoordinatorDelegate>)navigationControllerDelegate
{
    NSParameterAssert(self.viewModel != nil && self.menuViewController != nil);

    self.navigationController.delegate = nil;
    self.transitionDelegate.delegate = nil;
    self.transitionDelegate = [[ALAnimationTransitionDelegate alloc] initWithNavigationControllerDelegate:navigationControllerDelegate];
    self.transitionDelegate.delegate = self;
    self.transitionDelegate.appearingAnimation = self.viewModel.rootControllerAppearingAnimation;
    self.transitionDelegate.disappearingAnimation = self.viewModel.rootControllerDisappearingAnimation;
    self.transitionDelegate.viewControllerClassForCustomAnimations = [self.menuViewController class];
    self.navigationController.delegate = self.transitionDelegate;
}

#pragma mark - ALMenuViewControllerDelegate

- (void)menuViewController:(UIViewController<ALMenuViewController> *)menuViewController didSelectOptionAtIndex:(NSUInteger)index
{
    // ask for the next VC from delegate
    UIViewController *viewController = [self.delegate navigationCoordinator:self viewControllerForMenuItemAtIndex:index];

    // hide the menu
    [self toggleMenuWithCompletionHandler:^{

        // then push the VC on the stack
        if ([self.navigationController.viewControllers containsObject:viewController])
        {
            [self.navigationController popToViewController:viewController animated:YES];
        }
        else
        {
            [self.navigationController pushViewController:viewController animated:YES];
        }

    }];
}

#pragma mark - ALAnimationTransitionDelegateDelegate

- (void)transitionDelegate:(ALAnimationTransitionDelegate *)transitionDelegate didShowViewController:(UIViewController *)viewController
{
    if ([self isShowingMenu] == NO)
    {
        return;
    }

    // do something?
}

- (void)transitionDelegate:(ALAnimationTransitionDelegate *)transitionDelegate didHideViewController:(UIViewController *)viewController
{
    // now that the animation controller finished the mask transform animation,
    // we can restore the button's identity
    //
    self.button.userInteractionEnabled = YES;
    self.button.transform = CGAffineTransformIdentity;
}

#pragma mark - ALMenuItemDelegate

- (void)buttonWasTapped:(UIView<ALMenuItem> *)button
{
    self.button.userInteractionEnabled = NO;

    [self toggleMenu];
}

#pragma mark - ALMenuButtonDelegate

- (void)buttonBeganLongPress:(ALMenuButton *)button atLocation:(CGPoint)location
{
    self.previousButtonMovePoint = [self.navigationController.view convertPoint:location fromView:button];

    if (self.viewModel.buttonShouldShowShadowDuringReposition)
    {
        [button setShadowHidden:NO animated:YES];
    }

    [button al_transformToSize:kButtonExpandScaleFactor duration:kButtonScaleAnimationDuration];
}

- (void)buttonLongPressedMoved:(ALMenuButton *)button toLocation:(CGPoint)location
{
    CGPoint convertedPoint = [self.navigationController.view convertPoint:location fromView:self.button];
    CGPoint center = self.button.center;
    center.x += convertedPoint.x - self.previousButtonMovePoint.x;
    center.y += convertedPoint.y - self.previousButtonMovePoint.y;

    // update button center
    [self updateButtonCenterWithPoint:center];

    // then save point for next pass
    self.previousButtonMovePoint = convertedPoint;
}

- (void)buttonEndedLongPress:(ALMenuButton *)button
{
    self.button.userInteractionEnabled = NO;

    CGPoint currentPosition = self.button.center;
    CGPoint finalPosition = currentPosition;

    self.currentButtonSnapLocation = [self al_snapLocationNearestPoint:currentPosition];

    if (self.currentButtonSnapLocation != ALNavigationCoordinatorSnapLocationNone)
    {
        finalPosition = [self al_pointForSnapLocation:self.currentButtonSnapLocation];
    }

    void (^completion)(BOOL) = ^(BOOL finished) {
        self.transitionDelegate.initialShapeLayer = [self initialShapeLayerForTransition];
        self.button.userInteractionEnabled = YES;
    };

    NSTimeInterval duration = 0;

    void (^animations)(void) = nil;

    if (CGPointEqualToPoint(self.button.center, finalPosition) == NO)
    {
        duration = kButtonScaleAndMoveAnimationDuration;

        animations = ^{
            [self updateButtonCenterWithPoint:finalPosition];
        };
    }
    else
    {
        duration = kButtonScaleAnimationDuration;
    }

    [button al_restoreWithDuration:duration alongsideAnimations:animations completion:completion];

    if (self.viewModel.buttonShouldShowShadowDuringReposition)
    {
        [button setShadowHidden:YES animated:YES];
    }
}

#pragma mark - Navigation stack

- (void)willShowViewController:(UIViewController *)viewController
{
    NSParameterAssert(viewController == self.menuViewController);

    if ([self isShowingMenu])
    {
        return;
    }

    if ([self.menuViewController respondsToSelector:@selector(navigationCoordinator:willShowViewControllerFromPoint:)])
    {
        // give the menu VC a point to use as the anchor point for
        [(id)self.menuViewController navigationCoordinator:self willShowViewControllerFromPoint:[self initialShapeLayerForTransition].position];
    }

    self.button.transform = CGAffineTransformScale(CGAffineTransformIdentity, AL_SCALE_ZERO, AL_SCALE_ZERO);
    self.button.viewModel.color = self.viewModel.buttonActiveColor;

    [self.button al_restoreWithDuration:kButtonReappearAnimationDuration alongsideAnimations:nil completion:^(BOOL finished) {
        self.button.userInteractionEnabled = YES;
    }];
}

- (void)willHideViewController:(UIViewController *)viewController
{
    NSParameterAssert(viewController == self.menuViewController);

    if ([self isShowingMenu] == NO)
    {
        return;
    }

    if ([self.menuViewController respondsToSelector:@selector(navigationCoordinator:willHideViewControllerFromPoint:)])
    {
        // give the menu VC a point to use as the anchor point for
        [(id)self.menuViewController navigationCoordinator:self willHideViewControllerFromPoint:[self initialShapeLayerForTransition].position];
    }

    // disable springiness for this one animation, and re-enable it after
    self.button.springy = NO;

    void (^animations)(void) = ^{
        self.button.viewModel.color = self.viewModel.buttonDefaultColor;
    };

    void (^completion)(BOOL) = ^(BOOL finished) {
        // limit the size that the button can shrink to during the animation controller's animation
        self.button.transform = CGAffineTransformScale(CGAffineTransformIdentity, kButtonMinimumScaleFactor, kButtonMinimumScaleFactor);
        self.button.springy = YES;
    };

    [self.button al_transformToSize:AL_SCALE_ZERO duration:kButtonDisappearAnimationDuration alongsideAnimations:animations completion:completion];
}

- (void)toggleMenu
{
    [self toggleMenuWithCompletionHandler:nil];
}

- (void)toggleMenuWithCompletionHandler:(void (^) (void))completion
{
    if ([self isShowingMenu])
    {
        [self willHideViewController:self.menuViewController];

        [CATransaction begin];
        [CATransaction setCompletionBlock:completion];
        [self.navigationController popViewControllerAnimated:YES];
        [CATransaction commit];

        if (self.wasNavigationBarShowing)
        {
            [self.navigationController setNavigationBarHidden:NO animated:YES];
        }
    }
    else
    {
        self.wasNavigationBarShowing = self.navigationController.navigationBarHidden == NO;

        if (self.wasNavigationBarShowing)
        {
            [self.navigationController setNavigationBarHidden:YES animated:YES];
        }

        [self willShowViewController:self.menuViewController];

        [CATransaction begin];
        [CATransaction setCompletionBlock:completion];
        [self.navigationController pushViewController:self.menuViewController animated:YES];
        [CATransaction commit];
    }

    self.showingMenu = [self isShowingMenu] == NO;
}

#pragma mark - Button helpers

- (CGPoint)buttonDefaultPosition
{
    return [self al_pointForSnapLocation:self.viewModel.initialSnapLocation];
}

- (CAShapeLayer *)initialShapeLayerForTransition
{
    NSParameterAssert(self.button != nil);

    // calculate a shape layer in this view's coordinate space

    CAShapeLayer *shapeLayer = [[CAShapeLayer alloc] init];
    shapeLayer.bounds = self.button.frame;
    shapeLayer.position = self.button.center;

    if (self.button.scaledMaskPath)
    {
        CGAffineTransform transform = CGAffineTransformMakeTranslation(self.button.frame.origin.x, self.button.frame.origin.y);
        CGPathRef path = CGPathCreateCopyByTransformingPath(self.button.scaledMaskPath.CGPath, &transform);
        shapeLayer.path = path;
        CGPathRelease(path);
    }
    else
    {
        shapeLayer.path = [UIBezierPath bezierPathWithRect:self.button.frame].CGPath;
    }

    return shapeLayer;
}

- (CGSize)offsetForMenuButtonShadowWithButtonCenter:(CGPoint)buttonCenter
{
    // offsets are from button center to view center

    CGRect viewBounds = self.navigationController.view.bounds;
    CGPoint viewCenter = CGPointMake(CGRectGetMidX(viewBounds), CGRectGetMidY(viewBounds));
    CGSize viewSize = viewBounds.size;

    CGFloat xCenterToEdge = viewSize.width - viewCenter.x;
    CGFloat yCenterToEdge = viewSize.height - viewCenter.y;

    CGFloat xFromButtonCenter = buttonCenter.x - viewCenter.x;
    CGFloat yFromButtonCenter = buttonCenter.y - viewCenter.y;

    CGFloat xOffset = (kButtonMaximumShadowOffset * (xFromButtonCenter / xCenterToEdge));
    CGFloat yOffset = (kButtonMaximumShadowOffset * (yFromButtonCenter / yCenterToEdge));

    return CGSizeMake(xOffset, yOffset);
}

- (void)updateButtonCenterWithPoint:(CGPoint)point
{
    self.button.center = point;
    self.button.shadowOffset = [self offsetForMenuButtonShadowWithButtonCenter:point];
}

#pragma mark - Rotation

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [coordinator
     animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
         // update button position. our view will have correct dimensions in this scope
         CGPoint buttonCenter = CGPointZero;

         if (self.currentButtonSnapLocation != ALNavigationCoordinatorSnapLocationNone)
         {
             buttonCenter = [self al_pointForSnapLocation:self.currentButtonSnapLocation];
         }
         else
         {
             buttonCenter = [self buttonDefaultPosition];
         }

         [self updateButtonCenterWithPoint:buttonCenter];
     }
     completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
         // when rotation finishes, update shape layer
         self.transitionDelegate.initialShapeLayer = [self initialShapeLayerForTransition];
     }];
}

@end
