//
//  GDataLoginDialog.m
//  GTask
//
//  Created by ryan on 11-7-8.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "GDataLoginDialog.h"
#import <QuartzCore/QuartzCore.h>

@interface GDataLoginDialog (Private)

- (void)load;
- (void)askAccessTokenWithCode:(NSString *)code;

@end

@interface GDataLoginDialog (Animation)

- (void)bounceOut;
- (void)bounceIn;

@end

@implementation GDataLoginDialog


- (id)init{//WithScopes:(NSArray *)scopes delegate:(id <GDataLoginDialogDelegate>)delegate {

    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    if (self) {

        // Initialization code here.
        _webView = [[UIWebView alloc] initWithFrame:CGRectMake(10, 30, 300, 440)];
        _webView.autoresizingMask = UIViewAutoresizingFlexibleWidth |UIViewAutoresizingFlexibleHeight;
        _webView.delegate = self;

        self.backgroundColor = [UIColor whiteColor];
        self.layer.borderColor = [UIColor darkGrayColor].CGColor;
        self.layer.borderWidth = 5.f;
        [_webView.layer setCornerRadius:4];

//        NSAssert(scopes,@"scope can't be nil");
//        _scopes = [scopes retain];
//        
//        _delegate = delegate;
        //self.backgroundColor = [UIColor redColor];
        //_webView.backgroundColor = [UIColor redColor];
        
        [self addSubview:_webView];
    }
    
    return self;
}

- (void)show {    
    UIWindow* window = [UIApplication sharedApplication].keyWindow;
    if (window) {
        window = [[UIApplication sharedApplication].windows objectAtIndex:0];
    }
    [window addSubview:self];
  
    [self bounceOut];
}

////////////////////////////////////////////////////////////////////////////////////
- (void)bounceOut {
    [UIView beginAnimations:@"Bounce" context:NULL];
    self.transform = CGAffineTransformMakeScale(1.2,1.2);
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(bounceIn)];
    [UIView commitAnimations];        
}

- (void)bounceIn {
    [UIView beginAnimations:@"Bounce" context:NULL];
    [UIView setAnimationDuration:0.01];
    self.transform = CGAffineTransformMakeScale(1,1);
    [UIView setAnimationDelegate:self];
    [UIView commitAnimations];            
}

- (void)disappear {
    [UIView beginAnimations:@"Bounce" context:NULL];
    [UIView setAnimationDuration:0.4];
    self.transform = CGAffineTransformMakeScale(0.000001,0.000001);
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(removeFromSuperview)];
    [UIView commitAnimations];                
}

////////////////////////////////////////////////////////////////////////////////////
/*
- (void)load {
    NSString *scope = [_scopes componentsJoinedByString:@" "];
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            kClientID,@"client_id",
                            kRedirectURI,@"redirect_uri",
                            scope,@"scope",
                            responseType,@"response_type",
                            nil];
    
    NSString *query = [NSString queryStringFromParams:params];
    NSURL *url = [NSURL URLWithString:[kDialogBaseURL stringByAppendingFormat:@"?%@",query]];

    [_webView loadRequest:[NSURLRequest requestWithURL:url]];
}
*/

- (void)loadWithURL:(NSURL *)url blocksStart:(void(^)(UIWebView *))start finish:(void(^)(UIWebView *))finish fail:(void(^)(UIWebView *,NSError *))fail{
    [startLoad release];
    startLoad = [start copy];
    [finishLoad release];
    finishLoad = [finish copy];
    [failLoad release];
    failLoad = [fail copy];
    
    [self show];

    [_webView loadRequest:[NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:30]];

  
}


- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    if (startLoad) {
        startLoad(webView);
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    if (finishLoad) {
        finishLoad(webView);
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    if (failLoad) {
        failLoad(webView,error);
    }
}

- (void)dealloc {
    [_webView release];
    [startLoad release];
    [finishLoad release];
    [failLoad release];
    [super dealloc];
}

@end
