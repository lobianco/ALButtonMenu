//
//  ALButton.h
//  ALButtonMenu
//
//  Copyright © 2016 Anthony Lobianco. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ALMenuItem.h"

NS_ASSUME_NONNULL_BEGIN

@class ALButtonViewModel;

@interface ALButton : UIButton <ALMenuItem>

@property (nullable, nonatomic, readonly) UIBezierPath *scaledMaskPath;
@property (nonatomic, readonly) ALButtonViewModel *viewModel;

- (instancetype)initWithViewModel:(ALButtonViewModel *)viewModel NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
