//
//  ALDemoRootViewController.m
//  ALButtonMenu
//
//  Copyright © 2017 Anthony Lobianco. All rights reserved.
//

#import "ALDemoRootViewController.h"

#import "UIColor+ALComplementary.h"

#import "ALButtonMenu.h"

#import "ALDemoViewController.h"

static NSUInteger const kNumberOfMenuItems = 4;
static NSUInteger const kMenuColumns = 2;
static CGFloat const kMenuItemSpacing = 15.f;
static CGSize const kMenuItemSize = { 100.f, 100.f };

@interface ALDemoRootViewController () <ALNavigationCoordinatorDelegate>

@property (nonatomic) ALNavigationCoordinator *navigationCoordinator;

// these properties are made thread-safe in their getter methods
@property (nonatomic, copy, readonly) NSArray<UIView<ALMenuItem> *> *dummyMenuItems;
@property (nonatomic, copy, readonly) NSArray<ALDemoViewController *> *dummyViewControllers;

@end

@implementation ALDemoRootViewController

@synthesize dummyMenuItems = _dummyMenuItems;
@synthesize dummyViewControllers = _dummyViewControllers;

- (void)viewDidLoad
{
    [super viewDidLoad];

    NSParameterAssert(self.dummyMenuItems.count == self.dummyViewControllers.count);

    ALDemoViewController *rootViewController = self.dummyViewControllers[0];
    UINavigationController *rootNavigationController = [[UINavigationController alloc] initWithRootViewController:rootViewController];
    rootNavigationController.navigationBarHidden = YES;

    ALMenuViewControllerLayout layout;
    layout.columns = kMenuColumns;
    layout.itemSpacing = kMenuItemSpacing;
    layout.itemSize = kMenuItemSize;

    NSArray<UIView<ALMenuItem> *> *items = self.dummyMenuItems;

    ALMenuViewControllerViewModel *menuViewModel = [[ALMenuViewControllerViewModel alloc] initWithItems:items layout:layout];
    UIViewController<ALMenuViewController> *menuViewController = [[ALMenuViewController alloc] initWithViewModel:menuViewModel];

    ALNavigationCoordinatorViewModel *navViewModel = [[ALNavigationCoordinatorViewModel alloc] init];
    navViewModel.buttonCanBeRepositioned = YES;

    self.navigationCoordinator = [[ALNavigationCoordinator alloc] initWithViewModel:navViewModel menuViewController:menuViewController navigationController:rootNavigationController];
    self.navigationCoordinator.delegate = self;

    UIViewController *childViewController = self.navigationCoordinator.navigationController;

    [self addChildViewController:childViewController];
    [self.view addSubview:childViewController.view];
    [childViewController didMoveToParentViewController:self];

    [self.navigationCoordinator viewDidLoad];
}

#pragma mark - Private methods

- (NSArray<UIView<ALMenuItem> *> *)dummyMenuItems
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableArray<UIView<ALMenuItem> *> *buttons = [[NSMutableArray alloc] init];

        for (NSInteger i = 0; i < kNumberOfMenuItems; i++)
        {
            ALButtonViewModel *viewModel = [[ALButtonViewModel alloc] init];
            viewModel.color = self.dummyViewControllers[i].color;

            // since the button hasn't been added to the view heirarchy yet, we can construct
            // a path with a placeholder size and a proportional corner radius (in this case,
            // we want 10% rounder corners). then when the view is layed out, the mask path
            // will be upscaled for us automatically but the proportions will stay the same.
            //
            viewModel.maskPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0.f, 0.f, 20.f, 20.f) cornerRadius:2.f];

            ALButton *button = [[ALButton alloc] initWithViewModel:viewModel];

            UILabel *numberLabel = [[UILabel alloc] init];
            numberLabel.translatesAutoresizingMaskIntoConstraints = NO;
            numberLabel.text = [NSString stringWithFormat:@"%@", @(i + 1)];
            numberLabel.textColor = [UIColor colorWithWhite:0.1 alpha:1.f];
            numberLabel.font = [UIFont boldSystemFontOfSize:28.f];
            numberLabel.textAlignment = NSTextAlignmentCenter;

            [button addSubview:numberLabel];
            [numberLabel.leadingAnchor constraintEqualToAnchor:button.leadingAnchor].active = YES;
            [numberLabel.trailingAnchor constraintEqualToAnchor:button.trailingAnchor].active = YES;
            [numberLabel.topAnchor constraintEqualToAnchor:button.topAnchor].active = YES;
            [numberLabel.bottomAnchor constraintEqualToAnchor:button.bottomAnchor].active = YES;

            [buttons addObject:button];
        }

        _dummyMenuItems = [buttons copy];
    });

    return _dummyMenuItems;
}

- (NSArray<ALDemoViewController *> *)dummyViewControllers
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableArray *viewControllers = [[NSMutableArray alloc] init];

        for (NSInteger i = 0; i < kNumberOfMenuItems; ++i)
        {
            ALDemoViewController *viewController = [[ALDemoViewController alloc] init];
            viewController.index = i + 1;
            viewController.color = [UIColor al_neutralColor];
            viewControllers[i] = viewController;
        }

        _dummyViewControllers = [viewControllers copy];
    });

    return _dummyViewControllers;
}

#pragma mark - ALNavigationCoordinatorDelegate

- (UIViewController *)navigationCoordinator:(ALNavigationCoordinator *)navigationCoordinator viewControllerForMenuItemAtIndex:(NSUInteger)index
{
    return self.dummyViewControllers[index];
}

#pragma mark - Status bar

- (UIViewController *)childViewControllerForStatusBarHidden
{
    return self.navigationCoordinator.menuViewController;
}

#pragma mark - Rotation

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];

    [self.navigationCoordinator viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}

@end
