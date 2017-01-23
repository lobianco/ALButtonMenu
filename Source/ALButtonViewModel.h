//
//  ALButtonViewModel.h
//  ALButtonMenu
//
//  Copyright © 2016 Anthony Lobianco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ALButtonViewModel : NSObject

/**
 Should the button bounce on touch down.
 
 Default is YES.
 */
@property (nonatomic) BOOL bounces;

/**
 Should the button bounce on touch up. If bounces == NO, this value will be ignored.
 
 Default is YES.
 */
@property (nonatomic) BOOL bouncesOnTouchUp;

/**
 The button color.
 
 Default is black.
 */
@property (nonatomic) UIColor *color;

/**
 An optional image that can be displayed on the button.
 
 Default is nil.
 */
@property (nullable, nonatomic) UIImage *image;

/**
 A bezier path can be specified to give the button a custom shape. It will be scaled down to
 proportionally fit inside the button.
 
 Default is nil.
 */
@property (nullable, nonatomic) UIBezierPath *maskPath;

/**
 The distance outside of the button's bounds that will still register as a touch on the button.
 
 Default is 0.f.
 */
@property (nonatomic) CGFloat touchArea;

@end

NS_ASSUME_NONNULL_END
