//
//  MMViewController.m
//  MMHorizontalListView
//
//  Created by Manuele Maggi on 02/08/13.
//  Copyright (c) 2013 Manuele Maggi. All rights reserved.
//

#import "MMViewController.h"

@interface MMViewController ()

@end

@implementation MMViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [self.horizontalView setScrollEnabled:YES];
    
    self.horizontalView.delegate = self;
    self.horizontalView.dataSource = self;
    self.horizontalView.cellSpacing = 20.0;
    
    [self.horizontalView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSUInteger)MMHorizontalListViewNumberOfCells:(MMHorizontalListView *)horizontalListView {
    
    return 20;
}

- (CGFloat)MMHorizontalListViewWidthForCellAtIndex:(NSUInteger)index {
    
    return 160;
}

- (MMHorizontalListViewCell*)MMHorizontalListView:(MMHorizontalListView *)horizontalListView cellAtIndex:(NSUInteger)index {
    
    MMHorizontalListViewCell *cell = [horizontalListView dequeueCellWithReusableIdentifier:@"test"];
    
    if (!cell) {
        cell = [[MMHorizontalListViewCell alloc] initWithFrame:CGRectMake(0, 0, 160, 160)];
        cell.reusableIdentifier = @"test";
    }
    
    [cell setBackgroundColor:[UIColor blueColor]];
    
    return cell;
}

- (void)MMHorizontalListView:(MMHorizontalListView*)horizontalListView didSelectCellAtIndex:(NSUInteger)index {
    
}

- (void)MMHorizontalListViewDidScrollToIndex:(NSUInteger)index {
    
}


@end
