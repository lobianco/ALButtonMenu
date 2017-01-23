//
//  ALMenuCollectionViewLayout.h
//  ALButtonMenu
//
//  Copyright © 2017 Anthony Lobianco. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class ALMenuCollectionViewLayout;

@protocol ALMenuCollectionViewLayoutDelegate <NSObject>

- (void)menuCollectionViewLayout:(ALMenuCollectionViewLayout *)layout didChangeSize:(CGSize)newSize;

@end

@interface ALMenuCollectionViewLayout : UICollectionViewLayout

@property (nullable, nonatomic, weak) id<ALMenuCollectionViewLayoutDelegate> delegate;
@property (nonatomic) CGSize itemSize;
@property (nonatomic) CGFloat itemSpacing;
@property (nonatomic) NSUInteger numberOfColumns;

@end

NS_ASSUME_NONNULL_END
