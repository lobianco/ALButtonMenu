//
//  ALNavigationCoordinator.h
//  ALButtonMenu
//
//  Copyright © 2016 Anthony Lobianco. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ALMenuViewController.h"
#import "ALNavigationCoordinatorViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@class ALNavigationCoordinator;

@protocol ALNavigationCoordinatorDelegate <UINavigationControllerDelegate>

- (UIViewController *)navigationCoordinator:(ALNavigationCoordinator *)navigationCoordinator viewControllerForMenuItemAtIndex:(NSUInteger)index;

@end

@interface ALNavigationCoordinator : NSObject

/**
 This delegate will also forward UINavigationControllerDelegate callbacks for the navigationController from init.
 */
@property (nullable, nonatomic, weak) id<ALNavigationCoordinatorDelegate> delegate;

/**
 Can be an instance of [ALMenuViewController class] or any custom subclass that inherits from <ALMenuViewController>.
 */
@property (nonatomic, readonly) UIViewController<ALMenuViewController> *menuViewController;

/**
 You will not be able to register as this object's delegate because ALNavigationCoordinator will hijack it,
 but if register as id<ALNavigationCoordinatorDelegate> delegate above then you will also receive forwarded
 UINavigationControllerDelegate callbacks (if you decide to implement them). Add this object as a child
 view controller of your own view controller.
 */
@property (nonatomic, readonly) UINavigationController *navigationController;

/**
 The viewModel object provided in init.
 */
@property (nonatomic, readonly) ALNavigationCoordinatorViewModel *viewModel;

- (instancetype)initWithViewModel:(ALNavigationCoordinatorViewModel *)viewModel menuViewController:(UIViewController<ALMenuViewController> *)menuViewController rootViewController:(UIViewController *)rootViewController;

- (instancetype)initWithViewModel:(ALNavigationCoordinatorViewModel *)viewModel menuViewController:(UIViewController<ALMenuViewController> *)menuViewController navigationController:(UINavigationController *)navigationController;

/**
 These methods should be called from the respective methods of navigationController's parent view controller. 
 */
- (void)viewDidLoad;
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator;

@end

NS_ASSUME_NONNULL_END
