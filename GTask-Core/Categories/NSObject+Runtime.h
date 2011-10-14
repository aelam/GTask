//
//  NSObject+Runtime.h
//  GTask-iOS
//
//  Created by Ryan Wang on 11-10-10.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

typedef enum {
    NS_OBJC_ASSOCIATION_ASSIGN = 0,
    NS_OBJC_ASSOCIATION_RETAIN_NONATOMIC = 1,
    NS_OBJC_ASSOCIATION_COPY_NONATOMIC = 3,
    NS_OBJC_ASSOCIATION_RETAIN = 01401,
    NS_OBJC_ASSOCIATION_COPY = 01403
} NSAssociationPolicy;

@interface NSObject (Helper)

- (void)printProperties;

- (void)setAssociatedObject:(id)object forKey:(char *)hashKey;
- (void)setAssociatedObject:(id)object forKey:(char *)hashKey policy:(NSAssociationPolicy)policy;
- (id)associatedObjectForKey:(char *)hashKey;


@end
