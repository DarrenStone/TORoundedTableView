//
//  TORoundedTableView.h
//  TORoundedTableView
//
//  Created by Tim Oliver on 29/11/16.
//  Copyright © 2016 Tim Oliver. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TORoundedTableViewCell;

@interface TORoundedTableView : UITableView

/** The distance from the edges of each side of the table view */
@property (nonatomic, assign) CGFloat horizontalInset;

/** The maximum width that the table cells / accessory views may be */
@property (nonatomic, assign) CGFloat maximumWidth;

/** The corner radius of each section */
@property (nonatomic, assign) CGFloat sectionCornerRadius;

/** The default background color of every cell */
@property (nonatomic, strong) UIColor *cellBackgroundColor;

/** The default background of each cell when tapped */
@property (nonatomic, strong) UIColor *cellSelectedBackgroundColor;

@end
