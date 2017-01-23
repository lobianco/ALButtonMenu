//
//  ALMenuItem.h
//  ALButtonMenu
//
//  Copyright © 2016 Anthony Lobianco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ALMenuItem;

@protocol ALMenuItemDelegate <NSObject>

- (void)buttonWasTapped:(UIView<ALMenuItem> *)button;

@end

@protocol ALMenuItem <NSObject>

@property (nullable, nonatomic, weak) id<ALMenuItemDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
