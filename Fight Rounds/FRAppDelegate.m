//
//  FRAppDelegate.m
//  Fight Rounds
//
//  Created by Jad Osseiran on 12/06/13.
//  Copyright (c) 2013 Jad Osseiran. All rights reserved.
//

#import "FRAppDelegate.h"
#import "FRStoreManager.h"

@implementation FRAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	// Override point for customization after application launch.
	self.window.tintColor = [FRTintColorHelper tinitColor];

	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	if (![defaults valueForKey:DEFAULTS_SOUND_OPTION]) {
		[defaults setBool:YES forKey:DEFAULTS_SOUND_OPTION];
		[defaults synchronize];
	}

	if (![defaults valueForKey:DEFAULTS_FAV_ORDERING_OPTION]) {
		[defaults setValue:@(0) forKey:DEFAULTS_FAV_ORDERING_OPTION];
		[defaults synchronize];
	}

	if (![defaults valueForKey:DEFAULTS_IN_APP_PURCHASED]) {
		[defaults setBool:NO forKey:DEFAULTS_IN_APP_PURCHASED];
		[defaults synchronize];
	}
//    // Here do the In-App purchase checking. Yes at the very start of the app WWDC 2013.
//    [[SKPaymentQueue defaultQueue] addTransactionObserver:[FRStoreManager sharedManager]];
//
//    BOOL purchased = NO;
//    if (purchased) {
//        // Do the iCloud magic;
//        if (![defaults valueForKey:DEFAULTS_ICLOUD_OPTION]) {
//            [defaults setBool:YES forKey:DEFAULTS_ICLOUD_OPTION];
//        }
//    } else {
//        if (![defaults valueForKey:DEFAULTS_ICLOUD_OPTION]) {
//            [defaults setBool:NO forKey:DEFAULTS_ICLOUD_OPTION];
//        }
//    }

	if (!PAID_VERSION) {
//        [UIViewController prepareInterstitialAds];
	}

	return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
	// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
	// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
	// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
	// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
	// Saves changes in the application's managed object context before the application terminates.
}

@end
