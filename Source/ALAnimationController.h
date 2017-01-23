//
//  ALAnimationController.h
//  ALButtonMenu
//
//  Copyright © 2016 Anthony Lobianco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "ALNavigationCoordinatorViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@class ALAnimationController;

@protocol ALAnimationControllerDelegate <NSObject>

@optional

- (void)animationController:(ALAnimationController *)animationController didShowViewController:(UIViewController *)viewController;
- (void)animationController:(ALAnimationController *)animationController didHideViewController:(UIViewController *)viewController;

@end

@interface ALAnimationController : NSObject <UIViewControllerAnimatedTransitioning>

@property (nonatomic) ALNavigationCoordinatorAnimation appearingAnimation;
@property (nonatomic) ALNavigationCoordinatorAnimation disappearingAnimation;
@property (nullable, nonatomic, weak) id<ALAnimationControllerDelegate> delegate;
@property (nonatomic) CAShapeLayer *initialShapeLayer;
@property (nonatomic, getter=isPresenting) BOOL presenting;

@end

NS_ASSUME_NONNULL_END
