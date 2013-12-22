//
//  MMLabelHorizontalListViewCell.m
//  MMHorizontalListView
//
//  Created by 曾 宪华 on 13-12-22.
//  Copyright (c) 2013年 Manuele Maggi. All rights reserved.
//

#import "MMLabelHorizontalListViewCell.h"

@implementation MMLabelHorizontalListViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 35)];
        _label.textAlignment = NSTextAlignmentCenter;
        _label.backgroundColor = [UIColor clearColor];
        _label.textColor = [UIColor blackColor];
        [self addSubview:self.label];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
