//
//  InboxTableViewController.m
//  justforfun
//
//  Created by Evan Latner on 7/14/15.
//  Copyright (c) 2015 Bite. All rights reserved.
//

#import "InboxTableViewController.h"
#import "UIScrollView+EmptyDataSet.h"
#import "AppDelegate.h"

@interface InboxTableViewController () <DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>

@property (nonatomic, strong) AppDelegate *appDelegate;

@end

@implementation InboxTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    self.tableView.tableFooterView = [UIView new];
    self.tableView.emptyDataSetSource = self;
    self.tableView.emptyDataSetDelegate = self;
    
    //[self queryForFavorites];
    
//    UIView *blackView = [[UIView alloc] initWithFrame:CGRectMake(0, -20, self.view.frame.size.width, 40)];
//    blackView.backgroundColor = [UIColor blackColor];
//    [self.view addSubview:blackView];
//    [self.view bringSubviewToFront:blackView];
//    UIView *view = (UIView *)[self.window.rootViewController.view viewWithTag:1001];
//    [view bringSubviewToFront:blackView];
    //view.backgroundColor = [UIColor blackColor];
    
//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu"] style:UIBarButtonItemStylePlain target:self action:@selector(menuButtonTapped)];

    self.title = @"surprise!";
}


-(void)menuButtonTapped {
    
    [UIView animateWithDuration:0.15 animations:^{
        
        [self.appDelegate.swipeBetweenVC scrollToViewControllerAtIndex:0 animated:false];
        
    } completion:^(BOOL finished) {
    }];
}

-(void)viewWillAppear:(BOOL)animated {
    
    //self.navigationController.navigationBar.backgroundColor = [UIColor whiteColor];
    //[self.navigationController.navigationBar setHidden:true];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.messages.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    InboxTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    // Configure the cell...
    PFObject *object = [self.messages objectAtIndex:indexPath.row];
    cell.venueNameLabel.text = [object objectForKey:@"venueName"];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 80;
}

-(void)queryForFavorites {
    
    PFQuery *query = [PFQuery queryWithClassName:@"Venues"];
    [query orderByAscending:@"venueName"];
    [query setLimit:4];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (error) {
            
        }
        else {
            self.messages = objects;
            [self.tableView reloadData];
        }
    }];
}

//***********************************************************************
// Empty Table View Properties

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    
    NSString *text = @"Coming soon 😆";
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont fontWithName:@"Montserrat-Regular" size:20],
                                 NSForegroundColorAttributeName: [UIColor colorWithRed:0.8 green:0.796 blue:0.796 alpha:1]};
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (BOOL)emptyDataSetShouldDisplay:(UIScrollView *)scrollView {
    
    if (self.messages.count == 0) {
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        return YES;
    }
    else {
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;

    }
    return NO;
}

- (CGPoint)offsetForEmptyDataSet:(UIScrollView *)scrollView {
    
    CGPoint point = CGPointMake(0, -50);
    return point;
    
}

- (BOOL)emptyDataSetShouldAllowScroll:(UIScrollView *)scrollView {
    
    return YES;
}

//***********************************************************************

@end
