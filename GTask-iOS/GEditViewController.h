//
//  GEditViewController.h
//  GTask-iOS
//
//  Created by Ryan Wang on 11-10-9.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Task;

@interface GEditViewController : UITableViewController <UITextFieldDelegate,UITextViewDelegate> {
//    float textViewHeight;
}

@property (retain) Task *task;
@property (copy)   Task *tempTask;
@property (retain)   UITextView *textView;
@property (assign)   float textViewHeight;

@property (retain) IBOutlet UILabel *titleLabel;

@end
