//
//  ALButton_ALPrivate.h
//  ALButtonMenu
//
//  Copyright © 2016 Anthony Lobianco. All rights reserved.
//

#import "ALButton.h"

#import "ALTouchGestureRecognizer.h"
#import "ALButtonViewModel_ALPrivate.h"

@interface ALButton (Private)

@property (nonatomic, readonly) ALTouchGestureRecognizer *touchGestureRecognizer;

- (void)configureGestureRecognizers NS_REQUIRES_SUPER;
- (void)viewModelDidUpdate:(ALButtonViewModel *)viewModel NS_REQUIRES_SUPER;

@end
