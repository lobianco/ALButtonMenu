//
//  UIColor+ALComplementary.h
//  ALButtonMenu
//
//  Copyright © 2016 Anthony Lobianco. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (ALComplementary)

- (UIColor *)al_complementaryColor;
- (UIColor *)al_complementaryColorWithAlpha:(CGFloat)alpha;

- (UIColor *)al_neutralColor;
+ (UIColor *)al_neutralColor;

@end
