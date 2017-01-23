//
//  ALDemoViewController.m
//  ALButtonMenu
//
//  Copyright © 2016 Anthony Lobianco. All rights reserved.
//

#import "ALDemoViewController.h"

#import "UIColor+ALComplementary.h"

#import "ALButton.h"

@implementation ALDemoViewController

- (NSString *)title
{
    return [NSString stringWithFormat:@"VC %@", @(self.index)];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = [[self.color al_complementaryColor] al_neutralColor];

    UIColor *nearBlackColor = [UIColor colorWithWhite:0.1f alpha:1.f];

    UIView *labelContainer = [[UIView alloc] init];
    labelContainer.translatesAutoresizingMaskIntoConstraints = NO;
    labelContainer.backgroundColor = self.color;
    labelContainer.layer.borderColor = [nearBlackColor CGColor];
    labelContainer.layer.borderWidth = 4.f;
    labelContainer.layer.cornerRadius = 12.f;

    UILabel *label = [[UILabel alloc] init];
    label.translatesAutoresizingMaskIntoConstraints = NO;
    label.textAlignment = NSTextAlignmentCenter;
    label.text = [NSString stringWithFormat:@"%@", @(self.index)];
    label.font = [UIFont systemFontOfSize:100.f];
    label.textColor = nearBlackColor;
    label.numberOfLines = 0;

    [labelContainer addSubview:label];
    [label.topAnchor constraintEqualToAnchor:labelContainer.topAnchor constant:20.f].active = YES;
    [label.leftAnchor constraintEqualToAnchor:labelContainer.leftAnchor constant:20.f].active = YES;
    [label.bottomAnchor constraintEqualToAnchor:labelContainer.bottomAnchor constant:-20.f].active = YES;
    [label.rightAnchor constraintEqualToAnchor:labelContainer.rightAnchor constant:-20.f].active = YES;

    [self.view addSubview:labelContainer];
    [labelContainer.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
    [labelContainer.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor].active = YES;
    [labelContainer.widthAnchor constraintEqualToAnchor:labelContainer.heightAnchor].active = YES;
}

@end
