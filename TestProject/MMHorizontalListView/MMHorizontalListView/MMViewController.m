//
//  MMViewController.m
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

#import "MMViewController.h"
#import "MMLabelHorizontalListViewCell.h"

@interface MMViewController ()

@end

@implementation MMViewController

- (void)scroll {
    [self.horizontalView scrollToIndex:99 animated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Scroll", @"") style:UIBarButtonItemStyleBordered target:self action:@selector(scroll)];
    
    [self.horizontalView setScrollEnabled:YES];
    
    self.horizontalView.delegate = self;
    self.horizontalView.dataSource = self;
    self.horizontalView.cellSpacing = 0;
    self.horizontalView.pagingEnabled = YES;
    
    [self.horizontalView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)MMHorizontalListViewNumberOfCells:(MMHorizontalListView *)horizontalListView {
    
    return 100;
}

- (CGFloat)MMHorizontalListView:(MMHorizontalListView *)horizontalListView widthForCellAtIndex:(NSInteger)index {
    
    return CGRectGetWidth(self.view.frame);
}

- (MMHorizontalListViewCell*)MMHorizontalListView:(MMHorizontalListView *)horizontalListView cellAtIndex:(NSInteger)index {
    
    MMLabelHorizontalListViewCell *cell = (MMLabelHorizontalListViewCell *)[horizontalListView dequeueCellWithReusableIdentifier:@"test"];
    
    if (!cell) {
        cell = [[MMLabelHorizontalListViewCell alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame))];
        cell.reusableIdentifier = @"test";
    }
    [cell.label setText:[NSString stringWithFormat:@"index : %d", index]];
    
    [cell setBackgroundColor:[UIColor colorWithRed:(arc4random() % 255)/255.0 green:(arc4random() % 255)/255.0 blue:(arc4random() % 255)/255.0 alpha:1.0]];
    
    return cell;
}

- (void)MMHorizontalListView:(MMHorizontalListView*)horizontalListView didSelectCellAtIndex:(NSInteger)index {
    
    NSLog(@"selected cell %d", index);
}

- (void)MMHorizontalListView:(MMHorizontalListView *)horizontalListView didDeselectCellAtIndex:(NSInteger)index {
    
    NSLog(@"deselected cell %d", index);
}

@end
