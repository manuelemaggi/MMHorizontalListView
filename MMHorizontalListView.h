//
//  MMHorizontalListView.h
//  MMHorizontalListView
//
//  Created by Manuele Maggi on 02/08/13.
//  Copyright (c) 2013 Manuele Maggi. All rights reserved.
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

- (void)MMHorizontalListViewDidScrollToIndex:(NSUInteger)index;

@end

@interface MMHorizontalListView : UIScrollView <UIScrollViewDelegate> {
    
    @private
    
    __weak id<UIScrollViewDelegate> _scrollViewDelegate;
    __weak id<MMHorizontalListViewDelegate> _horizontalListDelegate;
    
    NSRecursiveLock *_mainLock;
    NSMutableArray *_cellQueue;
    NSMutableDictionary *_visibleCells;
    NSMutableArray *_cellFrames;
}

@property (nonatomic, unsafe_unretained) id<MMHorizontalListViewDelegate> delegate;
@property (nonatomic, unsafe_unretained) id<MMHorizontalListViewDataSource> dataSource;

@property (nonatomic, assign) CGFloat cellSpacing;

- (void)reloadData;

- (MMHorizontalListViewCell*)dequeueCellWithReusableIdentifier:(NSString*)identifier;

- (void)scrollToIndex:(NSUInteger)index animated:(BOOL)animated;

- (void)scrollToIndex:(NSUInteger)index animated:(BOOL)animated nearestPosition:(MMHorizontalListViewPosition)position;

@end
