//
//  NSMutableURLRequest+Shorten.m
//  GTask-iOS
//
//  Created by ryan on 11-9-21.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "NSMutableURLRequest+Shorten.h"

@implementation NSMutableURLRequest (Shorten)

- (void)attachPostParams:(NSDictionary *)params {
    NSMutableArray* pairs = [NSMutableArray array];
    for (NSString* key in params.keyEnumerator) {
        [pairs addObject:[NSString stringWithFormat:@"%@=%@", key, [params objectForKey:key]]];
    }
    NSString* query = [pairs componentsJoinedByString:@"&"];
    
    [self setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    NSData *body = [query dataUsingEncoding:NSUTF8StringEncoding];
    
    [self setHTTPMethod:@"POST"];
    [self setHTTPBody:body];
}

- (void)attachJSONBody:(NSDictionary *)json {
    NSMutableArray *pairs = [NSMutableArray array];
    for(NSString *key in [json allKeys]) {
        NSString *value = [json objectForKey:key];
        [pairs addObject:[NSString stringWithFormat:@"%@:\"%@\"",key,value]];
    }
    NSString *pairString = [pairs componentsJoinedByString:@","];
    if (pairString) {
        pairString = [NSString stringWithFormat:@"{%@}",pairString];
    }
    NSData *body = [pairString dataUsingEncoding:NSUTF8StringEncoding];

    [self setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [self setHTTPBody:body];
}

@end
