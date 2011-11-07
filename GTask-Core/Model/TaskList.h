//
//  TaskList.h
//  GTask-iOS
//
//  Created by ryan on 11-9-22.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

@class Task;

typedef enum {
    TaskUpgradeLevelUpLevel     = 1,
    TaskUpgradeLevelDownLevel   = -1,
    TaskUpgradeLevelNoChange    = 0,
}TaskUpgradeLevel;

typedef enum {
    TaskOrderTypeByDisplayOrder,    // 按displayOrder排序
    TaskOrderTypeByAlphabetical     // 字母排序
}TaskOrderType;


@interface TaskList : NSObject


@property (assign) NSInteger localListId;
@property (copy)  NSString *serverListId;
@property (copy)  NSString *kind;
@property (copy)  NSString *title;
@property (copy)  NSString *link;
@property (assign)  BOOL     isDefault;
@property (assign)  BOOL     isDeleted;
@property (assign)  BOOL    isCleared;
//@property (assign)  NSInteger status;
@property (assign)  NSInteger  sortType;
@property (retain)  NSMutableArray *tasks;
@property (assign)  NSInteger displayOrder;

@property (retain)  NSDate *lastestSyncTime;
@property (retain)  NSDate *serverModifyTime;
@property (retain)  NSDate *localModifyTime;


- (NSMutableArray *)tasks;
- (void)setTasks:(NSMutableArray *)tasks;

///////////////////////////////////////////////////////////////////////////////////////
- (Task *)firstTask;
- (Task *)lastTask;

- (Task *)parentOfTask:(Task *)task;
- (NSArray *)sonsOfTask:(Task *)task;

- (NSInteger)generationLevelOfTask:(Task *)task;

- (NSArray *)siblingsAndMeOfTask:(Task *)task;
- (NSArray *)siblingsTaskOfTask:(Task *)task;

// 前一任务 后一任务
- (Task *)prevTaskOfTask:(Task *)task;
- (Task *)nextTaskOfTask:(Task *)task;

- (NSInteger)nextSiblingOrUncleIndexOfTask:(Task *)task;


// 同级别前一任务 同级别后一任务
- (Task *)prevSiblingOfTask:(Task *)task;
- (Task *)nextSiblingOfTask:(Task *)task;

- (NSArray *)youngerSiblingsOfTask:(Task *)task;

// 所有子任务 递归
- (NSArray *)allDescendantsOfTask:(Task *)task;

//////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)insertTask:(Task *)aTask;
- (BOOL)deleteTask:(Task *)aTask;
- (BOOL)deleteTaskAtIndex:(NSInteger)index;

- (void)moveTaskAtIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex;
- (BOOL)upgradeTaskLevel:(TaskUpgradeLevel)level atIndex:(NSInteger)index;

- (void)moveTaskWithSubTasks:(Task *)task toList:(TaskList *)toList;

// Private method, when move task from a list to another list
- (void)updateListIdAndOrders;


@end
