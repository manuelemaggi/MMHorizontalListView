MMHorizontalListView
====================

An horizontal list scrol view designed to implement cells reusability 

**INSTALL:**

Import MMHorizontalListView (.h .m) and MMHorizontalListView (.h .m) in your project

**HOW TO USE:**

1.  Create and add to a view an instance of MMHorizontalListView.

        MMHorizontalListView *listView = [[MMHorizontalListView alloc] initWithFrame:self.view.frame];

2.  assign the datasource and the delegate, the delegate is optional but not the datasource

        listView.dataSource = self;
        listView.delegate = self;
            
3.  Implement the dataSource and delegate mehtods

    in the interface of the class implementing the protocols...
        
        @interface MMViewController : UIViewController <MMHorizontalListViewDataSource, MMHorizontalListViewDelegate>
      
    in the implementaion of the same class (that must be the instance assigned to delegate and dataSource properties)
        
        #pragma mark - MMHorizontalListViewDatasource methods
        
        - (NSInteger)MMHorizontalListViewNumberOfCells:(MMHorizontalListView *)horizontalListView {
    
            return 100; // the number of cell to display is your data source
        }

        - (CGFloat)MMHorizontalListView:(MMHorizontalListView *)horizontalListView widthForCellAtIndex:(NSInteger)index {
    
            return 160;
        }
  
        - (MMHorizontalListViewCell*)MMHorizontalListView:(MMHorizontalListView *)horizontalListView cellAtIndex:(NSInteger)index {
    
            // dequeue cell for reusability
            MMHorizontalListViewCell *cell = [horizontalListView dequeueCellWithReusableIdentifier:@"test"];
    
            if (!cell) {
                cell = [[MMHorizontalListViewCell alloc] initWithFrame:CGRectMake(0, 0, 160, 160)];
                cell.reusableIdentifier = @"test";  // assign the cell identifier for reusability
            }
    
            [cell setBackgroundColor:[UIColor blackColor];
    
            return cell;
        }
        
        #pragma mark - MMHorizontalListViewDelegate methods
        
        - (void)MMHorizontalListView:(MMHorizontalListView*)horizontalListView didSelectCellAtIndex:(NSInteger)index {
    
            //do something when a cell is selected
            NSLog(@"selected cell %d", index);
        }

        - (void)MMHorizontalListView:(MMHorizontalListView *)horizontalListView didDeselectCellAtIndex:(NSInteger)index {
    
            // do something when a cell is deselected
            NSLog(@"deselected cell %d", index);
        }
        
