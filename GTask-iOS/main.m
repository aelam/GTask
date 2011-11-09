//
//  main.m
//  GTask-iOS
//
//  Created by ryan on 11-9-19.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "RWAppDelegate.h"

int main(int argc, char *argv[])
{
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
//    @autoreleasepool {
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([RWAppDelegate class]));
//    }
    [pool drain];
}
