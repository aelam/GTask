//
//  GListChooseController.h
//  GTask-iOS
//
//  Created by ryan on 11-10-20.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TaskList;

@interface GListChooseController : UITableViewController

@property (strong, nonatomic) NSMutableArray *taskLists;
@property (retain) TaskList *selectedList;

@end
