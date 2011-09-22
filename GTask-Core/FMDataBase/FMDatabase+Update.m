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
//　For 2.0.1 
//  add
+ (void)databaseUpdate {
	
	NSString *tableName = @"coupons_in_pocket";
	NSString *columnName = @"expire_date";
	
	FMDatabase *db_ = [FMDatabase database];
	[db_ open];
	
	BOOL exists = [db_ columnExists:tableName columnName:columnName];
	if (!exists) {
		NSString *update = [NSString stringWithFormat:@"ALTER TABLE %@ ADD %@ TIMESTAMP DEFAULT 0",tableName,columnName];
		NIF_TRACE(@"--------- %@",update);
		[db_ executeUpdate:update];
	}
    
    //added in 2.1.0
    tableName = @"coupons_in_pocket";
	columnName = @"detail_data";
    exists = [db_ columnExists:tableName columnName:columnName];
	if (!exists) {
		NSString *update = [NSString stringWithFormat:@"ALTER TABLE %@ ADD %@ TEXT",tableName,columnName];
		NIF_TRACE(@"--------- %@",update);
		[db_ executeUpdate:update];
	}
    
	columnName = @"small_image_path";
    exists = [db_ columnExists:tableName columnName:columnName];
	if (!exists) {
		NSString *update = [NSString stringWithFormat:@"ALTER TABLE %@ ADD %@ VARCHAR",tableName,columnName];
		NIF_TRACE(@"--------- %@",update);
		[db_ executeUpdate:update];
	}
    
	columnName = @"big_image_path";
    exists = [db_ columnExists:tableName columnName:columnName];
	if (!exists) {
		NSString *update = [NSString stringWithFormat:@"ALTER TABLE %@ ADD %@ VARCHAR",tableName,columnName];
		NIF_TRACE(@"--------- %@",update);
		[db_ executeUpdate:update];
	}
    
    columnName = @"city_code";
    exists = [db_ columnExists:tableName columnName:columnName];
	if (!exists) {
		NSString *update = [NSString stringWithFormat:@"ALTER TABLE %@ ADD %@ VARCHAR",tableName,columnName];
		NIF_TRACE(@"--------- %@",update);
		[db_ executeUpdate:update];
	}
    
    columnName = @"show_image";
    exists = [db_ columnExists:tableName columnName:columnName];
	if (!exists) {
		NSString *update = [NSString stringWithFormat:@"ALTER TABLE %@ ADD %@ INTEGER DEFAULT 0",tableName,columnName];
		NIF_TRACE(@"--------- %@",update);
		[db_ executeUpdate:update];
	}
    
    columnName = @"version";
    exists = [db_ columnExists:tableName columnName:columnName];
	if (!exists) {
		NSString *update = [NSString stringWithFormat:@"ALTER TABLE %@ ADD %@ VARCHAR; UPDATE %@ SET VERSION='0200'",tableName,columnName,tableName];
		NIF_TRACE(@"--------- %@",update);
		[db_ executeUpdate:update];
        update = [NSString stringWithFormat:@"UPDATE %@ SET VERSION='0200'",tableName];
		NIF_TRACE(@"--------- %@",update);
		[db_ executeUpdate:update];
	}
    
	tableName = @"search_history";
	exists = [db_ tableExists:tableName];
	if(!exists)
	{
		NSString *update = [NSString stringWithFormat:@"CREATE TABLE search_history(row_id INTEGER PRIMARY KEY AUTOINCREMENT,search_key VARCHAR)"];
		NIF_TRACE(@"--------- %@",update);
		[db_ executeUpdate:update];
	}
	
	[db_ close];
	
}

///////////////////////////////////////////////////////////////////////////////




@end
