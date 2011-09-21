//
//  RWMasterViewController.h
//  GTask-iOS
//
//  Created by ryan on 11-9-19.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RWDetailViewController;

@interface RWMasterViewController : UITableViewController

@property (strong, nonatomic) RWDetailViewController *detailViewController;

@end
