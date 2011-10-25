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


- (NSMutableArray *)sharedTaskLists;

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

- (BOOL)insertTask:(Task *)aTask;
- (BOOL)deleteTask:(Task *)aTask;

- (void)deleteTask:(Task *)aTask atIndex:(NSInteger)index forList:(TaskList *)aList;
- (void)modifyTask:(Task *)aTask forList:(TaskList *)aList;

- (void)updateTask:(Task *)aTask;

//- (void)moveTaskAtIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex forTasks:(NSMutableArray *)tasks;
//- (BOOL)upgradeTaskLevel:(TaskUpgradeLevel)level atIndex:(NSInteger)index forTasks:(NSMutableArray *)tasks;

- (void)deleteTaskAtIndex:(NSInteger)index forTasks:(NSMutableArray *)tasks;

- (void)moveTaskAndSubTasks:(Task *)task fromList:(TaskList *)fromList toList:(TaskList *)toList;

@end
