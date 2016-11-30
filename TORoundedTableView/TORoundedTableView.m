//
//  TORoundedTableView.m
//  TORoundedTableView
//
//  Created by Tim Oliver on 29/11/16.
//  Copyright © 2016 Tim Oliver. All rights reserved.
//

#import "TORoundedTableView.h"

@interface TORoundedTableView ()

@property (nonatomic, strong) UIImage *topBackgroundImage;
@property (nonatomic, strong) UIImage *bottomBackgroundImage;

@property (nonatomic, strong) NSArray *previousVisibleCells;

// View Lifecyle
- (void)setUp;

// Table View Introspection
- (UIView *)wrapperViewForTable;

// Sizing relayout
- (CGFloat)widthForCurrentSizeClass;

- (void)resizeWrapperView:(UIView *)wrapperView forColumnWidth:(CGFloat)columnWidth;
- (void)resizeAuxiliaryViewsInWrapperView:(UIView *)wrapperView forColumnWidth:(CGFloat)width;
- (void)resizeView:(UIView *)view forColumnWidth:(CGFloat)width;

- (void)removeExteriorCellSeparatorViewsFromCell:(UITableViewCell *)cell;
- (void)configureVisibleTableViewCellsWithColumnWidth:(CGFloat)columnWidth;
- (void)configureStyleForTableViewCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

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
    _regularWidthFraction = 0.8f;
    _compactPadding = 10.0f;
}

#pragma mark - Content Resizing / Layout -

- (UIView *)wrapperViewForTable
{
    UIView *wrapperView = nil;
    for (UIView *view in self.subviews) {
        NSUInteger hash = NSStringFromClass([view class]).hash;
        if (hash == (NSUInteger)10216744557202100403U) { // UITableViewWrapperView
            wrapperView = view;
            break;
        }
    }
    
    return wrapperView;
}

- (CGFloat)widthForCurrentSizeClass
{
    if (self.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassRegular) {
        return self.frame.size.width * self.regularWidthFraction;
    }
    
    return self.frame.size.width - (self.compactPadding * 2.0f);
}

- (void)resizeView:(UIView *)view forColumnWidth:(CGFloat)width
{
    CGRect frame = view.frame;
    frame.size.width = width;
    view.frame = frame;
}

- (void)resizeWrapperView:(UIView *)wrapperView forColumnWidth:(CGFloat)columnWidth
{
    CGRect frame = wrapperView.frame;
    frame.size.width = columnWidth;
    frame.origin.x = (self.frame.size.width - columnWidth) * 0.5f;
    wrapperView.frame = frame;
}

- (void)resizeAuxiliaryViewsInWrapperView:(UIView *)wrapperView forColumnWidth:(CGFloat)width
{
    for (UIView *view in wrapperView.subviews) {
        // skip table cells; we'll handle those later
        if ([view isKindOfClass:[UITableViewCell class]]) {
            continue;
        }
        
        [self resizeView:view forColumnWidth:width];
    }
}

- (void)removeExteriorCellSeparatorViewsFromCell:(UITableViewCell *)cell
{
    CGFloat hairLineHeight = 1.0f / [UIScreen mainScreen].scale;
    CGFloat totalWidth = cell.frame.size.width;
    
    for (UIView *view in cell.subviews) {
        CGRect frame = view.frame;
        if (frame.origin.x > FLT_EPSILON) { continue; } // Doesn't start at the edge
        if (frame.size.height > hairLineHeight + FLT_EPSILON) { continue; } // View is thicker than a hairline
        if (frame.size.width < totalWidth - FLT_EPSILON) { continue; } // Doesn't span the entire length of cell
        [view removeFromSuperview];
    }
}

- (void)configureStyleForTableViewCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    BOOL firstCellInSection = indexPath.row == 0;
    BOOL lastCellInSection = indexPath.row == ([self numberOfRowsInSection:indexPath.section]-1);
    
    if (firstCellInSection || lastCellInSection) {
        [self removeExteriorCellSeparatorViewsFromCell:cell];
    }
}

- (void)configureVisibleTableViewCellsWithColumnWidth:(CGFloat)columnWidth
{
    NSArray *indexPaths = [self indexPathsForVisibleRows];
    BOOL pendingChanges = ![self.previousVisibleCells isEqualToArray:indexPaths];
    
    if (!pendingChanges) {
        return;
    }
    
    for (NSIndexPath *indexPath in indexPaths) {
        UITableViewCell *cell = [self cellForRowAtIndexPath:indexPath];
        if (cell == nil) { continue; }
    
        [self resizeView:cell forColumnWidth:columnWidth];
        [self configureStyleForTableViewCell:cell atIndexPath:indexPath];
    }
    
    self.previousVisibleCells = indexPaths;
}

#pragma mark - Layout Override -

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    //Loop through the subviews to find the wrapper view
    UIView *wrapperView = [self wrapperViewForTable];
    if (!wrapperView) { return; }
    
    CGFloat columnWidth = [self widthForCurrentSizeClass];

    // Set the width / inset of the wrapper view
    [self resizeWrapperView:wrapperView forColumnWidth:columnWidth];
    
    // Resize all non-table cell views
    [self resizeAuxiliaryViewsInWrapperView:wrapperView forColumnWidth:columnWidth];

    // Restyle and reconfigure each table view cell
    [self configureVisibleTableViewCellsWithColumnWidth:columnWidth];
}

@end
