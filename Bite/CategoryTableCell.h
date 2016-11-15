//
//  CategoryTableCell.h
//  Bite
//
//  Created by Evan Latner on 7/10/15.
//  Copyright (c) 2015 Bite. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ParseUI/ParseUI.h>

@interface CategoryTableCell : UITableViewCell


//@property (weak, nonatomic) IBOutlet UILabel *venueTeaser;
@property (weak, nonatomic) IBOutlet UILabel *categoryName;

@property (weak, nonatomic) IBOutlet UIView *venueCardView;
@property (weak, nonatomic) IBOutlet UIImageView *categoryIcon;

@property (weak, nonatomic) IBOutlet UIView *bkgView;



@end
