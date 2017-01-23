//
//  ALMenuCollectionViewCell.m
//  ALButtonMenu
//
//  Copyright © 2017 Anthony Lobianco. All rights reserved.
//

#import "ALMenuCollectionViewCell.h"

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
        [button.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor].active = YES;
        [button.topAnchor constraintEqualToAnchor:self.contentView.topAnchor].active = YES;
        [button.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor].active = YES;
        [button.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor].active = YES;
    }

    _button = button;
}

@end
