//
//  SecondViewController.h
//  Example
//
//  Created by Jonathan Tribouharet
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import "VenueTableCell.h"
#import "UIScrollView+EmptyDataSet.h"
#import <MapKit/MapKit.h>

@interface SecondViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate, UIScrollViewDelegate, MKMapViewDelegate>

@property (nonatomic) int rgbString;
@property (nonatomic, strong) NSString *dasString;
@property (weak, nonatomic) IBOutlet UITableView *tableview;

@property (nonatomic, strong) NSString *category;

@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;


@property (weak, nonatomic) IBOutlet UIImageView *categoryIcon;

@property (nonatomic, strong) UIImage *icon;
@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPress;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) PFGeoPoint *currentLocation;
@property (nonatomic, strong) NSString *userCity;
@property (nonatomic, strong) NSString *categoryId;
@property (nonatomic, strong) NSMutableArray *venueIconArray;
@property (nonatomic, strong) NSMutableArray *venueImagesArray;

@end
