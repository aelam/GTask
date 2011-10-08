//
//  Task.m
//  GTask-iOS
//
//  Created by ryan on 11-9-22.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "Task.h"

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
@synthesize previousSiblingTask = _previousSiblingTask;

- (NSString *)description {
    return [NSString stringWithFormat:
            @"localTaskId   : %d\
            parent          : %d\
            updated         : %0.0f\
            displayOrder    : %d",self.localTaskId,self.localParentId,self.serverModifyTime,self.displayOrder];
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

- (void)dealloc {
    [_serverTaskId release];
    [_title release];
    [_notes release];
    [_link release];
    [_parentTask release];
    [_previousSiblingTask release];
    [super dealloc];
}

@end
