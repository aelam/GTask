//
//  Created by Ryan W. on 10-7-28.
//  Copyright 2010 Yuxi Pacific Group, LLC. All rights reserved.
//



/**
 *	JSONValue failed
 *	Add a Preprocessor Macro in Build : DEBUG
 *
 */

//extern const char * class_getName(Class cls);

//#warning Not a release version. Please distribute a release version
//发行版的时候注释掉
//#define UNIVERSAL_VERSION

//#define _DEBUG
#define DEBUG 1

#define _NIF_LOG(fmt, ...) NSLog(fmt, ##__VA_ARGS__)
 
#ifdef DEBUG
	#define NIF_TRACE(fmt, ...) NSLog(@" [LINE:%d] %s " fmt,__LINE__,__FUNCTION__, ##__VA_ARGS__)
#else
	#define NIF_TRACE(fmt, ...)
#endif

//#define NIF_INFO(fmt, ...)  _NIF_LOG(@"- %s [LINE:%d]" fmt,__FUNCTION__,__LINE__, ##__VA_ARGS__)
#define NIF_INFO(fmt, ...)  NSLog(@"- %s [LINE:%d]" fmt,__FUNCTION__,__LINE__, ##__VA_ARGS__)
#define NIF_ERROR(fmt, ...) NSLog(@"! %s [LINE:%d]" fmt,__FUNCTION__,__LINE__, ##__VA_ARGS__)

