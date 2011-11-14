//
//  NSMutableURLRequest+Operations.h
//  GTask-iOS
//
//  Created by Ryan Wang on 11-11-14.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//


#import "TaskList.h"

@interface NSMutableURLRequest (Operations)

+ (NSMutableURLRequest *)requestWithRemovingList:(TaskList *)aList;

@end
