//
//  AppDelegate.h
//  Bite
//
//  Created by Evan Latner on 7/10/15.
//  Copyright (c) 2015 Bite. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YZSwipeBetweenViewController.h"


@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong) YZSwipeBetweenViewController *swipeBetweenVC;

- (void)setupRootViewControllerForWindow;


@end

