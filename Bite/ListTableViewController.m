//
//  ListTableViewController.m
//  justforfun
//
//  Created by Evan Latner on 5/23/16.
//  Copyright © 2016 Bite. All rights reserved.
//

#import "ListTableViewController.h"

@interface ListTableViewController ()

@end

@implementation ListTableViewController


#define kCLIENTID @"VPHBFYCGLAKRNZTCX2E2SUXQXQLZFVZ4JLWCRN5TCLFLW2CI"
#define kCLIENTSECRET @"MAJMGKNWIUNYHIBUGHSS2GSMMTV0M2T5T3LCTBYI0ZGOF22D"

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.imageArray = [[NSMutableArray alloc] init];
    
    [self.view setBackgroundColor: [self colorWithHexString:self.colorString]];
    [self queryForDasVenues];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.venues.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   
    ListTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    // Configure the cell...
    NSDictionary *venue = [self.venues objectAtIndex:indexPath.row];
    
    cell.venueName.text = [venue valueForKey:@"name"];
    if (self.imageArray.count>0) {
        NSString *urlString = [self.imageArray objectAtIndex:0];
        NSURL *url = [NSURL URLWithString:urlString];
        cell.venueImage.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
        cell.venueImage.layer.cornerRadius = cell.venueImage.frame.size.width/2;
    }
    
    return cell;
}

-(void) queryForDasVenues {
    
    NSString *clientID = kCLIENTID;
    NSString *clientSecret = kCLIENTSECRET;
    
    NSString *url = [NSString stringWithFormat:@"https://api.foursquare.com/v2/venues/search?client_id=%@&client_secret=%@&v=20130815&ll=%f,%f&radius=2000&limit=10&categoryId=4bf58dd8d48988d14e941735", clientID, clientSecret, self.currentLocation.latitude, self.currentLocation.longitude];
    
    NSURL *googleRequestURL=[NSURL URLWithString:url];
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSData* data = [NSData dataWithContentsOfURL: googleRequestURL];
        [self performSelectorOnMainThread:@selector(fetchedData:) withObject:data waitUntilDone:YES];
    });
}

-(void)fetchedData:(NSData *)responseData {
    
    
    NSString *clientID = kCLIENTID;
    NSString *clientSecret = kCLIENTSECRET;
    
    NSError* error;
    NSDictionary* json = [NSJSONSerialization
                          JSONObjectWithData:responseData
                          
                          options:kNilOptions
                          error:&error];
    
    self.venues = [[NSMutableArray alloc] init];
    self.venues = [[json objectForKey:@"response"] objectForKey:@"venues"];
    
    NSLog(@"Here: %lu", (unsigned long)self.venues.count);
    NSDictionary *tempVen = [self.venues objectAtIndex:0];
    NSLog(@"Hi: %@", [tempVen valueForKey:@"id"]);
    
    NSString *url = [NSString stringWithFormat:@"https://api.foursquare.com/v2/venues/%@/photos?client_id=%@&client_secret=%@&v=20130815&group=venue",[tempVen valueForKey:@"id"], clientID, clientSecret];
    
    NSURL *googleRequestURL=[NSURL URLWithString:url];
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSData* data = [NSData dataWithContentsOfURL: googleRequestURL];
        [self performSelectorOnMainThread:@selector(fetchedImage:) withObject:data waitUntilDone:YES];
    });
    
    [self.tableView reloadData];
    
}

-(void)fetchedImage: (NSData *)responseData {
    
    NSError* error;
    NSDictionary* json = [NSJSONSerialization
                          JSONObjectWithData:responseData
                          
                          options:kNilOptions
                          error:&error];
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    array = [[[json objectForKey:@"response"] objectForKey:@"photos"] valueForKey:@"items"];
    
    
    NSString *prefix = [[array valueForKey:@"prefix"] objectAtIndex:0];
    NSString *suffix = [[array valueForKey:@"suffix"] objectAtIndex:0];
    NSString *imageUrl = [NSString stringWithFormat:@"%@100x100%@", prefix, suffix];
    NSLog(@"Pic: %@", imageUrl);
    [self.imageArray addObject:imageUrl];
    [self.tableView reloadData];
}

-(UIColor*)colorWithHexString:(NSString*)hex {
    
    NSString *cString = [[hex stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // String should be 6 or 8 characters
    if ([cString length] < 6) return [UIColor grayColor];
    
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];
    
    if ([cString length] != 6) return  [UIColor grayColor];
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];
    
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:1.0f];
}

@end
