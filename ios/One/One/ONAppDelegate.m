//
//  ONAppDelegate.m
//  One
//
//  Created by Masakazu Ohtsuka on 2013/05/17.
//  Copyright (c) 2013年 KAYAC Inc. All rights reserved.
//

#import "ONAppDelegate.h"
#import "ONHelper.h"
#import "ONURLHandler.h"
#import <IRKit/IRKit.h>

@implementation ONAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    LOG( @"options: %@", launchOptions );
    // Override point for customization after application launch.

    NSURL *url = launchOptions[UIApplicationLaunchOptionsURLKey];
    if (url) {
        return [ONURLHandler canHandleOpenURL: url];
    }

    [[IRKit sharedInstance] startScan];
    //[IRKit sharedInstance].retainConnectionInBackground = YES;

    // customize everything
    [[UINavigationBar appearance] setBackgroundImage:[IRHelper imageWithColor:[UIColor colorWithRed:0x16/255. green:0x16/255. blue:0x1a/255. alpha:1.0]]
                                       forBarMetrics:UIBarMetricsDefault];

    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithDictionary: [[UINavigationBar appearance] titleTextAttributes]];
    [attributes setObject:[UIFont fontWithName:@"Avenir-Light" size:20.]
                   forKey:UITextAttributeFont ];
    [[UINavigationBar appearance] setTitleTextAttributes: attributes];

    return YES;
}

- (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    LOG( @"options: %@", launchOptions);

    NSURL *url = launchOptions[UIApplicationLaunchOptionsURLKey];
    if (url) {
        return [ONURLHandler canHandleOpenURL: url];
    }

    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    LOG( @"url: %@, sourceApplication: %@, annotation: %@", url, sourceApplication, annotation );

    if ([ONURLHandler canHandleOpenURL:url]) {
        [ONURLHandler handleOpenURL: url];
        return YES;
    }
    return NO;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    LOG_CURRENT_METHOD;
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    LOG_CURRENT_METHOD;
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    LOG_CURRENT_METHOD;
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    LOG_CURRENT_METHOD;
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
