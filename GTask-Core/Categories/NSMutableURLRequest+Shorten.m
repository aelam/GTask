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
@end
