//
//  GDataLoginDialog.h
//  GTask
//
//  Created by ryan on 11-7-8.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

// Blocks http://gkoreman.com/blog/2011/02/15/uialertview-with-blocks/
// http://stackoverflow.com/questions/5023566/objective-c-calling-self-methodname-from-inside-a-block

#import "NSString+Categories.h"

@protocol GDataLoginDialogDelegate;
    
@interface GDataLoginDialog : UIView <UIWebViewDelegate>{
    UIWebView   *_webView;          //strong
  
    void (^startLoad)(UIWebView *webView);
    void (^finishLoad)(UIWebView *webView);
    void (^failLoad)(UIWebView *webView,NSError *error);
    
}

- (void)show;
- (void)disappear;

- (void)loadWithURL:(NSURL *)url blocksStart:(void(^)(UIWebView *))start finish:(void(^)(UIWebView *))finish fail:(void(^)(UIWebView *,NSError *))fail;


@end
