//
//  NSMutableURLRequest+Operations.m
//  GTask-iOS
//
//  Created by Ryan Wang on 11-11-14.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "NSMutableURLRequest+Operations.h"
#import "NSMutableURLRequest+Shorten.h"
#import "NSString+Categories.h"

@implementation NSMutableURLRequest (Operations)

+ (NSMutableURLRequest *)requestWithRemovingList:(TaskList *)aList {
    NSString *selfLink = [NSString stringWithFormat:@"https://www.googleapis.com/tasks/v1/users/@me/lists/%@",aList.serverListId];
    NSURL *url = [NSURL URLWithString:selfLink];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"DELETE"];

    return request;
}

+ (NSMutableURLRequest *)requestWithAddingList:(TaskList *)aList {
    NSString *selfLink = [NSString stringWithFormat:@"https://www.googleapis.com/tasks/v1/users/@me/lists"];
    NSURL *url = [NSURL URLWithString:selfLink];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    NSDictionary *json = [NSDictionary dictionaryWithObjectsAndKeys:aList.title,@"title",nil];
    [request attachJSONBody:json];
    return request;
}

+ (NSMutableURLRequest *)requestWithUpdateList:(TaskList *)aList {
    NSString *selfLink = [NSString stringWithFormat:@"https://www.googleapis.com/tasks/v1/users/@me/lists/%@",aList.serverListId];
    NSURL *url = [NSURL URLWithString:selfLink];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"PUT"];
    NSDictionary *json = [NSDictionary dictionaryWithObjectsAndKeys:aList.serverListId,@"id",/*aList.kind,@"kind",selfLink,@"selfLink",*/aList.title,@"title",nil];
    [request attachJSONBody:json];

    return request;
}

+ (NSMutableURLRequest *)requestOfGettingServerTasksOfList:(TaskList *)aList withParams:(NSDictionary *)params{
    NSString *query = [NSString queryStringFromParams:params];
    NSString *listsLink = [NSString stringWithFormat:@"https://www.googleapis.com/tasks/v1/lists"];
    NSString *tasksLink = [listsLink stringByAppendingFormat:@"/%@/tasks%@",aList.serverListId,query?[NSString stringWithFormat:@"?%@",query]:@""];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:tasksLink]];
    return request;
}

//+ (NSMutableURLRequest *)requestWithURL:(NSString *)url HTTPMethod:(RequestMethod)method param:(NSDictionary *)params {
//    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
//    switch (method) {
//        case RequestMethodGET:
//            [request setHTTPMethod:@"GET"];
//            break;
//        case RequestMethodPOST:
//            [request setHTTPMethod:@"POST"];
//            break;
//        case RequestMethodPUT:
//            [request setHTTPMethod:@"PUT"];
//            break;
//        case RequestMethodDELETE:
//            [request setHTTPMethod:@"DELETE"];
//            break;
//        default:
//            [request setHTTPMethod:@"GET"];
//            break;
//    }
//    return request;
//}



@end
