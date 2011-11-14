//
//  RSimpleConnection.m
//  GTask-iOS
//
//  Created by ryan on 11-9-21.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "RSimpleConnection.h"
#import <YAJL/YAJL.h>

/*
@interface RSimpleConnection()

@property (nonatomic, retain)  NSURLRequest     *request;
@property (nonatomic, retain)  NSURLConnection	*connection;
@property (nonatomic, retain)  NSMutableData	*buffer;

@end

@implementation RSimpleConnection

@synthesize delegate = _delegate;
@synthesize request = _request;
@synthesize connection = _connection;
@synthesize buffer = _buffer;


+ (id)connectionWithRequest:(NSURLRequest *)request {
    return [[[self alloc] initWithRequest:request delegate:nil tag:RSimpleConnectionTagDefault] autorelease];    
}

+ (id)connectionWithRequest:(NSURLRequest *)request tag:(RSimpleConnectionTag)tag  {
    return [[[self alloc] initWithRequest:request delegate:nil tag:tag] autorelease];
}

+ (id)connectionWithRequest:(NSURLRequest *)request delegate:(id)delegate tag:(RSimpleConnectionTag)tag  {
    return [[[self alloc] initWithRequest:request delegate:delegate tag:tag] autorelease];
}

- (id)initWithRequest:(NSURLRequest *)request delegate:(id)delegate tag:(RSimpleConnectionTag)tag {
    if (self = [super init]) {
        _request = [request retain];
        _delegate = [delegate retain];
        _connectionTag = tag;
    }
    return self;
}


- (void)startWithBlocksStart:(void(^)(RSimpleConnection *))start finish:(void(^)(RSimpleConnection *,NSDictionary *))finish fail:(void(^)(RSimpleConnection *,NSError *))fail {
    [startLoad release];
    startLoad = [start copy];
    [finishLoad release];
    finishLoad = [finish copy];
    [failLoad release];
    failLoad = [fail copy];

    NIF_TRACE(@"URL:%@", [_request URL]);
    
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:_request delegate:self];
    self.connection = conn;
    [conn release];
    
    [self.connection start];
}



#pragma mark -
#pragma mark - NSURLConnectionDelegate
- (void)connection:(NSURLConnection *)aConnection didFailWithError:(NSError *)error {
	self.buffer = nil;
    if (failLoad) {
        failLoad(self,error);
    }
    
}

- (void)connection:(NSURLConnection *)aConnection didReceiveResponse:(NSURLResponse *)response {
	self.buffer = [NSMutableData data];
}

- (void)connection:(NSURLConnection *)aConnection didReceiveData:(NSData *)data {
	[self.buffer appendData:data]; 
}

- (void)connectionDidFinishLoading:(NSURLConnection *)aConnection {
    NSDictionary *jsonValue = nil;
	
	@try {
		jsonValue = [self.buffer yajl_JSON];
	}
    @catch (NSException * e) {
        if (e) {
			NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"JSON PARSER ERROR!"
																 forKey:NSLocalizedDescriptionKey];
			NSError *error = [NSError errorWithDomain:NSCocoaErrorDomain
                                                 code:1000
                                             userInfo:userInfo];
            if (failLoad) {
                failLoad(self,error);
            }
        }
    }
    @finally {
        if (jsonValue) {
            NIF_INFO(@"%@", jsonValue);
            if (finishLoad) {
                finishLoad(self,jsonValue);
            }       
        } else {
            // 解析失败时候返回原始NSData
            if (finishLoad) {
                finishLoad(self,(NSMutableDictionary *)self.buffer);
            }       
        }
    }
}

- (void)dealloc {
    self.delegate = nil;
    [_buffer release];
    [_request release];
    [_connection release];
    [super dealloc];
}

@end

*/
@implementation RSimpleConnection

+ (void)sendAsynchronousRequest:(NSURLRequest *)request queue:(NSOperationQueue *)queue completionHandler:(void (^)(NSURLResponse*response, NSData*responseData, NSError*error))handler {
    
    if (!queue) {
        queue = [NSOperationQueue mainQueue];
    }
    NSBlockOperation *operation  = [NSBlockOperation blockOperationWithBlock:^{
        NSError *anError = nil;
        NSURLResponse *aResponse = nil;
        NSData *responsingData = [NSURLConnection sendSynchronousRequest:request returningResponse:&aResponse error:&anError];
        handler(aResponse,responsingData,anError);
    }];
    [queue addOperation:operation];
}

@end


