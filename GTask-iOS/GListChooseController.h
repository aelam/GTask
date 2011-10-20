//
//  GListChooseController.h
//  GTask-iOS
//
//  Created by ryan on 11-10-20.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TaskList;
@protocol GListChooseDelegate;

@interface GListChooseController : UITableViewController

@property (assign) id<GListChooseDelegate> chooseDelegate;
@property (strong, nonatomic) NSMutableArray *taskLists;
@property (retain) TaskList *selectedList;

@end


@protocol GListChooseDelegate <NSObject>

- (void)listChooseController:(GListChooseController *)listController didChooseList:(TaskList *)aList;

@end