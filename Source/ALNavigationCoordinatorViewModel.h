//
//  ALNavigationCoordinatorViewModel.h
//  ALButtonMenu
//
//  Copyright © 2016 Anthony Lobianco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, ALNavigationCoordinatorAnimation)
{
    // no animation
    ALNavigationCoordinatorAnimationNone = 0,

    // the nav controller will expand away from the button's center when showing the menu and
    // contract towards the button's center when hiding the menu.
    //
    ALNavigationCoordinatorAnimationOrigin,
};

typedef NS_OPTIONS(NSInteger, ALNavigationCoordinatorSnapLocation)
{
    // none
    ALNavigationCoordinatorSnapLocationNone = 0,

    // individual positions
    ALNavigationCoordinatorSnapLocationTopLeft = (1UL << 0),
    ALNavigationCoordinatorSnapLocationTop = (1UL << 1),
    ALNavigationCoordinatorSnapLocationTopRight = (1UL << 2),
    ALNavigationCoordinatorSnapLocationRight = (1UL << 3),
    ALNavigationCoordinatorSnapLocationBottomRight = (1UL << 4),
    ALNavigationCoordinatorSnapLocationBottom = (1UL << 5),
    ALNavigationCoordinatorSnapLocationBottomLeft = (1UL << 6),
    ALNavigationCoordinatorSnapLocationLeft = (1UL << 7),
    ALNavigationCoordinatorSnapLocationMiddle = (1UL << 8),

    // edges
    ALNavigationCoordinatorSnapLocationAllTop = (ALNavigationCoordinatorSnapLocationTopLeft
                                                | ALNavigationCoordinatorSnapLocationTop
                                                | ALNavigationCoordinatorSnapLocationTopRight),

    ALNavigationCoordinatorSnapLocationAllRight = (ALNavigationCoordinatorSnapLocationTopRight
                                                  | ALNavigationCoordinatorSnapLocationRight
                                                  | ALNavigationCoordinatorSnapLocationBottomRight),

    ALNavigationCoordinatorSnapLocationAllBottom = (ALNavigationCoordinatorSnapLocationBottomRight
                                                   | ALNavigationCoordinatorSnapLocationBottom
                                                   | ALNavigationCoordinatorSnapLocationBottomLeft),

    ALNavigationCoordinatorSnapLocationAllLeft = (ALNavigationCoordinatorSnapLocationBottomLeft
                                                 | ALNavigationCoordinatorSnapLocationLeft
                                                 | ALNavigationCoordinatorSnapLocationTopLeft),

    // corners
    ALNavigationCoordinatorSnapLocationCorners = (ALNavigationCoordinatorSnapLocationTopLeft
                                                 | ALNavigationCoordinatorSnapLocationTopRight
                                                 | ALNavigationCoordinatorSnapLocationBottomRight
                                                 | ALNavigationCoordinatorSnapLocationBottomLeft),

    // all
    ALNavigationCoordinatorSnapLocationAll = (ALNavigationCoordinatorSnapLocationTopLeft
                                             | ALNavigationCoordinatorSnapLocationTop
                                             | ALNavigationCoordinatorSnapLocationTopRight
                                             | ALNavigationCoordinatorSnapLocationRight
                                             | ALNavigationCoordinatorSnapLocationBottomRight
                                             | ALNavigationCoordinatorSnapLocationBottom
                                             | ALNavigationCoordinatorSnapLocationBottomLeft
                                             | ALNavigationCoordinatorSnapLocationLeft
                                             | ALNavigationCoordinatorSnapLocationMiddle)
};

@protocol ALNavigationCoordinatorViewModelDataSource <NSObject>

/**
 Data source method to use in conjunction with ALNavigationCoordinatorModeReplace.

 @param index The index of the button that was tapped.

 @return The view controller that corresponds with that index. It will be set as the new root controller.
 */
- (UIViewController *)viewControllerForItemAtIndex:(NSUInteger)index;

@end

@interface ALNavigationCoordinatorViewModel : NSObject

/**
 The animation type for presenting the root controller when the menu is dismissed.

 Default is ALNavigationCoordinatorAnimationOrigin.
 */
@property (nonatomic) ALNavigationCoordinatorAnimation rootControllerAppearingAnimation;

/**
 The animation type for dismissing the root controller when the menu is presented.

 Default is ALNavigationCoordinatorAnimationOrigin.
 */
@property (nonatomic) ALNavigationCoordinatorAnimation rootControllerDisappearingAnimation;

/**
 The menu button's color when the menu is shown.

 Default is a pale white color.
 */
@property (nonatomic) UIColor *buttonActiveColor;

/**
 If YES, the menu button can be repositioned via long press. See snappingLocations below.

 Default is NO.
 */
@property (nonatomic) BOOL buttonCanBeRepositioned;

/**
 The menu button's color when the menu is not shown.

 Default is a dark grey color.
 */
@property (nonatomic) UIColor *buttonDefaultColor;

/**
 A bezier path can be specified to give the menu button a custom shape. It will be scaled down to 
 proportionally fit inside the button.

 Default is a circle path.
 */
@property (nullable, nonatomic) UIBezierPath *buttonPath;

/**
 Show a drop shadow while menu button is being dragged around (if buttonCanBeRepositioned is YES).
 
 Default is YES.
 */
@property (nonatomic) BOOL buttonShouldShowShadowDuringReposition;

/**
 The button's size.

 Default is { 50.f, 50.f }.
 */
@property (nonatomic) CGSize buttonSize;

/**
 The number of points outside the button's bounds that will still register as a touch on the button.

 Default is 10.f.
 */
@property (nonatomic) CGFloat buttonTouchArea;

/**
 The data source that will provide view controller information in conjunction with ALNavigationCoordinatorModeNotify.
 */
@property (nullable, nonatomic, weak) id<ALNavigationCoordinatorViewModelDataSource> dataSource;

/**
 The snap location that the button will initially begin at. If value is ALNavigationCoordinatorSnapLocationNone,
 the menu button's default position will be { x = snapPadding, y = snapPadding }.
 
 Default is ALNavigationCoordinatorSnapLocationBottomLeft.
 */
@property (nonatomic) ALNavigationCoordinatorSnapLocation initialSnapLocation;

/**
 The individual locations that the menu button will snap to if buttonCanBeRepositioned is YES.

 Default is ALNavigationCoordinatorSnapLocationCorners.
 */
@property (nonatomic) ALNavigationCoordinatorSnapLocation snapLocations;

/**
 The padding from the edge of the screen to the center of the button.
 
 Default is 60.f.
 */
@property (nonatomic) CGFloat snapPadding;

@end

NS_ASSUME_NONNULL_END
