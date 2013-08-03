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

typedef enum {
  
    MMHorizontalListViewPositionNone = 0,
    MMHorizontalListViewPositionLeft,
    MMHorizontalListViewPositionRight,
    MMHorizontalListViewPositionCenter,
    
} MMHorizontalListViewPosition;

@class MMHorizontalListView;

@protocol MMHorizontalListViewDataSource <NSObject>

- (NSUInteger)MMHorizontalListViewNumberOfCells:(MMHorizontalListView*)horizontalListView;

- (CGFloat)MMHorizontalListViewWidthForCellAtIndex:(NSUInteger)index;

- (MMHorizontalListViewCell*)MMHorizontalListView:(MMHorizontalListView*)horizontalListView cellAtIndex:(NSUInteger)index;

@end

@protocol MMHorizontalListViewDelegate <UIScrollViewDelegate>

@optional

- (void)MMHorizontalListView:(MMHorizontalListView*)horizontalListView didSelectCellAtIndex:(NSUInteger)index;

- (void)MMHorizontalListView:(MMHorizontalListView*)horizontalListView didDeselectCellAtIndex:(NSUInteger)index;

@end

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
}

@property (nonatomic, unsafe_unretained) id<MMHorizontalListViewDelegate> delegate;
@property (nonatomic, unsafe_unretained) id<MMHorizontalListViewDataSource> dataSource;

@property (nonatomic, assign) CGFloat cellSpacing;

- (void)reloadData;

- (MMHorizontalListViewCell*)dequeueCellWithReusableIdentifier:(NSString*)identifier;

- (void)scrollToIndex:(NSUInteger)index animated:(BOOL)animated;

- (void)scrollToIndex:(NSUInteger)index animated:(BOOL)animated nearestPosition:(MMHorizontalListViewPosition)position;

- (void)selectCellAtIndex:(NSUInteger)index animated:(BOOL)animated;

- (void)deselectCellAtIndex:(NSUInteger)index animated:(BOOL)animated;

@end
