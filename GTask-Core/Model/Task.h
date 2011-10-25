//
//  Task.h
//  GTask-iOS
//
//  Created by ryan on 11-9-22.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <objc/runtime.h>

@class TaskList;

@interface Task : NSObject

@property (retain) TaskList *list;
@property (assign) NSInteger localTaskId;
//@property (assign) NSInteger localListId;
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
@property (assign)  double  completedTimestamp;
@property (assign)  double  reminderTimestamp;
@property (assign)  double  due;
@property (assign)  double serverModifyTime;
@property (assign)  double localModifyTime;

@property (assign)  NSInteger displayOrder;
@property (assign)  NSInteger generationLevel;


- (BOOL)isSameContent:(Task *)anotherTask;

- (void)setDisplayOrder:(NSInteger)displayOrder updateDB:(BOOL)update;
- (void)setLocalParentId:(NSInteger)localParentId updateDB:(BOOL)update;
- (void)setGenerationLevel:(NSInteger)generationLevel updateDB:(BOOL)update;
- (void)setIsCompleted:(BOOL)isCompleted updateDB:(BOOL)update;

- (void)setList:(TaskList *)aList updateDB:(BOOL)update;


//////////////////////////////////////////////////////////////////////////////////////////

- (BOOL)isFirstLevelTask;



@end
