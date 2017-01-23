//
//  ALMenuViewController.h
//  ALButtonMenu
//
//  Copyright © 2016 Anthony Lobianco. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ALMenuViewControllerViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ALMenuViewController;

@protocol ALMenuViewControllerDelegate <NSObject>

- (void)menuViewController:(UIViewController<ALMenuViewController> *)menuViewController didSelectOptionAtIndex:(NSUInteger)index;

@end

@protocol ALMenuViewController <NSObject>

// this delegate should be considered readonly. use it only to forward the protocol messages above.
@property (nullable, nonatomic, weak) id<ALMenuViewControllerDelegate> delegate;

@end

@interface ALMenuViewController : UIViewController <ALMenuViewController>

@property (nonatomic, readonly) ALMenuViewControllerViewModel *viewModel;

- (instancetype)initWithViewModel:(ALMenuViewControllerViewModel *)viewModel;

@end

NS_ASSUME_NONNULL_END
