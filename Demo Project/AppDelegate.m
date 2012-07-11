//
//  AppDelegate.m
//  Demo Project
//
//  Created by Peyton Randolph on 7/10/12.
//

#import "AppDelegate.h"

#import "AlertViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    AlertViewController *alertViewController = [[AlertViewController alloc] initWithNibName:nil bundle:nil];
    
    UITabBarController *rootController = [[UITabBarController alloc] init];
    rootController.viewControllers = [NSArray arrayWithObjects:alertViewController, nil];
    self.window.rootViewController = rootController;
    [self.window makeKeyAndVisible];
    return YES;
}

@end
