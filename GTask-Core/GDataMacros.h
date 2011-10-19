//
//  GDataMacros.h
//  GTask
//
//  Created by Ryan Wang on 11-7-9.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#define SAFELY_RELEASE(obj) [obj release]; obj = nil;

#define RGB_COLOR(r,g,b)		[UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1]
#define RGBA_COLOR(r,g,b,a)	[UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)]
