//
//  MMHorizontalListView.m
//  MMHorizontalListView
//
//  Created by Manuele Maggi on 02/08/13.
//  Copyright (c) 2013 Manuele Maggi. All rights reserved.
//

#import "MMHorizontalListView.h"

// Cell class extension to access properties setter
@interface MMHorizontalListViewCell ()
@property (nonatomic, readwrite, assign) NSUInteger index;
@end

@interface MMGestureRecognizer : UITapGestureRecognizer
@end

@implementation MMGestureRecognizer
@end

@implementation MMHorizontalListView

@synthesize dataSource;
@synthesize cellSpacing;

#pragma mark - Object life cycle

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

        _mainLock = [[NSRecursiveLock alloc] init];
        _cellQueue = [[NSMutableArray alloc] init];
        _visibleCells = [[NSMutableDictionary alloc] init];
        _cellFrames = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)awakeFromNib {
    
    _mainLock = [[NSRecursiveLock alloc] init];
    _cellQueue = [[NSMutableArray alloc] init];
    _visibleCells = [[NSMutableDictionary alloc] init];
    _cellFrames = [[NSMutableArray alloc] init];
}

- (void)dealloc {
    
#if !__has_feature(objc_arc)
    
    [_mainLock release];
    [_callQueue release];
    [_visibleCells release];
    [_cellFrames release];
    [super dealloc];
#endif
    
    _mainLock = nil;
    _cellQueue = nil;
}

#pragma mark - Public interface

- (void)reloadData {
    
    [_mainLock lock];
    
    // clean up old cells
    [[_visibleCells allValues] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [_visibleCells removeAllObjects];
    [_cellFrames removeAllObjects];
    
    // calculate the scrollview content size and setUp the cell destination frame list
    
    NSUInteger numberOfCells = [self.dataSource MMHorizontalListViewNumberOfCells:self];
    
    CGFloat contentWidth = 0.0;
    
    for (int i=0; i < numberOfCells; i++) {
        
        CGFloat cellWidth = [self.dataSource MMHorizontalListViewWidthForCellAtIndex:i];

        CGRect cellDestinationFrame = CGRectMake(contentWidth, 0.0, cellWidth, self.frame.size.height);

        contentWidth += cellWidth;
        contentWidth += ((numberOfCells > 1 && i < numberOfCells - 1) ? self.cellSpacing : 0.0);
        
        [_cellFrames addObject:NSStringFromCGRect(cellDestinationFrame)];
    }
    
    self.contentSize = CGSizeMake(contentWidth, self.frame.size.height);
    
    // add the visible cells
    [self updateVisibleCells];
    
    [_mainLock unlock];
}

- (MMHorizontalListViewCell*)dequeueCellWithReusableIdentifier:(NSString *)identifier {
    
    MMHorizontalListViewCell *reusableCell = nil;
    
    [_mainLock lock];
    
    NSPredicate *identifierPredicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        MMHorizontalListViewCell *cell = (MMHorizontalListViewCell*)evaluatedObject;
        
        return [cell.reusableIdentifier isEqualToString:identifier];
    }];
    
    NSArray *reusableCells = [_cellQueue filteredArrayUsingPredicate:identifierPredicate];
    
    if ([reusableCells count] > 0) {
        reusableCell = [reusableCells lastObject];
        [_cellQueue removeObject:reusableCell];
    }
    
    [_mainLock unlock];
    
    return reusableCell;
}

- (void)scrollToIndex:(NSUInteger)index animated:(BOOL)animated {
    
    [_mainLock lock];
    
    NSString *frameString = [_cellFrames objectAtIndex:index];
    CGRect cellVisibleFrame = CGRectFromString(frameString);
    
    [self scrollRectToVisible:cellVisibleFrame animated:animated];
    
    [_mainLock unlock];
}

#pragma mark - Private methods

- (void)addCellAtIndex:(NSUInteger)index {
    
    MMHorizontalListViewCell *cell = [self.dataSource MMHorizontalListView:self cellAtIndex:index];
    
    cell.index = index;
    
    NSString *frameString = [_cellFrames objectAtIndex:index];
    
    [_visibleCells setObject:cell forKey:frameString];
    
    CGRect cellDestinationFrame = CGRectFromString(frameString);

    CGRect cellFrame = cell.frame;
    cellFrame.size.width = cellDestinationFrame.size.width;
    cellFrame.origin.x = cellDestinationFrame.origin.x;
    cellFrame.origin.y = (cellDestinationFrame.size.height - cellFrame.size.height)/2;
    
    [cell setFrame:cellFrame];
    
    MMGestureRecognizer *tap = [[MMGestureRecognizer alloc] initWithTarget:self action:@selector(cellTap:)];
    [cell addGestureRecognizer:tap];
    
    [self addSubview:cell];
}

- (NSArray*)visibleIndexes {
    
    NSMutableArray *visibleIndexes = [NSMutableArray array];
    
    [_mainLock lock];
    
    for (int i=0; i < [_cellFrames count]; i++) {
        
        NSString *frameString = [_cellFrames objectAtIndex:i];
        CGRect cellDestinationFrame = CGRectFromString(frameString);
        
        if (CGRectIntersectsRect([self visibleRect], cellDestinationFrame)) {
            
            [visibleIndexes addObject:[NSNumber numberWithUnsignedInteger:i]];
        }
    }
    
    [_mainLock unlock];
    
    return [NSArray arrayWithArray:visibleIndexes];
}

- (CGRect)visibleRect {
    
    CGRect visibleRect;
    
    visibleRect.origin = self.contentOffset;
    visibleRect.size = self.frame.size;
    
    return visibleRect;
}

- (void)updateVisibleCells {
    
    [_mainLock lock];
    
    NSArray *visibleIndexes = [self visibleIndexes];
    
    NSMutableArray *nonVisibleCellKeys = [NSMutableArray arrayWithArray:[_visibleCells allKeys]];
    
    for (NSNumber *index in visibleIndexes) {
        
        NSString * frameString = [_cellFrames objectAtIndex:[index unsignedIntegerValue]];
        
        // already on view
        if ([nonVisibleCellKeys containsObject:frameString]) {
            [nonVisibleCellKeys removeObject:frameString];
        }
        else {
            [self addCellAtIndex:[index unsignedIntegerValue]];
        }
    }
    
    // enqueue cells
    for (NSString *unusedCellKey in nonVisibleCellKeys) {
        
        MMHorizontalListViewCell *cell = [_visibleCells objectForKey:unusedCellKey];
        [self enqueueCell:cell forKey:unusedCellKey];
    }
    
    [_mainLock unlock];
}

- (void)enqueueCell:(MMHorizontalListViewCell*)cell forKey:(NSString*)frameKey {
    
    [_mainLock lock];
    
    [_cellQueue addObject:cell];
    [cell removeFromSuperview];
    
    NSArray *gestures = cell.gestureRecognizers;
    for (MMGestureRecognizer *gesture in gestures) {
        if ([gesture isKindOfClass:[MMGestureRecognizer class]]) {
            [cell removeGestureRecognizer:gesture];
        }
    }
    
    cell.index = -1;
    
    [_visibleCells removeObjectForKey:frameKey];

    [_mainLock unlock];
}

#pragma mark - Override methods

- (void)setDelegate:(id<MMHorizontalListViewDelegate>)delegate {
    
    [super setDelegate:self];
    
    _horizontalListDelegate = delegate;
}

- (void)setFrame:(CGRect)frame {
    
    [super setFrame:frame];
    
    [self reloadData];
}

#pragma mark - GestureRecognized Delegate/Action

- (void)cellTap:(id)sender {
    
    MMHorizontalListViewCell *cell = (MMHorizontalListViewCell *)((MMGestureRecognizer*)sender).view;
    
    if ([_horizontalListDelegate respondsToSelector:@selector(MMHorizontalListView:didSelectCellAtIndex:)]) {
        [_horizontalListDelegate MMHorizontalListView:self didSelectCellAtIndex:cell.index];
    }
}

#pragma mark - UIScrollViewDelegste

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    [self updateVisibleCells];
    
    if ([_horizontalListDelegate respondsToSelector:@selector(scrollViewDidScroll:)]) {
        [_horizontalListDelegate scrollViewDidScroll:scrollView];
    }
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    
    if ([_horizontalListDelegate respondsToSelector:@selector(scrollViewDidZoom:)]) {
        [_horizontalListDelegate scrollViewDidZoom:scrollView];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    if ([_horizontalListDelegate respondsToSelector:@selector(scrollViewWillBeginDragging:)]) {
        [_horizontalListDelegate scrollViewWillBeginDragging:scrollView];
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    
    if ([_horizontalListDelegate respondsToSelector:@selector(scrollViewWillEndDragging:withVelocity:targetContentOffset:)]) {
        [_horizontalListDelegate scrollViewWillEndDragging:scrollView withVelocity:velocity targetContentOffset:targetContentOffset];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
    if ([_horizontalListDelegate respondsToSelector:@selector(scrollViewDidEndDragging:willDecelerate:)]) {
        [_horizontalListDelegate scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    }
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    
    if ([_horizontalListDelegate respondsToSelector:@selector(scrollViewWillBeginDecelerating:)]) {
        [_horizontalListDelegate scrollViewWillBeginDecelerating:scrollView];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {

    if ([_horizontalListDelegate respondsToSelector:@selector(scrollViewDidEndDecelerating:)]) {
        [_horizontalListDelegate scrollViewDidEndDecelerating:scrollView];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {

    if ([_horizontalListDelegate respondsToSelector:@selector(scrollViewDidEndScrollingAnimation:)]) {
        [_horizontalListDelegate scrollViewDidEndScrollingAnimation:scrollView];
    }
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    
    UIView *view = nil;
    
    if ([_horizontalListDelegate respondsToSelector:@selector(viewForZoomingInScrollView:)]) {
        view = [_horizontalListDelegate viewForZoomingInScrollView:scrollView];
    }
    
    return view;
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view {

    if ([_horizontalListDelegate respondsToSelector:@selector(scrollViewWillBeginZooming:withView:)]) {
        [_horizontalListDelegate scrollViewWillBeginZooming:scrollView withView:view];
    }
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale {
    
    if ([_horizontalListDelegate respondsToSelector:@selector(scrollViewDidEndZooming:withView:atScale:)]) {
        [_horizontalListDelegate scrollViewDidEndZooming:scrollView withView:view atScale:scale];
    }
}
- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView {
    
    BOOL shouldScroll = YES;
    
    if ([_horizontalListDelegate respondsToSelector:@selector(scrollViewShouldScrollToTop:)]) {
        shouldScroll = [_horizontalListDelegate scrollViewShouldScrollToTop:scrollView];
    }
    
    return shouldScroll;
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView {
    
    if ([_horizontalListDelegate respondsToSelector:@selector(scrollViewDidScrollToTop)]) {
        [_horizontalListDelegate scrollViewDidScrollToTop:scrollView];
    }
}

@end
