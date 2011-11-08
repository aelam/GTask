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

- (NSMutableArray *)sharedTaskLists {
    static NSMutableArray *taskLists = nil;
    if (taskLists == nil) {
        taskLists = [[self localTaskLists] retain];
    }
    return taskLists;
}

- (id)init {
    if (self = [super init]) {
        _localTaskLists = [[NSMutableArray alloc] init];
    }
    return self;
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

/*
- (BOOL)_saveTasksForTaskList:(TaskList *)aList fromJSON:(NSDictionary *)json {
    FMDatabase *db = [FMDatabase database];
    if (![db open]) {
        NSLog(@"Could not open db.");
		return NO;
    } else {
        BOOL rs = NO;
        NSArray *items = [json objectForKey:@"items"];
//        [self testArray:items];
        NSMutableArray *parentItems = [NSMutableArray array];

        for (NSDictionary*item in items) {
            NSString *_id = [item objectForKey:@"id"];
            NSString *notes = [item objectForKey:@"notes"];
            NSString *link = [item objectForKey:@"selfLink"];
            NSString *title = [item objectForKey:@"title"];
            NSString *parentId = [item objectForKey:@"parent"];
            NSString *position = [item objectForKey:@"position"];
            
            double updated = [[NSDate dateFromRFC3339:[item objectForKey:@"updated"]] timeIntervalSince1970];
                        
            NSInteger localParentId = -1;

            if (parentId) {
                [parentItems addObject:item];                
            }
            
            FMResultSet *set = [db executeQuery:[NSString stringWithFormat:@"SELECT * FROM tasks WHERE server_task_id = '%@'",_id]];
            if ([set next]) {
//                NIF_INFO(@"已经存在记录了");
            } else {
                NSString *sql = [NSString stringWithFormat:@"INSERT INTO tasks (server_task_id,local_list_id,local_parent_id,notes,self_link,title,server_modify_timestamp) VALUES ('%@',%d,%d,'%@','%@','%@',%0.0f)",_id,aList.localListId,localParentId,notes?notes:@"",link,title,updated];
                NIF_INFO(@"save to DB sql : %@", sql);
                //rs = [db executeUpdate:sql];
                NSError *error = nil;
                rs = [db executeUpdate:sql error:&error withArgumentsInArray:nil orVAList:nil];
                if (error) {
                    NIF_INFO(@"%@", error);
                }
                NIF_INFO(@"%d", rs);                
            }
        }
        [db close];
        [self _syncParentIdWithItems:parentItems];
        return rs;
    }    
}*/

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

- (void)setLocalTaskLists:(NSMutableArray *)aLists {
    if (_localTaskLists != aLists) {
        [_localTaskLists release];
        _localTaskLists = [aLists retain];
    }
}

- (NSMutableArray *)localTaskLists{
    if (_localTaskLists == nil || [_localTaskLists count] == 0) {
        FMDatabase *db = [FMDatabase database];
        if (![db open]) {
            NSLog(@"Could not open db.");
            return nil;
        } else {
            [_localTaskLists removeAllObjects];
            
            FMResultSet *rs = [db executeQuery:[NSString stringWithFormat:@"SELECT * FROM task_lists ORDER BY display_order"]];
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
                
                [_localTaskLists addObject:list];
                [list release];
            }
            [db close];            
        }
    }
    return _localTaskLists;
}

- (NSMutableArray *)localTaskListsWithSortType:(NSInteger)sortType {
    NSMutableArray *taskLists = nil;
    FMDatabase *db = [FMDatabase database];
    if (![db open]) {
        NSLog(@"Could not open db.");
		return nil;
    } else {
        taskLists = [NSMutableArray array];
        FMResultSet *rs = [db executeQuery:[NSString stringWithFormat:@"SELECT * FROM task_lists"]];
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
            
            [taskLists addObject:list];
            [list release];
        }
        [db close];            
        return taskLists;
    }
}

/*
- (void)fetchServerTaskListsWithResultHander:(void(^)(GTaskEngine *,NSMutableArray *))resultHander {
    NSURL *url = [NSURL URLWithString:kTaskListsURL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [self fetchWithRequest:request resultBlock:^(GDataEngine *engine, id result) {
        if ([result isKindOfClass:[NSError class]]) {
            NIF_ERROR(@"--- %d", [(NSError *)result code]);
            NIF_ERROR(@"--- %@", [(NSError *)result localizedDescription]);
        } else if ([result isKindOfClass:[NSDictionary class]]) {
            BOOL rs = [self _saveTaskListsFromJSON:result];
            NIF_INFO(@"%d", rs);
            NSMutableArray *taskLists = [self localTaskListsWithSortType:1];
            resultHander(self,taskLists);
        }
    }];
}

- (void)fetchServerTasksForList:(TaskList *)aList resultHander:(void(^)(GTaskEngine *,NSMutableArray *))resultHander {
    NSString *urlString = [NSString stringWithFormat:kTasksURLFormat,aList.serverListId];
    NIF_INFO(@"%@", urlString);
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    GTaskEngine *engine = [GTaskEngine engine];
    [engine fetchWithRequest:request resultBlock:^(GDataEngine *engine, id result) {
        if ([result isKindOfClass:[NSError class]]) {
            NIF_TRACE(@"--- %d", [(NSError *)result code]);
        } else if ([result isKindOfClass:[NSDictionary class]]) {
            NIF_INFO(@"json:\n%@", result);
            BOOL rs = [self _saveTasksForTaskList:aList fromJSON:result];
            NIF_INFO(@"UPDATE DB SUCCESS?:%d", rs);
            NSMutableArray *tasks = [self localTasksForList:aList];
            resultHander(self,tasks);
        }
    }];
}
*/

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


- (void)sync {
    
    // download all List
    // check the timestamp of changed List, update local List 
    // download tasks for every list 
    // check the timestamp of changed Task, update local Task 
    // update all changes to server
        
    // List 重命名 、
//    TaskList *list = [[[TaskList alloc] init] autorelease];
//    list.title = @"阿米托福";
//    [list createWithRemoteHandler:^(TaskList *currentList, id result) {
//        NIF_INFO(@"%@", result);
//    }];
//    return;
    
    // foreign Key test;
//    FMDatabase *db = [FMDatabase database];
//    [db open];
//    [db setPragmaValue:1 forKey:@"foreign_keys"];
//    NSError *error = nil;
//    BOOL rs = [db executeUpdate:@"INSERT INTO tasks (title,local_parent_id,local_list_id) values(?,?,?)",@"Test",@"-1",@"1"];
//    NIF_INFO(@"success ? : %d", rs);
//    if (error) {
//        NIF_INFO(@"%@", error);
//    }
//    [db close];
//    return;
    
    
    [self fetchServerTaskListsWithResultHander:^(GTaskEngine *engine, NSMutableArray *lists) {

        // 获取到服务器上lists
        FMDatabase *db = [FMDatabase database];
        if (![db open]) {
            NSLog(@"Could not open db.");
        } else {
            [db setPragmaValue:1 forKey:@"foreign_keys"];
            // 下载比对
            for (NSDictionary *item in lists) {
                NSString *_id = [item objectForKey:@"id"];
                NSString *kind = [item objectForKey:@"kind"];
                NSString *link = [item objectForKey:@"selfLink"];
                NSString *title = [item objectForKey:@"title"];
             
                FMResultSet *set = [db executeQuery:@"SELECT * FROM task_lists WHERE server_list_id = ? AND server_modify_timestamp > local_modify_timestamp",_id];
                if (![set next]) {
                    // 本地没有这个list 则插入
                    NSDate *now = [NSDate date];
                    [db executeUpdate:@"INSERT INTO task_lists (server_list_id,kind,self_link,title,server_modify_timestamp,local_modify_timestamp) VALUES (?,?,?,?,?,?)",_id,kind,link,title,now,now];
                } else {
                    NSString *aTitle = [set stringForColumn:@"title"];
                    if (![aTitle isEqualToString:title]) {
                        // 本地有这个list 且title不一样 则更新title
                        [db executeUpdate:@"UPDATE task_lists SET title = ?",aTitle];
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
                    } else {
                        // 需要删除服务器List
                        [list deleteWithRemoteHandler:^(TaskList *currentList, id result) {
                            
                        }];
                    }
                } else {
                    if (list.serverListId == nil) {
                        [list createWithRemoteHandler:^(TaskList *currentList, id result) {
                            // UPDATE LOCAL SERVER ID;
                            // ... !TODO
                        }];                        
                    } else {
                        [list updateWithRemoteHandler:^(TaskList *currentList, NSDictionary *result) {
                            [list setServerModifyTime:[NSDate date] updateDB:YES];
                        }];
                    }
                }
                
            }
        }        
    }];
}


- (void)fetchServerTaskListsWithResultHander:(void(^)(GTaskEngine *,NSMutableArray *))resultHander {
    NSURL *url = [NSURL URLWithString:kTaskListsURL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [self fetchWithRequest:request resultBlock:^(GDataEngine *engine, id result) {
        if ([result isKindOfClass:[NSError class]]) {
            NIF_ERROR(@"--- %d", [(NSError *)result code]);
            NIF_ERROR(@"--- %@", [(NSError *)result localizedDescription]);
        } else if ([result isKindOfClass:[NSDictionary class]]) {
            resultHander(self,[result objectForKey:@"items"]);
        }
    }];
}


@end

