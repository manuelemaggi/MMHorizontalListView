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
    
    return 100;
}

- (CGFloat)MMHorizontalListViewWidthForCellAtIndex:(NSUInteger)index {
    
    return (arc4random() % 160)+ 20;
}

- (MMHorizontalListViewCell*)MMHorizontalListView:(MMHorizontalListView *)horizontalListView cellAtIndex:(NSUInteger)index {
    
    MMHorizontalListViewCell *cell = [horizontalListView dequeueCellWithReusableIdentifier:@"test"];
    
    if (!cell) {
        cell = [[MMHorizontalListViewCell alloc] initWithFrame:CGRectMake(0, 0, 160, 160)];
        cell.reusableIdentifier = @"test";
    }
    
    [cell setBackgroundColor:[UIColor colorWithRed:(arc4random() % 255)/255.0 green:(arc4random() % 255)/255.0 blue:(arc4random() % 255)/255.0 alpha:1.0]];
    
    return cell;
}

- (void)MMHorizontalListView:(MMHorizontalListView*)horizontalListView didSelectCellAtIndex:(NSUInteger)index {
    
    NSLog(@"selected cell %d", index);
    
    NSUInteger randomIndex = arc4random() % [self MMHorizontalListViewNumberOfCells:self.horizontalView];
    
    NSLog(@"random cell %d", randomIndex);
    
    [self.horizontalView scrollToIndex:randomIndex animated:YES nearestPosition:MMHorizontalListViewPositionCenter];
}

- (void)MMHorizontalListViewDidScrollToIndex:(NSUInteger)index {
    
}


@end
