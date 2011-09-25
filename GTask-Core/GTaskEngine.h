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

- (void)fetchServerTaskListsWithResultHander:(void(^)(GTaskEngine *,NSMutableArray *))resultHander;

- (NSMutableArray *)localTaskLists;
- (NSMutableArray *)localTaskListsWithSortType:(NSInteger)sortType;
- (void)syncTaskLists;

- (void)addTaskList:(TaskList *)alist;
- (void)deleteTaskList:(TaskList *)aList;
- (void)modifyTaskList:(TaskList *)aList;

- (void)updateTaskList:(TaskList *)aList;

// Tasks
- (void)fetchServerTasksForList:(TaskList *)aList resultHander:(void(^)(GTaskEngine *,NSMutableArray *))resultHander;

- (NSMutableArray *)localAllTasks;
- (NSMutableArray *)localTasksForList:(TaskList *)aList;

- (void)syncTasks;
- (void)syncTasksForList:(TaskList *)aList;

- (void)addTask:(Task *)aTask forList:(TaskList *)alist;
- (void)deleteTask:(Task *)aTask forList:(TaskList *)aList;
- (void)modifyTask:(Task *)aTask forList:(TaskList *)aList;

- (void)updateTask:(Task *)aTask;

@end
