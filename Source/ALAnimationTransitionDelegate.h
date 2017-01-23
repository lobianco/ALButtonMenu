//
//  ALAnimationTransition.h
//  ALButtonMenu
//
//  Copyright © 2016 Anthony Lobianco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "ALNavigationCoordinatorViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@class ALAnimationTransitionDelegate;

// hey dawg, i heard you like delegates
@protocol ALAnimationTransitionDelegateDelegate <NSObject>

@optional

// always referring to the VC on the top of the stack
- (void)transitionDelegate:(ALAnimationTransitionDelegate *)transitionDelegate didShowViewController:(UIViewController *)viewController;
- (void)transitionDelegate:(ALAnimationTransitionDelegate *)transitionDelegate didHideViewController:(UIViewController *)viewController;

@end

@interface ALAnimationTransitionDelegate : NSObject <UINavigationControllerDelegate>

@property (nonatomic) ALNavigationCoordinatorAnimation appearingAnimation;
@property (nonatomic, weak) id<ALAnimationTransitionDelegateDelegate> delegate;
@property (nonatomic) ALNavigationCoordinatorAnimation disappearingAnimation;
@property (nonatomic) CAShapeLayer *initialShapeLayer;
@property (nonatomic) Class viewControllerClassForCustomAnimations;

- (instancetype)initWithNavigationControllerDelegate:(nullable id<UINavigationControllerDelegate>)delegate;

@end

NS_ASSUME_NONNULL_END
