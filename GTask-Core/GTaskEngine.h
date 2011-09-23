//
//  GTaskEngine.h
//  GTask-iOS
//
//  Created by ryan on 11-9-23.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "GDataEngine.h"

@class TaskList;
@class Task;

@interface GTaskEngine : GDataEngine

+ (GTaskEngine *)sharedEngine;
+ (GTaskEngine *)engine;

// Lists
- (NSMutableArray *)localTaskListsWithSortType:(NSInteger)sortType;

- (void)fetchServerTaskListsWithResultHander:(void(^)(GTaskEngine *,NSMutableArray *))resultHander;
- (void)localTaskLists;
- (void)syncTaskList;

// Tasks
- (void)fetchServerTasksForList:(TaskList *)aList resultHander:(void(^)(GTaskEngine *,NSMutableArray *))resultHander;
- (void)localTasks;
- (void)syncTasks;

@end
