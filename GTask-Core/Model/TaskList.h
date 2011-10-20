//
//  TaskList.h
//  GTask-iOS
//
//  Created by ryan on 11-9-22.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

@class Task;

@interface TaskList : NSObject


@property (assign) NSInteger localListId;
@property (copy)  NSString *serverListId;
@property (copy)  NSString *kind;
@property (copy)  NSString *title;
@property (copy)  NSString *link;
@property (assign)  BOOL     isDefault;
@property (assign)  BOOL     isDeleted;
@property (assign)  BOOL    isCleared;
@property (assign)  NSInteger status;
@property (assign)  NSInteger  sortType;
@property (assign)  double lastestSyncTime;
@property (assign)  double serverModifyTime;
@property (assign)  double localModifyTime;
@property (retain)  NSMutableArray *tasks;
@property (assign)  NSInteger displayOrder;

@end
