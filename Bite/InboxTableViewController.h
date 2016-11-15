//
//  InboxTableViewController.h
//  justforfun
//
//  Created by Evan Latner on 7/14/15.
//  Copyright (c) 2015 Bite. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import "InboxTableCell.h"

@interface InboxTableViewController : UITableViewController

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) NSArray *messages;


@end
