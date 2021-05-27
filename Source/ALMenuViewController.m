//
//  ALMenuViewController.m
//  ALButtonMenu
//
//  Copyright © 2016 Anthony Lobianco. All rights reserved.
//

#import "ALMenuViewController_ALPrivate.h"

#import "UIView+ALLayout.h"

#import "ALMenuItem.h"
#import "ALMenuCollectionViewCell.h"
#import "ALMenuCollectionViewLayout.h"
#import "ALNavigationCoordinator.h"
#import "ALUtils.h"

static NSTimeInterval const kStatusBarAnimationDuration = 0.3;
static NSTimeInterval const kItemAppearanceAnimationDuration = 0.35;
static NSTimeInterval const kItemAppearanceAnimationDelay = 0.08;
static CGFloat const kItemAppearanceAnimationDamping = 0.6f;
static CGFloat const kItemAppearanceAnimationVelocity = 0.2f;
static NSTimeInterval const kContainerViewAppearingAnimationDuration = 0.6;
static NSTimeInterval const kContainerViewDisappearingAnimationDuration = 0.5;

static NSString * const kCollectionViewCellReuseIdentifier = @"menuCollectionViewCellReuseIdentifier";

@interface ALMenuViewController ()
<
ALMenuItemDelegate,
ALMenuCollectionViewLayoutDelegate,
UICollectionViewDelegate,
UICollectionViewDataSource
>

@property (nonatomic) UICollectionView *collectionView;
@property (nonatomic) UIView<ALMenuItem> *containerView;
@property (nonatomic, getter=isStatusBarHidden) BOOL statusBarHidden;
@property (nonatomic, weak) NSLayoutConstraint *containerViewWidthConstraint;
@property (nonatomic, weak) NSLayoutConstraint *containerViewHeightConstraint;
@property (nonatomic, weak) NSLayoutConstraint *containerViewCenterXConstraint;
@property (nonatomic, weak) NSLayoutConstraint *containerViewCenterYConstraint;
@property (nonatomic) CGFloat transformXOffset;
@property (nonatomic) CGFloat transformYOffset;

@end

@implementation ALMenuViewController

@synthesize delegate = _delegate;

- (instancetype)initWithViewModel:(ALMenuViewControllerViewModel *)viewModel
{
    AL_INIT([super init]);

    _viewModel = viewModel;

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self buildView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if (self.viewModel.shouldHideStatusBar)
    {
        [self hideStatusBarAnimated:animated];
    }

    [self reloadCollectionView];
    [self handleViewAnimationsForViewWillAppear];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [self handleViewAnimationsForViewDidAppear];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    if (self.viewModel.shouldHideStatusBar)
    {
        [self showStatusBarAnimated:animated];
    }

    [self handleViewAnimationsForViewWillDisappear];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];

    [self handleViewAnimationsForViewDidDisappear];
}

#pragma mark - Private methods

- (void)navigationCoordinator:(ALNavigationCoordinator *)navigationCoordinator willShowViewControllerFromPoint:(CGPoint)point
{
    if (self.viewModel.appearingAnimation != ALMenuViewControllerAppearingAnimationOrigin)
    {
        return;
    }

    // force view to layout so containerView has correct dimensions
    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];

    // convert it to container view's coordinate space, since that's what we'll be animating
    CGPoint convertedPoint = [self.view convertPoint:point fromView:navigationCoordinator.navigationController.view];
    CGPoint currentPoint = self.containerView.center;
    CGFloat xOffset = convertedPoint.x - currentPoint.x;
    CGFloat yOffset = convertedPoint.y - currentPoint.y;

    // apply the points immediately and animate to center of screen
    self.containerViewCenterXConstraint.constant = xOffset;
    self.containerViewCenterYConstraint.constant = yOffset;

    // apply new constraints immediately
    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];
}

- (void)navigationCoordinator:(ALNavigationCoordinator *)navigationCoordinator willHideViewControllerFromPoint:(CGPoint)point
{
    if (self.viewModel.disappearingAnimation == ALMenuViewControllerDisappearingAnimationNone)
    {
        return;
    }

    // convert it to container view's coordinate space, since that's what we'll be animating
    CGPoint convertedPoint = [self.view convertPoint:point fromView:navigationCoordinator.navigationController.view];
    CGPoint currentPoint = self.containerView.center;
    CGFloat xOffset = convertedPoint.x - currentPoint.x;
    CGFloat yOffset = convertedPoint.y - currentPoint.y;

    // save the point for later to animate away from center of screen
    self.transformXOffset = xOffset;
    self.transformYOffset = yOffset;
}

#pragma mark - View layout

- (void)buildView
{
    NSUInteger numberOfItems = [self.viewModel numberOfItems];

    if (numberOfItems == 0)
    {
        return;
    }
    
    self.containerView = [[UIView<ALMenuItem> alloc] init];
    self.containerView.backgroundColor = [UIColor clearColor];
    self.containerView.translatesAutoresizingMaskIntoConstraints = NO;
    self.containerView.clipsToBounds = NO;

    // setup container view and constrain
    [self.view addSubview:self.containerView];

    self.containerViewCenterXConstraint = [self.containerView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor];
    self.containerViewCenterXConstraint.priority = UILayoutPriorityRequired;
    self.containerViewCenterXConstraint.active = YES;

    self.containerViewCenterYConstraint = [self.containerView.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor];
    self.containerViewCenterYConstraint.priority = UILayoutPriorityRequired;
    self.containerViewCenterYConstraint.active = YES;

    // setup collection view
    ALMenuCollectionViewLayout *layout = [[ALMenuCollectionViewLayout alloc] init];
    layout.delegate = self;
    layout.itemSize = self.viewModel.layout.itemSize;
    layout.itemSpacing = self.viewModel.layout.itemSpacing;
    layout.numberOfColumns = self.viewModel.layout.columns;
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.clipsToBounds = NO;
    self.collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;

    [self.collectionView registerClass:[ALMenuCollectionViewCell class] forCellWithReuseIdentifier:kCollectionViewCellReuseIdentifier];

    [self.containerView addSubview:self.collectionView];
    [self.collectionView al_pinToSuperview];

    self.containerViewWidthConstraint = [self.containerView.widthAnchor constraintEqualToConstant:self.collectionView.contentSize.width];
    self.containerViewWidthConstraint.active = YES;

    self.containerViewHeightConstraint = [self.containerView.heightAnchor constraintEqualToConstant:self.collectionView.contentSize.height];
    self.containerViewHeightConstraint.active = YES;
}

- (void)reloadCollectionView
{
    [self.collectionView.collectionViewLayout invalidateLayout];
    [self.collectionView reloadData];
}

#pragma mark - ALMenuCollectionViewLayoutDelegate

- (void)menuCollectionViewLayout:(ALMenuCollectionViewLayout *)layout didChangeSize:(CGSize)newSize
{
    self.containerViewWidthConstraint.constant = newSize.width;
    self.containerViewHeightConstraint.constant = newSize.height;
}

#pragma mark - UICollectionViewDelegate

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

#pragma mark - UICollectionViewDataSource

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UIView<ALMenuItem> *button = [self.viewModel itemAtIndex:indexPath.row];
    button.delegate = self;

    ALMenuCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCollectionViewCellReuseIdentifier forIndexPath:indexPath];
    cell.button = button;

    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    ALMenuCollectionViewCell *c = (id)cell;
    c.button = nil;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.viewModel numberOfItems];
}

#pragma mark - Subview animations

- (NSArray<UIView<ALMenuItem> *> *)viewsForAppearingAnimation
{
    ALMenuViewControllerAppearingAnimation appearingAnimation = self.viewModel.appearingAnimation;
    NSArray<UIView<ALMenuItem> *> *views = nil;

    if (appearingAnimation == ALMenuViewControllerAppearingAnimationIndividual)
    {
        views = self.viewModel.items;
    }
    else if (appearingAnimation == ALMenuViewControllerAppearingAnimationOrigin
             || appearingAnimation == ALMenuViewControllerAppearingAnimationCenter)
    {
        views = @[self.containerView];
    }

    return views;
}

- (void)handleViewAnimationsForViewWillAppear
{
    if (self.viewModel.appearingAnimation == ALMenuViewControllerAppearingAnimationNone)
    {
        return;
    }

    NSArray<UIView *> *views = [self viewsForAppearingAnimation];

    [self prepareForAppearingAnimationForViews:views];

    if (self.viewModel.appearingAnimation == ALMenuViewControllerAppearingAnimationOrigin)
    {
        NSParameterAssert(views.count == 1);

        // perform animation immediately for container view if we have an origin item
        // appearance animation set
        //
        NSParameterAssert(self.containerViewCenterXConstraint.constant != 0.f && self.containerViewCenterYConstraint.constant != 0.f);

        self.containerViewCenterXConstraint.constant = 0.f;
        self.containerViewCenterYConstraint.constant = 0.f;

        [self
         executeAppearingAnimationForViews:views
         duration:kContainerViewAppearingAnimationDuration
         additionalAnimations:^{
             [self.view layoutIfNeeded];
         }
         completion:^{
             [self cleanupAfterAnimations];
         }];
    }
}

- (void)handleViewAnimationsForViewDidAppear
{
    if (self.viewModel.appearingAnimation == ALMenuViewControllerAppearingAnimationNone
        || self.viewModel.appearingAnimation == ALMenuViewControllerAppearingAnimationOrigin)
    {
        return;
    }

    // the None animation already took place in handleViewAnimationsForViewWillAppear
    [self executeAppearingAnimationForViews:[self viewsForAppearingAnimation] duration:kItemAppearanceAnimationDuration];
}

- (void)handleViewAnimationsForViewWillDisappear
{
    if (self.viewModel.disappearingAnimation == ALMenuViewControllerDisappearingAnimationNone)
    {
        return;
    }

    [self executeDisappearingAnimationForContainerViewWithCompletion:^(BOOL finished) {
        [self cleanupAfterAnimations];
    }];
}

- (void)handleViewAnimationsForViewDidDisappear
{
    // do nothing
}

- (void)prepareForAppearingAnimationForViews:(NSArray<UIView *> *)views
{
    for (UIView *view in views)
    {
        view.transform = CGAffineTransformScale(CGAffineTransformIdentity, AL_SCALE_ZERO, AL_SCALE_ZERO);
    }
}

- (void)executeAppearingAnimationForViews:(NSArray<UIView *> *)views duration:(NSTimeInterval)duration
{
    [self executeAppearingAnimationForViews:views duration:duration additionalAnimations:nil completion:nil];
}

- (void)executeAppearingAnimationForViews:(NSArray<UIView *> *)views duration:(NSTimeInterval)duration additionalAnimations:(void (^) (void))additionalAnimations completion:(void (^) (void))completion
{
    NSTimeInterval delay = 0.;

    for (NSInteger i = 0; i < views.count; i++)
    {
        UIView *view = views[i];

        void (^actualAnimations)(void) = ^{
            view.transform = CGAffineTransformIdentity;
            if (additionalAnimations != nil)
            {
                additionalAnimations();
            }
        };

        void (^actualCompletion)(BOOL) = ^(BOOL finished) {
            if ((i == views.count - 1) && completion != nil)
            {
                completion();
            }
        };

        [UIView animateWithDuration:duration
                              delay:delay
             usingSpringWithDamping:kItemAppearanceAnimationDamping
              initialSpringVelocity:kItemAppearanceAnimationVelocity
                            options:UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionBeginFromCurrentState
                         animations:actualAnimations
                         completion:actualCompletion];

        delay += kItemAppearanceAnimationDelay;
    }
}

- (void)executeDisappearingAnimationForContainerViewWithCompletion:(void (^) (BOOL))completion
{
    NSParameterAssert(self.transformXOffset != 0.f && self.transformYOffset != 0.f);

    self.containerViewCenterXConstraint.constant = self.transformXOffset;
    self.containerViewCenterYConstraint.constant = self.transformYOffset;

    [UIView animateWithDuration:kContainerViewDisappearingAnimationDuration
                          delay:0.
                        options:UIViewAnimationOptionCurveEaseIn|UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         // animate constraints
                         [self.view layoutIfNeeded];

                         // and animate transform
                         self.containerView.transform = CGAffineTransformScale(CGAffineTransformIdentity, AL_SCALE_ZERO, AL_SCALE_ZERO);
                     }
                     completion:completion];
}

- (void)cleanupAfterAnimations
{
    // reset transform
    self.containerView.transform = CGAffineTransformIdentity;

    // then reset the constraint points
    self.containerViewCenterXConstraint.constant = 0.f;
    self.containerViewCenterYConstraint.constant = 0.f;

    self.transformXOffset = 0.f;
    self.transformYOffset = 0.f;
}

#pragma mark - Status bar

- (BOOL)prefersStatusBarHidden
{
    if (self.viewModel.shouldHideStatusBar == NO)
    {
        return NO;
    }

    return [self isStatusBarHidden];
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation
{
    return UIStatusBarAnimationSlide;
}

- (void)showStatusBarAnimated:(BOOL)animated
{
    [self toggleStatusBar:YES animated:animated];
}

- (void)hideStatusBarAnimated:(BOOL)animated
{
    [self toggleStatusBar:NO animated:animated];
}

- (void)toggleStatusBar:(BOOL)show animated:(BOOL)animated
{
    NSParameterAssert(self.viewModel.shouldHideStatusBar);
    self.statusBarHidden = show == NO;
    
    [UIView animateWithDuration:animated ? kStatusBarAnimationDuration : 0. animations:^{
        [self setNeedsStatusBarAppearanceUpdate];
    }];
}

#pragma mark - ALMenuItemDelegate

- (void)buttonWasTapped:(UIView<ALMenuItem> *)button
{
    [self.delegate menuViewController:self didSelectOptionAtIndex:[self.viewModel indexOfItem:button]];
}

#pragma mark - Rotation

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [self reloadCollectionView];
}

@end
