//
//  VenueView.h
//  
//
//  Created by Evan Latner on 8/11/16.
//
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "AppDelegate.h"

@interface VenueView : UIView <UIGestureRecognizerDelegate,UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate>

@property CGPoint initialPosition;
@property Boolean isUp;
@property UITableView *tableView;
@property (nonatomic, strong) AppDelegate *appDelegate;
@property (nonatomic, strong) PFObject *venue;
@property (nonatomic, strong) PFGeoPoint *currentLocation;
@property (nonatomic, strong) NSString *colorString;
@property (nonatomic, strong) NSMutableArray *venueImagesArray;
@property (nonatomic) int imageIndex;
@property(nonatomic) float w, h;
@property (nonatomic, strong) UITapGestureRecognizer *tap;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

-(void)updateViewDetails:(PFObject *)venue;


@end
