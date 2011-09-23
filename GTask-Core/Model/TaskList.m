//
//  TaskList.m
//  GTask-iOS
//
//  Created by ryan on 11-9-22.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "TaskList.h"
#import "FMDatabase.h"

@implementation TaskList

@synthesize localListId = _localListId;
@synthesize serverListId = _serverListId;
@synthesize kind = _kind;
@synthesize title = _title;
@synthesize isDefault = _isDefault;
@synthesize isDeleted = _isDeleted;
@synthesize isCleared = _isCleared;
@synthesize status = _status;
@synthesize sortType = _sortType;
@synthesize lastestSyncTime = _lastestSyncTime;
@synthesize serverModifyTime = _serverModifyTime;
@synthesize localModifyTime = _localModifyTime;
@synthesize tasks = _tasks;
@synthesize link = _link;

+ (NSMutableArray *)taskListsFromDBWithSortType:(NSInteger)sortType {
    NSMutableArray *taskLists = [NSMutableArray array];
    FMDatabase *db = [FMDatabase database];
    if (![db open]) {
        NSLog(@"Could not open db.");
		return nil;
    } else {
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

+ (BOOL)saveTaskListFromJSON:(NSDictionary *)json {
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
            
            NSString *sql = [NSString stringWithFormat:@"INSERT INTO task_lists (server_list_id,kind,self_link,title,latest_sync_timestamp) VALUES ('%@','%@','%@','%@',%0.0f)",_id,kind,link,title,timeStamp];
            NIF_INFO(@"save to DB sql : %@", sql);
            rs = [db executeUpdate:sql];
            NIF_INFO(@"%d", rs);
        }
        return rs;
    }
}


- (void)dealloc {
    [_serverListId release];
    [_kind release];
    [_title release];
    [_tasks release];
    [_link release];
    [super dealloc];
}


@end
