//
//  ALButtonViewModel.m
//  ALButtonMenu
//
//  Copyright © 2016 Anthony Lobianco. All rights reserved.
//

#import "ALButtonViewModel_ALPrivate.h"

#import "ALUtils.h"

@implementation ALButtonViewModel

- (instancetype)init
{
    AL_INIT([super init]);

    [self configureDefaults];

    return self;
}

- (void)configureDefaults
{
    _bounces = YES;
    _bouncesOnTouchUp = YES;
    _color = [UIColor blackColor];
}

- (void)setCanReposition:(BOOL)canReposition
{
    if (_canReposition == canReposition)
    {
        return;
    }

    _canReposition = canReposition;

    [self.delegate viewModelDidUpdate:self];
}

- (void)setColor:(UIColor *)color
{
    if (_color == color)
    {
        return;
    }

    _color = color;

    [self.delegate viewModelDidUpdate:self];
}

- (void)setImage:(UIImage *)image
{
    if (_image == image)
    {
        return;
    }

    _image = image;

    [self.delegate viewModelDidUpdate:self];
}

- (void)setMaskPath:(UIBezierPath *)maskPath
{
    if (_maskPath == maskPath)
    {
        return;
    }

    _maskPath = maskPath;

    [self.delegate viewModelDidUpdate:self];
}

@end
