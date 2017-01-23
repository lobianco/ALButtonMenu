//
//  ALMenuCollectionViewCell.h
//  ALButtonMenu
//
//  Copyright © 2017 Anthony Lobianco. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ALMenuItem;

@interface ALMenuCollectionViewCell : UICollectionViewCell

@property (nullable, nonatomic) UIView<ALMenuItem> *button;

@end

NS_ASSUME_NONNULL_END
