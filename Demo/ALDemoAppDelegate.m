//
//  ALDemoAppDelegate.m
//  ALButtonMenu
//
//  Copyright © 2016 Anthony Lobianco. All rights reserved.
//

#import "ALDemoAppDelegate.h"

#import "ALDemoRootViewController.h"

@implementation ALDemoAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    ALDemoRootViewController *rootViewController = [[ALDemoRootViewController alloc] init];

    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.rootViewController = rootViewController;

    [self.window makeKeyAndVisible];

    return YES;
}

@end
