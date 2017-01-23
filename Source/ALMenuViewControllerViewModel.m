//
//  ALMenuViewControllerViewModel.m
//  ALButtonMenu
//
//  Copyright © 2016 Anthony Lobianco. All rights reserved.
//

#import "ALMenuViewControllerViewModel.h"

#import "ALButton.h"
#import "ALButtonViewModel.h"
#import "ALUtils.h"

@interface ALMenuViewControllerViewModel ()

@property (nonatomic) NSArray<UIView<ALMenuItem> *> *items;

@end

@implementation ALMenuViewControllerViewModel

@synthesize appearingAnimation = _appearingAnimation;
@synthesize disappearingAnimation = _disappearingAnimation;
@synthesize shouldHideStatusBar = _shouldHideStatusBar;

- (instancetype)initWithItems:(NSArray<UIView<ALMenuItem> *> *)items layout:(ALMenuViewControllerLayout)layout
{
    AL_INIT([super init]);

    _items = items;
    _layout = layout;

    [self configureDefaults];

    return self;
}

- (void)configureDefaults
{
    _appearingAnimation = ALMenuViewControllerAppearingAnimationIndividual;
    _disappearingAnimation = ALMenuViewControllerDisappearingAnimationOrigin;
    _shouldHideStatusBar = YES;
}

#pragma mark - ALMenuViewControllerViewModel

- (NSUInteger)numberOfItems
{
    return self.items.count;
}

- (UIView<ALMenuItem> *)itemAtIndex:(NSUInteger)index
{
    if (index >= [self numberOfItems])
    {
        return nil;
    }

    return self.items[index];
}

- (NSUInteger)indexOfItem:(UIView<ALMenuItem> *)item
{
    return [self.items indexOfObject:item];
}

@end
