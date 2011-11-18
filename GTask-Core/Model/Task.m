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

@synthesize localListId = _localListId;
@synthesize list = _list;
@synthesize localTaskId = _localTaskId;
@synthesize localParentId = _localParentId;
@synthesize serverTaskId = _serverTaskId;
@synthesize serverParentId = _serverParentId;
@synthesize title = _title;
@synthesize notes = _notes;
@synthesize isUpdated = _isUpdated;
@synthesize isDeleted = _isDeleted;
@synthesize isCompleted = _isCompleted;
@synthesize isCleared = _isCleared;
@synthesize isHidden = _isHidden;
@synthesize isMoved = _Moved;

@synthesize link = _link;
@synthesize displayOrder = _displayOrder;

@synthesize completedDate = _completedDate;
@synthesize reminderDate = _reminderDate;
@synthesize due = _due;
@synthesize serverModifyTime = _serverModifyTime;
@synthesize localModifyTime = _localModifyTime;

@synthesize generationLevel = _generationLevel;

- (id)init {
    if (self = [super init]) {
        _displayOrder = INITIAL_INTEGER;
        _localParentId = INITIAL_INTEGER;
        _generationLevel = -1;
    }
    return self;
}

#define NAME_AND_DUE      3
#define DESCRIPTION_LEVEL NAME_AND_DUE

- (NSString *)description {
#if DESCRIPTION_LEVEL == 3
    return [NSString stringWithFormat:
            @"localTaskId   : %d\
            title           : %@\
            list            : %@\
            parent          : %d\
            updated         : %@\
            displayOrder    : %d\
            isDeleted       : %d\
            notes           : %@",self.localTaskId,self.title,self.list.title,self.localParentId,self.serverModifyTime,self.displayOrder,self.isDeleted,self.notes];
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
            due             : %@\
            ",self.localTaskId,self.title,self.due];
    
#endif

}

- (id)copyWithZone:(NSZone *)zone {
    Task *task = [[Task allocWithZone:zone] init];
    task.list = self.list;
    task.localTaskId = self.localTaskId;
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
    task.completedDate = self.completedDate;
    task.reminderDate = self.reminderDate;
    task.due = self.due;
    task.serverModifyTime = self.serverModifyTime;
    task.localModifyTime = self.localModifyTime;
    task.displayOrder = self.displayOrder;

    return task;
}

- (BOOL)isSameContent:(Task *)anotherTask {

    return (
            anotherTask.list == self.list &&
            anotherTask.localTaskId == self.localTaskId &&
            anotherTask.localParentId == self.localParentId &&
            ([anotherTask.serverTaskId isEqualToString:self.serverTaskId]||(anotherTask.serverTaskId == nil && self.serverTaskId == nil))&&
            ([anotherTask.title isEqualToString:self.title]||(anotherTask.title == nil && self.title == nil))&&
            ([anotherTask.notes isEqualToString:self.notes]||(anotherTask.notes == nil && self.notes == nil))&&
            ([anotherTask.link isEqualToString:self.link]||(anotherTask.link == nil && self.link == nil))&&
            anotherTask.isUpdated == self.isUpdated &&
            anotherTask.isDeleted == self.isDeleted &&
            anotherTask.isCompleted == self.isCompleted &&
            anotherTask.isCleared == self.isCleared &&
            anotherTask.isHidden == self.isHidden &&
            [anotherTask.completedDate timeIntervalSinceDate:self.completedDate] == 0 &&
            [anotherTask.reminderDate timeIntervalSinceDate:self.reminderDate] == 0 &&
            [anotherTask.due timeIntervalSinceDate:self.due] == 0 &&
            [anotherTask.serverModifyTime timeIntervalSinceDate:self.serverModifyTime] == 0 &&
            [anotherTask.localModifyTime timeIntervalSinceDate:self.localModifyTime] == 0 &&
            anotherTask.displayOrder == self.displayOrder);

    return YES;
}

- (void)setDisplayOrder:(NSInteger)order updateDB:(BOOL)update {
    if (update) {
        FMDatabase *db = [FMDatabase database];
        if (![db open]) {
            NIF_ERROR(@"Could not open db.");
        } else {
            BOOL update = [db executeUpdate:@"UPDATE tasks SET moved = 1,display_order = ?,local_modify_timestamp = ? WHERE local_task_id = ?",[NSNumber numberWithInt:order],[NSDate date],[NSNumber numberWithInt:self.localTaskId]];
            NIF_INFO(@"UPDATE DISPLAYORDER SUCCESS ? : %d", update);
            [db close];
        }        
    }
    
    self.displayOrder = order;

}

- (void)setIsMoved:(BOOL)isMoved updateDB:(BOOL)update {
    self.isMoved = isMoved;
    if (update) {
        FMDatabase *db = [FMDatabase database];
        if (![db open]) {
            NIF_ERROR(@"Could not open db.");
        } else {
            BOOL update = [db executeUpdate:@"UPDATE tasks SET moved = 1 WHERE local_task_id = ?",[NSNumber numberWithInt:self.localTaskId]];
            NIF_INFO(@"UPDATE DISPLAYORDER SUCCESS ? : %d", update);
            [db close];
        }        

    }
}


- (void)setLocalParentId:(NSInteger)aParentId updateDB:(BOOL)update {
    if (update) {
        FMDatabase *db = [FMDatabase database];
        if (![db open]) {
            NIF_ERROR(@"Could not open db.");
        } else {
            BOOL update = [db executeUpdate:@"UPDATE tasks SET local_parent_id = ?,local_modify_timestamp = ? WHERE local_task_id = ?",[NSNumber numberWithInt:aParentId],[NSDate date],[NSNumber numberWithInt:self.localTaskId]];
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
            self.completedDate = isCompleted?[NSDate date]:nil;
            BOOL update = [db executeUpdate:@"UPDATE tasks SET is_completed = ?,completed_timestamp = ?,local_modify_timestamp = ? WHERE local_task_id = ?",[NSNumber numberWithInt:isCompleted],self.completedDate,[NSDate date],[NSNumber numberWithInt:self.localTaskId]];
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
            BOOL update = [db executeUpdate:@"UPDATE tasks SET generation_level = ?,local_modify_timestamp = ? WHERE local_task_id = ?",[NSNumber numberWithInt:aLevel],[NSDate date],[NSNumber numberWithInt:self.localTaskId]];
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
            BOOL update = [db executeUpdate:@"UPDATE tasks SET local_list_id = ?,local_modify_timestamp = ? WHERE local_task_id = ?",[NSNumber numberWithInt:aList.localListId],[NSDate date],[NSNumber numberWithInt:self.localTaskId]];                           
            NIF_INFO(@"UPDATE List of task SUCCESS ? : %d", update);
            [db close];
        }
    }
    self.list = aList;
}

- (void)update {
    FMDatabase *db = [FMDatabase database];
    if (![db open]) {
        NIF_ERROR(@"Could not open db.");            
    } else {
        BOOL update = [db executeUpdate:@"UPDATE tasks SET server_task_id = ?,local_parent_id = ?,title = ?,notes = ?,is_updated = ?,is_completed = ?,is_hidden = ?,is_deleted = ?,is_cleared = ?,completed_timestamp = ?,reminder_timestamp = ?,due = ?,local_modify_timestamp = ?,display_order = ? WHERE local_task_id = ?",
                       self.serverTaskId,
                       [NSNumber numberWithInt:self.localParentId],
                       self.title,
                       self.notes,
                       [NSNumber numberWithBool:self.isUpdated],
                       [NSNumber numberWithBool:self.isCompleted],
                       [NSNumber numberWithBool:self.isHidden],
                       [NSNumber numberWithBool:self.isDeleted],
                       [NSNumber numberWithBool:self.isCleared],
                       self.completedDate,
                       self.reminderDate,
                       self.due,
                       [NSDate date],
                       [NSNumber numberWithInt:self.displayOrder],
                       [NSNumber numberWithInt:self.localTaskId]
                       ];                           
        NIF_INFO(@"UPDATE task SUCCESS ? : %d", update);
        [db close];
    }
}
    
- (void)dealloc {
    [_list release];
    [_title release];
    [_notes release];
    [_link release];
    [_completedDate release];
    [_reminderDate release];
    [_due release];
    [_serverModifyTime release];
    [_localModifyTime release];
    [_serverParentId release];
    [super dealloc];
}


//////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)isFirstLevelTask {
    if (_localParentId == -1)  return YES;
    else return NO;
}



@end
