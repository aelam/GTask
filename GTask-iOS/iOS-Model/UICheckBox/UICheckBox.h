//
//  UICheckBox.h
//  GTask-iOS
//
//  Created by ryan on 11-10-16.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//


typedef void (^ActionBlock)();

@interface UICheckBox : UIButton {
    BOOL checked;
    ActionBlock _actionBlock;
}

@property (nonatomic, assign) BOOL checked;

-(void) handleCheckEventWithBlock:(ActionBlock) action;

@end
