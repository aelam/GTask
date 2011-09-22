//
//  Task.h
//  GTask-iOS
//
//  Created by ryan on 11-9-22.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//



@interface Task : NSObject

@property (assign,readonly) NSInteger localTaskId;
@property (assign,readonly) NSInteger localListId;
@property (assign,readonly) NSInteger localParentId;
@property (copy)  NSString *serverTaskId;
@property (copy)  NSString *title;
@property (copy)  NSString *notes;
@property (copy)  NSString *link;
@property (assign)  BOOL     isUpdated;
@property (assign)  BOOL     isDeleted;
@property (assign)  BOOL    isCleared;
@property (assign)  BOOL     isHidden;
@property (assign)  double  completedTimestamp;
@property (assign)  double  reminder_timestamp;
@property (assign)  double  due;
@property (assign)  double serverModifyTime;
@property (assign)  double localModifyTime;




@end
