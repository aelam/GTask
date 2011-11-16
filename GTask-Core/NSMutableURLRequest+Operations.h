//
//  NSMutableURLRequest+Operations.h
//  GTask-iOS
//
//  Created by Ryan Wang on 11-11-14.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//


#import "TaskList.h"

typedef enum{
    RequestMethodGET,
    RequestMethodPOST,
    RequestMethodPUT,
    RequestMethodDELETE    
}RequestMethod;

@interface NSMutableURLRequest (Operations)

+ (NSMutableURLRequest *)requestWithRemovingList:(TaskList *)aList;
+ (NSMutableURLRequest *)requestWithAddingList:(TaskList *)aList;
+ (NSMutableURLRequest *)requestWithUpdateList:(TaskList *)aList;

+ (NSMutableURLRequest *)requestOfGettingServerTasksOfList:(TaskList *)aList withParams:(NSDictionary *)params;

@end
