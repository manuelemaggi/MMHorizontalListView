//
//  MMHorizontalListViewCell.h
//  MMHorizontalListView
//
//  Created by Manuele Maggi on 02/08/13.
//  Copyright (c) 2013 Manuele Maggi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MMHorizontalListViewCell : UIView

@property (nonatomic, strong) NSString *reusableIdentifier;
@property (nonatomic, readonly, assign) NSUInteger index;
@property (nonatomic, readonly, assign) BOOL selected;
@property (nonatomic, readonly, assign) BOOL highlighted;

- (void)setSelected:(BOOL)selected animated:(BOOL)animated;
- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated;
@end
