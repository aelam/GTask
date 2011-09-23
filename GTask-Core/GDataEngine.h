//
//  GDataEngine.h
//  GTask
//
//  Created by ryan on 11-7-8.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIkit.h>
#import "GDataLoginDialog.h"

@interface GDataEngine : NSObject { 
    
}

@property (nonatomic, copy)    NSString    *accessToken;
@property (nonatomic, copy)    NSString    *refreshToken;
@property (nonatomic, assign)  NSInteger   expirationTimeStamp;      // TIMESTAMP SINECE 1970

+ (BOOL)isFirstLogIn;
+ (BOOL)isSessionValid;
+ (void)logout;

+ (NSArray *)scopesInfo;

- (id)init;

- (void)authorizeWithResultBlock:(void(^)(GDataEngine *,id))resultBlock;
- (void)fetchWithRequest:(NSMutableURLRequest *)request resultBlock:(void(^)(GDataEngine *,id))resultBlock;

@end