//
//  NSString+Categories.m
//  GTask
//
//  Created by ryan on 11-7-8.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "NSString+Categories.h"

@implementation NSString (urlParams)

+ (NSString *)queryStringFromParams:(NSDictionary *)params  {
    if (params) {
		NSMutableArray* pairs = [NSMutableArray array];
		for (NSString* key in params.keyEnumerator) {
			NSString* value = [params objectForKey:key];
			NSString* escaped_value = (NSString *)CFURLCreateStringByAddingPercentEscapes(
																						  NULL, /* allocator */
																						  (CFStringRef)value,
																						  NULL, /* charactersToLeaveUnescaped */
																						  (CFStringRef)@"!*'();:@&=+$,/?%#[]",
																						  kCFStringEncodingUTF8);
			
			[pairs addObject:[NSString stringWithFormat:@"%@=%@", key, escaped_value]];
			[escaped_value release];
		}
		NSString* query = [pairs componentsJoinedByString:@"&"];
        return query;
    }
    return nil;
}


@end
