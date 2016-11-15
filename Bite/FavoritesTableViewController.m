//
//  FavoritesTableViewController.m
//  justforfun
//
//  Created by Evan Latner on 7/14/15.
//  Copyright (c) 2015 Bite. All rights reserved.
//

#import "FavoritesTableViewController.h"

@interface FavoritesTableViewController ()

@property (nonatomic, strong) NSArray *array;


@end

@implementation FavoritesTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.array.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    // Configure the cell...
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 100;
}

-(void)queryForFavorites {
    
    PFQuery *query = [PFQuery queryWithClassName:@""];
    [query whereKey:@"" equalTo:@""];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
       
        if (error) {
            NSLog(@"Error");
        }
        else {
            NSLog(@"YO");
        }
    }];
}


@end
