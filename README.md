# ALButtonMenu

ALButtomMenu is a fast, customizable, fully documented menu solution for iOS.

### Preview

![Preview1](https://github.com/lobianco/ALButtonMenu/blob/master/Screenshots/demo1.gif?raw=true) ![Preview2](https://github.com/lobianco/ALButtonMenu/blob/master/Screenshots/demo2.gif?raw=true)

## Installation

Installation is easy.

### Cocoapods

1. `pod 'ALButtonMenu'` in your Podfile
2. `#import <ALButtonMenu/ALButtonMenu.h>` in your view of choice

### Manually

1. [Download the .zip](https://github.com/lobianco/ALButtonMenu/archive/master.zip) from Github and copy `ALButtonMenu/Source` directory to your project
2. `#import "ALButtonMenu.h"` in your view of choice

## Example Usage

Refer to the demo project for an interactive example, or just take a look at the code and comments below. 

```objc

//
//  MyRootViewController.m
//

// this, or whatever init method you choose to use
- (instancetype)init 
{
	if ((self = [super init]) == NO)
	{
		return nil;
	}

	// the layout that we'll use for the menu view controller
	ALMenuViewControllerLayout layout;

	// the menu items will be displayed in a grid with this many columns. however, in landscape mode, 
	// this value will be used for the number of rows instead.
	//
    layout.columns = 2;

    // the spacing between menu items
    layout.itemSpacing = 15.f;

    // the size of the menu items
    layout.itemSize = CGSizeMake(100.f, 100.f);

    // can be an array of any number of items that inherit from ALButton or conform to the <ALMenuItem> protocol
    NSArray<UIView<ALMenuItem> *> *items = [self allMenuItems];

    // create the view model for the menu view controller
    ALMenuViewControllerViewModel *menuViewModel = [[ALMenuViewControllerViewModel alloc] initWithItems:items layout:layout];

    // tweak the default values. see ALMenuViewControllerViewModel.h for configurable properties
    menuViewModel.appearingAnimation = ALMenuViewControllerAppearingAnimationOrigin;

    // the menu view controller can be an instance of ALMenuViewController, or any class that conforms
    // to the <ALMenuViewController> protocol
    //
    ALMenuViewController *menuViewController = [[ALMenuViewController alloc] initWithViewModel:menuViewModel];

    // an instance of your view controller class
	MyViewController *viewController = [[MyViewController alloc] init];

	// create the view model for the navigation coordinator
    ALNavigationCoordinatorViewModel *navViewModel = [[ALNavigationCoordinatorViewModel alloc] init];

    // tweak the default values. see ALNavigationCoordinatorViewModel.h for configurable properties. 
    navViewModel.buttonCanBeRepositioned = YES;

    // create the navigation coordinator with the menu view controller and your app's root view controller. the 
    // root view controller can be an instance of UIViewController or UINavigationController
    //
    _navigationCoordinator = [[ALNavigationCoordinator alloc] initWithViewModel:navViewModel menuViewController:menuViewController rootViewController:rootViewController];

    // and be sure to assign yourself as the delegate. if you configure the navigation coordinator with a navigation
    // controller (instead of a root view controller), the coordinator will need to assign itself as that navigation 
    // controller's delegate, so you can optionally receive those delegate callbacks via this assignment. just 
    // implement the methods. 
    //
    _navigationCoordinator.delegate = self;

	return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // the navigation coordinator creates a navigation controller configured with the provided 
    // menu view controller and root view controller. we need to add that navigation controller
    // to the view heirarchy
    //
    UIViewController *childViewController = self.navigationCoordinator.navigationController;

    // then add it as a child view controller
    [self addChildViewController:childViewController];
    [self.view addSubview:childViewController.view];
    [childViewController didMoveToParentViewController:self];

    // then notify the navigation coordinator about our viewDidLoad event
    [self.navigationCoordinator viewDidLoad];
}

#pragma mark - ALNavigationCoordinatorDelegate

// be sure to implement the navigation coordinator's delegate method. it will fire when an item in the menu view controller is 
// tapped. return your specific UIViewController instance for that index. 
//
- (UIViewController *)navigationCoordinator:(ALNavigationCoordinator *)navigationCoordinator viewControllerForMenuItemAtIndex:(NSUInteger)index
{
    return [[MyViewController alloc] init];
}

#pragma mark - Status bar

// optionally, return the menu view controller in this method to hide the status bar when the menu is shown. 
- (UIViewController *)childViewControllerForStatusBarHidden
{
    return self.navigationCoordinator.menuViewController;
}

#pragma mark - Rotation

// be sure to alert the navigation coordinator about size change events.
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];

    [self.navigationCoordinator viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}

```

## Contact Me

You can reach me anytime at the addresses below. If you use ALButtonMenu, feel free to give me a shoutout on Twitter to let me know how you like it. I'd love to hear your thoughts! 

Github: [lobianco](https://github.com/lobianco) <br>
Twitter: [@lobnco](https://twitter.com/lobnco) <br>
Email: [anthony@lobian.co](mailto:anthony@lobian.co) 

## Credits & License

ALButtonMenu is developed and maintained by Anthony Lobianco ([@lobnco](https://twitter.com/lobnco)). Licensed under the MIT License. Basically, I would appreciate attribution if you use it.

Enjoy!