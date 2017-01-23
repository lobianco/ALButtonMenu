//
//  ALMenuButton.h
//  ALButtonMenu
//
//  Copyright © 2016 Anthony Lobianco. All rights reserved.
//

#import "ALButton.h"

NS_ASSUME_NONNULL_BEGIN

@class ALMenuButton;

@protocol ALMenuButtonDelegate <ALMenuItemDelegate>

@optional

- (void)buttonBeganLongPress:(ALMenuButton *)button atLocation:(CGPoint)location;
- (void)buttonLongPressedMoved:(ALMenuButton *)button toLocation:(CGPoint)location;
- (void)buttonEndedLongPress:(ALMenuButton *)button;

@end

@interface ALMenuButton : ALButton

@property (nullable, nonatomic, weak) id<ALMenuButtonDelegate> delegate;
@property (nonatomic) CGSize shadowOffset;

- (void)setShadowHidden:(BOOL)hidden animated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
