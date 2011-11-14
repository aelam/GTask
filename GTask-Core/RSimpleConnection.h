//
//  RSimpleConnection.h
//  GTask-iOS
//
//  Created by ryan on 11-9-21.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

/*
@protocol RSimpleConnectionDelegate;

typedef enum {
	RSimpleConnectionTagDefault	= 0,
	RSimpleConnectionTagFirst,
	RSimpleConnectionTagSecond,
	RSimpleConnectionTagThird,
	RSimpleConnectionTagForth,
	RSimpleConnectionTagFifth
} RSimpleConnectionTag;


//typedef void(^ConnectionHandler)(GTaskEngine *currentEngine, SyncStep step);

@interface RSimpleConnection : NSObject {
    
    RSimpleConnectionTag _connectionTag;
	
	NSMutableData		*_buffer;
    NSURLRequest        *_request;
	NSURLConnection		*_connection;

    id <RSimpleConnectionDelegate>_delegate;

    void (^startLoad)(RSimpleConnection *);
    void (^finishLoad)(RSimpleConnection *,NSDictionary *);
    void (^failLoad)(RSimpleConnection *,NSError *);
}

@property (nonatomic ,retain)id <RSimpleConnectionDelegate>delegate;

+ (id)connectionWithRequest:(NSURLRequest *)request;
+ (id)connectionWithRequest:(NSURLRequest *)request tag:(RSimpleConnectionTag)tag;
+ (id)connectionWithRequest:(NSURLRequest *)request delegate:(id)delegate tag:(RSimpleConnectionTag)tag;

- (id)initWithRequest:(NSURLRequest *)request delegate:(id)delegate tag:(RSimpleConnectionTag)tag;


- (void)startWithBlocksStart:(void(^)(RSimpleConnection *))start finish:(void(^)(RSimpleConnection *,NSDictionary *))finish fail:(void(^)(RSimpleConnection *,NSError *))fail;

@end

@protocol RSimpleConnectionDelegate <NSObject>

- (void)connection:(RSimpleConnection *)connection didFinishLoading:(NSDictionary *)json;
- (void)connection:(RSimpleConnection *)connection didFailWithError:(NSError *)error;

@end

*/
@interface RSimpleConnection : NSURLConnection

typedef void (^CompletionHandler)(NSURLResponse*, NSData*, NSError*);

+ (void)sendAsynchronousRequest:(NSURLRequest *)request queue:(NSOperationQueue *)queue completionHandler:(CompletionHandler)handler NS_AVAILABLE(10_7, 4_0);

@end

