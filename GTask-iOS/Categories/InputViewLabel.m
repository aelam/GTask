//
//  InputViewLabel.m
//  GTask-iOS
//
//  Created by Ryan Wang on 11-11-2.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "InputViewLabel.h"

@implementation InputViewLabel

@synthesize inputView = inputView_;
@synthesize inputAccessoryView = inputAccessoryView_;


- (UIView *)inputView {
    return inputView_;
}

- (void)setInputView:(UIView *)anInputView {
    if (inputView_ != anInputView) {
        [inputView_ release];
        inputView_ = [anInputView retain];
    }
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}


@end
