//
//  CellOne.h
//  justforfun
//
//  Created by Evan Latner on 8/11/16.
//  Copyright © 2016 Bite. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CellOne : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *venueIconImageView;
@property (weak, nonatomic) IBOutlet UILabel *venueNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *venueDistanceLabel;

@end
