//
//  MMHorizontalListView.h
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

#import <UIKit/UIKit.h>
#import "MMHorizontalListViewCell.h"

/**< Scroll position enum type declaration */
typedef enum {
  
    MMHorizontalListViewPositionNone = 0,   /**< No specific position */
    MMHorizontalListViewPositionLeft,       /**< Cell alignment from the left side of the list view */
    MMHorizontalListViewPositionRight,      /**< Cell alignment from the right side of the list view */
    MMHorizontalListViewPositionCenter,     /**< Cell alignment at the center of the list view */
    
} MMHorizontalListViewPosition;

@class MMHorizontalListView;

/**
 *  This protocol rapresent the MMHorizontalListView datasource
 *
 *  You MUST implement all the datasource method for the correct behavior of the horizontal list, 
 *  none of them are optional.
 */
@protocol MMHorizontalListViewDataSource <NSObject>

/**
 *  Method to get the number of cells to display in the datasource
 *  
 *  @param horizontalListView - the MMHorizontalListView asking for the number if cells to diplay
 *
 *  @return NSInteger the number of cells to display
 */
- (NSInteger)MMHorizontalListViewNumberOfCells:(MMHorizontalListView*)horizontalListView;

/**
 *  Method to get the width of cell to display at a specific index
 *
 *  @param horizontalListView - the MMHorizontalListView asking for the width of the cell to diplay
 *  @param index - the given index of the cell asking for the width
 *
 *  @return CGFloat the width of the cell to display
 */
- (CGFloat)MMHorizontalListView:(MMHorizontalListView*)horizontalListView widthForCellAtIndex:(NSInteger)index;

/**
 *  Method to get the width MMHorizontalListViewCell view to display at a specific index
 *
 *  @param horizontalListView - the MMHorizontalListView asking for the MMHorizontalListViewCell view to diplay
 *  @param index - the given index of the cell asking for the view to display
 *
 *  @return MMHorizontalListViewCell the cell to display
 */
- (MMHorizontalListViewCell*)MMHorizontalListView:(MMHorizontalListView*)horizontalListView cellAtIndex:(NSInteger)index;

@end

/**
 *  This protocol rapresent the MMHorizontalListView delegate, the optional method are called to handle selections of the cells
 *
 *  MMHorizontalListViewDelegate is conform to the UIScrollViewDelegate
 */
@protocol MMHorizontalListViewDelegate <UIScrollViewDelegate>

@optional

/**
 *  Method called when a cell is selected at a specific index
 *
 *  @param horizontalListView - the MMHorizontalListView of the selected cell
 *  @param index - the given index of the selected cell
 */
- (void)MMHorizontalListView:(MMHorizontalListView*)horizontalListView didSelectCellAtIndex:(NSInteger)index;

/**
 *  Method called when a cell is deselected at a specific index
 *
 *  @param horizontalListView - the MMHorizontalListView of the deselected cell
 *  @param index - the given index of the deselected cell
 */
- (void)MMHorizontalListView:(MMHorizontalListView*)horizontalListView didDeselectCellAtIndex:(NSInteger)index;

@end

/**
 *  MMHorizontalListView is a UIScrollView subclass implementing a scrollable horizontal datasource of reusable MMHorizontalListViewCell
 *
 *  like UITableView, MMHorizontalListView implement cells reusability using an identifier that should be assinged to the same kind of cells
 */
@interface MMHorizontalListView : UIScrollView <UIScrollViewDelegate, UIGestureRecognizerDelegate> {
    
    @private
    
    __weak id<UIScrollViewDelegate> _scrollViewDelegate;
    __weak id<MMHorizontalListViewDelegate> _horizontalListDelegate;
    
    NSRecursiveLock *_mainLock;
    NSMutableArray *_cellQueue;
    NSMutableDictionary *_visibleCells;
    NSMutableArray *_cellFrames;
    NSMutableArray *_selectedIndexes;
    NSMutableArray *_highlightedIndexes;
    BOOL _editing;
}

@property (nonatomic, unsafe_unretained) id<MMHorizontalListViewDelegate> delegate;     /**< The MMHorizontalListViewDelegate is conform to UIScrollView and should be implemented to handle cells selections */
@property (nonatomic, unsafe_unretained) id<MMHorizontalListViewDataSource> dataSource; /**< The list datasource MUST be implemented to populate the list */

@property (nonatomic, assign) CGFloat cellSpacing;  /**< spacing between cells, the default value is 0.0f */

/**
 *  Method to reload the list datasource
 *
 *  Calling this method the whole datasource will be rebuilt also the contentsize of the scrollview will change, but not the contetoffset
 *  the datasource delegate method will be called to build it
 */
- (void)reloadData;

/**
 *  Method to dequeue unused cells, when a cell go outside the view bound is enqueued to be reused
 *
 *  Use this method to implement the cells reusability to save memory, each kind of cell should have is own identifier
 *  if an enqueued cell is dequeued can be reused to be displayed at a different index rather than allocate a new cell
 */
- (MMHorizontalListViewCell*)dequeueCellWithReusableIdentifier:(NSString*)identifier;

/**
 *  Method to scroll the list to a specific index, 
 *  calling this method is like call 'scrollToIndex:animated:nearestPosition:' using MMHorizontalListViewPositionNone
 *
 *  @param index - the index of the list to scroll to
 *  @param animated - perform the scrolling using an animatiom
 */
- (void)scrollToIndex:(NSInteger)index animated:(BOOL)animated;

/**
 *  Method to scroll the list to a specific index,
 *  calling this method is like call 'scrollToIndex:animated:nearestPosition:' using MMHorizontalListViewPositionNone
 *
 *  @param index - the index of the list to scroll to
 *  @param animated - perform the scrolling using an animatiom
 *  @param position - the nearest position to scroll the list to the cell's view frame
 *
 *  @discussion this method use UIScrollView 'scrollRectToVisible:animated:', if MMHorizontalListViewPositionNone is used
 *  the nearest position containing the cell frame depending to the scrolling direction.
 */
- (void)scrollToIndex:(NSInteger)index animated:(BOOL)animated nearestPosition:(MMHorizontalListViewPosition)position;

/**
 *  Method to set selected a cell at a specific index 
 *
 *  @param index - the given index to select in the datasource
 *  @param animated - select the cell using animation (the cell it self has to implement the animation)
 */
- (void)selectCellAtIndex:(NSInteger)index animated:(BOOL)animated;

/**
 *  Method to set deselected a cell at a specific index
 *
 *  @param index - the given index to deselect in the datasource
 *  @param animated - deselect the cell using animation (the cell it self has to implement the animation)
 */
- (void)deselectCellAtIndex:(NSInteger)index animated:(BOOL)animated;

/**
 *  Method to insert a cell at a specific index
 *  
 *  this method insert a cell at the given index reloading the datasource only for the visible cells including the new one
 *
 *  @param index - the given index to insert the new cell in the datasource
 *  @param animated - perform the insert using an animation
 */
- (void)insertCellAtIndex:(NSInteger)index animated:(BOOL)animated;

/**
 *  Method to insert a cell at a specific index
 *
 *  this method insert a cell at the given index reloading the datasource only for the visible cells including the new one
 *
 *  @param index - the given index to insert the new cell in the datasource
 *  @param animated - perform the insert using an animation
 */
- (void)deleteCellAtIndex:(NSInteger)index animated:(BOOL)animated;

@end
