//
//  RWDetailViewController.h
//  GTask-iOS
//
//  Created by ryan on 11-9-19.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RWDetailViewController : UITableViewController <UISplitViewControllerDelegate>

@property (strong, nonatomic) id detailItem;

@property (strong, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

@property (strong, nonatomic) NSMutableArray *tasks;

@end
