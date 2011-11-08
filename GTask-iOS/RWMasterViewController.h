//
//  RWMasterViewController.h
//  GTask-iOS
//
//  Created by ryan on 11-9-19.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RWDetailViewController;
@class GAddListController;

@interface RWMasterViewController : UITableViewController

@property (strong, nonatomic) RWDetailViewController *detailViewController;
@property (strong, nonatomic) NSMutableArray *taskLists;

@property (strong, nonatomic) NSMutableArray *customCategories;

- (IBAction)addNewList:(id)sender;

- (void)addListCancelled:(GAddListController *)addListController;
- (void)addListFinished:(GAddListController *)addListController;

@end
