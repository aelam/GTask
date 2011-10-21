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
@synthesize displayOrder = _displayOrder;


- (void)dealloc {
    [_serverListId release];
    [_kind release];
    [_title release];
    [_tasks release];
    [_link release];
    [super dealloc];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"LocalListId : %d ServerListId : %@",self.localListId,self.serverListId];
}


- (NSMutableArray *)tasks {
    if (_tasks == nil) {
        FMDatabase *db = [FMDatabase database];
        if (![db open]) {
            NSLog(@"Could not open db.");
            _tasks = nil;
        } else {
            _tasks = [[NSMutableArray alloc] init];
            FMResultSet *rs = [db executeQuery:[NSString stringWithFormat:@"SELECT * FROM tasks WHERE local_list_id = %d ORDER BY display_order",self.localListId]];
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
                task.completedTimestamp = [rs doubleForColumn:@"completed_timestamp"];
                task.reminderTimestamp = [rs doubleForColumn:@"reminder_timestamp"];
                task.due = [rs doubleForColumn:@"due"];
                task.serverModifyTime = [rs doubleForColumn:@"server_modify_timestamp"];
                task.displayOrder = [rs intForColumn:@"display_order"];
                task.generationLevel = [rs intForColumn:@"generation_level"];
                
                task.list = self;
                [_tasks addObject:task];
                [task release];
            }
            [db close]; 
        }        
    }
    return _tasks;
}


- (void)setTasks:(NSMutableArray *)tasks {
    if (_tasks != tasks) {
        [_tasks release];
        _tasks = [tasks retain];
    }
}

//////////////////////////////////////////////////////////////////////////////////////////
- (Task *)firstTask {
    if (!self.tasks || [self.tasks count] == 0) return nil; 
    return [self.tasks objectAtIndex:0];
}

- (Task *)lastTask {
    if (!self.tasks || [self.tasks count] == 0) return nil;
    return [self.tasks lastObject];
}

- (NSInteger)generationLevelOfTask:(Task *)task {
    if (!self.tasks || [self.tasks count] == 0) return 0;
    Task *parent = [self parentOfTask:task];
    if (parent) {
        return 1 + [self generationLevelOfTask:task];
    } else {
        return 0;
    }
}

- (Task *)parentOfTask:(Task *)task {
    if (!self.tasks || [self.tasks count] == 0) return nil;
    if ([task isFirstLevelTask]) return nil;
    else {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"localTaskId = %d",task.localParentId];
        NSArray *filteredParents = [self.tasks filteredArrayUsingPredicate:predicate];
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
    if (!self.tasks || [self.tasks count] == 0) return nil;
    NSAssert(task.localTaskId != task.localParentId,@"%@ taskId and parentId is the same!",task.title);
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"localParentId = %d",task.localTaskId];
    NSArray *subtasks = [self.tasks filteredArrayUsingPredicate:predicate];
    if (subtasks == nil || [subtasks count] == 0) {
        return nil;
    } else {
        return subtasks;
    }
}


// 前一任务 后一任务
- (Task *)prevTaskOfTask:(Task *)task {
    if (!self.tasks || [self.tasks count] == 0) return nil;
    else if ([self firstTask] == nil || [self firstTask] == task) {
        return nil;
    }
    else {
        NSInteger index = [self.tasks indexOfObject:task];
        return [self.tasks objectAtIndex:index - 1];
    }
}

- (Task *)nextTaskOfTask:(Task *)task {
    if (!self.tasks || [self.tasks count] == 0) return nil;
    else if ([self lastTask] == nil || [self lastTask] == task) return nil;
    else {
        NSInteger index = [self.tasks indexOfObject:self];
        return [self.tasks objectAtIndex:index + 1];
    }
}

- (NSArray *)siblingsAndMeOfTask:(Task *)task {
    if (!self.tasks || [self.tasks count] == 0) return nil;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"localParentId = %d",task.localParentId];
    NSArray *siblings = [self.tasks filteredArrayUsingPredicate:predicate];
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
    } else if ([siblingsAndMe containsObject:self]) {
        [siblingsAndMe removeObject:self];
        return siblingsAndMe;
    } else {
        NIF_ERROR(@"THIS SIBLINGS SHOULD INCLUDE ME!");
        return nil;
    }
}

- (NSInteger)nextSiblingOrUncleIndexOfTask:(Task *)task {
    NSInteger generationLevel = [self generationLevelOfTask:task];
    if (!self.tasks || [self.tasks count] == 0) return -1;
    NSInteger index = [self.tasks indexOfObject:self];
    if (index < [self.tasks count] - 1) {
        for(int i = index+1; i < [self.tasks count]; i++) {
            Task *tempTask = [self.tasks objectAtIndex:i];
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
    if (!self.tasks || [self.tasks count] == 0) return nil;
    NSArray *siblingsAndMe = [self siblingsAndMeOfTask:task];
    NSInteger indexOfMe = [siblingsAndMe indexOfObject:self];
    NIF_INFO(@"indexOfMe : %d", indexOfMe);
    if (indexOfMe > 0) {
        return [siblingsAndMe objectAtIndex:(indexOfMe - 1)];
    } else {
        return nil;
    }
}

- (Task *)nextSiblingOfTask:(Task *)task {
    if (!self.tasks || [self.tasks count] == 0) return nil;
    NSArray *siblingsAndMe = [self siblingsAndMeOfTask:task];
    NSInteger indexOfMe = [siblingsAndMe indexOfObject:self];
    NIF_INFO(@"indexOfMe : %d", indexOfMe);
    if (indexOfMe < [self.tasks count] - 1) {
        return [siblingsAndMe objectAtIndex:(indexOfMe + 1)];
    } else {
        return nil;
    }
}

- (NSArray *)youngerSiblingsOfTask:(Task *)task {
//- (NSArray *)youngerSiblingsTaskAtTasks:(NSMutableArray *)tasks {
    if (!self.tasks || [self.tasks count] == 0) return nil;
    NSArray *siblingsAndMe = [self siblingsAndMeOfTask:task];
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
- (NSArray *)allDescendantsOfTask:(Task *)task {
//- (NSArray *)allDescendantsAtTasks:(NSMutableArray *)tasks {
    NSMutableArray *descendants = [NSMutableArray array];
    
//    NSArray *sons = [self sonsAtTasks:tasks];
    NSArray *sons = [self sonsOfTask:task];
    if (!sons || [sons count] == 0) {
        return nil;
    }
    for(Task *son in sons) {
        [descendants addObject:son];
        NSArray *sonz_sons = [self sonsOfTask:son];
        if (sonz_sons && [sonz_sons count]) {
            [descendants addObjectsFromArray:sonz_sons];            
        }
    }
    return descendants;    
}


//////////////////////////////////////////////////////////////////////////////////////////

- (BOOL)deleteTask:(Task *)aTask {
    FMDatabase *db = [FMDatabase database];
    if (![db open]) {
        NSLog(@"Could not open db.");
		return NO;
    } else {
        NSString *sql = [NSString stringWithFormat:@"DELETE FROM tasks WHERE local_task_id = %d",aTask.localTaskId];
        NIF_INFO(@"save to DB sql : %@", sql);
        NSError *error = nil;
        BOOL rs = [db executeUpdate:sql error:&error withArgumentsInArray:nil orVAList:nil];
        if (error) {
            NIF_INFO(@"%@", error);
        }
        [db close];        
        
        return rs;
    }
}

- (void)moveTaskAtIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex forTasks:(NSMutableArray *)tasks {
    
    Task *fromTask = [[tasks objectAtIndex:fromIndex] retain];
    Task *toTask = [tasks objectAtIndex:toIndex];
    
    
    if ([[fromTask allDescendantsAtTasks:tasks] containsObject:toTask]) {
        return;
    }
    
    NSArray *subTasks = [fromTask allDescendantsAtTasks:tasks];
    
    int begin = 0;
    int end = 0;
    if (fromTask.displayOrder > toTask.displayOrder) {  // *** 上移 ***
        
        Task *prevToTask = [toTask prevTaskAtTasks:tasks];
        
        NSInteger toTaskLevel = [toTask generationLevelAtTasks:tasks];
        NSInteger prevToTaskLevel = [prevToTask generationLevelAtTasks:tasks];
        
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
            [tasks removeObject:aTask];
            [tasks insertObject:aTask atIndex:toIndex];
        }
        
        [tasks removeObject:fromTask];
        [tasks insertObject:fromTask atIndex:toIndex];
        [fromTask release];
        
        begin = toTask.displayOrder;
        end = fromTask.displayOrder + [subTasks count];
    } else if ( fromTask.displayOrder == toTask.displayOrder) {     // *** 移 ***
        Task *prevTask = [fromTask prevTaskAtTasks:tasks];
        Task *parent = [fromTask parentTaskAtTasks:tasks];
        if (prevTask  && prevTask != parent) {
            [fromTask setLocalParentId:prevTask.localParentId updateDB:YES];
        } else {
            
        }
        
    }
    else {                                                          // *** 下移 ***
        NIF_INFO(@"fromTask.displayOrder:%d > toTask.displayOrder: %d", fromTask.displayOrder ,toTask.displayOrder);
        
        Task *nextToTask = [toTask nextTaskAtTasks:tasks];
        
        NSInteger toTaskLevel = [toTask generationLevelAtTasks:tasks];
        NSInteger nextToTaskLevel = [nextToTask generationLevelAtTasks:tasks];
        
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
        
        [tasks removeObject:fromTask];
        [tasks insertObject:fromTask atIndex:toIndex];
        [fromTask release];
        
        NSEnumerator *enumerator = [subTasks objectEnumerator];
        Task *aTask = nil;
        while (aTask = [enumerator nextObject]) {
            [tasks removeObject:aTask];
            [tasks insertObject:aTask atIndex:toIndex];
        }
        
        begin = fromTask.displayOrder;
        end = toTask.displayOrder;
    }
    
    for (int i = begin;i <= end;i++) {
        Task *task = [tasks objectAtIndex:i];
        [task setDisplayOrder:i updateDB:YES];
    }
}




@end
