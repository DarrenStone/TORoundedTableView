//
//  TORoundedTableView.m
//  TORoundedTableView
//
//  Created by Tim Oliver on 29/11/16.
//  Copyright © 2016 Tim Oliver. All rights reserved.
//

#import "TORoundedTableView.h"
#import "TORoundedTableViewCell.h"

#define TOROUNDEDTABLEVIEW_SELECTED_BACKGROUND_COLOR [UIColor colorWithWhite:0.85f alpha:1.0f]

// Private declaration of internal cell properties
@interface TORoundedTableViewCell ()
- (void)setBackgroundImage:(UIImage *)image;
@end

// -------------------------------------------------------

@interface TORoundedTableView ()

@property (nonatomic, strong) UIImage *roundedCornerImage;
@property (nonatomic, strong) UIImage *selectedRoundedCornerImage;

// View Lifecyle
- (void)setUp;
- (void)loadCornerImages;

// Size Caluclations
- (CGFloat)widthForCurrentSizeClass;

// View resizing
- (void)resizeView:(UIView *)view forColumnWidth:(CGFloat)width centered:(BOOL)centered;

// Image Generation
+ (UIImage *)roundedCornerImageWithRadius:(CGFloat)radius color:(UIColor *)color;

@end

@implementation TORoundedTableView

#pragma mark - View Creation -

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    if (self = [super initWithFrame:frame style:UITableViewStyleGrouped]) {
        [self setUp];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame style:UITableViewStyleGrouped]) {
        [self setUp];
    }
    
    return self;
}

- (instancetype)init
{
    if (self = [super initWithFrame:CGRectZero style:UITableViewStyleGrouped]) {
        [self setUp];
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        if (self.style != UITableViewStyleGrouped) {
            // We can't override this property after creation, so trigger an exception
            [[NSException exceptionWithName:NSInternalInconsistencyException
                                    reason:@"Must be initialized with UITableViewStyleGrouped style."
                                   userInfo:nil] raise];
        }
        
        [self setUp];
    }
    
    return self;
}

- (void)setUp
{
    _sectionCornerRadius = 5.0f;
    _horizontalInset = 22.0f;
    _maximumWidth = 675.0f;
    _cellBackgroundColor = [UIColor whiteColor];
    _cellSelectedBackgroundColor = TOROUNDEDTABLEVIEW_SELECTED_BACKGROUND_COLOR;
}

- (void)loadCornerImages
{
    // Load the rounded image for default cell state
    if (!self.roundedCornerImage) {
        self.roundedCornerImage = [[self class] roundedCornerImageWithRadius:self.sectionCornerRadius
                                                                       color:self.cellBackgroundColor];
    }
    
    // Load the rounded image for when the cell is selected
    if (!self.selectedRoundedCornerImage) {
        self.selectedRoundedCornerImage = [[self class] roundedCornerImageWithRadius:self.sectionCornerRadius
                                                                               color:self.cellSelectedBackgroundColor];
    }
}

- (void)didMoveToSuperview
{
    if (self.superview == nil) {
        return;
    }
    
    [self loadCornerImages];
}

#pragma mark - Content Resizing / Layout -

- (CGFloat)widthForCurrentSizeClass
{
    CGFloat width = self.frame.size.width;
    width -= self.horizontalInset * 2.0f;
    
    if (self.maximumWidth > 0.0f) {
        width = MIN(self.maximumWidth, width);
    }

    return width;
}

- (void)resizeView:(UIView *)view forColumnWidth:(CGFloat)columnWidth centered:(BOOL)centered
{
    CGRect frame = view.frame;
    if (frame.size.width < columnWidth + FLT_EPSILON) { return; }
    frame.size.width = columnWidth;
    if (centered) { frame.origin.x = (self.frame.size.width - columnWidth) * 0.5f; }
    view.frame = frame;
}

#pragma mark - Layout Override -

- (void)layoutSubviews
{
    [super layoutSubviews];

    // Work out the width of the column
    CGFloat columnWidth = [self widthForCurrentSizeClass];
    
    // Loop through every subview related to 'UITableView' and resize it
    for (UIView *subview in self.subviews) {
        if (subview.frame.size.width > self.frame.size.width - FLT_EPSILON) { // Resize everything but the scroll indicators
            [self resizeView:subview forColumnWidth:columnWidth centered:YES];
        }
    }
}

#pragma mark - Accessor Overrides -

- (void)setSectionCornerRadius:(CGFloat)sectionCornerRadius
{
    if (fabs(sectionCornerRadius - _sectionCornerRadius) < FLT_EPSILON) {
        return;
    }
    
    _sectionCornerRadius = sectionCornerRadius;

    self.roundedCornerImage = nil;
    self.selectedRoundedCornerImage = nil;
    
    [self loadCornerImages];
    [self reloadData];
}

- (void)setCellBackgroundColor:(UIColor *)cellBackgroundColor
{
    if (cellBackgroundColor == _cellBackgroundColor) {
        return;
    }
    
    _cellBackgroundColor = cellBackgroundColor;
    
    self.roundedCornerImage = nil;
    [self loadCornerImages];
    [self reloadData];
}

- (void)setCellSelectedBackgroundColor:(UIColor *)cellSelectedBackgroundColor
{
    if (_cellSelectedBackgroundColor == cellSelectedBackgroundColor) {
        return;
    }
    
    _cellSelectedBackgroundColor = cellSelectedBackgroundColor;
    
    self.selectedRoundedCornerImage = nil;
    [self loadCornerImages];
    [self reloadData];
}

#pragma mark - Image Generation -
+ (UIImage *)roundedCornerImageWithRadius:(CGFloat)radius color:(UIColor *)color
{
    UIImage *image = nil;
    
    // Make sure we have a valid color
    if (color == nil) { color = [UIColor whiteColor]; }
    
    // Rectangle if only one side is rounded, square otherwise
    CGRect rect = CGRectMake(0, 0, radius * 2, radius * 2);
    
    // Generation the image
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0.0f);
    {
        UIBezierPath *bezierPath = [UIBezierPath bezierPathWithOvalInRect:rect];
        [color set];
        [bezierPath fill];
        image = UIGraphicsGetImageFromCurrentImageContext();
    }
    UIGraphicsEndImageContext();
    
    // Make the image conform to the tint color
    return image;
}

@end
