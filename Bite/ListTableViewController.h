//
//  ListTableViewController.h
//  justforfun
//
//  Created by Evan Latner on 5/23/16.
//  Copyright © 2016 Bite. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "ListTableCell.h"

@interface ListTableViewController : UITableViewController

@property (nonatomic, strong) NSMutableArray *venues;
@property (nonatomic, strong) NSMutableArray *imageArray;
@property (nonatomic, strong) NSString *dasString;
@property (nonatomic, strong) PFGeoPoint *currentLocation;
@property (nonatomic, strong) NSString *colorString;


@end
