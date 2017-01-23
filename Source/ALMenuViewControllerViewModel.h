//
//  ALMenuViewControllerViewModel.h
//  ALButtonMenu
//
//  Copyright © 2016 Anthony Lobianco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "ALMenuItem.h"

NS_ASSUME_NONNULL_BEGIN

struct ALMenuViewControllerLayout
{
    NSUInteger columns;
    CGSize itemSize;
    CGFloat itemSpacing;
};

typedef struct ALMenuViewControllerLayout ALMenuViewControllerLayout;

typedef NS_ENUM(NSUInteger, ALMenuViewControllerAppearingAnimation)
{
    // no animation
    ALMenuViewControllerAppearingAnimationNone = 0,

    // the menu items will simultaneously expand outward from the menu button's center.
    ALMenuViewControllerAppearingAnimationOrigin,

    // the menu items will appear simultaneously from the center of the screen.
    ALMenuViewControllerAppearingAnimationCenter,

    // the menu items will appear individually.
    ALMenuViewControllerAppearingAnimationIndividual,
};

typedef NS_ENUM(NSUInteger, ALMenuViewControllerDisappearingAnimation)
{
    // no animation
    ALMenuViewControllerDisappearingAnimationNone = 0,

    // the menu items will contract simultaneously towards the menu button's center.
    ALMenuViewControllerDisappearingAnimationOrigin,
};

@protocol ALMenuViewControllerViewModel <NSObject>

/**
 The animation type for presenting the menu view controller when the menu is being shown.
 
 Default is ALMenuViewControllerAppearingAnimationIndividual.
 */
@property (nonatomic) ALMenuViewControllerAppearingAnimation appearingAnimation;

/**
 The animation type for dismissing the menu view controller when the menu is hiding.
 
 Default is ALMenuViewControllerDisappearingAnimationOrigin.
 */
@property (nonatomic) ALMenuViewControllerDisappearingAnimation disappearingAnimation;


/**
 Should the status bar be hidden when the menu is shown. 
 
 Default is YES.
 */
@property (nonatomic) BOOL shouldHideStatusBar;

- (NSUInteger)numberOfItems;
- (nullable UIView<ALMenuItem> *)itemAtIndex:(NSUInteger)index;
- (NSUInteger)indexOfItem:(UIView<ALMenuItem> *)item;

@end

@interface ALMenuViewControllerViewModel : NSObject <ALMenuViewControllerViewModel>

@property (nullable, nonatomic, readonly) NSArray<UIView<ALMenuItem> *> *items;

/**
 The layout details to use for the menu items.
 */
@property (nonatomic, readonly) ALMenuViewControllerLayout layout;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithItems:(nullable NSArray<UIView<ALMenuItem> *> *)items layout:(ALMenuViewControllerLayout)layout NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
