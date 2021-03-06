//
//  GDataEngine.m
//  GTask
//
//  Created by ryan on 11-7-8.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "GDataEngine.h"
#import "GDataLoginDialog.h"
#import "NSMutableURLRequest+Shorten.h"
#import "RSimpleConnection.h"
#import <QuartzCore/QuartzCore.h>
#import <YAJL/YAJL.h>

#define USER_DEFAULTS_ACCESS_TOKEN              @"USER_DEFAULTS_ACCESS_TOKEN"
#define USER_DEFAULTS_EXPIRATION_TIMESTAMP      @"USER_DEFAULTS_EXPIRATION_TIMESTAMP"
#define USER_DEFAULTS_REFRESH_TOKEN             @"USER_DEFAULTS_REFRESH_TOKEN"
#define USER_DEFAULTS_GOOGLE_SCOPE              @"USER_DEFAULTS_GOOGLE_SCOPE"

static NSString *const kDialogBaseURL   = @"https://accounts.google.com/o/oauth2/auth";
static NSString *const kAskAuthTokenURL = @"https://accounts.google.com/o/oauth2/token";
static NSString *const kClientID        = @"907346070567.apps.googleusercontent.com";
static NSString *const kClientSecret    = @"JwJmwe_L6iHZgyZ6daWO2AF9";
static NSString *const kRedirectURI     = @"urn:ietf:wg:oauth:2.0:oob";
static NSString *const responseType     = @"code";

////////////////////////////////////////////////////
static int kJsonError = 0x11;

////////////////////////////////////////////////////


@interface GDataEngine (RefreshToken)

- (BOOL)_saveTokensInUserDefaultsWithJson:(NSDictionary *)json;
- (void)_fetchWithRequest:(NSMutableURLRequest *)request resultBlock:(void(^)(GDataEngine *,id))resultBlock;

@end

@implementation GDataEngine

@synthesize accessToken = _accessToken;
@synthesize refreshToken = _refreshToken;
@synthesize expirationTimeStamp = _expirationTimeStamp;
@synthesize operationQueue = _operationQueue;

+ (BOOL)isFirstLogIn {
    NSString *accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULTS_ACCESS_TOKEN];
    NSString *refreshToken = [[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULTS_REFRESH_TOKEN];
    double expirationTimestamp = [[NSUserDefaults standardUserDefaults] doubleForKey :USER_DEFAULTS_EXPIRATION_TIMESTAMP];
    
    if (accessToken || refreshToken || expirationTimestamp) {
        return NO;
    } else {
        return YES;
    }
}

+ (BOOL)isSessionValid {
    double expirationTimestamp = [[NSUserDefaults standardUserDefaults] doubleForKey :USER_DEFAULTS_EXPIRATION_TIMESTAMP];
    double currentTimestamp = [[NSDate date] timeIntervalSince1970];
    NIF_TRACE(@"-- > current : %0.0f expired : %0.0f", currentTimestamp, expirationTimestamp);
    if (currentTimestamp > expirationTimestamp) {
        NIF_TRACE(@"无效");
        return NO;
    } else 
        NIF_TRACE(@"有效");
    return YES;
}


+ (NSArray *)scopesInfo {
    static NSArray *_scopesInfo = nil;
    if (_scopesInfo == nil) {
        _scopesInfo = [[NSArray arrayWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"GDataScopes" ofType:@"plist"]] retain];
    }
    return _scopesInfo;
}

+ (NSString *)authorizationHeader {
    if (![GDataEngine isSessionValid]) {
        return nil;
    }
    
    NSString *accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULTS_ACCESS_TOKEN];
    if (!accessToken) {
        return nil;
    }
    return [NSString stringWithFormat:@"OAuth %@",accessToken];
}

- (id)init {
    if (self = [super init]) {
        self.accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULTS_ACCESS_TOKEN];
        self.refreshToken = [[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULTS_REFRESH_TOKEN];
        self.expirationTimeStamp = [[NSUserDefaults standardUserDefaults] doubleForKey :USER_DEFAULTS_EXPIRATION_TIMESTAMP];
        
        _operationQueue = [[NSOperationQueue alloc] init];
    }
    return self;
}

+ (void)logout {
//    return;
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:USER_DEFAULTS_EXPIRATION_TIMESTAMP];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:USER_DEFAULTS_ACCESS_TOKEN];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:USER_DEFAULTS_REFRESH_TOKEN];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:USER_DEFAULTS_GOOGLE_SCOPE];

    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)authorizeWithResultBlock:(void(^)(GDataEngine *,id))resultBlock {
    [self fetchWithRequest:nil resultBlock:^(GDataEngine *engine, id result) {
        resultBlock(engine,result);
    }];
}

/***
 *
 * 只是登陆的时候request 为nil
 * 这种情况在登陆完成以后就返回结果
 * 否则再完成request请求返回结果
 *
 **/

- (void)fetchWithRequest:(NSMutableURLRequest *)request resultBlock:(void(^)(GDataEngine *,id))resultBlock {
    if ([GDataEngine isSessionValid]) {
        if (request == nil) {           // 只是登陆
                        resultBlock(self,@"已经登陆");
        } else {
            [self _fetchWithRequest:request resultBlock:^(GDataEngine *engine, id result) {
                                resultBlock(self,result);
            }];
        }
    }
    else if(![GDataEngine isSessionValid] && ![GDataEngine isFirstLogIn]){  //refresh
        // 刷新accessToken
        NIF_INFO(@"刷新AccessToken...");
        NSMutableURLRequest *_request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:kAskAuthTokenURL]];
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                                kClientID,@"client_id",
                                kClientSecret,@"client_secret",
                                self.refreshToken,@"refresh_token",
                                @"refresh_token",@"grant_type",
                                nil];
        [_request attachPostParams:params];
        
        [RSimpleConnection sendAsynchronousRequest:_request queue:_operationQueue completionHandler:^(NSURLResponse *respone, NSData *responsingData, NSError *error) {
            if (error) {
                resultBlock(self,error);
            } else {
                NSDictionary *json = [responsingData yajl_JSON];
                BOOL rs = [self _saveTokensInUserDefaultsWithJson:json];
                if (!rs) {
                    NSError *error = [[[NSError alloc] initWithDomain:@"!!SAVE TOKEN ERROR" code:kJsonError userInfo:nil] autorelease];
                    resultBlock(self,error);
                } else {
                    if (request == nil) {
                        resultBlock(self,@"已经登陆");
                    } else { 
                        [self _fetchWithRequest:request resultBlock:^(GDataEngine *engine, id result) {
                            resultBlock(self,result);
                        }];
                    }
                }                
            }
        }];
    }
    else if ([GDataEngine isFirstLogIn]) {
        NIF_INFO(@"请求AccessToken...");
        NSArray *scopeInfo = [GDataEngine scopesInfo];
        NSMutableArray *scopes = [NSMutableArray array];
        for (NSDictionary *aScope in scopeInfo) {
            BOOL valid = [[aScope objectForKey:@"valid"] boolValue];
            if (valid) {
                [scopes addObject:[aScope objectForKey:@"url"]];
            }
        }
        
        NSString *scope = [scopes componentsJoinedByString:@" "];
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                                kClientID,@"client_id",
                                kRedirectURI,@"redirect_uri",
                                scope,@"scope",
                                responseType,@"response_type",
                                nil];
        
        NSString *query = [NSString queryStringFromParams:params];
        NSURL *url = [NSURL URLWithString:[kDialogBaseURL stringByAppendingFormat:@"?%@",query]];
        NIF_INFO(@"loginURL : %@", url);
        
        GDataLoginDialog *loginDialog = [[[GDataLoginDialog alloc] init] autorelease];
        [loginDialog loadWithURL:url blocksStart:^(UIWebView *webView) {

        } finish:^(UIWebView *webView) {        
            // 获取 title, title中access token
            NSString *codeFragile = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
            NSString *seperator = @"code=";
            NSRange range = [codeFragile rangeOfString:@"code=" options:NSCaseInsensitiveSearch];
            if (range.length > 0) {
                [loginDialog disappear];
                
                NSString *code = [[codeFragile componentsSeparatedByString:seperator] objectAtIndex:1];
                
                NSMutableURLRequest *_request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:kAskAuthTokenURL]];
                NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                                        kClientID,@"client_id",
                                        code,@"code",
                                        kClientSecret,@"client_secret",
                                        kRedirectURI,@"redirect_uri",
                                        @"authorization_code",@"grant_type",
                                        nil];
                [_request attachPostParams:params];
                
                [RSimpleConnection sendAsynchronousRequest:_request queue:_operationQueue completionHandler:^(NSURLResponse *respone, NSData *responsingData, NSError *error) {
                    if (error) {
                        resultBlock(self,error);
                    } else {
                        NSDictionary *json = [responsingData yajl_JSON];
                        BOOL rs = [self _saveTokensInUserDefaultsWithJson:json];
                        if (!rs) {
                            NSError *error = [[[NSError alloc] initWithDomain:@"!!SAVE TOKEN ERROR" code:kJsonError userInfo:nil] autorelease];
                            resultBlock(self,error);
                        } else {
                            if (request == nil) {
                                resultBlock(self,@"已经登陆");
                            } else { 
                                [self _fetchWithRequest:request resultBlock:^(GDataEngine *engine, id result) {
                                    resultBlock(self,result);
                                }];
                            }
                        }                
                    }
                }];

            }
        
        } fail:^(UIWebView *webView, NSError *error) {
                        resultBlock(self,error);
        }];
    } 
}

- (void)_fetchWithRequest:(NSMutableURLRequest *)request resultBlock:(void(^)(GDataEngine *,id))resultBlock {

    // SET OAuth Header
    [request setValue:[NSString stringWithFormat:@"OAuth %@",self.accessToken] forHTTPHeaderField:@"Authorization"];
    
    [RSimpleConnection sendAsynchronousRequest:request queue:_operationQueue completionHandler:^(NSURLResponse *respone, NSData *responsingData, NSError *error) {
        if (error) {
            resultBlock(self,error);
        } else {
            NSDictionary *json = [responsingData yajl_JSON];
            if (![json isKindOfClass:[NSDictionary class]]) {
                NSError *error = [[[NSError alloc] initWithDomain:@"!!JSON PARSE ERROR 2" code:kJsonError userInfo:nil] autorelease];
                resultBlock(self,error);
            } else {
                if (request == nil) {

                } else { 
                    resultBlock(self,json);
                }
            }                
        }
    }];

}


- (BOOL)_saveTokensInUserDefaultsWithJson:(NSDictionary *)json {
    
    self.accessToken = [json objectForKey:@"access_token"];
    NSString *refresh = [json objectForKey:@"refresh_token"];
    if (refresh) {
        self.refreshToken = refresh;
    }
    
    NSInteger expiresIn = [[json objectForKey:@"expires_in"] intValue];
    _expirationTimeStamp = [[NSDate date] timeIntervalSince1970] + expiresIn;
        
    [[NSUserDefaults standardUserDefaults] setObject:_accessToken forKey:USER_DEFAULTS_ACCESS_TOKEN];
    [[NSUserDefaults standardUserDefaults] setObject:_refreshToken forKey:USER_DEFAULTS_REFRESH_TOKEN];
    [[NSUserDefaults standardUserDefaults] setInteger:_expirationTimeStamp forKey:USER_DEFAULTS_EXPIRATION_TIMESTAMP];

    return [[NSUserDefaults standardUserDefaults] synchronize];
    
}

- (void)dealloc {
    [_accessToken release];  _accessToken = nil;
    [_refreshToken release]; _refreshToken = nil;
    [_operationQueue release];
    [super dealloc];
}

@end
