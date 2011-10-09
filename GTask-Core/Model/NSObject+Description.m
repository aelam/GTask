//
//  NSObject+Description.m
//  GTask-iOS
//
//  Created by Ryan Wang on 11-10-10.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "NSObject+Description.h"
#import <objc/runtime.h>

@implementation NSObject (Description)

- (void)printProperties {
    unsigned int outCount = 0;
    
    objc_property_t *propertyList = class_copyPropertyList([self class], &outCount);
    for (int i = 0; i < outCount; i++) {
        const char *propertyName = property_getName(propertyList[i]);
        const char *attributesName = property_getAttributes(propertyList[i]);
        
        NSLog(@"%s",propertyName);
        NSLog(@"%s",attributesName);
        
        SEL property = NSSelectorFromString([NSString stringWithFormat:@"%s",propertyName]);
        [self performSelector:property];
    }
    

}

@end
