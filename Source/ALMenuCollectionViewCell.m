//
//  ALMenuCollectionViewCell.m
//  ALButtonMenu
//
//  Copyright © 2017 Anthony Lobianco. All rights reserved.
//

#import "ALMenuCollectionViewCell.h"

#import "UIView+ALLayout.h"

#import "ALMenuItem.h"
#import "ALUtils.h"

@implementation ALMenuCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    AL_INIT([super initWithFrame:frame]);

    self.translatesAutoresizingMaskIntoConstraints = NO;

    return self;
}

- (void)setButton:(UIView<ALMenuItem> *)button
{
    if (_button == button)
    {
        return;
    }

    button.translatesAutoresizingMaskIntoConstraints = NO;

    if (button == nil)
    {
        [_button removeFromSuperview];
    }
    else
    {
        [self.contentView addSubview:button];
        [button al_pinToSuperview];
    }

    _button = button;
}

@end
