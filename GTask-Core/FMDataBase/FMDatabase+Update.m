//
//  FMDatabase+Update.m
//  DDCoupon
//
//  Created by ryan on 11-6-28.
//  Copyright 2011 DDmap. All rights reserved.
//

#import "FMDatabase+Update.h"
#import "FMDatabaseAdditions.h"

@implementation FMDatabase (Update)

///////////////////////////////////////////////////////////////////////////////
//  add
+ (void)defaultDatabaseUpdate {
		
	FMDatabase *db_ = [FMDatabase defaultDatabase];
	[db_ open];
    
    int schemaVersion = [db_ schemaVersion];
    switch (schemaVersion) {
        case 0: {
            NSError *error = nil;
            NSString *schemaPath = [[NSBundle mainBundle] pathForResource:@"GTaskSchema" ofType:@"sql"];
            NSString *schemas = [NSString stringWithContentsOfFile:schemaPath encoding:NSUTF8StringEncoding error:&error];
            NSError *dbError = nil;
            [db_ executeBatch:schemas error:&dbError];
            if (dbError) {
                NIF_INFO(@"%@", dbError);
            }
        };
        default:
            break;
    }
    
	[db_ close];
	
}

///////////////////////////////////////////////////////////////////////////////




@end
