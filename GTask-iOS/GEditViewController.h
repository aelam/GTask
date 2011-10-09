//
//  GEditViewController.h
//  GTask-iOS
//
//  Created by Ryan Wang on 11-10-9.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Task;

@interface GEditViewController : UITableViewController

@property (retain) Task *task;

@property (retain) IBOutlet UILabel *titleLabel;

@property (assign) NSInteger integer;
@property (assign) char charcter;
@property (assign) char *charcter_t;

@end
