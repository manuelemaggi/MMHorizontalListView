//
//  MMHorizontalListViewCell.m
//  MMHorizontalListView
//
//  Created by Manuele Maggi on 02/08/13.
//  Copyright (c) 2013 Manuele Maggi. All rights reserved.
//

#import "MMHorizontalListViewCell.h"

@interface MMHorizontalListViewCell ()
@property (nonatomic, readwrite, assign) NSUInteger index;
@property (nonatomic, readwrite, assign) BOOL selected;
@property (nonatomic, readwrite, assign) BOOL highlighted;
@end

@implementation MMHorizontalListViewCell

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    self.selected = selected;
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    
    self.highlighted = highlighted;
}

@end
