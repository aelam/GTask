//
//  GTaskEngine.h
//  GTask-iOS
//
//  Created by ryan on 11-9-23.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "GDataEngine.h"
#import "TaskList.h"
#import "NSMutableURLRequest+Operations.h"

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
@property (assign) BOOL isSyncing;

- (NSMutableArray *)sharedTaskLists;

- (void)reloadLocalLists;


// Lists

- (void)fetchServerTaskListsWithResultHander:(void(^)(GTaskEngine *,NSArray *))resultHander;

- (NSMutableArray *)localTaskLists;
- (NSMutableArray *)localTaskListsWithSortType:(NSInteger)sortType;
//- (void)syncTaskLists;


- (void)deleteLocalList:(TaskList *)aList;
- (void)updateTaskList:(TaskList *)aList;
- (void)insertList:(TaskList *)taskList updateDB:(BOOL)update;


- (void)clearDeletedLists;

- (void)clearServerTasksDeletedByLocalWithError:(NSError **)error;


// Tasks
- (void)fetchServerTasksForList:(TaskList *)aList resultHander:(void(^)(GTaskEngine *,NSMutableArray *))resultHander;

- (NSMutableArray *)localAllTasks;
- (NSMutableArray *)localTasksForList:(TaskList *)aList;

//- (void)syncTasks;
//- (void)syncTasksForList:(TaskList *)aList;

- (void)syncWithSyncHandler:(SyncHandler)handler;

- (void)uploadList:(TaskList *)aList remoteHandler:(RemoteHandler)handler;
- (void)updateList:(TaskList *)aList remoteHandler:(RemoteHandler)handler;
- (void)removeList:(TaskList *)aList remoteHandler:(RemoteHandler)handler;

@end
