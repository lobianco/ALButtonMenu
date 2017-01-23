//
//  ALButtonViewModel_ALPrivate.h
//  ALButtonMenu
//
//  Copyright © 2017 Anthony Lobianco. All rights reserved.
//

#import "ALButtonViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@class ALButtonViewModel;

@protocol ALButtonViewModelDelegate <NSObject>

- (void)viewModelDidUpdate:(ALButtonViewModel *)viewModel;

@end

@interface ALButtonViewModel ()

@property (nonatomic) BOOL canReposition;
@property (nonatomic, weak) id<ALButtonViewModelDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
