//
//  NSDate+RFC3339.h
//  GTask-iOS
//
//  Created by Ryan Wang on 11-9-26.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (RFC3339)

+ (NSDate *)dateFromRFC3339:(NSString *)rfc3339;

- (NSString *)locateTimeDescription;
- (NSString *)locateTimeDescriptionWithFormatter:(NSString *)formatter;

- (NSString *)RFC3339String;

@end
