//
//  ALMenuCollectionViewLayout.m
//  ALButtonMenu
//
//  Copyright © 2017 Anthony Lobianco. All rights reserved.
//

#import "ALMenuCollectionViewLayout.h"

#import "ALUtils.h"

@interface ALMenuCollectionViewLayout ()

@property (nonatomic) NSMutableArray *itemAttributes;
@property (nonatomic) CGSize contentSize;

@end

@implementation ALMenuCollectionViewLayout

- (void)prepareLayout
{
    [super prepareLayout];

    NSUInteger numberOfColumns = self.numberOfColumns;

    NSParameterAssert(numberOfColumns > 0);

    UICollectionView *collectionView = self.collectionView;
    id <UICollectionViewDataSource> dataSource = collectionView.dataSource;

    NSInteger numberOfItems = [dataSource collectionView:collectionView numberOfItemsInSection:0];

    NSParameterAssert(numberOfColumns <= numberOfItems);

    NSUInteger numberOfRows = ceil((CGFloat)numberOfItems / numberOfColumns);

    if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]))
    {
        // flip the rows/columns for landscape orientations
        numberOfColumns = numberOfRows;
        numberOfRows = self.numberOfColumns;
    }

    CGFloat itemWidth = self.itemSize.width;
    CGFloat itemHeight = self.itemSize.height;
    CGFloat itemSpacing = self.itemSpacing;

    // calculate content size
    CGFloat contentWidth = numberOfColumns * itemWidth + ((numberOfColumns - 1) * itemSpacing);
    CGFloat contentHeight = numberOfRows * itemHeight + ((numberOfRows - 1) * itemSpacing);
    self.contentSize = CGSizeMake(contentWidth, contentHeight);

    // empty attribuets array
    self.itemAttributes = [[NSMutableArray alloc] init];

    // then preload attributes
    for (NSUInteger i = 0; i < numberOfItems; ++i)
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
        UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];

        NSInteger indexOfItemInCurrentRow = (i % numberOfColumns);
        NSInteger currentRow = (i / (CGFloat)numberOfColumns);

        CGRect frame;
        frame.size.width = itemWidth;
        frame.size.height = itemHeight;
        frame.origin.x = ((CGFloat)indexOfItemInCurrentRow * itemWidth) + (itemSpacing * (CGFloat)(indexOfItemInCurrentRow));
        frame.origin.y = ((CGFloat)currentRow * itemHeight) + (itemSpacing * (CGFloat)(currentRow));
        attributes.frame = frame;
        
        self.itemAttributes[i] = attributes;
    }

    // then notify the delegate
    [self.delegate menuCollectionViewLayout:self didChangeSize:self.contentSize];
}

- (CGSize)collectionViewContentSize
{
    return self.contentSize;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    return [self.itemAttributes copy];
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [[self.itemAttributes copy] objectAtIndex:indexPath.row];
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    return CGRectEqualToRect(newBounds, self.collectionView.bounds) == NO;
}

- (void)prepareForAnimatedBoundsChange:(CGRect)oldBounds
{
    [super prepareForAnimatedBoundsChange:oldBounds];
    [self invalidateLayout];
}

@end
