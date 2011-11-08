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

static NSString *kTaskListsURL = @"https://www.googleapis.com/tasks/v1/users/@me/lists";
static NSString *kTasksURLFormat = @"https://www.googleapis.com/tasks/v1/lists/%@/tasks";

@interface GTaskEngine (Private)

- (BOOL)_saveTaskListsFromJSON:(NSDictionary *)json;
- (BOOL)_syncParentIdWithItems:(NSArray *)items;

// 
- (NSArray *)_parseServerTaskListsFromJSON:(NSDictionary *)json;

- (NSArray *)_readListsFromDB;

@end


@implementation GTaskEngine


@synthesize localTaskLists = _localTaskLists;

- (void)dealloc {
    
    [_localTaskLists release];
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

//- (NSMutableArray *)sharedTaskLists {
//    static NSMutableArray *taskLists = nil;
//    if (taskLists == nil) {
//        taskLists = [[self localTaskLists] retain];
//    }
//    return taskLists;
//}

- (id)init {
    if (self = [super init]) {
        _localTaskLists = [[NSMutableArray alloc] init];
        
        NSArray *tempLists = [self _readListsFromDB];
        if (tempLists && [tempLists count]) {
            [_localTaskLists addObjectsFromArray:tempLists];
        }
    }
    return self;
}

- (void)insertList:(TaskList *)taskList updateDB:(BOOL)update {
    if(update) {
        FMDatabase *db = [FMDatabase database];
        if (![db open]) {
            NSLog(@"Could not open db.");
        } else {
            [db executeUpdate:@"INSERT INTO task_lists (server_list_id,kind,self_link,title,server_modify_timestamp,local_modify_timestamp) VALUES (?,?,?,?,?,?)",taskList.serverListId,taskList.kind,taskList.link,taskList.title,taskList.serverModifyTime,taskList.localModifyTime];
            
            FMResultSet *set = [db executeQuery:@"SELECT * FROM task_lists WHERE server_list_id = ?",taskList.serverListId];
            if ([set next]) {
                NSInteger localListId = [set intForColumn:@"local_list_id"];
                taskList.localListId = localListId;
            }
            [db close];
        }        
    }
    [_localTaskLists addObject:taskList];
}


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

- (NSArray *)_readListsFromDB {
    FMDatabase *db = [FMDatabase database];
    if (![db open]) {
        NSLog(@"Could not open db.");
        return nil;
    } else {
        NSMutableArray *tempLists = [NSMutableArray array];
        FMResultSet *rs = [db executeQuery:[NSString stringWithFormat:@"SELECT * FROM task_lists WHERE is_deleted = 0 ORDER BY display_order "]];
        while ([rs next]) {
            TaskList *list = [[TaskList alloc] init];
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
    
    NSDate *serverModifyTime = [NSDate date];
    NSArray *items = [json objectForKey:@"items"];
    
    for (NSDictionary*item in items) {
        TaskList *aList = [[TaskList alloc] init];
        
        aList.serverListId = [item objectForKey:@"id"];
        aList.kind = [item objectForKey:@"kind"];
        aList.link = [item objectForKey:@"selfLink"];
        aList.title = [item objectForKey:@"title"];
        aList.serverModifyTime = serverModifyTime;
        
        [tempLists addObject:aList];
        [aList release];
    }
    return tempLists;
}

- (void)syncWithSyncHandler:(SyncHandler)handler {
    
    // download all List
    // check the timestamp of changed List, update local List 
    // download tasks for every list 
    // check the timestamp of changed Task, update local Task 
    // update all changes to server
    
    // List 重命名 、
        
    [self fetchServerTaskListsWithResultHander:^(GTaskEngine *engine, NSArray *lists) {

        handler(self,SyncStepListsDownloaded);

        // 获取到服务器上lists
        FMDatabase *db = [FMDatabase database];
        if (![db open]) {
            NSLog(@"Could not open db.");
        } else {
            [db setPragmaValue:1 forKey:@"foreign_keys"];
            // 下载比对
            for (TaskList *item in lists) {

                FMResultSet *set = [db executeQuery:@"SELECT * FROM task_lists WHERE server_list_id = ? AND server_modify_timestamp >= local_modify_timestamp",item.serverListId];
                if (![set next]) {
                    // 本地没有这个list 则插入
                    NSDate *now = [NSDate date];
                    item.serverModifyTime = now;
                    item.localModifyTime = now;
                    
                    [self insertList:item updateDB:YES];
                    
                } else {
                    NSString *aTitle = [set stringForColumn:@"title"];
                    if (![aTitle isEqualToString:item.title]) {
                        // 本地有这个list 且title不一样 则更新title
                        [item setTitle:aTitle updateDB:YES];
                    } else {
                        // List 一样 啥都不做                     
                    }
                }
            }

            // 上传新加List
            FMResultSet *set = [db executeQuery:@"SELECT * FROM task_lists server_modify_timestamp < local_modify_timestamp"];
            if ([set next]) {
                
                TaskList *list = [[[TaskList alloc] init] autorelease];
                list.serverListId = [set stringForColumn:@"server_list_id"];
                list.title = [set stringForColumn:@"title"];
                list.link = [set stringForColumn:@"self_link"];
                list.kind = [set stringForColumn:@"kind"];
                list.isDeleted = [set boolForColumn:@"is_deleted"];
                
                if (list.isDeleted) {
                    if (list.serverListId == nil) {
                        // 删除本地未同步的List
                        // ... !TODO
                        [list deleteLocal];
                    } else {
                        // 需要删除服务器List
                        [list deleteWithRemoteHandler:^(TaskList *currentList, id result) {
                            [list deleteLocal];
                        }];
                    }
                } else {
                    if (list.serverListId == nil) {
                        [list createWithRemoteHandler:^(TaskList *currentList, NSDictionary *result) {
                            // UPDATE LOCAL SERVER ID;
                            // ... !TODO
                            NIF_INFO(@"%@", result);
                            NSString *_id = [result objectForKey:@"id"];
                            [list setServerListId:_id updateDB:YES];
                        }];                        
                    } else {
                        [list updateWithRemoteHandler:^(TaskList *currentList, NSDictionary *result) {
                            [list setServerModifyTime:[NSDate date] updateDB:YES];
                        }];
                    }
                }
                
            }
            handler(self,SyncStepListsUpdated);
        }        
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


@end

