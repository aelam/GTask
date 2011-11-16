//
//  GTaskEngine.m
//  GTask-iOS
//
//  Created by ryan on 11-9-23.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "GTaskEngine.h"
#import "FMDatabase.h"
#import "TaskList.h"
#import "Task.h"
#import "NSDate+RFC3339.h"
#import "NSMutableURLRequest+Shorten.h"
#import <YAJL/YAJL.h>


static NSString *kTaskListsURL = @"https://www.googleapis.com/tasks/v1/users/@me/lists";
static NSString *kTasksURLFormat = @"https://www.googleapis.com/tasks/v1/lists/%@/tasks";

@interface GTaskEngine (Private)

- (BOOL)_saveTaskListsFromJSON:(NSDictionary *)json;
- (BOOL)_syncParentIdWithItems:(NSArray *)items;

// 
- (NSArray *)_parseServerTaskListsFromJSON:(NSDictionary *)json;

- (NSArray *)fetchServerListsWithError:(NSError **)error;


- (NSArray *)_deletingLists;
- (NSArray *)_addingLists;


@end


@implementation GTaskEngine


@synthesize localTaskLists = _localTaskLists;
//@synthesize deletedTaskLists = _deletedTaskLists;
@synthesize isSyncing = _isSyncing;

- (void)dealloc {
    
    [_localTaskLists release];
//    [_deletedTaskLists release];
    [super dealloc];
}

+ (GTaskEngine *)sharedEngine {
    static GTaskEngine *_shareEngine = nil;
    if (_shareEngine == nil) {
        _shareEngine = [[GTaskEngine alloc] init];
    }
    return _shareEngine;
}

+ (GTaskEngine *)engine {
    return [[[self alloc] init] autorelease];
}


- (id)init {
    if (self = [super init]) {
        _isSyncing = NO;
        _localTaskLists = [[NSMutableArray alloc] init];

        [self reloadLocalLists];
        
//        _deletedTaskLists =[[NSMutableArray alloc] init];
//        [self reloadDeletedLists];
        
    }
    return self;
}

- (void)insertLists:(NSArray *)taskLists updateDB:(BOOL)update {
    if(update && taskLists && [taskLists count]) {
        FMDatabase *db = [FMDatabase database];
        if (![db open]) {
            NSLog(@"Could not open db.");
        } else {
            for(TaskList *taskList in taskLists) {
                [db executeUpdate:@"INSERT INTO task_lists (server_list_id,kind,self_link,title,server_modify_timestamp,local_modify_timestamp) VALUES (?,?,?,?,?,?)",taskList.serverListId,taskList.kind,taskList.link,taskList.title,taskList.serverModifyTime,taskList.localModifyTime];
                
                taskList.localListId = [db lastInsertRowId];                
                [_localTaskLists addObject:taskList];
            }
            [db close];
        }        
    } else {
        [_localTaskLists addObjectsFromArray:taskLists];        
    }
    
}

- (void)insertList:(TaskList *)taskList updateDB:(BOOL)update {
    if(update) {
        FMDatabase *db = [FMDatabase database];
        if (![db open]) {
            NSLog(@"Could not open db.");
        } else {
            [db executeUpdate:@"INSERT INTO task_lists (server_list_id,kind,self_link,title,server_modify_timestamp,local_modify_timestamp) VALUES (?,?,?,?,?,?)",taskList.serverListId,taskList.kind,taskList.link,taskList.title,taskList.serverModifyTime,taskList.localModifyTime];
            
            taskList.localListId = [db lastInsertRowId];

            [db close];
        }        
    }
    [_localTaskLists addObject:taskList];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)addNewLocalList:(TaskList *)taskList {
    FMDatabase *db = [FMDatabase database];
    if (![db open]) {
        NSLog(@"Could not open db.");
    } else {
        BOOL rs = [db executeUpdate:@"INSERT INTO task_lists (server_list_id,kind,self_link,title,server_modify_timestamp,local_modify_timestamp) VALUES (?,?,?,?,?,?)",taskList.serverListId,taskList.kind,taskList.link,taskList.title,taskList.serverModifyTime,taskList.localModifyTime];
        if (rs) {
            [_localTaskLists addObject:taskList];    
            taskList.localListId = [db lastInsertRowId];        
        }
        [db close];
    }        
}

- (void)deleteLocalList:(TaskList *)aList {
    FMDatabase *db = [FMDatabase database];
    if (![db open]) {
        NIF_ERROR(@"Could not open db.");            
    } else {
        [db executeUpdate:@"UPDATE task_lists SET is_deleted = 1 WHERE local_list_id = ?",[NSNumber numberWithInt:aList.localListId]];
        [db close];
    }    
//    [_deletedTaskLists addObject:aList];
    [_localTaskLists removeObject:aList];
}

- (void)clearDeletedList:(TaskList *)aList {
    FMDatabase *db = [FMDatabase database];
    if (![db open]) {
        NIF_ERROR(@"Could not open db.");            
    } else {
        [db setPragmaValue:1 forKey:@"foreign_keys"];

        [db executeUpdate:@"DELETE FROM task_lists WHERE local_list_id = ?",[NSNumber numberWithInt:aList.localListId]];
        [db close];
        
        [_localTaskLists removeObject:aList];
    }    
}

- (void)clearDeletedLists {

    FMDatabase *db = [FMDatabase database];
    if (![db open]) {
        NIF_ERROR(@"Could not open db.");            
    } else {
        [db setPragmaValue:1 forKey:@"foreign_keys"];
        [db executeUpdate:@"DELETE FROM task_lists WHERE is_deleted = 1"];            
        [db close];        
    }        
}

- (void)updateLocalList:(TaskList *)aList {
    FMDatabase *db = [FMDatabase database];
    if (![db open]) {
        NIF_ERROR(@"Could not open db.");            
    } else {
        [db executeUpdate:@"UPDATE task_lists SET local_list_id = ?,title = ?",[NSNumber numberWithInt:aList.localListId],aList.title];
    }
}



////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)uploadList:(TaskList *)aList remoteHandler:(RemoteHandler)handler {
    NSString *selfLink = [NSString stringWithFormat:@"https://www.googleapis.com/tasks/v1/users/@me/lists"];
    NSURL *url = [NSURL URLWithString:selfLink];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    NSDictionary *json = [NSDictionary dictionaryWithObjectsAndKeys:aList.title,@"title",nil];
    [request attachJSONBody:json];
    [self fetchWithRequest:request resultBlock:^(GDataEngine *engine, NSDictionary *result) {
        handler(aList,result);
    }];
}

- (void)updateList:(TaskList *)aList remoteHandler:(RemoteHandler)handler {
    NSString *selfLink = [NSString stringWithFormat:@"https://www.googleapis.com/tasks/v1/users/@me/lists/%@",aList.serverListId];
    NSURL *url = [NSURL URLWithString:selfLink];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"PUT"];
    NSDictionary *json = [NSDictionary dictionaryWithObjectsAndKeys:aList.serverListId,@"id",/*aList.kind,@"kind",selfLink,@"selfLink",*/aList.title,@"title",nil];
    [request attachJSONBody:json];
    [self fetchWithRequest:request resultBlock:^(GDataEngine *engine, NSDictionary *result) {
        handler(aList,result);
    }];
}

- (void)removeList:(TaskList *)aList remoteHandler:(RemoteHandler)handler {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithRemovingList:aList];
    [self fetchWithRequest:request resultBlock:^(GDataEngine *engine, NSDictionary *result) {
        handler(aList,result);
    }]; 
}

//////////////////////////////////////////////////////





- (BOOL)_saveTaskListsFromJSON:(NSDictionary *)json {
    FMDatabase *db = [FMDatabase database];
    if (![db open]) {
        NSLog(@"Could not open db.");
		return NO;
    } else {
        BOOL rs = NO;
        NSArray *items = [json objectForKey:@"items"];
        for (NSDictionary*item in items) {
            NSString *_id = [item objectForKey:@"id"];
            NSString *kind = [item objectForKey:@"kind"];
            NSString *link = [item objectForKey:@"selfLink"];
            NSString *title = [item objectForKey:@"title"];
            
            double timeStamp = [[NSDate date] timeIntervalSince1970];
            NIF_TRACE(@"timeStamp : %0.0f", timeStamp);
            
            FMResultSet *set = [db executeQuery:[NSString stringWithFormat:@"SELECT * FROM task_lists WHERE server_list_id = '%@'",_id]];
            if ([set next]) {
                NIF_INFO(@"已经存在记录了");
            } else {
                NSString *sql = [NSString stringWithFormat:@"INSERT INTO task_lists (server_list_id,kind,self_link,title,latest_sync_timestamp) VALUES ('%@','%@','%@','%@',%0.0f)",_id,kind,link,title,timeStamp];
                NIF_INFO(@"save to DB sql : %@", sql);
                rs = [db executeUpdate:sql];
                NIF_INFO(@"%d", rs);                
            }
            
        }
        return rs;
    }
}

- (BOOL)_saveTasksForTaskList:(TaskList *)aList fromJSON:(NSDictionary *)json {
    FMDatabase *db = [FMDatabase database];
    if (![db open]) {
        NSLog(@"Could not open db.");
		return NO;
    } else {
        BOOL rs = NO;
        NSArray *items = [json objectForKey:@"items"];
        
        NSInteger order = 0;
        for (NSDictionary*item in items) {
            NSString *_id = [item objectForKey:@"id"];
            NSString *notes = [item objectForKey:@"notes"];
            NSString *link = [item objectForKey:@"selfLink"];
            NSString *title = [item objectForKey:@"title"];
            NSString *parentId = [item objectForKey:@"parent"];
            NSString *statusString = [item objectForKey:@"status"];
            BOOL isCompleted = NO;
            if ([statusString isEqualToString:@"needAction"]) {
                isCompleted = NO;
            } else if ([statusString isEqualToString:@"completed"]) {
                isCompleted = YES;
            }

            NSString *completedDate = [item objectForKey:@"completed"];
            
            NSDate *completedTime = [NSDate dateFromRFC3339:completedDate];
            NSDate *updated = [NSDate dateFromRFC3339:[item objectForKey:@"updated"]];
            NSDate *due = [NSDate dateFromRFC3339:[item objectForKey:@"due"]];
            
            
            NSInteger localParentId = -1;

            FMResultSet *parentSet = [db executeQuery:[NSString stringWithFormat:@"SELECT * FROM tasks WHERE server_task_id = '%@'",parentId]];
            if ([parentSet next]) {
                localParentId = [parentSet intForColumn:@"local_task_id"];
            } else {
                
            }
            
            NIF_INFO(@"---------------- localParentId : %d", localParentId);
            
            FMResultSet *set = [db executeQuery:[NSString stringWithFormat:@"SELECT * FROM tasks WHERE server_task_id = '%@'",_id]];
            if ([set next]) {
                //                NIF_INFO(@"已经存在记录了");
                NSDate *local_modify_time = [set dateForColumn:@"local_modify_timestamp"];
                NSDate *server_modify_time = [set dateForColumn:@"server_modify_timestamp"];
                if ([local_modify_time timeIntervalSinceDate:server_modify_time] > 0) {
                    
                }
                
            } else {
                rs = [db executeUpdate:@"INSERT INTO tasks (server_task_id,local_list_id,local_parent_id,notes,self_link,title,due,server_modify_timestamp,display_order,is_completed,completed_timestamp) VALUES (?,?,?,?,?,?,?,?,?,?,?)",
                      _id,
                      [NSNumber numberWithInt:aList.localListId],
                      [NSNumber numberWithInt:localParentId],
                      notes,
                      link,
                      title,
                      due,
                      updated,
                      [NSNumber numberWithInt:order],
                      [NSNumber numberWithInt:isCompleted],
                      completedTime];
            }
            order++;

        }
        [db close];
        return rs;
    }    
}

- (BOOL)_syncParentIdWithItems:(NSArray *)items {
    FMDatabase *db = [FMDatabase database];
    if (![db open]) {
        NSLog(@"Could not open db.");
		return NO;
    } else {
        BOOL rs = NO;
        for (NSDictionary*item in items) {
            NSString *serverId = [item objectForKey:@"id"];
            NSString *parentId = [item objectForKey:@"parent"];
            NSString *sql = [NSString stringWithFormat:@"UPDATE tasks SET local_parent_id = (SELECT local_task_id FROM tasks WHERE server_task_id = '%@') WHERE server_task_id = '%@'",parentId,serverId];
            NIF_INFO(@"SYNC PARENT SQL : %@", sql);
            NSError *error = nil;
            rs = [db executeUpdate:sql error:&error withArgumentsInArray:nil orVAList:nil];
            if (error) {
                NIF_INFO(@"%@", error);
            }
            
        }
        [db close];
        return rs;
    }
}

- (void)reloadLocalLists {
    FMDatabase *db = [FMDatabase database];
    if (![db open]) {
        NSLog(@"Could not open db.");
    } else {
        [_localTaskLists removeAllObjects];
        
        FMResultSet *rs = [db executeQuery:[NSString stringWithFormat:@"SELECT * FROM task_lists WHERE is_deleted = 0 ORDER BY display_order "]];
        while ([rs next]) {

            TaskList *list = [[TaskList alloc] initWithLocalListId:[rs intForColumn:@"local_list_id"]];

            list.serverListId = [rs stringForColumn:@"server_list_id"];
            list.kind = [rs stringForColumn:@"kind"];
            list.link = [rs stringForColumn:@"self_link"];
            list.title = [rs stringForColumn:@"title"];
            list.isDefault = [rs boolForColumn:@"is_default"];
            list.isDeleted = [rs boolForColumn:@"is_deleted"];
            list.isCleared = [rs boolForColumn:@"is_cleared"];
            list.lastestSyncTime = [rs dateForColumn:@"latest_sync_timestamp"];
            list.serverModifyTime = [rs dateForColumn:@"server_modify_timestamp"];
            list.localModifyTime = [rs dateForColumn:@"local_modify_timestamp"];
            list.displayOrder = [rs intForColumn:@"display_order"];
            
            [_localTaskLists addObject:list];
            [list release];
        }
        [db close];  
    }
}

- (void)reloadDeletedLists {
    FMDatabase *db = [FMDatabase database];
    if (![db open]) {
        NSLog(@"Could not open db.");
    } else {

        FMResultSet *rs = [db executeQuery:[NSString stringWithFormat:@"SELECT * FROM task_lists WHERE is_deleted = 1"]];
        while ([rs next]) {
            TaskList *list = [[TaskList alloc] initWithLocalListId:[rs intForColumn:@"local_list_id"]];
            list.localListId = [rs intForColumn:@"local_list_id"];
            list.serverListId = [rs stringForColumn:@"server_list_id"];
            list.kind = [rs stringForColumn:@"kind"];
            list.link = [rs stringForColumn:@"self_link"];
            list.title = [rs stringForColumn:@"title"];
            list.isDefault = [rs boolForColumn:@"is_default"];
            list.isDeleted = [rs boolForColumn:@"is_deleted"];
            list.isCleared = [rs boolForColumn:@"is_cleared"];
            list.lastestSyncTime = [rs dateForColumn:@"latest_sync_timestamp"];
            list.serverModifyTime = [rs dateForColumn:@"server_modify_timestamp"];
            list.localModifyTime = [rs dateForColumn:@"local_modify_timestamp"];
            list.displayOrder = [rs intForColumn:@"display_order"];

            [list release];
        }
        [db close];  
    }
}

- (NSArray *)_deletingLists {
    FMDatabase *db = [FMDatabase database];
    if (![db open]) {
        NSLog(@"Could not open db.");
        return nil;
    } else {
        NSMutableArray *tempLists = [NSMutableArray array];
        FMResultSet *rs = [db executeQuery:[NSString stringWithFormat:@"SELECT * FROM task_lists WHERE is_deleted = 1"]];
        while ([rs next]) {
            TaskList *list = [[TaskList alloc] initWithLocalListId:[rs intForColumn:@"local_list_id"]];
            list.localListId = [rs intForColumn:@"local_list_id"];
            list.serverListId = [rs stringForColumn:@"server_list_id"];
            list.kind = [rs stringForColumn:@"kind"];
            list.link = [rs stringForColumn:@"self_link"];
            list.title = [rs stringForColumn:@"title"];
            list.isDefault = [rs boolForColumn:@"is_default"];
            list.isDeleted = [rs boolForColumn:@"is_deleted"];
            list.isCleared = [rs boolForColumn:@"is_cleared"];
            list.lastestSyncTime = [rs dateForColumn:@"latest_sync_timestamp"];
            list.serverModifyTime = [rs dateForColumn:@"server_modify_timestamp"];
            list.localModifyTime = [rs dateForColumn:@"local_modify_timestamp"];
            list.displayOrder = [rs intForColumn:@"display_order"];
            
            [tempLists addObject:list];
            [list release];
        }
        [db close];  
        return tempLists;
    }
}

- (NSArray *)_addingLists {
    FMDatabase *db = [FMDatabase database];
    if (![db open]) {
        NSLog(@"Could not open db.");
        return nil;
    } else {
        NSMutableArray *tempLists = [NSMutableArray array];
        FMResultSet *rs = [db executeQuery:[NSString stringWithFormat:@"SELECT * FROM task_lists WHERE is_deleted = 0 AND server_list_id is null"]];
        while ([rs next]) {
            TaskList *list = [[TaskList alloc] initWithLocalListId:[rs intForColumn:@"local_list_id"]];
            list.localListId = [rs intForColumn:@"local_list_id"];
            list.serverListId = [rs stringForColumn:@"server_list_id"];
            list.kind = [rs stringForColumn:@"kind"];
            list.link = [rs stringForColumn:@"self_link"];
            list.title = [rs stringForColumn:@"title"];
            list.isDefault = [rs boolForColumn:@"is_default"];
            list.isDeleted = [rs boolForColumn:@"is_deleted"];
            list.isCleared = [rs boolForColumn:@"is_cleared"];
            list.lastestSyncTime = [rs dateForColumn:@"latest_sync_timestamp"];
            list.serverModifyTime = [rs dateForColumn:@"server_modify_timestamp"];
            list.localModifyTime = [rs dateForColumn:@"local_modify_timestamp"];
            list.displayOrder = [rs intForColumn:@"display_order"];
            
            [tempLists addObject:list];
            [list release];
        }
        [db close];  
        return tempLists;
    }
}


/**
 *
 * JSON parse Methods
 *
 */
- (NSArray *)_parseServerTaskListsFromJSON:(NSDictionary *)json {
    NSMutableArray *tempLists = [NSMutableArray array];
    
    NSArray *items = [json objectForKey:@"items"];
    
    for (NSDictionary*item in items) {
        TaskList *aList = [[TaskList alloc] init];
        
        aList.serverListId = [item objectForKey:@"id"];
        aList.kind = [item objectForKey:@"kind"];
        aList.link = [item objectForKey:@"selfLink"];
        aList.title = [item objectForKey:@"title"];
        aList.serverModifyTime = [NSDate date];
        aList.localModifyTime = [NSDate dateWithTimeIntervalSince1970:0];
        [tempLists addObject:aList];
        [aList release];
    }
    return tempLists;
}

- (void)syncWithSyncHandler:(SyncHandler)handler {
        
    if (_isSyncing) {
        return;
    }
    
    _isSyncing = YES;
        
    //Check Network
    
    // Delete list
    // add new list
    
    // download all List
    // check the timestamp of changed List, update local List 
    // download tasks for every list 
    // check the timestamp of changed Task, update local Task 
    // update all changes to server
    
    // List 重命名 、
    
    // 
    // 如果未登陆 则登陆
    // 
    [self authorizeWithResultBlock:^(GDataEngine *engine, id result) {
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(queue, ^{
            // 删除
            NSArray *deletingLists = [self _deletingLists];
            for(TaskList *list in deletingLists) {
                if (list.isDeleted) {
                    if(!list.serverListId) {
                        // List 未上传到服务器就删除了 没有ServerId
                        [self clearDeletedList:list];
                    } else {
                        [self removeList:list remoteHandler:^(TaskList *currentList, id result) {
                            [self clearDeletedList:list];                   
                        }];
                    }
                }
            }
            
            ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
            //// 删除
            FMDatabase *db = [FMDatabase database];
            if (![db open]) {
                NSLog(@"Could not open db.");
                //return nil;
            } else {
                // clean 
                [db executeUpdate:@"DELETE FROM task_lists WHERE is_deleted = 1 AND server_list_id is null"];
                
                FMResultSet *rs = [db executeQuery:@"SELECT server_list_id FROM task_lists WHERE is_deleted = 1 AND server_list_id is not null"];
                while ([rs next]) {
                    NSString *server_list_id = [rs objectForColumnName:@"server_list_id"];
                    
                    NSString *selfLink = [NSString stringWithFormat:@"https://www.googleapis.com/tasks/v1/users/@me/lists/%@",server_list_id];
                    NSURL *url = [NSURL URLWithString:selfLink];
                    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
                    [request setValue:[NSString stringWithFormat:@"OAuth %@",self.accessToken] forHTTPHeaderField:@"Authorization"];
                    [request setHTTPMethod:@"DELETE"];
                    NSError *error = nil;
                    NSURLResponse *response = nil;
                    NSData *responsingData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
                    if (error) {
                        
                    } else {
                        
                    }
                    
                }
                
            }
            
            // 添加
            NSArray *addingLists = [self _addingLists];
            
            for(TaskList *list in addingLists) {
                NSMutableURLRequest *request = [NSMutableURLRequest requestWithAddingList:list];
                [request setValue:[NSString stringWithFormat:@"OAuth %@",self.accessToken] forHTTPHeaderField:@"Authorization"];
                NSError *error = nil;
                NSURLResponse *response = nil;
                NSData *responsingData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
                if (error) {
                    
                } else {
                    NSDictionary *json = [responsingData yajl_JSON];
                    list.serverListId = [json objectForKey:@"id"];
                    list.kind = [json objectForKey:@"kind"];
                    list.link = [json objectForKey:@"selfLink"];
                    [list localUpdate];
                }
            }
            NIF_INFO(@"upload lists success!"); 
            
            
            // Download ServerList
            NSError *error = nil;
            NSArray *serverLists =  [self fetchServerListsWithError:&error];
            if (error) {
                NIF_INFO(@"%@", error);
            } else {
                
                // 对比服务器与本地的List 如果服务器不存在 而本地存在 则说明被服务器删掉 此时需要清理本地list
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SUBQUERY(%@, $list, SELF.serverListId == $list.serverListId ).@count == 0", serverLists];
                NSArray *deletedByServerLists = [_localTaskLists filteredArrayUsingPredicate:predicate];
                
                for (TaskList *item in deletedByServerLists) {
                    [self clearDeletedList:item];
                }
                
                // 如果本地 服务器都存在 则比较title有木有变化
                NSPredicate *predicate3 = [NSPredicate predicateWithFormat:@"SUBQUERY(%@, $list, SELF.serverListId == $list.serverListId AND SELF.title != $list.title).@count > 0", serverLists];
                NSArray *mayModifiedLists = [_localTaskLists filteredArrayUsingPredicate:predicate3];
                for(TaskList *list in mayModifiedLists) {
                    if ([list.localModifyTime timeIntervalSinceDate:list.serverModifyTime] > 0) {
                        // 取本地名字为最新
                        NSMutableURLRequest *request = [NSMutableURLRequest requestWithUpdateList:list];
                        [request setValue:[NSString stringWithFormat:@"OAuth %@",self.accessToken] forHTTPHeaderField:@"Authorization"];
                        NSError *error = nil;
                        NSURLResponse *response = nil;
                        NSData *responsingData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
                        if (error) {
                            NIF_INFO(@"%@", error);
                        } else {
                            NSDictionary *json = [responsingData yajl_JSON];                            
                            NIF_INFO(@"%@", json);
                        }
                    } else {
                        // 更新数据库list title即可
                        NSPredicate *predicate4 = [NSPredicate predicateWithFormat:@"serverListId = %@", list.serverListId];
                        NSArray *filterArray = [serverLists filteredArrayUsingPredicate:predicate4];
                        if (filterArray && [filterArray count]) {
                            TaskList *serverList = [filterArray objectAtIndex:0];
                            [list setTitle:serverList.title updateDB:YES];
                        }
                    }
                }
                
                // 如果本地不存在这个list 则添加
                NSPredicate *predicate2 = [NSPredicate predicateWithFormat:@"SUBQUERY(%@, $list, SELF.serverListId == $list.serverListId ).@count == 0", _localTaskLists];
                NSArray *notAddedLists = [serverLists filteredArrayUsingPredicate:predicate2];
                [self insertLists:notAddedLists updateDB:YES];
                
                
                // update tasks 

                NSHTTPURLResponse *response = nil;
                NSError *error = nil;

                TaskList *aList = [[TaskList alloc] init];
                aList.serverListId = @"MTI4MTA3OTcwNjkxODkyNzIyNDQ6NjI3MDQyMzc0OjA";

                BOOL clearSuccess = [aList clearServerCompletedTasks];
                NIF_INFO(@"%d", clearSuccess);
                    
                for (TaskList *list in _localTaskLists) {

//                    NSURLResponse *response = nil;
//                    NSError *error = nil;
//                    [list clearServerCompletedTasksWithResponse:&response error:&error];
                    
                    
                    
//                    NSError *error = nil;
//                    NSString *lastSyncTimeString = [list.lastestSyncTime RFC3339String];
//                    NSDictionary *filters = [NSDictionary dictionaryWithObjectsAndKeys:
//                                            lastSyncTimeString?lastSyncTimeString:@"",@"updatedMin",
//                                             @"True",@"showDeleted",
//                                            nil];
//                    NSArray *serverTasks = [list fetchServerTasksSynchronouslyWithFilters:filters error:&error];
//                    
//                    for (Task *aTask in serverLists) {
//
//                    }
                    
                    
                    
                    
                    [list updateLastestSyncTime:[NSDate date]];
                    
                }
                
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                handler(self,SyncStepListsUpdated);                
            });
        });
    
        _isSyncing = NO;

    }];

}


- (void)fetchServerTaskListsWithResultHander:(void(^)(GTaskEngine *,NSArray *))resultHander {
    NSURL *url = [NSURL URLWithString:kTaskListsURL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [self fetchWithRequest:request resultBlock:^(GDataEngine *engine, id result) {
        if ([result isKindOfClass:[NSError class]]) {
            NIF_ERROR(@"--- %d", [(NSError *)result code]);
            NIF_ERROR(@"--- %@", [(NSError *)result localizedDescription]);
        } else if ([result isKindOfClass:[NSDictionary class]]) {
            NSArray *theLists = [self _parseServerTaskListsFromJSON:result];
            resultHander(self,theLists);
        }
    }];
}

// #同步方法# 获取serverlists 
- (NSArray *)fetchServerListsWithError:(NSError **)error {
    
    NSString *nextPageToken = nil;
    NSMutableArray *serverLists = [NSMutableArray array];
    
    do {
        
        NSString *urlString = nextPageToken?[NSString stringWithFormat:@"%@?pageToken=%@",kTaskListsURL,nextPageToken]:kTaskListsURL;
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
        [request setValue:[NSString stringWithFormat:@"OAuth %@",self.accessToken] forHTTPHeaderField:@"Authorization"];
        NSURLResponse *response = nil;
        NSData *responsingData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:error];
        if (*error) {
            
        } else {
            NSDictionary *json = [responsingData yajl_JSON];
            
            nextPageToken = [json objectForKey:@"nextPageToken"];
            NSArray *tempServerLists = [self _parseServerTaskListsFromJSON:json];
            
            if (tempServerLists && [tempServerLists count]) {
                [serverLists addObjectsFromArray:tempServerLists];
            }            
        }        
    } while (nextPageToken && !(*error));
    
    return serverLists;
}

- (void)clearServerTasksDeletedByLocalWithError:(NSError **)error {
    FMDatabase *db = [FMDatabase database];
    if (![db open]) {
        NSLog(@"Could not open db.");
    } else {
        [db executeUpdate:@"DELETE FROM task_lists WHERE is_deleted = 1 AND server_list_id is null"];
        
        FMResultSet *rs = [db executeQuery:@"SELECT server_task_id,task_lists.server_list_id AS server_list_id FROM tasks \
                           LEFT JOIN task_lists ON task_lists.local_list_id = task_lists.local_task_id\
                           WHERE server_task_id.is_deleted = 1 AND server_list_id is not null"];
        while ([rs next]) {
            
            NSString *serverTaskId = [rs stringForColumn:@"server_task_id"];
            NSString *serverListId = [rs stringForColumn:@"server_list_id"];
            
            NSString *urlString = [NSString stringWithFormat:@"https://www.googleapis.com/tasks/v1/lists/%@/tasks/%@",serverListId,serverTaskId];
            
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
            [request setValue:[NSString stringWithFormat:@"OAuth %@",self.accessToken] forHTTPHeaderField:@"Authorization"];
            [request setHTTPMethod:@"DELETE"];
            
            NSURLResponse *response = nil;
            NSData *responsingData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:error];
            if (*error) {
                
            } else {

            }            
        }
        
        
    }
    
}

@end

