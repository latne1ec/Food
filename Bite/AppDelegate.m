//
//  AppDelegate.m
//  Bite
//
//  Created by Evan Latner on 7/10/15.
//  Copyright (c) 2015 Bite. All rights reserved.
//

#import "AppDelegate.h"
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    [Parse enableLocalDatastore];
    
//    // Initialize Parse.
    [Parse setApplicationId:@"pYC7HKEPpntoqcTAcjClPrM5In7rAkSxkD7FmNn9"
                  clientKey:@"SeLrSGboumslVnNrXOi7bnATQZ2V811QOQAxj4mI"];
    
    // [Optional] Track statistics around application opens.
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
//    [Parse initializeWithConfiguration:[ParseClientConfiguration configurationWithBlock:^(id<ParseMutableClientConfiguration> configuration) {
//        
//        configuration.applicationId = @"pYC7HKEPpntoqcTAcjClPrM5In7rAkSxkD7FmNn9";
//        configuration.clientKey = @"SeLrSGboumslVnNrXOi7bnATQZ2V811QOQAxj4mI";
//        configuration.server = @"http://intense-mountain-21851.herokuapp.com";
//
//    }]];
    
    [PFImageView class];

    //[GMSServices provideAPIKey:@"AIzaSyAiTPMYxrAjydZnj07MwMkxM-jp4JqIFIg"];
    
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:0.0 green:0.75 blue:0.65 alpha:1.0]];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    
//    UIView *view=[[UIView alloc] initWithFrame:CGRectMake(0, 0,[UIScreen mainScreen].bounds.size.width, 20)];
//    view.backgroundColor=[UIColor whiteColor];
//    view.tag = 1001;
//    [self.window.rootViewController.view addSubview:view];
    
    self.swipeBetweenVC = [YZSwipeBetweenViewController new];
    [self setupRootViewControllerForWindow];
    self.window.rootViewController = self.swipeBetweenVC;
    [self.window makeKeyAndVisible];

    
    self.window.backgroundColor = [UIColor whiteColor];
    
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowColor = [UIColor clearColor];
    shadow.shadowOffset = CGSizeMake(0, .0);
    [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                          [UIColor whiteColor], NSForegroundColorAttributeName,
                                                          shadow, NSShadowAttributeName,
                                                          [UIFont fontWithName:@"Montserrat-Regular" size:26], NSFontAttributeName, nil]];
    
    return YES;
}


- (void)setupRootViewControllerForWindow {
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UINavigationController *navCon1 = [storyboard instantiateViewControllerWithIdentifier:@"Categories"];
    UINavigationController *navCon2 = [storyboard instantiateViewControllerWithIdentifier:@"InboxNav"];
//    UINavigationController *navCon3 = [storyboard instantiateViewControllerWithIdentifier:@"FavoritesNav"];
    //UINavigationController *navCon4 = [storyboard instantiateViewControllerWithIdentifier:@"ViewVideoNav"];
    
    self.swipeBetweenVC.viewControllers = @[navCon1, navCon2];
    self.swipeBetweenVC.initialViewControllerIndex = (NSInteger)self.swipeBetweenVC.viewControllers.count/2;
    
//    UIView *view=[[UIView alloc] initWithFrame:CGRectMake(0, 0,[UIScreen mainScreen].bounds.size.width, 20)];
//    view.backgroundColor=[UIColor whiteColor];
//    [self.swipeBetweenVC.view addSubview:view];
    
}

- (void)applicationWillResignActive:(UIApplication *)application {
}
- (void)applicationDidEnterBackground:(UIApplication *)application {
}
- (void)applicationWillEnterForeground:(UIApplication *)application {
}
- (void)applicationDidBecomeActive:(UIApplication *)application {
}
- (void)applicationWillTerminate:(UIApplication *)application {
}

@end
