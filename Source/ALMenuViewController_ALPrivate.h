//
//  ALMenuViewController_ALPrivate.h
//  ALButtonMenu
//
//  Copyright © 2016 Anthony Lobianco. All rights reserved.
//

#import "ALMenuViewController.h"

@class ALNavigationCoordinator;

@interface ALMenuViewController ()

// point will be in navigation controller's coordinate space
- (void)navigationCoordinator:(ALNavigationCoordinator *)navigationCoordinator willShowViewControllerFromPoint:(CGPoint)point;
- (void)navigationCoordinator:(ALNavigationCoordinator *)navigationCoordinator willHideViewControllerFromPoint:(CGPoint)point;

@end
