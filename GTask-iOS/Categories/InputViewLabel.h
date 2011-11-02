//
//  InputViewLabel.h
//  GTask-iOS
//
//  Created by Ryan Wang on 11-11-2.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//



@interface InputViewLabel : UIButton

@property (nonatomic, retain) UIView *inputView;
@property (nonatomic, retain) UIView *inputAccessoryView;


- (BOOL)canBecomeFirstResponder;

@end
