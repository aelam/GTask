//
//  GTaskEngine.m
//  GTask-iOS
//
//  Created by ryan on 11-9-23.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "GTaskEngine.h"
#import "TaskList.h"
#import "Task.h"

@implementation GTaskEngine

- (void)fetchServerTaskListsWithResultHander:(void(^)(GTaskEngine *,NSMutableArray *))resultHander {
    NSURL *url = [NSURL URLWithString:@"https://www.googleapis.com/tasks/v1/users/@me/lists"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [self fetchWithRequest:request resultBlock:^(GDataEngine *engine, id result) {
        if ([result isKindOfClass:[NSError class]]) {
            NIF_TRACE(@"--- %d", [(NSError *)result code]);
        } else if ([result isKindOfClass:[NSDictionary class]]) {
            BOOL rs = [TaskList saveTaskListFromJSON:result];
            NIF_INFO(@"%d", rs);
            NSMutableArray *taskLists = [TaskList taskListsFromDBWithSortType:1];
            resultHander(self,taskLists);
        }
    }];
}

- (void)fetchServerTasksFromList:(TaskList *)aList resultHander:(void(^)(GTaskEngine *,NSMutableArray *))resultHander {
    
}


@end
