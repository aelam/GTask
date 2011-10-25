//
//  Task.m
//  GTask-iOS
//
//  Created by ryan on 11-9-22.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "Task.h"
#import "FMDatabase.h"
#import "TaskList.h"

#define INITIAL_INTEGER -2

@implementation Task

@synthesize list = _list;
@synthesize localTaskId = _localTaskId;
//@synthesize localListId = _localListId;
@synthesize localParentId = _localParentId;
@synthesize serverTaskId = _serverTaskId;
@synthesize title = _title;
@synthesize notes = _notes;
@synthesize isUpdated = _isUpdated;
@synthesize isDeleted = _isDeleted;
@synthesize isCompleted = _isCompleted;
@synthesize isCleared = _isCleared;
@synthesize isHidden = _isHidden;
//@synthesize status = _status;
@synthesize completedTimestamp = _completedTimestamp;
@synthesize reminderTimestamp = _reminderTimestamp;
@synthesize due = _due;
@synthesize serverModifyTime = _serverModifyTime;
@synthesize localModifyTime = _localModifyTime;
@synthesize link = _link;
@synthesize displayOrder = _displayOrder;

@synthesize generationLevel = _generationLevel;

- (id)init {
    if (self = [super init]) {
        _displayOrder = INITIAL_INTEGER;
        _localParentId = INITIAL_INTEGER;
        _generationLevel = -1;
    }
    return self;
}

#define NAME_AND_DUE      4
#define DESCRIPTION_LEVEL NAME_AND_DUE

- (NSString *)description {
#if DESCRIPTION_LEVEL == 3
    return [NSString stringWithFormat:
            @"localTaskId   : %d\
            title           : %@\
            parent          : %d\
            updated         : %0.0f\
            displayOrder    : %d",self.localTaskId,self.title,self.localParentId,self.serverModifyTime,self.displayOrder];
#elif DESCRIPTION_LEVEL == 2
    return [NSString stringWithFormat:
            @"localTaskId: %d title : %@ parent: %d\
            displayOrder  : %d",self.localTaskId,self.title,self.localParentId,self.displayOrder];
#elif DESCRIPTION_LEVEL == 1
    return [NSString stringWithFormat:
            @"id:%d title : %@ parent: %d displayOrder:%d indent:%d",self.localTaskId,self.title,self.localParentId,self.displayOrder,self.generationLevel];
#elif DESCRIPTION_LEVEL == NAME_AND_DUE
    return [NSString stringWithFormat:
            @"localTaskId   : %d\
            title           : %@\
            due             : %0.0f\
            ",self.localTaskId,self.title,self.due];
    
#endif

}

- (id)copyWithZone:(NSZone *)zone {
    Task *task = [[Task allocWithZone:zone] init];
    task.list = self.list;
    task.localTaskId = self.localTaskId;
//    task.localListId = self.localListId;
    task.localParentId = self.localParentId;
    task.serverTaskId = self.serverTaskId;
    task.title = self.title;
    task.notes = self.notes;
    task.link = self.link;
    task.isUpdated = self.isUpdated;
    task.isDeleted = self.isDeleted;
    task.isCompleted = self.isCompleted;
    task.isCleared = self.isCleared;
    task.isHidden = self.isHidden;
    task.completedTimestamp = self.completedTimestamp;
    task.reminderTimestamp = self.reminderTimestamp;
    task.due = self.due;
    task.serverModifyTime = self.serverModifyTime;
    task.localModifyTime = self.localModifyTime;
    task.displayOrder = self.displayOrder;

    return task;
}

- (BOOL)isSameContent:(Task *)anotherTask {
    return (//anotherTask.localListId == self.localListId &&
            anotherTask.list == self.list &&
            anotherTask.localTaskId == self.localTaskId &&
//            anotherTask.localListId == self.localListId &&
            anotherTask.localParentId == self.localParentId &&
            [anotherTask.serverTaskId isEqualToString:self.serverTaskId] &&
            [anotherTask.title isEqualToString:self.title]&&
            [anotherTask.notes isEqualToString:self.notes]&&
            [anotherTask.link isEqualToString:self.link]&&
            anotherTask.isUpdated == self.isUpdated &&
            anotherTask.isDeleted == self.isDeleted &&
            anotherTask.isCompleted == self.isCompleted &&
            anotherTask.isCleared == self.isCleared &&
            anotherTask.isHidden == self.isHidden &&
            anotherTask.completedTimestamp == self.completedTimestamp &&
            anotherTask.reminderTimestamp == self.reminderTimestamp &&
            anotherTask.due == self.due &&
            anotherTask.serverModifyTime == self.serverModifyTime &&
            anotherTask.localModifyTime == self.localModifyTime &&
            anotherTask.displayOrder == self.displayOrder);

    return YES;
}

- (void)setDisplayOrder:(NSInteger)order updateDB:(BOOL)update {
    if (update) {
        FMDatabase *db = [FMDatabase database];
        if (![db open]) {
            NIF_ERROR(@"Could not open db.");
        } else {
            NSString *sql = [NSString stringWithFormat:@"UPDATE tasks SET display_order = %d WHERE local_task_id = %d",order,self.localTaskId];
            BOOL update = [db executeUpdate:sql];
            //NIF_INFO(@"UPDATE DISPLAYORDER SUCCESS ? : %d", update);
            [db close];
        }        
    }
    
    self.displayOrder = order;

}

- (void)setLocalParentId:(NSInteger)aParentId updateDB:(BOOL)update {
    if (update) {
        FMDatabase *db = [FMDatabase database];
        if (![db open]) {
            NIF_ERROR(@"Could not open db.");
        } else {
            NSString *sql = [NSString stringWithFormat:@"UPDATE tasks SET local_parent_id = %d WHERE local_task_id = %d",aParentId,self.localTaskId];
            BOOL update = [db executeUpdate:sql];
            NIF_INFO(@"UPDATE PARENT_ID SUCCESS ? : %d", update);
            [db close];
        }
    }    
    self.localParentId = aParentId;

}

- (void)setIsCompleted:(BOOL)isCompleted updateDB:(BOOL)update {
    if (update) {
        FMDatabase *db = [FMDatabase database];
        if (![db open]) {
            NIF_ERROR(@"Could not open db.");
        } else {
            NSString *sql = [NSString stringWithFormat:@"UPDATE tasks SET is_completed = %d WHERE local_task_id = %d",isCompleted,self.localTaskId];
            BOOL update = [db executeUpdate:sql];
            NIF_INFO(@"UPDATE is_complete SUCCESS ? : %d", update);
            [db close];
        }
    }    
    self.isCompleted = isCompleted;

}

- (void)setGenerationLevel:(NSInteger)aLevel updateDB:(BOOL)update {
    if (update) {
        FMDatabase *db = [FMDatabase database];
        if (![db open]) {
            NIF_ERROR(@"Could not open db.");
        } else {
            NSString *sql = [NSString stringWithFormat:@"UPDATE tasks SET generation_level = %d WHERE local_task_id = %d",aLevel,self.localTaskId];
            BOOL update = [db executeUpdate:sql];                           
            NIF_INFO(@"UPDATE GENERATION SUCCESS ? : %d", update);
            [db close];
        }
    }    
    self.generationLevel = aLevel;

}

- (void)setList:(TaskList *)aList updateDB:(BOOL)update {
    if (update) {
        FMDatabase *db = [FMDatabase database];
        if (![db open]) {
            NIF_ERROR(@"Could not open db.");            
        } else {
            NSString *sql = [NSString stringWithFormat:@"UPDATE tasks SET local_list_id = %d WHERE local_task_id = %d",aList.localListId,self.localTaskId];
            BOOL update = [db executeUpdate:sql];                           
            NIF_INFO(@"UPDATE List of task SUCCESS ? : %d", update);
            [db close];
        }
    }
    self.list = aList;
}
    
- (void)dealloc {
    [_list release];
    [_title release];
    [_notes release];
    [_link release];
    [super dealloc];
}


//////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)isFirstLevelTask {
    if (self.localParentId == -1)  return YES;
    else return NO;
}



@end
