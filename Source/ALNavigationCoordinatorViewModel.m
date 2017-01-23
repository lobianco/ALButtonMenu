//
//  ALNavigationCoordinatorViewModel.m
//  ALButtonMenu
//
//  Copyright © 2016 Anthony Lobianco. All rights reserved.
//

#import "ALNavigationCoordinatorViewModel.h"

#import "ALUtils.h"

static NSInteger const kDefaultSnappingLocations = ALNavigationCoordinatorSnapLocationCorners;
static CGFloat const kDefaultSnapPadding = 60.f;
static CGFloat const kDefaultButtonSize = 50.f;
static CGFloat const kDefaultButtonTouchArea = 10.f;
static CGFloat const kButtonActiveWhiteValue = 0.9f;
static CGFloat const kButtonDefaultWhiteValue = 0.1f;

@implementation ALNavigationCoordinatorViewModel

- (instancetype)init
{
    AL_INIT([super init]);

    [self configureDefaults];

    return self;
}

- (void)configureDefaults
{
    _buttonActiveColor = [UIColor colorWithWhite:kButtonActiveWhiteValue alpha:1.f];
    _buttonCanBeRepositioned = NO;
    _buttonDefaultColor = [UIColor colorWithWhite:kButtonDefaultWhiteValue alpha:1.f];
    _buttonShouldShowShadowDuringReposition = YES;
    _buttonSize = CGSizeMake(kDefaultButtonSize, kDefaultButtonSize);
    _buttonPath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0.f, 0.f, _buttonSize.width, _buttonSize.height)];
    _buttonTouchArea = kDefaultButtonTouchArea;
    _initialSnapLocation = ALNavigationCoordinatorSnapLocationBottomLeft;
    _rootControllerAppearingAnimation = ALNavigationCoordinatorAnimationOrigin;
    _rootControllerDisappearingAnimation = ALNavigationCoordinatorAnimationOrigin;
    _snapLocations = kDefaultSnappingLocations;
    _snapPadding = kDefaultSnapPadding;
}

@end
