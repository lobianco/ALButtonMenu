//
//  ALButton.m
//  ALButtonMenu
//
//  Copyright © 2016 Anthony Lobianco. All rights reserved.
//

#import "ALButton_ALPrivate.h"

#import "UIBezierPath+ALScaling.h"
#import "UIButton+ALBounce.h"

#import "ALUtils.h"

static NSTimeInterval const kButtonScaleAnimationDuration = 0.25;
static CGFloat const kButtonShrinkScaleFactor = 0.9f;

@interface ALButton () <ALButtonViewModelDelegate, UIGestureRecognizerDelegate>

@property (nonatomic) CGSize configuredMaskSize;
@property (nonatomic) UIImageView *imgView;
@property (nonatomic) CALayer *maskContainerLayer;
@property (nonatomic) ALTouchGestureRecognizer *touchGestureRecognizer;

@end

@implementation ALButton

@synthesize delegate = _delegate;

- (instancetype)initWithViewModel:(ALButtonViewModel *)viewModel
{
    AL_INIT([super initWithFrame:CGRectZero]);

    _viewModel = viewModel;
    _viewModel.delegate = self;

    self.backgroundColor = [UIColor clearColor];

    [self configureGestureRecognizers];

    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    NSAssert(NO, @"Hello there! Please use designated initializer.");
    AL_INIT([self initWithViewModel:[ALButtonViewModel new]]);
    return nil;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    NSAssert(NO, @"Hello there! Please use designated initializer.");
    AL_INIT([self initWithViewModel:[ALButtonViewModel new]]);
    return nil;
}

- (UIBezierPath *)scaledMaskPath
{
    return [self.viewModel.maskPath al_scaledToRect:self.bounds]; // bounds, not frame
}

- (void)didMoveToSuperview
{
    [super didMoveToSuperview];

    [self updateValues];
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    if (self.imgView != nil)
    {
        self.imgView.frame = CGRectMake(0.f, 0.f, self.frame.size.width, self.frame.size.height);
    }
}

- (void)layoutSublayersOfLayer:(CALayer *)layer
{
    [super layoutSublayersOfLayer:layer];

    if (CGSizeEqualToSize(layer.bounds.size, CGSizeZero))
    {
        // wait until the view has been layed out
        return;
    }

    if ([self needsToUpdateMask])
    {
        [self removeMask];
        [self applyMaskIfNecessary];
    }

    // update color outside above conditional to save on CPU cycles
    if (self.maskContainerLayer != nil)
    {
        self.backgroundColor = [UIColor clearColor];
        self.maskContainerLayer.backgroundColor = [self.viewModel.color CGColor];
    }
    else
    {
        self.backgroundColor = self.viewModel.color;
    }
}

- (void)updateValues
{
    [self updateImageIfNecessary];

    [self.layer setNeedsLayout];
    [self.layer layoutIfNeeded];
}

- (void)updateImageIfNecessary
{
    if (self.viewModel.image == nil)
    {
        [self.imgView removeFromSuperview];
    }
    else
    {
        if (self.imgView == nil)
        {
            self.imgView = [[UIImageView alloc] initWithImage:self.viewModel.image];

            // add to view heirarchy
            [self addSubview:self.imgView];
        }
        else
        {
            self.imgView.image = self.viewModel.image;
        }
    }
}

#pragma mark - Masking

- (void)removeMask
{
    // remove old mask layer
    [self.maskContainerLayer removeFromSuperlayer];

    // nil out values for future needsToUpdateMaskContainerLayer checks
    self.maskContainerLayer = nil;
    self.configuredMaskSize = CGSizeZero;
}

- (void)applyMaskIfNecessary
{
    if ([self shouldMask] == NO)
    {
        return;
    }

    // apply a mask layer to a container layer, so we can clip ourself
    // to the provided path shape but still be able to apply a shadow
    // if desired.
    //

    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.path = self.scaledMaskPath.CGPath;
    maskLayer.bounds = self.bounds;
    maskLayer.position = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));

    self.maskContainerLayer = [CALayer layer];
    self.maskContainerLayer.bounds = self.bounds;
    self.maskContainerLayer.position = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    self.maskContainerLayer.mask = maskLayer;

    self.configuredMaskSize = self.bounds.size;

    // send it to the back so other subviews can still appear above it
    [self.layer insertSublayer:self.maskContainerLayer atIndex:0];
}

- (BOOL)needsToUpdateMask
{
    BOOL hasMask = self.maskContainerLayer != nil;
    BOOL shouldMask = [self shouldMask];

    if (hasMask != shouldMask)
    {
        return YES;
    }

    if (shouldMask && CGSizeEqualToSize(self.configuredMaskSize, self.bounds.size) == NO)
    {
        return YES;
    }

    return NO;
}

- (BOOL)shouldMask
{
    return self.viewModel.maskPath != nil;
}

#pragma mark - Gestures

- (void)configureGestureRecognizers
{
    self.touchGestureRecognizer = [[ALTouchGestureRecognizer alloc] initWithTarget:self action:@selector(handleTouchGesture:)];
    self.touchGestureRecognizer.delegate = self;

    [self addGestureRecognizer:self.touchGestureRecognizer];
}

- (void)handleTouchGesture:(ALTouchGestureRecognizer *)sender
{
    switch (sender.state)
    {
        case UIGestureRecognizerStateBegan:
        {
            if (self.viewModel.bounces)
            {
                [self al_transformToSize:kButtonShrinkScaleFactor duration:kButtonScaleAnimationDuration];
            }

            break;
        }
        case UIGestureRecognizerStateEnded:
        {
            if (self.viewModel.bounces && self.viewModel.bouncesOnTouchUp)
            {
                [self al_restoreWithDuration:kButtonScaleAnimationDuration];
            }

            if ([self.delegate respondsToSelector:@selector(buttonWasTapped:)])
            {
                [self.delegate buttonWasTapped:self];
            }

            break;
        }
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
        {
            if (self.viewModel.bounces)
            {
                [self al_restoreWithDuration:kButtonScaleAnimationDuration];
            }
            
            break;
        }
        case UIGestureRecognizerStateChanged:
        case UIGestureRecognizerStatePossible:
        {
            // do nothing
            break;
        }
    }
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

#pragma mark - ALButtonViewModelDelegate

- (void)viewModelDidUpdate:(ALButtonViewModel *)viewModel
{
    [self updateValues];
}

#pragma mark - Hit tests

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *view = [super hitTest:point withEvent:event];
    return (view == self || [self.subviews containsObject:view]) ? self : view;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    return CGRectContainsPoint(CGRectInset(self.bounds, -(self.viewModel.touchArea), -(self.viewModel.touchArea)), point);
}

@end
