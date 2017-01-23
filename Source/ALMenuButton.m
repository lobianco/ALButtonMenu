//
//  ALMenuButton.m
//  ALButtonMenu
//
//  Copyright © 2016 Anthony Lobianco. All rights reserved.
//

#import "ALMenuButton.h"
#import "ALButton_ALPrivate.h"

#import "ALUtils.h"

static NSTimeInterval const kLongPressMinimumDuration = 0.3;
static NSTimeInterval const kButtonShadowAnimationDuration = 0.1;
static CGFloat const kButtonShadowAlpha = 0.4f;
static CGFloat const kButtonShadowRadius = 0.f;

@interface ALMenuButton () <UIGestureRecognizerDelegate>

@property (nonatomic) UILongPressGestureRecognizer *longPressGestureRecognizer;
@property (nonatomic, getter=isShadowHidden) BOOL shadowHidden;

@end

@implementation ALMenuButton

@dynamic delegate;

- (instancetype)initWithViewModel:(ALButtonViewModel *)viewModel
{
    AL_INIT([super initWithViewModel:viewModel]);

    _shadowHidden = YES;

    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowRadius = kButtonShadowRadius;

    return self;
}

- (void)viewModelDidUpdate:(ALButtonViewModel *)viewModel
{
    [super viewModelDidUpdate:viewModel];

    [self updateGestureEnabled];
}

- (void)layoutSublayersOfLayer:(CALayer *)layer
{
    [super layoutSublayersOfLayer:layer];

    // always keep the shadow path updated here 
    self.layer.shadowPath = self.scaledMaskPath.CGPath ?: [UIBezierPath bezierPathWithRect:self.bounds].CGPath;
}

#pragma mark - Shadow

- (void)setShadowOffset:(CGSize)shadowOffset
{
    self.layer.shadowOffset = shadowOffset;
}

- (void)setShadowHidden:(BOOL)hidden animated:(BOOL)animated
{
    if (_shadowHidden == hidden)
    {
        return;
    }

    _shadowHidden = hidden;

    void (^animateShadow)(CGFloat, CGFloat) = ^(CGFloat from, CGFloat to) {
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"shadowOpacity"];
        animation.fromValue = @(from);
        animation.toValue = @(to);
        animation.duration = kButtonShadowAnimationDuration;

        [self.layer addAnimation:animation forKey:@"shadowOpacity"];
    };

    if (_shadowHidden)
    {
        if (animated)
        {
            animateShadow(kButtonShadowAlpha, 0.f);
        }

        self.layer.shadowOpacity = 0.f;
    }
    else
    {
        if (animated)
        {
            animateShadow(0.f, kButtonShadowAlpha);
        }

        self.layer.shadowOpacity = kButtonShadowAlpha;
    }
}

#pragma mark - Gestures

- (void)configureGestureRecognizers
{
    [super configureGestureRecognizers];

    self.longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGesture:)];
    self.longPressGestureRecognizer.minimumPressDuration = kLongPressMinimumDuration;
    self.longPressGestureRecognizer.delegate = self;

    [self addGestureRecognizer:self.longPressGestureRecognizer];

    [self updateGestureEnabled];
}

- (void)updateGestureEnabled
{
    self.longPressGestureRecognizer.enabled = self.viewModel.canReposition;
}

- (void)handleLongPressGesture:(UILongPressGestureRecognizer *)sender
{
    CGPoint location = [sender locationInView:self];

    switch (sender.state)
    {
        case UIGestureRecognizerStateBegan:
        {
            // cancel the touch gesture so it doesn't fire when our touch ends
            [self.touchGestureRecognizer cancel];

            if ([self.delegate respondsToSelector:@selector(buttonBeganLongPress:atLocation:)])
            {
                [self.delegate buttonBeganLongPress:self atLocation:location];
            }

            break;
        }
        case UIGestureRecognizerStateChanged:
        {
            if ([self.delegate respondsToSelector:@selector(buttonLongPressedMoved:toLocation:)])
            {
                [self.delegate buttonLongPressedMoved:self toLocation:location];
            }

            break;
        }
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
        {
            if ([self.delegate respondsToSelector:@selector(buttonEndedLongPress:)])
            {
                [self.delegate buttonEndedLongPress:self];
            }

            break;
        }
        case UIGestureRecognizerStatePossible:
        {
            // do nothing
            break;
        }
    }
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer == self.longPressGestureRecognizer)
    {
        // don't active long press if the touch gesture was cancelled
        return self.touchGestureRecognizer.state == UIGestureRecognizerStateBegan;
    }

    return YES;
}

@end
