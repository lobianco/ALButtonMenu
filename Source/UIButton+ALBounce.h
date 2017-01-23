//
//  UIButton+ALBounce.h
//  ALButtonMenu
//
//  Copyright © 2016 Anthony Lobianco. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (ALBounce)

@property (nonatomic, getter=isSpringy) BOOL springy;

- (void)al_transformToSize:(CGFloat)size duration:(NSTimeInterval)duration;
- (void)al_transformToSize:(CGFloat)size duration:(NSTimeInterval)duration alongsideAnimations:(void (^) (void))animations;
- (void)al_transformToSize:(CGFloat)size duration:(NSTimeInterval)duration alongsideAnimations:(void (^) (void))animations completion:(void (^) (BOOL))completion;

- (void)al_restoreWithDuration:(NSTimeInterval)duration;
- (void)al_restoreWithDuration:(NSTimeInterval)duration alongsideAnimations:(void (^) (void))animations;
- (void)al_restoreWithDuration:(NSTimeInterval)duration alongsideAnimations:(void (^) (void))animations completion:(void (^) (BOOL))completion;

@end
