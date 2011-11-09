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
@class GTaskEngine;

typedef enum {
    SyncStepListsDownloaded,
    SyncStepListsUpdated,
    SyncStepTasksDownloaded,
    SyncStepTasksUpdated    
}SyncStep;


typedef void(^SyncHandler)(GTaskEngine *currentEngine, SyncStep step);

@interface GTaskEngine : GDataEngine

+ (GTaskEngine *)sharedEngine;
+ (GTaskEngine *)engine;


@property (retain) NSMutableArray *localTaskLists;
@property (retain) NSMutableArray *deletedTaskLists;


- (NSMutableArray *)sharedTaskLists;

// Lists

- (void)fetchServerTaskListsWithResultHander:(void(^)(GTaskEngine *,NSArray *))resultHander;

- (NSMutableArray *)localTaskLists;
- (NSMutableArray *)localTaskListsWithSortType:(NSInteger)sortType;
- (void)syncTaskLists;


//- (void)addTaskList:(TaskList *)alist;
//- (void)deleteTaskList:(TaskList *)aList;
//- (void)modifyTaskList:(TaskList *)aList;

- (void)deleteLocalList:(TaskList *)aList;

- (void)updateTaskList:(TaskList *)aList;

- (void)insertList:(TaskList *)taskList updateDB:(BOOL)update;


- (void)clearDeletedLists;


// Tasks
- (void)fetchServerTasksForList:(TaskList *)aList resultHander:(void(^)(GTaskEngine *,NSMutableArray *))resultHander;

- (NSMutableArray *)localAllTasks;
- (NSMutableArray *)localTasksForList:(TaskList *)aList;

- (void)syncTasks;
- (void)syncTasksForList:(TaskList *)aList;


- (void)sync;
- (void)syncWithSyncHandler:(SyncHandler)handler;


@end
