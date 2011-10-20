//
//  TaskList.m
//  GTask-iOS
//
//  Created by ryan on 11-9-22.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "TaskList.h"
#import "FMDatabase.h"

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

@end
