//
//  TaskList.m
//  GTask-iOS
//
//  Created by ryan on 11-9-22.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "TaskList.h"
#import "FMDatabase.h"
#import "Task.h"
#import "GTaskEngine.h"
#import "NSMutableURLRequest+Shorten.h"
#import "NSDate+RFC3339.h"

@interface TaskList (Private)

- (NSArray *)_parseServerTasksFromJSON:(NSDictionary *)json;

@end

@implementation TaskList

@synthesize localListId = _localListId;
@synthesize serverListId = _serverListId;
@synthesize kind = _kind;
@synthesize title = _title;
@synthesize isDefault = _isDefault;
@synthesize isDeleted = _isDeleted;
@synthesize isCleared = _isCleared;
@synthesize sortType = _sortType;
@synthesize lastestSyncTime = _lastestSyncTime;
@synthesize serverModifyTime = _serverModifyTime;
@synthesize localModifyTime = _localModifyTime;
@synthesize tasks = _tasks;
@synthesize link = _link;
@synthesize displayOrder = _displayOrder;


- (void)dealloc {
    [_serverListId release];
    [_kind release];
    [_title release];
    [_tasks release];
    [_link release];
    [_lastestSyncTime release];
    [_serverModifyTime release];
    [_localModifyTime release];
    [super dealloc];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"List: %@ LocalListId : %d ServerListId : %@ server:%@ local:%@",_title,_localListId,_serverListId,self.serverModifyTime,self.localModifyTime];
}

- (id)init {
    return [self initWithLocalListId:-1];
}

- (id)initWithLocalListId:(NSInteger)anId {
    if (self = [super init]) {
        _tasks = [[NSMutableArray alloc] init];
        _localListId = anId;
        if (_localListId != -1) {
            [self reloadLocalTasks];
        }
    }
    return self;
}

- (void)reloadLocalTasks {
    FMDatabase *db = [FMDatabase database];
    if (![db open]) {
        NSLog(@"Could not open db.");
    } else {
        [_tasks removeAllObjects];
        
        FMResultSet *rs = [db executeQuery:[NSString stringWithFormat:@"SELECT * FROM tasks WHERE local_list_id = %d AND is_deleted = 0 ORDER BY display_order",_localListId]];
        while ([rs next]) {
            Task *task = [[Task alloc] init];
            task.localTaskId = [rs intForColumn:@"local_task_id"];
            task.serverTaskId = [rs stringForColumn:@"server_task_id"];
            task.localParentId = [rs intForColumn:@"local_parent_id"];
            task.title = [rs stringForColumn:@"title"];
            task.notes = [rs stringForColumn:@"notes"];
            task.isUpdated = [rs boolForColumn:@"is_updated"];
            task.isCompleted = [rs boolForColumn:@"is_completed"];
            task.isHidden = [rs boolForColumn:@"is_hidden"];
            task.isDeleted = [rs boolForColumn:@"is_deleted"];
            task.isCleared = [rs boolForColumn:@"is_cleared"];
            task.completedDate = [rs dateForColumn:@"completed_timestamp"];
            task.reminderDate = [rs dateForColumn:@"reminder_timestamp"];
            task.due = [rs dateForColumn:@"due"];
            task.serverModifyTime = [rs dateForColumn:@"server_modify_timestamp"];
            task.displayOrder = [rs intForColumn:@"display_order"];
            
            task.list = self;
            [_tasks addObject:task];
            [task release];
        }
        [db close]; 
    }            
}

- (void)setServerModifyTime:(NSDate *)serverModifyTime updateDB:(BOOL)update {
    if (update) {
        FMDatabase *db = [FMDatabase database];
        if (![db open]) {
            NSLog(@"Could not open db.");
        } else {
            [db executeUpdate:@"UPDATE task_lists SET server_modify_time = ? WHERE local_list_id = ?",serverModifyTime,self.localListId];
            [db close];
        }
    }
    
    if (_serverModifyTime != serverModifyTime) {
        [_serverModifyTime release];
        _serverModifyTime = [serverModifyTime retain];
    }
}

- (void)setServerListId:(NSString *)serverListId updateDB:(BOOL)update {
    if (update) {
        FMDatabase *db = [FMDatabase database];
        if (![db open]) {
            NSLog(@"Could not open db.");
        } else {
            [db executeUpdate:@"UPDATE task_lists SET server_list_id = ?,server_modify_time = ? WHERE local_list_id = ?",serverListId,[NSDate date],[NSNumber numberWithInt:self.localListId]];
            [db close];
        }
    }
    [_serverListId release];
    _serverListId = [serverListId copy];    
}

- (void)setTitle:(NSString *)title updateDB:(BOOL)update {
    if (update) {
        FMDatabase *db = [FMDatabase database];
        if (![db open]) {
            NSLog(@"Could not open db.");
        } else {
            [db executeUpdate:@"UPDATE task_lists SET title = ? WHERE local_list_id = ?",title,[NSNumber numberWithInt:self.localListId]];
            [db close];
        }
    }
    
    [_title release];
    _title = [title copy];    
    
}

- (void)updateLastestSyncTime:(NSDate *)date {
    FMDatabase *db = [FMDatabase database];
    if (![db open]) {
        NSLog(@"Could not open db.");
    } else {
        [db executeUpdate:@"UPDATE task_lists SET latest_sync_timestamp = ? WHERE local_list_id = ?",date,[NSNumber numberWithInt:self.localListId]];
        [db close];
    }
    self.lastestSyncTime = date;
}


//////////////////////////////////////////////////////////////////////////////////////////
- (Task *)firstTask {
    if (!_tasks || [_tasks count] == 0) return nil; 
    return [_tasks objectAtIndex:0];
}

- (Task *)lastTask {
    if (!_tasks || [_tasks count] == 0) return nil;
    return [_tasks lastObject];
}

- (NSInteger)generationLevelOfTask:(Task *)task {
    if (!_tasks || [_tasks count] == 0) return 0;
    Task *parent = [self parentOfTask:task];
    if (parent) {
        return 1 + [self generationLevelOfTask:parent];
    } else {
        return 0;
    }
}

- (Task *)parentOfTask:(Task *)task {
    if (!_tasks || [_tasks count] == 0) return nil;
    if ([task isFirstLevelTask]) return nil;
    else {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"localTaskId = %d",task.localParentId];
        NSArray *filteredParents = [_tasks filteredArrayUsingPredicate:predicate];
        if (filteredParents == nil || [filteredParents count] == 0) {
            NIF_ERROR(@"THIS TASK SHOULD HAVE A PARENT!!");
            return nil;
        } else {
            return [filteredParents objectAtIndex:0];
        }
    }
}

// 
- (NSArray *)sonsOfTask:(Task *)task {
    if (!_tasks || [_tasks count] == 0) return nil;
    NSAssert(task.localTaskId != task.localParentId,@"%@ taskId and parentId is the same!",task.title);
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"localParentId = %d",task.localTaskId];
    NSArray *subtasks = [_tasks filteredArrayUsingPredicate:predicate];
    if (subtasks == nil || [subtasks count] == 0) {
        return nil;
    } else {
        return subtasks;
    }
}


// 前一任务 后一任务
- (Task *)prevTaskOfTask:(Task *)task {
    if (!_tasks || [_tasks count] == 0) return nil;
    else if ([self firstTask] == nil || [self firstTask] == task) {
        return nil;
    }
    else {
        NSInteger index = [_tasks indexOfObject:task];
        return [_tasks objectAtIndex:index - 1];
    }
}

- (Task *)nextTaskOfTask:(Task *)task {
    if (!_tasks || [_tasks count] == 0) return nil;
    else if ([self lastTask] == nil || [self lastTask] == task) return nil;
    else {
        NSInteger index = [_tasks indexOfObject:task];
        return [_tasks objectAtIndex:index + 1];
    }
}

- (NSArray *)siblingsAndMeOfTask:(Task *)task {
    if (!_tasks || [_tasks count] == 0) return nil;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"localParentId = %d",task.localParentId];
    NSArray *siblings = [_tasks filteredArrayUsingPredicate:predicate];
    if(siblings == nil || [siblings count] == 0) {
        return nil;
    } else {
        return siblings;
    }
}

- (NSArray *)siblingsTaskOfTask:(Task *)task {
    NSMutableArray *siblingsAndMe = [NSMutableArray arrayWithArray:[self siblingsAndMeOfTask:task]];
    if (siblingsAndMe == nil) {
        return nil;
    } else if ([siblingsAndMe containsObject:task]) {
        [siblingsAndMe removeObject:task];
        return siblingsAndMe;
    } else {
        NIF_ERROR(@"THIS SIBLINGS SHOULD INCLUDE ME!");
        return nil;
    }
}

- (NSInteger)nextSiblingOrUncleIndexOfTask:(Task *)task {
    NSInteger generationLevel = [self generationLevelOfTask:task];
    if (!_tasks || [_tasks count] == 0) return -1;
    NSInteger index = [_tasks indexOfObject:task];
    if (index < [_tasks count] - 1) {
        for(int i = index+1; i < [_tasks count]; i++) {
            Task *tempTask = [_tasks objectAtIndex:i];
            if ([self generationLevelOfTask:tempTask] <= generationLevel) {
                return i;
            }
        }
        return -1;
    } else {
        return -1;
    }
}


// 同级别前一任务 同级别后一任务
- (Task *)prevSiblingOfTask:(Task *)task {
    if (!_tasks || [_tasks count] == 0) return nil;
    NSArray *siblingsAndMe = [self siblingsAndMeOfTask:task];
    NSInteger indexOfMe = [siblingsAndMe indexOfObject:task];
    NIF_INFO(@"indexOfMe : %d", indexOfMe);
    if (indexOfMe > 0) {
        return [siblingsAndMe objectAtIndex:(indexOfMe - 1)];
    } else {
        return nil;
    }
}

- (Task *)nextSiblingOfTask:(Task *)task {
    if (!_tasks || [_tasks count] == 0) return nil;
    NSArray *siblingsAndMe = [self siblingsAndMeOfTask:task];
    NSInteger indexOfMe = [siblingsAndMe indexOfObject:task];
    NIF_INFO(@"indexOfMe : %d", indexOfMe);
    if (indexOfMe < [_tasks count] - 1) {
        return [siblingsAndMe objectAtIndex:(indexOfMe + 1)];
    } else {
        return nil;
    }
}

- (NSArray *)youngerSiblingsOfTask:(Task *)task {
    if (!_tasks || [_tasks count] == 0) return nil;
    NSArray *siblingsAndMe = [self siblingsAndMeOfTask:task];
    NSInteger indexOfMe = [siblingsAndMe indexOfObject:task];
    NIF_INFO(@"indexOfMe : %d", indexOfMe);
    if ([siblingsAndMe count] > 1) {
        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(indexOfMe + 1, [siblingsAndMe count] - indexOfMe - 1)];
        return [siblingsAndMe objectsAtIndexes:indexSet];        
    } else {
        return nil;
    }
}



// 所有子任务 递归
- (NSArray *)allDescendantsOfTask:(Task *)task {
    NSMutableArray *descendants = [NSMutableArray array];
    
    NSArray *sons = [self sonsOfTask:task];
    if (!sons || [sons count] == 0) {
        return nil;
    }
    for(Task *son in sons) {
        [descendants addObject:son];
        NSArray *sonz_sons = [self allDescendantsOfTask:son];
        if (sonz_sons && [sonz_sons count]) {
            [descendants addObjectsFromArray:sonz_sons];            
        }
    }
    return descendants;    
}


//////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)insertTask:(Task *)aTask {
    [_tasks insertObject:aTask atIndex:0];
    FMDatabase *db = [FMDatabase database];
    if (![db open]) {
        NSLog(@"Could not open db.");
		return NO;
    } else {
        BOOL rs = [db executeUpdate:
                   @"INSERT INTO tasks (local_list_id,local_parent_id,notes,self_link,title,due,is_updated,display_order,is_completed,completed_timestamp,local_modify_timestamp) VALUES (?,?,?,?,?,?,?,?,?,?,?)",
                   [NSNumber numberWithInt:aTask.list.localListId],
                   [NSNumber numberWithInt:aTask.localParentId],
                   aTask.notes,
                   aTask.link,
                   aTask.title, 
                   aTask.due,
                   [NSNumber numberWithBool:aTask.isUpdated],
                   [NSNumber numberWithInt:aTask.displayOrder],
                   [NSNumber numberWithBool:aTask.isCompleted],
                   aTask.completedDate,
                   aTask.localModifyTime
                ];
        
        aTask.localTaskId = [db lastInsertRowId];
        
        [db close];        
        return rs;
    }
}

- (BOOL)deleteTask:(Task *)aTask {
    FMDatabase *db = [FMDatabase database];
    if (![db open]) {
        NSLog(@"Could not open db.");
		return NO;
    } else {
        NSString *sql = [NSString stringWithFormat:@"UPDATE tasks SET is_deleted = 1 WHERE local_task_id = %d",aTask.localTaskId];
      NIF_INFO(@"save to DB sql : %@", sql);
        NSError *error = nil;
        BOOL rs = [db executeUpdate:sql error:&error withArgumentsInArray:nil orVAList:nil];
        if (error) {
            NIF_INFO(@"%@", error);
        }
        [db close];        
        [_tasks removeObject:aTask];
        
        return rs;
    }
}

- (BOOL)deleteTaskAtIndex:(NSInteger)index {
    return [self deleteTask:[_tasks objectAtIndex:index]];
}


- (void)moveTaskAtIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex {
    
    Task *fromTask = [[_tasks objectAtIndex:fromIndex] retain];
    Task *toTask = [_tasks objectAtIndex:toIndex];
    
    NSArray *subTasks = [self allDescendantsOfTask:fromTask];
    
    if ([subTasks containsObject:toTask]) {
        return;
    }
        
    int begin = 0;
    int end = 0;
    if (fromTask.displayOrder > toTask.displayOrder) {  // *** 上移 ***
        
        Task *prevToTask = [self prevTaskOfTask:toTask];
        
        NSInteger toTaskLevel = [self generationLevelOfTask:toTask];
        NSInteger prevToTaskLevel = [self generationLevelOfTask:prevToTask];
        
        if (prevToTask == nil) {
            [fromTask setLocalParentId:-1 updateDB:YES];
        } else if (toTaskLevel == prevToTaskLevel) {
            [fromTask setLocalParentId:prevToTask.localParentId updateDB:YES];
        } else if (toTaskLevel > prevToTaskLevel) {
            [fromTask setLocalParentId:prevToTask.localTaskId updateDB:YES];
        } else if (toTaskLevel < prevToTaskLevel) {
            [fromTask setLocalParentId:prevToTask.localParentId updateDB:YES];
        } else {
            NIF_ERROR(@"HOW TO MOVE ABOVE !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
        }
        
        
        NSEnumerator *enumerator = [subTasks reverseObjectEnumerator];
        Task *aTask = nil;
        while (aTask = [enumerator nextObject]) {
            [_tasks removeObject:aTask];
            [_tasks insertObject:aTask atIndex:toIndex];
        }
        
        [_tasks removeObject:fromTask];
        [_tasks insertObject:fromTask atIndex:toIndex];
        [fromTask release];
        
        begin = toTask.displayOrder;
        end = fromTask.displayOrder + [subTasks count];
    } else if ( fromTask.displayOrder == toTask.displayOrder) {     // *** 移 ***
        Task *prevTask = [self prevTaskOfTask:fromTask];
        Task *parent = [self parentOfTask:fromTask];
        
        if (prevTask  && prevTask != parent) {
            [fromTask setLocalParentId:prevTask.localParentId updateDB:YES];
        } else {
            
        }
        
    }
    else {                                                          // *** 下移 ***
        NIF_INFO(@"fromTask.displayOrder:%d > toTask.displayOrder: %d", fromTask.displayOrder ,toTask.displayOrder);
        
        Task *nextToTask = [self nextTaskOfTask:toTask];
        
        NSInteger toTaskLevel = [self generationLevelOfTask:toTask];
        NSInteger nextToTaskLevel = [self generationLevelOfTask:nextToTask];
        
        if (nextToTask == nil) {
            [fromTask setLocalParentId:toTask.localParentId updateDB:YES];     
        } else if (toTaskLevel == nextToTaskLevel) { // =
            [fromTask setLocalParentId:nextToTask.localParentId updateDB:YES];
        } else if (toTaskLevel > nextToTaskLevel) {  // _-
            [fromTask setLocalParentId:toTask.localParentId updateDB:YES];
        } else if (toTaskLevel < nextToTaskLevel) { // -_
            [fromTask setLocalParentId:nextToTask.localParentId updateDB:YES];     
        } else {
            NIF_ERROR(@"HOW TO MOVE DOWN !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
        }
        
        [_tasks removeObject:fromTask];
        [_tasks insertObject:fromTask atIndex:toIndex];
        [fromTask release];
        
        NSEnumerator *enumerator = [subTasks objectEnumerator];
        Task *aTask = nil;
        while (aTask = [enumerator nextObject]) {
            [_tasks removeObject:aTask];
            [_tasks insertObject:aTask atIndex:toIndex];
        }
        
        begin = fromTask.displayOrder;
        end = toTask.displayOrder;
    }
    
    for (int i = begin;i <= end;i++) {
        Task *task = [_tasks objectAtIndex:i];
        [task setDisplayOrder:i updateDB:YES];
    }
}


- (BOOL)upgradeTaskLevel:(TaskUpgradeLevel)level atIndex:(NSInteger)index {
    Task *task = [_tasks objectAtIndex:index];
    Task *prevSiblingTask = [self prevSiblingOfTask:task];
    
    if (level == TaskUpgradeLevelDownLevel) {
        if (prevSiblingTask == nil) {
            NIF_ERROR(@"NO task above this task!");
            return NO;
        } else {
            [task setLocalParentId:prevSiblingTask.localTaskId updateDB:YES];
            return YES;
        }
        
    } else if (level == TaskUpgradeLevelUpLevel) {
        if (task.localParentId == -1) {
            NIF_ERROR(@"YOU'VE ALREADY IN 1ST LEVEL!");
            return NO;
        } else {
            Task *parent = [self parentOfTask:task];
            NSArray *youngerSiblings = [self youngerSiblingsOfTask:task];

            for(Task *sibling in youngerSiblings) {
                [sibling setLocalParentId:task.localTaskId updateDB:YES];
            }
            
            [task setLocalParentId:parent.localParentId updateDB:YES];
            return YES;
        }
        
    } else {
        NIF_ERROR(@"MAKE SURE YOU NEED UPGRADE OR DOWNGRADE??");
        return NO;
    }
}

- (void)moveTaskWithSubTasks:(Task *)task toList:(TaskList *)toList {
    NIF_INFO(@"MOVE TASK:%@ TO LIST: %@", task.title,toList.title);
    
    NSArray *subTasks = [self allDescendantsOfTask:task];
    
    if (subTasks && [subTasks count] > 0) {
        for (int i = [subTasks count] - 1 ; i >= 0 ; i--) {
            Task *e = [subTasks objectAtIndex:i];
            e.list = toList;
            if (![toList.tasks containsObject:e]) {
                [toList.tasks insertObject:e atIndex:0];
                NIF_INFO(@"[_tasks containsObject:e] = %d", [_tasks containsObject:e]);
                [_tasks removeObject:e];
                
            }
        }
    }
    
    if (![toList.tasks containsObject:task]) {
        task.list = toList;
        [task setLocalParentId:-1 updateDB:YES];
        [toList.tasks insertObject:task atIndex:0];
        NIF_INFO(@"[_tasks containsObject:task] = %d", [_tasks containsObject:task]);
        [_tasks removeObject:task];        
    }
    
    [self updateListIdAndOrders];
    [toList updateListIdAndOrders];

}

- (void)updateListIdAndOrders {
    FMDatabase *db = [FMDatabase database];
    if (![db open]) {
        NIF_ERROR(@"Could not open db.");            
    } else {
        
        for(int i = 0; i < [_tasks count];i++) {
            Task *e = [_tasks objectAtIndex:i];
            e.displayOrder = i;
            NSError *error = nil;

            NSString *sql = [NSString stringWithFormat:@"UPDATE tasks SET display_order = %d,local_list_id = %d WHERE local_task_id = %d",e.displayOrder,e.list.localListId,e.localTaskId];
            [db executeUpdate:sql error:&error withArgumentsInArray:nil orVAList:nil];
        }
        [db close];
    }
}

- (void)deleteLocal {
    FMDatabase *db = [FMDatabase database];
    if (![db open]) {
        NIF_ERROR(@"Could not open db.");            
    } else {
        
        for(int i = 0; i < [_tasks count];i++) {
            Task *e = [_tasks objectAtIndex:i];
            e.displayOrder = i;
            NSError *error = nil;
            
            NSString *sql = [NSString stringWithFormat:@"DELETE FROM task_lists WHERE local_list_id = %d",self.localListId];
            [db executeUpdate:sql error:&error withArgumentsInArray:nil orVAList:nil];
        }
        [db close];
    }
}

- (void)updateLocal {
    FMDatabase *db = [FMDatabase database];
    if (![db open]) {
        NIF_ERROR(@"Could not open db.");            
    } else {
        [db executeUpdate:@"UPDATE task_lists SET local_list_id = ?,title = ?,"];
    }
}

////////////////////////////////////////////////////////////////////////////
// Remote Update
- (void)fetchServerTasksWithCondition:(NSDictionary *)conditions resultHander:(RemoteHandler)handler {

    NSString *query = [NSString queryStringFromParams:conditions];
    NSString *listsLink = [NSString stringWithFormat:@"https://www.googleapis.com/tasks/v1/lists"];
    NSString *tasksLink = [listsLink stringByAppendingFormat:@"/%@/tasks%@",self.serverListId,query?[NSString stringWithFormat:@"?%@",query]:@""];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:tasksLink]];
    [[GTaskEngine sharedEngine] fetchWithRequest:request resultBlock:^(GDataEngine *anEngine, NSDictionary *result) {

        NSArray *tasks = [self _parseServerTasksFromJSON:result];
        handler(self,tasks);
    }];
    
}

- (NSArray *)_parseServerTasksFromJSON:(NSDictionary *)json {
    NSMutableArray *tempTasks = [NSMutableArray array];
    
    NSArray *items = [json objectForKey:@"items"];
    
    for (NSDictionary*item in items) {
        Task *aTask = [[Task alloc] init];
        
        aTask.serverTaskId = [item objectForKey:@"id"];
        aTask.link = [item objectForKey:@"selfLink"];
        aTask.title = [item objectForKey:@"title"];
        aTask.isDeleted = [[item objectForKey:@"deleted"] boolValue];
        [tempTasks addObject:aTask];
        [aTask release];
    }
    return tempTasks;
}

- (void)uploadTasks {
    
}

@end
