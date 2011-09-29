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


@end


@implementation GTaskEngine

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
        NSMutableArray *parentItems = [NSMutableArray array];
        for (NSDictionary*item in items) {
            NSString *_id = [item objectForKey:@"id"];
            NSString *notes = [item objectForKey:@"notes"];
            NSString *link = [item objectForKey:@"selfLink"];
            NSString *title = [item objectForKey:@"title"];
            NSString *parentId = [item objectForKey:@"parent"];
            NSString *position = [item objectForKey:@"position"];
            
            NIF_INFO(@"%@", position);
            
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

- (NSMutableArray *)localTaskLists{
    return [self localTaskListsWithSortType:1];
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
            list.status = [rs intForColumn:@"status"];
            list.lastestSyncTime = [rs doubleForColumn:@"latest_sync_timestamp"];
            list.serverModifyTime = [rs doubleForColumn:@"server_modify_timestamp"];
            list.localModifyTime = [rs doubleForColumn:@"local_modify_timestamp"];
            
            [taskLists addObject:list];
            [list release];
        }
        [db close];            
        return taskLists;
    }
}

- (NSMutableArray *)localTasksForList:(TaskList *)aList {
    NSMutableArray *tasks = nil;
    FMDatabase *db = [FMDatabase database];
    if (![db open]) {
        NSLog(@"Could not open db.");
		return nil;
    } else {
        tasks = [NSMutableArray array];
        FMResultSet *rs = [db executeQuery:[NSString stringWithFormat:@"SELECT * FROM tasks WHERE local_list_id = %d ORDER BY local_task_id",aList.localListId]];
        while ([rs next]) {
            Task *task = [[Task alloc] init];
            task.localTaskId = [rs intForColumn:@"local_task_id"];
            task.serverTaskId = [rs stringForColumn:@"server_task_id"];
            task.localListId = [rs intForColumn:@"local_list_id"];
            task.localParentId = [rs intForColumn:@"local_parent_id"];
            task.title = [rs stringForColumn:@"title"];
            task.notes = [rs stringForColumn:@"notes"];
            task.isUpdated = [rs boolForColumn:@"is_updated"];
            task.isCompleted = [rs boolForColumn:@"is_completed"];
            task.isHidden = [rs boolForColumn:@"is_hidden"];
            task.isDeleted = [rs boolForColumn:@"is_deleted"];
            task.status = [rs intForColumn:@"status"];
            task.isCleared = [rs boolForColumn:@"is_cleared"];
            task.completedTimestamp = [rs doubleForColumn:@"completed_timestamp"];
            task.reminderTimestamp = [rs doubleForColumn:@"reminder_timestamp"];
            task.due = [rs doubleForColumn:@"due"];
            task.serverModifyTime = [rs doubleForColumn:@"server_modify_timestamp"];
            [tasks addObject:task];
            [task release];
        }
        [db close];            
        return tasks;
    }
}

- (void)fetchServerTaskListsWithResultHander:(void(^)(GTaskEngine *,NSMutableArray *))resultHander {
    NSURL *url = [NSURL URLWithString:kTaskListsURL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [self fetchWithRequest:request resultBlock:^(GDataEngine *engine, id result) {
        if ([result isKindOfClass:[NSError class]]) {
            NIF_TRACE(@"--- %d", [(NSError *)result code]);
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
            BOOL rs = [self _saveTasksForTaskList:aList fromJSON:result];
            NSMutableArray *tasks = [self localTasksForList:aList];
            resultHander(self,tasks);
        }
    }];
}


@end
