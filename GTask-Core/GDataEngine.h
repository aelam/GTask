//
//  GDataEngine.h
//  GTask
//
//  Created by ryan on 11-7-8.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIkit.h>
#import "GDataLoginDialog.h"

@protocol GDataSessionDelegate;

@interface GDataEngine : NSObject { 
    
    id<GDataSessionDelegate> _sessionDelegate;      // weak

}

@property (nonatomic, copy)    NSString    *accessToken;
@property (nonatomic, copy)    NSString    *refreshToken;
@property (nonatomic, assign)  NSInteger   expirationTimeStamp;      // TIMESTAMP SINECE 1970

+ (BOOL)isFirstLogIn;
+ (BOOL)isSessionValid;

- (NSArray *)scopesInfo;

- (id)init;
- (void)authorizeWithResultBlock:(void(^)(GDataEngine *,id))resultBlock;
//- (void)refreshToken;
- (void)logout;
- (void)fetchWithRequest:(NSMutableURLRequest *)request resultBlock:(void(^)(GDataEngine *,id))resultBlock;

@end



@protocol GDataSessionDelegate <NSObject>

@optional
/**
 * Called when the user successfully logged in.
 */
- (void)googleDidLogin;

/**
 * Called when the user dismissed the dialog without logging in.
 */
- (void)googleNotLogin:(BOOL)cancelled;

/**
 * Called when the user logged out.
 */
- (void)googleDidLogout;

@end