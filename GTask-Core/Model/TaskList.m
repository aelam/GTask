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
#import <YAJL/YAJL.h>

@interface TaskList (Private)

+ (NSArray *)_parseServerTasksFromJSON:(NSDictionary *)json;

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

+ (TaskList *)taskListWithLocalListId:(NSInteger)anId {
    return [[[self alloc] initWithLocalListId:anId] autorelease];
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
            task.localModifyTime = [rs dateForColumn:@"local_modify_timestamp"];
            task.displayOrder = [rs intForColumn:@"display_order"];
            
            task.list = self;
            [_tasks addObject:task];
            [task release];
        }
        [db close]; 
    }            
}

- (NSMutableArray *)localTasks {
    FMDatabase *db = [FMDatabase database];
    if (![db open]) {
        NSLog(@"Could not open db.");
        return nil;
    } else {
        NSMutableArray *localTasks = [NSMutableArray array];
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
            [localTasks addObject:task];
            [task release];
        }
        [db close]; 
        return localTasks;
    }            
}

// 同步方法
- (void)sync {
    
    FMDatabase *db = [FMDatabase database];
    [db open];
    
    NSString *updatedMin = self.lastestSyncTime?[self.lastestSyncTime RFC3339String]:[NSDate RFC3339Of1970];
    
    NSMutableDictionary *filters = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"items(completed,deleted,due,hidden,id,notes,parent,position,status,title,updated)",@"fields",updatedMin,@"updatedMin",@"true",@"showDeleted",nil];
    NSError *error = nil;
    NSArray *serverTasks = [TaskList fetchServerTasksSynchronouslyForServerListId:self.serverListId filters:filters error:&error];
    int displayOrder = 0;
    for(Task *task in serverTasks) {
        FMResultSet *set = [db executeQuery:@"SELECT * FROM tasks WHERE server_task_id = ?",task.serverTaskId];
        if (![set next]) {
            FMResultSet *localParentIdSet = [db executeQuery:@"SELECT * FROM tasks WHERE server_task_id = ?",task.serverParentId];
            int localParentId = 0;
            if ([localParentIdSet next]) {
                localParentId = [localParentIdSet intForColumn:@"local_task_id"];                
            }
            
            FMResultSet *localListIdSet = [db executeQuery:@"SELECT local_list_id FROM task_lists WHERE server_list_id = ?",self.serverListId];
            int localListId_ = 0;
            if ([localListIdSet next]) {
                localListId_ = [localListIdSet intForColumn:@"local_list_id"];
            }
            
            [db executeUpdate:@"INSERT INTO tasks \
             (local_list_id,server_task_id,local_parent_id, notes, title, due, server_modify_timestamp, \
             local_modify_timestamp, is_completed, completed_timestamp,is_deleted) VALUES(?,?,?,?,?,?,?,?,?,?,?)",[NSNumber numberWithInt:localListId_],task.serverTaskId,[NSNumber numberWithInt:localParentId],task.notes,task.title,task.due,[NSDate date],[NSDate dateWithTimeIntervalSince1970:0],[NSNumber numberWithBool:task.isCompleted],task.completedDate,[NSNumber numberWithBool:task.isDeleted]];
            
        } else {
            if (task.isDeleted) {
                [db executeUpdate:@"DELETE FROM tasks WHERE server_list_id = ?",task.serverTaskId];
            } else {
                [db executeUpdate:@"UPDATE tasks SET title = ?,due = ?,notes = ?,is_completed, completed_timestamp WHERE server_list_id = ? AND local_modify_timestamp < server_modify_timestamp",task.title,task.due,task.notes,[NSNumber numberWithBool:task.isCompleted],task.completedDate,task.serverTaskId];
            }
        }
        [db executeUpdate:@"UPDATE tasks SET display_order = ? WHERE server_list_id = ?",[NSNumber numberWithInt:displayOrder],task.serverTaskId];
    }
    
    
    for(Task *task in _tasks) {
        if (!task.serverTaskId) {
            //!!! 上传task
            Task * parent = [self parentOfTask:task];
            Task * prevSibling = [self prevSiblingOfTask:task];
            
            NSMutableDictionary *queries = [NSMutableDictionary dictionary];
            NSString *query = nil;
            
            if (parent) {
                [queries setObject:parent.serverTaskId forKey:@"parent"];
            }
            if (prevSibling) {
                [queries setObject:prevSibling.serverTaskId forKey:@"previous"];
            }
            if ([queries count]) {
                query = [NSString queryStringFromParams:queries];                
            }
            
            NSMutableDictionary *postParameters = [NSMutableDictionary dictionary];
            
            [postParameters setValue:task.title forKey:@"title"];
            
            if (task.due) {
                NSString *dueString = task.due?[task.due RFC3339String]:[NSDate RFC3339Of1970];
                [postParameters setValue:dueString forKey:@"due"];
            }
            
            if (task.completedDate) {
                NSString *completedDateString = task.completedDate?[task.completedDate RFC3339String]:[NSDate RFC3339Of1970];
                [postParameters setValue:completedDateString forKey:@"completed"];
                [postParameters setValue:@"completed" forKey:@"status"];
            }

            if (task.notes) {
                [postParameters setValue:task.notes forKey:@"notes"];
            }
            
            NSString *url = [NSString stringWithFormat:@"https://www.googleapis.com/tasks/v1/lists/%@/tasks%@",self.serverListId,query?[NSString stringWithFormat:@"?%@",query]:@""];
            
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
            [request setValue:[GDataEngine authorizationHeader] forHTTPHeaderField:@"Authorization"];
            [request setHTTPMethod:@"POST"];
            [request attachJSONBody:postParameters];
            
            NSHTTPURLResponse *response = nil;
            NSError *error = nil;
            NSData *responsingData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
            if (response) {
                NIF_INFO(@"[response statusCode] =  %d", [response statusCode]); 
            }

            if (error) {
                
            } else {
                
            }
        } else {
            if ([task.localModifyTime timeIntervalSinceDate:task.serverModifyTime] > 0) {
                // Update Task 
                
                NSMutableDictionary *postParameters = [NSMutableDictionary dictionary];
                [postParameters setValue:task.title forKey:@"title"];
                
                if (task.due) {
                    NSString *dueString = task.due?[task.due RFC3339String]:[NSDate RFC3339Of1970];
                    [postParameters setValue:dueString forKey:@"due"];
                }
                
                if (task.completedDate) {
                    NSString *completedDateString = task.completedDate?[task.completedDate RFC3339String]:[NSDate RFC3339Of1970];
                    [postParameters setValue:completedDateString forKey:@"completed"];
                    [postParameters setValue:@"completed" forKey:@"status"];
                }
                
                if (task.notes) {
                    [postParameters setValue:task.notes forKey:@"notes"];
                }
                
                [postParameters setValue:task.serverTaskId forKey:@"id"];
                [postParameters setValue:task.isCompleted?@"completed":@"needsAction" forKey:@"status"];                
                
                NSString *url = [NSString stringWithFormat:@"https://www.googleapis.com/tasks/v1/lists/%@/tasks/%@",self.serverListId,task.serverTaskId];
                NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
                [request setValue:[GDataEngine authorizationHeader] forHTTPHeaderField:@"Authorization"];
                [request attachJSONBody:postParameters];
                [request setHTTPMethod:@"PUT"];
                
                NSHTTPURLResponse *response = nil;
                NSError *error = nil;
                NSData *responsingData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
                if (response) {
                    NIF_INFO(@"[response statusCode] =  %d", [response statusCode]); 
                    NSInteger statusCode = [response statusCode];
                    if (statusCode == 200 || statusCode == 204) {
                        [db executeUpdate:@"UPDATE tasks SET server_modify_timestamp = ? WHERE local_task_id = ?",[NSDate date],[NSNumber numberWithInt:task.localTaskId]];
                    }
                }
                
                if (error) {
                    
                } else {
                    NIF_INFO(@"%@", [responsingData yajl_JSON]);
                }
            }
            
            if (task.isMoved) {
                Task * parent = [self parentOfTask:task];
                Task * prevSibling = [self prevSiblingOfTask:task];
                
                NSMutableDictionary *queries = [NSMutableDictionary dictionary];
                NSString *query = nil;
                
                if (parent) {
                    [queries setObject:parent.serverTaskId forKey:@"parent"];
                }
                if (prevSibling) {
                    [queries setObject:prevSibling.serverTaskId forKey:@"previous"];
                }
                if ([queries count]) {
                    query = [NSString queryStringFromParams:queries];                
                }
                
                NSMutableDictionary *postParameters = [NSMutableDictionary dictionary];
                
                [postParameters setValue:task.title forKey:@"title"];
                
                if (task.due) {
                    NSString *dueString = task.due?[task.due RFC3339String]:[NSDate RFC3339Of1970];
                    [postParameters setValue:dueString forKey:@"due"];
                }
                
                if (task.completedDate) {
                    NSString *completedDateString = task.completedDate?[task.completedDate RFC3339String]:[NSDate RFC3339Of1970];
                    [postParameters setValue:completedDateString forKey:@"completed"];
                    [postParameters setValue:@"completed" forKey:@"status"];
                }
                
                if (task.notes) {
                    [postParameters setValue:task.notes forKey:@"notes"];
                }
                
                NSString *url = [NSString stringWithFormat:@"https://www.googleapis.com/tasks/v1/lists/%@/tasks/%@/move?%@",self.serverListId,task.serverTaskId,query?[NSString stringWithFormat:@"?%@",query]:@""];
                
                NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
                [request setValue:[GDataEngine authorizationHeader] forHTTPHeaderField:@"Authorization"];
                [request setHTTPMethod:@"POST"];
                [request attachJSONBody:postParameters];
                
                NSHTTPURLResponse *response = nil;
                NSError *error = nil;
                NSData *responsingData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
                if (response) {
                    NIF_INFO(@"[response statusCode] =  %d", [response statusCode]); 
                }
                
                if (error) {
                    
                } else {
                    
                }
            }
        }
    }
    
    [db close];
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
            [db executeUpdate:@"UPDATE task_lists SET server_list_id = ?,server_modify_timestamp = ? WHERE local_list_id = ?",serverListId,[NSDate date],[NSNumber numberWithInt:self.localListId]];
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

- (void)localUpdate {
    FMDatabase *db = [FMDatabase database];
    if (![db open]) {
        NSLog(@"Could not open db.");
    } else {
        BOOL rs = [db executeUpdate:@"UPDATE task_lists SET server_list_id = ?,server_modify_timestamp = ?,self_link = ?,kind = ? WHERE local_list_id = ?",_serverListId,[NSDate date],_link,_kind,[NSNumber numberWithInt:self.localListId]];
        NSError *error = nil;
        if(error) {
            NIF_INFO(@"%@", error);
        }
        NIF_INFO(@"update success?:%d", rs);

        [db close];
    }
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

- (void)deleteTaskFromServer:(Task *)task {
    
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
            [task setIsMoved:YES updateDB:YES];
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
                [task setIsMoved:YES updateDB:YES];
            }
            
            [task setLocalParentId:parent.localParentId updateDB:YES];
            [task setIsMoved:YES updateDB:YES];
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

            NSString *sql = [NSString stringWithFormat:@"UPDATE tasks SET is_moved = 1,display_order = %d,local_list_id = %d WHERE local_task_id = %d",e.displayOrder,e.list.localListId,e.localTaskId];
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

- (NSArray *)fetchServerTasksSynchronouslyWithFilters:(NSDictionary *)filters error:(NSError**)error {

    NSString *nextPageToken = nil;
    NSMutableArray *tasks_ = [NSMutableArray array];
    NSMutableDictionary *_filters = [NSMutableDictionary dictionaryWithDictionary:filters];
    
    do {
        NSMutableURLRequest *request = [NSMutableURLRequest requestOfGettingServerTasksOfList:self withParams:_filters];
        [request setValue:[GDataEngine authorizationHeader] forHTTPHeaderField:@"Authorization"];

        NSURLResponse *response = nil;
        NSData *responsingData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:error];
        if (*error) {
            
        } else {
            
            NSDictionary *json = [responsingData yajl_JSON];
            nextPageToken = [json objectForKey:@"nextPageToken"];
            if (nextPageToken) {
                [_filters setValue:nextPageToken forKey:@"nextPageToken"];
            } else {

            }
            
            NSArray *tempTasks = [TaskList _parseServerTasksFromJSON:json];
            if (tempTasks && [tempTasks count]) {
                [tasks_ addObjectsFromArray:tempTasks];
            }
            
        }        
    } while (nextPageToken && !(*error));
    
    return tasks_;

}

- (BOOL)clearServerCompletedTasks{
    NSString *url = [NSString stringWithFormat:@"https://www.googleapis.com/tasks/v1/lists/%@/clear",self.serverListId];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"POST"];
    [request setValue:[GDataEngine authorizationHeader] forHTTPHeaderField:@"Authorization"];
    
    NSHTTPURLResponse *response = nil;
    NSError *error = nil;
    
    NSData *responsingData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    if (error) {
        return NO;
    }
    
    if (response) {
        if ([response statusCode] == 200 || [response statusCode] == 204) {
            return YES;
        } else {
            return NO;
        }
    }
    return NO;
}


+ (NSArray *)fetchServerTasksSynchronouslyForServerListId:(NSString *)serverListId filters:(NSDictionary *)filters error:(NSError**)error {
    
    NSString *nextPageToken = nil;
    NSMutableArray *tasks_ = [NSMutableArray array];
    NSMutableDictionary *_filters = [NSMutableDictionary dictionaryWithDictionary:filters];
    
    do {
        NSString *query = [NSString queryStringFromParams:filters];
        NSString *listsLink = [NSString stringWithFormat:@"https://www.googleapis.com/tasks/v1/lists"];
        NSString *tasksLink = [listsLink stringByAppendingFormat:@"/%@/tasks%@",serverListId,query?[NSString stringWithFormat:@"?%@",query]:@""];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:tasksLink]];
        
        [request setValue:[GDataEngine authorizationHeader] forHTTPHeaderField:@"Authorization"];
        
        NSURLResponse *response = nil;
        NSData *responsingData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:error];
        if (*error) {
            
        } else {
            
            NSDictionary *json = [responsingData yajl_JSON];
            nextPageToken = [json objectForKey:@"nextPageToken"];
            if (nextPageToken) {
                [_filters setValue:nextPageToken forKey:@"nextPageToken"];
            } else {
                
            }
            
            NSArray *tempTasks = [self _parseServerTasksFromJSON:json];
            if (tempTasks && [tempTasks count]) {
                [tasks_ addObjectsFromArray:tempTasks];
            }
            
        }        
    } while (nextPageToken && !(*error));
    
    return tasks_;
    
}


+ (NSArray *)_parseServerTasksFromJSON:(NSDictionary *)json {
    NSMutableArray *tempTasks = [NSMutableArray array];
    
    NSArray *items = [json objectForKey:@"items"];
    
    for (NSDictionary*item in items) {
        Task *aTask = [[Task alloc] init];
        
        aTask.serverTaskId = [item objectForKey:@"id"];
        aTask.link = [item objectForKey:@"selfLink"];
        aTask.title = [item objectForKey:@"title"];
        aTask.isDeleted = [[item objectForKey:@"deleted"] boolValue];
        aTask.completedDate = [NSDate dateFromRFC3339:[item objectForKey:@"completed"]];
        if ([[item objectForKey:@"status"] isEqualToString:@"needsAction"]) {
            aTask.isCompleted = NO;
        } else {
            aTask.isCompleted = YES;
        }
        aTask.serverParentId = [item objectForKey:@"parent"];
        [tempTasks addObject:aTask];
        [aTask release];
    }
    return tempTasks;
}


- (void)uploadTasks {
    
}

@end
