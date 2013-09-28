//
//  MMHorizontalListView.m
//  MMHorizontalListView
//
// Version 1.0
//
// Created by Manuele Maggi on 02/08/13.
// email: manuele.maggi@gmail.com
// Copyright (c) 2013-present Manuele Maggi. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import "MMHorizontalListView.h"

#define kInsertDeleteDuration   0.5

#define sign(value) ({ (value) >= 0 ? 1 : -1; })

typedef enum {
    
    MM_EditingOptionNone    = 0,
    MM_EditingOptionAdd     = 1 << 0,
    MM_EditingOptionDelete  = 1 << 1,
    
} MM_EditingOption;

@interface MMTapGestureRecognizer : UITapGestureRecognizer
@end

@implementation MMTapGestureRecognizer
@end

@implementation MMHorizontalListView

@synthesize dataSource;
@synthesize cellSpacing;

#pragma mark - Object life cycle

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self initiliase];
    }

    return self;
}

- (void)awakeFromNib {
    
    [super awakeFromNib];
    
    [self initiliase];
}

- (void)dealloc {
    
#if !__has_feature(objc_arc)
    [_mainLock release];
    [_callQueue release];
    [_visibleCells release];
    [_cellFrames release];
    [_selectedIndexes release];
    [_highlightedIndexes release];
    [super dealloc];
#endif
    
    _mainLock = nil;
    _cellQueue = nil;
}

- (void)initiliase {
    
    _mainLock = [[NSRecursiveLock alloc] init];
    _cellQueue = [[NSMutableArray alloc] init];
    _visibleCells = [[NSMutableDictionary alloc] init];
    _cellFrames = [[NSMutableArray alloc] init];
    _selectedIndexes = [[NSMutableArray alloc] init];
    _highlightedIndexes = [[NSMutableArray alloc] init];
}

#pragma mark - Public interface

- (void)reloadData {
    
    [_mainLock lock];
    
    // clean up old cells
    [[_visibleCells allValues] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [_visibleCells removeAllObjects];
    [_cellFrames removeAllObjects];
    [_selectedIndexes removeAllObjects];
    [_highlightedIndexes removeAllObjects];
    
    // calculate the scrollview content size and setUp the cell destination frame list
    
    NSInteger numberOfCells = [self.dataSource MMHorizontalListViewNumberOfCells:self];
    
    CGFloat contentWidth = 0.0;
    
    for (int i=0; i < numberOfCells; i++) {
        
        CGFloat cellWidth = [self.dataSource MMHorizontalListView:self widthForCellAtIndex:i];

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
        reusableCell = [reusableCells objectAtIndex:0];
        [_cellQueue removeObjectAtIndex:0];
    }
    
    [_mainLock unlock];
    
    return reusableCell;
}

- (void)scrollToIndex:(NSInteger)index animated:(BOOL)animated {
    
    [self scrollToIndex:index animated:animated nearestPosition:MMHorizontalListViewPositionNone];
}

- (void)scrollToIndex:(NSInteger)index animated:(BOOL)animated nearestPosition:(MMHorizontalListViewPosition)position {
    
    [_mainLock lock];
    
    NSString *frameString = [_cellFrames objectAtIndex:index];
    CGRect cellVisibleFrame = CGRectFromString(frameString);
    
    switch (position) {
            
        case MMHorizontalListViewPositionLeft:
            cellVisibleFrame.size = self.frame.size;
            break;
            
        case MMHorizontalListViewPositionRight:
            cellVisibleFrame.origin.x += cellVisibleFrame.size.width - self.frame.size.width;
            cellVisibleFrame.size = self.frame.size;
            break;
            
        case MMHorizontalListViewPositionCenter:
            cellVisibleFrame.origin.x -= (self.frame.size.width - cellVisibleFrame.size.width)/2;
            cellVisibleFrame.size = self.frame.size;
            break;
            
        default:
        case MMHorizontalListViewPositionNone:
            break;
    }
    
    if (cellVisibleFrame.origin.x < 0.0) {
        cellVisibleFrame.origin.x = 0.0;
    }
    else if (cellVisibleFrame.origin.x > self.contentSize.width - self.frame.size.width) {
        cellVisibleFrame.origin.x = self.contentSize.width - self.frame.size.width;
    }
    
    [self scrollRectToVisible:cellVisibleFrame animated:animated];
    
    [_mainLock unlock];
}

- (void)selectCellAtIndex:(NSInteger)index animated:(BOOL)animated {
    
    [_mainLock lock];
    
    NSString *frameString = [_cellFrames objectAtIndex:index];
    
    if (![_selectedIndexes containsObject:@(index)]) {
        [_selectedIndexes addObject:@(index)];
    }
    
    MMHorizontalListViewCell *cell = [_visibleCells objectForKey:frameString];
    if (cell) {
        [cell setSelected:YES animated:animated];
    }
    
    [_mainLock unlock];
}

- (void)deselectCellAtIndex:(NSInteger)index animated:(BOOL)animated {
    
    [_mainLock lock];
    
    NSString *frameString = [_cellFrames objectAtIndex:index];
    
    if ([_selectedIndexes containsObject:@(index)]) {
        [_selectedIndexes removeObject:@(index)];
    }
    
    MMHorizontalListViewCell *cell = [_visibleCells objectForKey:frameString];
    if (cell) {
        [cell setSelected:NO animated:animated];
    }
    
    [_mainLock unlock];
}

- (void)insertCellAtIndex:(NSInteger)index animated:(BOOL)animated {
    
    [_mainLock lock];
    
    _editing = TRUE;
    
    // get the new cell width from the data source, needed to build the new cell frame and the offset to move the cells on the right
    CGFloat newCellWidth = [self.dataSource MMHorizontalListView:self widthForCellAtIndex:index];

    CGFloat newCellXOrigin = 0.0;
    
    // build the new area reserved for the new cell, from the existing cell (if exist)
    if (index < [_cellFrames count]) {
        
        // get the origin of the cell to insert
        NSString *indexFrameKey = [_cellFrames objectAtIndex:index];
        CGRect indexFrame = CGRectFromString(indexFrameKey);
        newCellXOrigin = indexFrame.origin.x;
    }
    else {
        
        NSString *indexFrameKey = [_cellFrames lastObject];
        CGRect indexFrame = CGRectFromString(indexFrameKey);
        newCellXOrigin = indexFrame.origin.x + indexFrame.size.width + self.cellSpacing;
    }
    
    // move all the cell at the right of the given index
    [self moveCellsFromIndex:index withOffset:newCellWidth animated:animated completion:^(BOOL finished) {
                
            // rebase the already selected indexes
            [self rebaseSelectionFromIndex:index withOption:MM_EditingOptionAdd];
            
            // add the new frame to the list
            CGRect newIndexFrame = CGRectMake(newCellXOrigin, 0.0, newCellWidth, self.frame.size.height);
            NSString *newIndexFrameKey = NSStringFromCGRect(newIndexFrame);
            [_cellFrames insertObject:newIndexFrameKey atIndex:index];
            
            // check if the rect is visible and add the cell if necessary
            if (CGRectIntersectsRect([self visibleRect], newIndexFrame)) {
                [self addCellAtIndex:index];
            }
        
        _editing = FALSE;

    }];    

    [_mainLock unlock];
}

- (void)deleteCellAtIndex:(NSInteger)index animated:(BOOL)animated {
    
    [_mainLock lock];
    
    _editing = TRUE;
    
    // get the frame key of the cell to remove
    NSString *frameKey = [_cellFrames objectAtIndex:index];
  
    // get the cell to remove if is visible and enqueue it
    MMHorizontalListViewCell *cell = [_visibleCells objectForKey:frameKey];
    if (cell) {
        [self enqueueCell:cell forKey:frameKey];
    }
    
    // cell to remove's frame necessary to get the offset to move the cell on the right
    CGRect cellFrame = CGRectFromString(frameKey);
    
    //add the cell that will be visible after deleting the cell
    for (int i=index+1; i<[_cellFrames count]; i++) {
        
        NSString *nextVisibleCellFrameString = [_cellFrames objectAtIndex:i];
        CGRect nextVisibleCellFrame = CGRectFromString(nextVisibleCellFrameString);
        nextVisibleCellFrame.origin.x -= (cellFrame.size.width + self.cellSpacing);
        
        CGRect visibleRect = [self visibleRect];
        
        if ([_visibleCells objectForKey:nextVisibleCellFrameString]) {
            
            continue;   // if the cell is already visible continue to the next loop
        }
        else if (CGRectIntersectsRect(nextVisibleCellFrame, visibleRect)) {
            
            [self addCellAtIndex:i];    // if the cell will be visible add it
        }
        else {
            
            break;  // if the cell won't be visible will be the same for the rest of the cells so exit the loop
        }
    }
    
    // move the cell on the right of the cell to remove
    [self moveCellsFromIndex:index+1 withOffset:-cellFrame.size.width animated:animated completion:^(BOOL finished) {
        
        // rebase the already selected indexes
        [self rebaseSelectionFromIndex:index withOption:MM_EditingOptionDelete];
        
        // remove the cell's frame key from the list
        [_cellFrames removeObjectAtIndex:index];
        
        _editing = FALSE;
    }];
    
    [_mainLock unlock];
}

#pragma mark - Private methods

- (NSInteger)indexOfCell:(MMHorizontalListViewCell*)cell {
    
    CGRect frame = cell.frame;
    
    frame.size.height = self.frame.size.height;
    frame.origin.y = 0.0f;
    
    return [_cellFrames indexOfObject:NSStringFromCGRect(frame)];
}

- (void)addCellAtIndex:(NSInteger)index {
    
    MMHorizontalListViewCell *cell = [self.dataSource MMHorizontalListView:self cellAtIndex:index];
    
    NSString *frameString = [_cellFrames objectAtIndex:index];
    
    [_visibleCells setObject:cell forKey:frameString];
    
    CGRect cellDestinationFrame = CGRectFromString(frameString);
    
    [cell setFrame:cellDestinationFrame];
    
    MMTapGestureRecognizer *tap = [[MMTapGestureRecognizer alloc] initWithTarget:self action:@selector(cellTap:)];
    tap.delegate = self;
    [cell addGestureRecognizer:tap];
    
    [self addSubview:cell];
}

- (NSArray*)visibleIndexes {
    
    NSMutableArray *visibleIndexes = [NSMutableArray array];
    
    [_mainLock lock];
    
    BOOL canBreak = FALSE;  // for a shorter loop... after the first match the next fail mean no more visible cells
    
    for (int i=0; i < [_cellFrames count]; i++) {
        
        NSString *frameString = [_cellFrames objectAtIndex:i];
        CGRect cellDestinationFrame = CGRectFromString(frameString);
        
        if (CGRectIntersectsRect([self visibleRect], cellDestinationFrame)) {
            canBreak = TRUE;
            [visibleIndexes addObject:[NSNumber numberWithUnsignedInteger:i]];
        }
        else if (canBreak) {
            break;
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
        
        // handle selection
        BOOL selected = [_selectedIndexes containsObject:index];
        MMHorizontalListViewCell *cell = [_visibleCells objectForKey:frameString];
        [cell setSelected:selected animated:NO];
    }
    
    // enqueue unused cells
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
    
    cell.frame = CGRectZero;
    
    NSArray *gestures = cell.gestureRecognizers;
    for (MMTapGestureRecognizer *gesture in gestures) {
        if ([gesture isKindOfClass:[MMTapGestureRecognizer class]]) {
            [cell removeGestureRecognizer:gesture];
        }
    }
        
    [_visibleCells removeObjectForKey:frameKey];

    [_mainLock unlock];
}

- (void)highlightCellAtIndex:(NSInteger)index animated:(BOOL)animated {
    
    [_mainLock lock];
    
    NSString *frameString = [_cellFrames objectAtIndex:index];
    
    if (![_highlightedIndexes containsObject:frameString]) {
        [_highlightedIndexes addObject:frameString];
    }
    
    MMHorizontalListViewCell *cell = [_visibleCells objectForKey:frameString];
    if (cell) {
        [cell setHighlighted:YES animated:animated];
    }
    
    [_mainLock unlock];
}

- (void)unhighlightCellAtIndex:(NSInteger)index animated:(BOOL)animated {
    
    [_mainLock lock];
    
    NSString *frameString = [_cellFrames objectAtIndex:index];
    
    if ([_highlightedIndexes containsObject:frameString]) {
        [_highlightedIndexes removeObject:frameString];
    }
    
    MMHorizontalListViewCell *cell = [_visibleCells objectForKey:frameString];
    if (cell) {
        [cell setHighlighted:NO animated:animated];
    }
    
    [_mainLock unlock];
}

- (void)moveCellsFromIndex:(NSInteger)index withOffset:(CGFloat)offset animated:(BOOL)animated completion:(void (^)(BOOL finished))completion {
    
    NSInteger currentCellCount = [_cellFrames count];
    
    NSMutableArray *toMoveFrames = nil;
    NSMutableDictionary *cellsToMove = nil;
    
    if (index < currentCellCount) {
        
        // frames at the right of the index to insert
        NSRange rightFramesRange = NSMakeRange(index, currentCellCount - index);
        NSArray *rightFrames = [_cellFrames subarrayWithRange:rightFramesRange];
        
        // move the frames at the right of the index
        toMoveFrames = [NSMutableArray arrayWithCapacity:[rightFrames count]];
        cellsToMove = [NSMutableDictionary dictionary];
        
        for (NSString *frameKey in rightFrames) {
            
            CGRect rightFrame = CGRectFromString(frameKey);
            rightFrame.origin.x += (offset + sign(offset)*self.cellSpacing);
            
            NSString *newFrameKey = NSStringFromCGRect(rightFrame);
            [toMoveFrames addObject:newFrameKey];

            // visible cell to move from frameKey to newFrameKey
            MMHorizontalListViewCell *rightCell = [_visibleCells objectForKey:frameKey];
            
            if (rightCell != nil) {
                [cellsToMove setObject:rightCell forKey:newFrameKey];
                [_visibleCells removeObjectForKey:frameKey];
            }
        }
        
        // remove old frames at thre right
        [_cellFrames removeObjectsInRange:rightFramesRange];
    }
    
    // add pushed frames at the right of the new index
    [_cellFrames addObjectsFromArray:toMoveFrames];
    
    __block BOOL userInteraction = self.userInteractionEnabled;
    
    [self setUserInteractionEnabled:NO];

    //adjust content size
    CGSize newContentSize = self.contentSize;
    newContentSize.width += (offset + sign(offset)*self.cellSpacing);
    self.contentSize = newContentSize;
    
    __block NSMutableDictionary *toEnqueCells = [[NSMutableDictionary alloc] init];
    
    [UIView animateWithDuration:kInsertDeleteDuration*animated
                          delay:0.0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         
                         // move visible cells
                         NSArray *toPushFrameKeys = [cellsToMove allKeys];
                         for (NSString *newFrameKey in toPushFrameKeys) {
                             
                             // get the cell to push
                             MMHorizontalListViewCell *cell = [cellsToMove objectForKey:newFrameKey];
                             [_visibleCells setObject:cell forKey:newFrameKey];
                                                          
                             // push with animation if needed
                             CGRect newDestinationFrame = CGRectFromString(newFrameKey);
                             
                             [cell setFrame:newDestinationFrame];
                             
                             if (!CGRectIntersectsRect([self visibleRect], newDestinationFrame)) {
                                 [toEnqueCells setObject:cell forKey:newFrameKey];
                             }
                         }
                     }
                     completion:^(BOOL finished) {
                         
                         NSArray *toEnqueFrameKeys = [toEnqueCells allKeys];
                         
                         for (NSString *toEnqueFrameKey in toEnqueFrameKeys) {
                             
                             MMHorizontalListViewCell *toEnqueCell = [toEnqueCells objectForKey:toEnqueFrameKey];
                             [self enqueueCell:toEnqueCell forKey:toEnqueFrameKey];
                         }
                         
                         // restore the original state of user interaction
                         [self setUserInteractionEnabled:userInteraction];
                         
                         completion(finished);
                     }];
}

- (void)rebaseSelectionFromIndex:(NSInteger)index withOption:(MM_EditingOption)options {
    
    NSInteger step = 0;
    
    if (options & MM_EditingOptionAdd) {
        step = 1;
    }
    else if (options & MM_EditingOptionDelete) {
        step = -1;
    }
    else {  // MM_EditingOptionNone or out of definition range
        return;
    }
    
    [_selectedIndexes sortUsingSelector:@selector(compare:)];
    NSInteger selectedIndex = [_selectedIndexes indexOfObject:[NSNumber numberWithInteger:index]];
    if (selectedIndex != NSNotFound) {
        
        for (int i=selectedIndex; i<[_selectedIndexes count]; i++) {
            
            NSNumber *selected = [_selectedIndexes objectAtIndex:i];
            selected = [NSNumber numberWithInteger:([selected integerValue]+step)];
            [_selectedIndexes replaceObjectAtIndex:i withObject:selected];
        }
    }    
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

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    
    if ([gestureRecognizer isKindOfClass:[MMTapGestureRecognizer class]]) {
        
        MMHorizontalListViewCell *cell = (MMHorizontalListViewCell *)((MMTapGestureRecognizer*)gestureRecognizer).view;
        
        NSInteger index = [self indexOfCell:cell];
        
        [self highlightCellAtIndex:index animated:NO];
    }
    
    return TRUE;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    
    BOOL shouldRecognize = TRUE;
    
    if ([gestureRecognizer isKindOfClass:[MMTapGestureRecognizer class]]) {
        
        MMHorizontalListViewCell *cell = (MMHorizontalListViewCell *)((MMTapGestureRecognizer*)gestureRecognizer).view;
        
        NSInteger index = [self indexOfCell:cell];

        [self unhighlightCellAtIndex:index animated:NO];
        
        shouldRecognize = NO;
    }
    
    return shouldRecognize;
}

- (void)cellTap:(id)sender {
    
    MMHorizontalListViewCell *cell = (MMHorizontalListViewCell *)((MMTapGestureRecognizer*)sender).view;
    
    NSInteger index = [self indexOfCell:cell];

    [self unhighlightCellAtIndex:index animated:NO];
    
    BOOL select = ![_selectedIndexes containsObject:@(index)];
    if (select) {
        [self selectCellAtIndex:index animated:NO];
    }
    else {
        [self deselectCellAtIndex:index animated:NO];
    }
    
    if (select && [_horizontalListDelegate respondsToSelector:@selector(MMHorizontalListView:didSelectCellAtIndex:)]) {
        [_horizontalListDelegate MMHorizontalListView:self didSelectCellAtIndex:index];
    }
    else if (!select && [_horizontalListDelegate respondsToSelector:@selector(MMHorizontalListView:didDeselectCellAtIndex:)]) {
        [_horizontalListDelegate MMHorizontalListView:self didDeselectCellAtIndex:index];
    }
}

#pragma mark - UIScrollViewDelegste

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (!_editing) {
        [self updateVisibleCells];
    }
        
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
