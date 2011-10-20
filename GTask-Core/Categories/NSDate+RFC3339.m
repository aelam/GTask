//
//  NSDate+RFC3339.m
//  GTask-iOS
//
//  Created by Ryan Wang on 11-9-26.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "NSDate+RFC3339.h"

@implementation NSDate (RFC3339)

//NSDate *getDateObject(NSString *rfc3339)
+ (NSDate *)dateFromRFC3339:(NSString *)rfc3339
{
    // Date and Time representation in RFC3399:
    // Pattern #1: "YYYY-MM-DDTHH:MM:SSZ"
    //                      1                  
    //  0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9
    // [Y|Y|Y|Y|-|M|M|-|D|D|T|H|H|:|M|M|:|S|S|Z]
    //
    // Pattern #2: "YYYY-MM-DDTHH:MM:SS.sssZ"
    //                      1                   2
    //  0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3
    // [Y|Y|Y|Y|-|M|M|-|D|D|T|H|H|:|M|M|:|S|S|.|s|s|s|Z]
    //   NOTE: The number of digits in the "sss" part is not defined.
    //
    // Pattern #3: "YYYY-MM-DDTHH:MM:SS+HH:MM"
    //                      1                   2
    //  0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 
    // [Y|Y|Y|Y|-|M|M|-|D|D|T|H|H|:|M|M|:|S|S|+|H|H|:|M|M]
    //
    // Pattern #4: "YYYY-MM-DDTHH:MM:SS.sss+HH:MM"
    //                      1                   2
    //  0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8
    // [Y|Y|Y|Y|-|M|M|-|D|D|T|H|H|:|M|M|:|S|S|.|s|s|s|+|H|H|:|M|M]
    //   NOTE: The number of digits in the "sss" part is not defined.
    
    // NSDate format: "YYYY-MM-DD HH:MM:SS +HHMM".
    
    NSCharacterSet *setOfT = [NSCharacterSet characterSetWithCharactersInString:@"tT"];
    NSRange tMarkPos = [rfc3339 rangeOfCharacterFromSet:setOfT];
    if (tMarkPos.location == NSNotFound) return nil;
    
    // extract date and time part:
    NSString *datePart = [rfc3339 substringToIndex:tMarkPos.location];
    NSString *timePart = [rfc3339 substringWithRange:NSMakeRange(tMarkPos.location + tMarkPos.length, 8)];
    NSString *restPart = [rfc3339 substringFromIndex:tMarkPos.location + tMarkPos.length + 8];
    
    // extract time offset part:
    NSString *tzSignPart, *tzHourPart, *tzMinPart;
    NSCharacterSet *setOfZ = [NSCharacterSet characterSetWithCharactersInString:@"zZ"];
    NSRange tzPos = [restPart rangeOfCharacterFromSet:setOfZ];
    if (tzPos.location == NSNotFound) { // Pattern #3 or #4
        NSCharacterSet *setOfSign = [NSCharacterSet characterSetWithCharactersInString:@"+-"];
        NSRange tzSignPos = [restPart rangeOfCharacterFromSet:setOfSign];
        if (tzSignPos.location == NSNotFound) return nil;
        
        tzSignPart = [restPart substringWithRange:tzSignPos];
        tzHourPart = [restPart substringWithRange:NSMakeRange(tzSignPos.location + tzSignPos.length, 2)];
        tzMinPart = [restPart substringFromIndex:tzSignPos.location + tzSignPos.length + 2 + 1];
    } else { // Pattern #1 or #2
        // "Z" means UTC.
        tzSignPart = @"+";
        tzHourPart = @"00";
        tzMinPart = @"00";
    }
    
    // construct a date string in the NSDate format
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSString *dateStr = [NSString stringWithFormat:@"%@ %@ %@%@%@", datePart, timePart, tzSignPart, tzHourPart, tzMinPart];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss +0000"];
    NSDate *date = [dateFormatter dateFromString:dateStr];
    [dateFormatter release];
    return date;
}

- (NSString *)locateTimeDescription {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd EE HH:mm a";

    NSTimeZone *timeZone = [NSTimeZone localTimeZone];

    [dateFormatter setTimeZone:timeZone];
    NSString *timeStamp = [dateFormatter stringFromDate:self];
    [dateFormatter release];
    return timeStamp;
}

- (NSString *)locateTimeDescriptionWithFormatter:(NSString *)formatter {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = formatter;
    
    NSTimeZone *timeZone = [NSTimeZone localTimeZone];
    [dateFormatter setTimeZone:timeZone];
    NSString *timeStamp = [dateFormatter stringFromDate:self];
    [dateFormatter release];
    return timeStamp;
        
}


@end
