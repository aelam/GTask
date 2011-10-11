//
//  Task.m
//  GTask-iOS
//
//  Created by ryan on 11-9-22.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "Task.h"
#import "FMDatabase.h"

#define INITIAL_INTEGER -2

@implementation Task

@synthesize localTaskId = _localTaskId;
@synthesize localListId = _localListId;
@synthesize localParentId = _localParentId;
@synthesize serverTaskId = _serverTaskId;
@synthesize title = _title;
@synthesize notes = _notes;
@synthesize isUpdated = _isUpdated;
@synthesize isDeleted = _isDeleted;
@synthesize isCompleted = _isCompleted;
@synthesize isCleared = _isCleared;
@synthesize isHidden = _isHidden;
@synthesize status = _status;
@synthesize completedTimestamp = _completedTimestamp;
@synthesize reminderTimestamp = _reminderTimestamp;
@synthesize due = _due;
@synthesize serverModifyTime = _serverModifyTime;
@synthesize localModifyTime = _localModifyTime;
@synthesize link = _link;
@synthesize displayOrder = _displayOrder;

@synthesize parentTask = _parentTask;
//@synthesize previousSiblingTask = _previousSiblingTask;

- (id)init {
    if (self = [super init]) {
        _displayOrder = INITIAL_INTEGER;
        _localParentId = INITIAL_INTEGER;
    }
    return self;
}

#define DESCRIPTION_LEVEL 1

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
            @"id:%d title : %@ parent: %d displayOrder:%d",self.localTaskId,self.title,self.localParentId,self.displayOrder];
#endif

}

- (id)copyWithZone:(id)zone {
    Task *task = [[Task alloc] init];
    task.localListId = self.localListId;
    task.localTaskId = self.localTaskId;
    task.localListId = self.localListId;
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
    task.status = self.status;
    task.completedTimestamp = self.completedTimestamp;
    task.reminderTimestamp = self.reminderTimestamp;
    task.due = self.due;
    task.serverModifyTime = self.serverModifyTime;
    task.localModifyTime = self.localModifyTime;
    task.displayOrder = self.displayOrder;

    return [task autorelease];
}

- (void)updateDisplayOrder:(NSInteger)order {
    FMDatabase *db = [FMDatabase database];
    if (![db open]) {
        NIF_ERROR(@"Could not open db.");
    } else {
        NSString *sql = [NSString stringWithFormat:@"UPDATE tasks SET display_order = %d WHERE local_task_id = %d",order,self.localTaskId];
        BOOL update = [db executeUpdate:sql];
        NIF_INFO(@"UPDATE DISPLAYORDER SUCCESS ? : %d", update);
        [db close];
    }

    self.displayOrder = order;
}

- (void)updateLocalParentId:(NSInteger)aParentId {
    FMDatabase *db = [FMDatabase database];
    if (![db open]) {
        NIF_ERROR(@"Could not open db.");
    } else {
        NSString *sql = [NSString stringWithFormat:@"UPDATE tasks SET local_parent_id = %d WHERE local_task_id = %d",aParentId,self.localTaskId];
        BOOL update = [db executeUpdate:sql];
        NIF_INFO(@"UPDATE PARENT_ID SUCCESS ? : %d", update);
        [db close];
    }
    
    self.localParentId = aParentId;
}

    
- (void)dealloc {
    [_serverTaskId release];
    [_title release];
    [_notes release];
    [_link release];
    [_parentTask release];
    [super dealloc];
}


//////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)isFirstTaskAtTasks:(NSMutableArray *)tasks {
    if (!tasks || [tasks count] == 0) return NO;
    
    return [[tasks objectAtIndex:0] isEqual:self];
}

- (BOOL)isLastTaskAtTasks:(NSMutableArray *)tasks {
    if (!tasks || [tasks count] == 0) return NO;
    return [[tasks lastObject] isEqual:self];
}

- (BOOL) isFirstLevelTaskAtTasks:(NSMutableArray *)tasks {
    if (!tasks || [tasks count] == 0) return NO;    

    if (self.localParentId == -1) return YES;
    else return NO;
        
}

- (BOOL)hasSonAtTasks:(NSMutableArray *)tasks {
    if (!tasks || [tasks count] == 0) return NO;    
    NSArray *sons = [self sonsAtTasks:tasks];
    if (!sons || [sons count]) return NO;
    return YES;        
}


- (Task *)parentTaskAtTasks:(NSMutableArray *)tasks {
    if (!tasks || [tasks count] == 0) return nil;
    if ([self isFirstLevelTaskAtTasks:tasks]) return nil;
    else {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"localTaskId = %d",self.localParentId];
        NSArray *filteredParents = [tasks filteredArrayUsingPredicate:predicate];
        if (filteredParents == nil || [filteredParents count] == 0) {
            NIF_ERROR(@"THIS TASK SHOULD HAVE A PARENT!!");
            return nil;
        } else {
            return [filteredParents objectAtIndex:0];
        }
    }
}

- (NSArray *)sonsAtTasks:(NSMutableArray *)tasks {
    if (!tasks || [tasks count] == 0) return nil;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"localParentId = %d",self.localTaskId];
    NSArray *subtasks = [tasks filteredArrayUsingPredicate:predicate];
    if (subtasks == nil || [subtasks count] == 0) {
        //NIF_ERROR(@"THIS TASK SHOULD HAVE A PARENT!!");
        return nil;
    } else {
        return subtasks;
    }
}


// 前一任务 后一任务
- (Task *)prevTaskAtTasks:(NSMutableArray *)tasks {
    if (!tasks || [tasks count] == 0) return nil;
    
    else if ([self isFirstTaskAtTasks:tasks]) {
        return nil;
    } else {
        NSInteger index = [tasks indexOfObject:self];
        return [tasks objectAtIndex:index - 1];
    }
}

- (Task *)nextTaskAtTasks:(NSMutableArray *)tasks {
    if (!tasks || [tasks count] == 0) return nil;
    
    else if ([self isLastTaskAtTasks:tasks]) {
        return nil;
    } else {
        NSInteger index = [tasks indexOfObject:self];
        return [tasks objectAtIndex:index + 1];
    }
}

- (NSArray *)siblingsAndMeTaskAtTasks:(NSMutableArray *)tasks {
    if (!tasks || [tasks count] == 0) return nil;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"localParentId = %d",self.localParentId];
    NSArray *siblings = [tasks filteredArrayUsingPredicate:predicate];
    if(siblings == nil || [siblings count] == 0) {
        return nil;
    } else {
        return siblings;
    }
}

- (NSArray *)siblingsTaskAtTasks:(NSMutableArray *)tasks {
    NSMutableArray *siblingsAndMe = [NSMutableArray arrayWithArray:[self siblingsAndMeTaskAtTasks:tasks]];
    if (siblingsAndMe == nil) {
        return nil;
    } else if ([siblingsAndMe containsObject:self]) {
        [siblingsAndMe removeObject:self];
        return siblingsAndMe;
    } else {
        NIF_ERROR(@"THIS SIBLINGS SHOULD INCLUDE ME!");
        return nil;
    }
}



// 同级别前一任务 同级别后一任务
- (Task *)prevSiblingTaskAtTasks:(NSMutableArray *)tasks {
    if (!tasks || [tasks count] == 0) return nil;
    NSArray *siblingsAndMe = [self siblingsAndMeTaskAtTasks:tasks];
    NSInteger indexOfMe = [siblingsAndMe indexOfObject:self];
    NIF_INFO(@"indexOfMe : %d", indexOfMe);
    if (indexOfMe > 0) {
        return [siblingsAndMe objectAtIndex:(indexOfMe - 1)];
    } else {
        return nil;
    }
}

- (Task *)nextSiblingTaskAtTasks:(NSMutableArray *)tasks {
    return nil;
}

- (NSArray *)youngerSiblingsTaskAtTasks:(NSMutableArray *)tasks {
    if (!tasks || [tasks count] == 0) return nil;
    NSArray *siblingsAndMe = [self siblingsAndMeTaskAtTasks:tasks];
    NSInteger indexOfMe = [siblingsAndMe indexOfObject:self];
    NIF_INFO(@"indexOfMe : %d", indexOfMe);
    if ([siblingsAndMe count] > 1) {
        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(indexOfMe + 1, [siblingsAndMe count] - indexOfMe - 1)];
        return [siblingsAndMe objectsAtIndexes:indexSet];        
    } else {
        return nil;
    }
}



// 所有子任务 递归
- (NSArray *)allDescendantsAtTasks:(NSMutableArray *)tasks {
    NSMutableArray *descendants = [NSMutableArray array];
    
    NSArray *sons = [self sonsAtTasks:tasks];
    for(Task *son in sons) {
        [descendants addObject:son];
        NSArray *sonz_sons = [son allDescendantsAtTasks:tasks];
        if (sonz_sons && [sonz_sons count]) {
            [descendants addObjectsFromArray:sonz_sons];            
        } 
    }
    return descendants;    
}



//////////////////////////////////////////////////////////////////////////////////////////




@end
