//
//  UIView+ALLayout.h
//  ALButtonMenu
//
//  Copyright © 2016 Anthony Lobianco. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (ALLayout)

#pragma mark - Positioning

- (void)al_adjustPositionForNewAnchorPoint:(CGPoint)anchorPoint;

#pragma mark - Auto Layout

- (void)al_pinToSuperview;
- (void)al_pinToView:(UIView *)view;

@end
