//
//  Task.h
//  GTask-iOS
//
//  Created by ryan on 11-9-22.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <objc/runtime.h>

@interface Task : NSObject

@property (assign) NSInteger localTaskId;
@property (assign) NSInteger localListId;
@property (assign) NSInteger localParentId;
@property (copy)  NSString *serverTaskId;
@property (copy)  NSString *title;
@property (copy)  NSString *notes;
@property (copy)  NSString *link;
@property (assign)  BOOL     isUpdated;
@property (assign)  BOOL     isDeleted;
@property (assign)  BOOL     isCompleted;
@property (assign)  BOOL     isCleared;
@property (assign)  BOOL     isHidden;
@property (assign)  NSInteger status;
@property (assign)  double  completedTimestamp;
@property (assign)  double  reminderTimestamp;
@property (assign)  double  due;
@property (assign)  double serverModifyTime;
@property (assign)  double localModifyTime;

@property (assign)  NSInteger displayOrder;

@property (retain) Task     *parentTask;
//@property (retain) Task     *previousSiblingTask;

- (void)updateDisplayOrder:(NSInteger)order;
- (void)updateLocalParentId:(NSInteger)aParentId;

//////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)isFirstTaskAtTasks:(NSMutableArray *)tasks;
- (BOOL)isLastTaskAtTasks:(NSMutableArray *)tasks;
- (BOOL)hasSonAtTasks:(NSMutableArray *)tasks;

- (BOOL) isFirstLevelTaskAtTasks:(NSMutableArray *)tasks;
- (Task *)parentTaskAtTasks:(NSMutableArray *)tasks;
- (NSArray *)sonsAtTasks:(NSMutableArray *)tasks;

// 前一任务 后一任务
- (Task *)prevTaskAtTasks:(NSMutableArray *)tasks;
- (Task *)nextTaskAtTasks:(NSMutableArray *)tasks;

// 同级别前一任务 同级别后一任务
- (Task *)prevSiblingTaskAtTasks:(NSMutableArray *)tasks;
- (Task *)nextSiblingTaskAtTasks:(NSMutableArray *)tasks;

// 所有子任务 递归
- (NSArray *)allDescendantsAtTasks:(NSMutableArray *)tasks;


//////////////////////////////////////////////////////////////////////////////////////////



@end
