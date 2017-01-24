//
//  UIColor+ALComplementary.m
//  ALButtonMenu
//
//  Copyright © 2016 Anthony Lobianco. All rights reserved.
//

#import "UIColor+ALComplementary.h"

@implementation UIColor (ALComplementary)

- (UIColor *)al_complementaryColor
{
    return [self al_complementaryColorWithAlpha:1.f];
}

- (UIColor *)al_complementaryColorWithAlpha:(CGFloat)alpha
{
    CGFloat r, g, b;
    [self getRed:&r green:&g blue:&b alpha:nil];
    
    return [UIColor colorWithRed:(1.f - r) green:(1.f - g) blue:(1.f - b) alpha:alpha];
}

- (UIColor *)al_neutralColor
{
    CGFloat r, g, b;
    [self getRed:&r green:&g blue:&b alpha:nil];

    NSUInteger red = ((r * 255.f) + 256) / 2;
    NSUInteger green = ((g * 255.f) + 256) / 2;
    NSUInteger blue = ((b * 255.f) + 256) / 2;

    return [UIColor colorWithRed:(red / 255.f) green:(green / 255.f) blue:(blue / 255.f) alpha:1.f];
}

+ (UIColor *)al_neutralColor
{
    NSUInteger red = arc4random_uniform(255);
    NSUInteger green = arc4random_uniform(255);
    NSUInteger blue = arc4random_uniform(255);

    return [[UIColor colorWithRed:(red / 255.f) green:(green / 255.f) blue:(blue / 255.f) alpha:1.f] al_neutralColor];
}

@end
