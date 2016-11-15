//
//  ListTableCell.h
//  justforfun
//
//  Created by Evan Latner on 5/25/16.
//  Copyright © 2016 Bite. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ListTableCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *venueName;

@property (weak, nonatomic) IBOutlet UIImageView *venueImage;

@end
