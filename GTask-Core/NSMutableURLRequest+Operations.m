//
//  NSMutableURLRequest+Operations.m
//  GTask-iOS
//
//  Created by Ryan Wang on 11-11-14.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "NSMutableURLRequest+Operations.h"

@implementation NSMutableURLRequest (Operations)

+ (NSMutableURLRequest *)requestWithRemovingList:(TaskList *)aList {
    NSString *selfLink = [NSString stringWithFormat:@"https://www.googleapis.com/tasks/v1/users/@me/lists/%@",aList.serverListId];
    NSURL *url = [NSURL URLWithString:selfLink];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"DELETE"];

    return request;
}

@end
