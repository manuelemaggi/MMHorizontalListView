//
//  MMViewController.h
//  MMHorizontalListView
//
//  Created by Manuele Maggi on 02/08/13.
//  Copyright (c) 2013 Manuele Maggi. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MMHorizontalListView.h"

@interface MMViewController : UIViewController <MMHorizontalListViewDataSource, MMHorizontalListViewDelegate>

@property (strong, nonatomic) IBOutlet MMHorizontalListView *horizontalView;

@end
