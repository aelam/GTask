//
//  GEditViewController.h
//  GTask-iOS
//
//  Created by Ryan Wang on 11-10-9.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Task;
@class UIPlaceHolderTextView;

@interface GEditViewController : UIViewController <UITextFieldDelegate,UITextViewDelegate,UITableViewDelegate,UITableViewDataSource> {

    BOOL isKeyboardHidden;
    BOOL isPickerShown;
}

@property (retain) Task *task;
@property (copy)   Task *tempTask;
@property (retain) UITextField *titleField;
@property (retain) UIPlaceHolderTextView *textView;
@property (assign) float textViewHeight;

@property (retain) IBOutlet UILabel *titleLabel;
@property (retain) IBOutlet UITableView *tableView;

@property (assign) UIButton *undoButton;
@property (assign) UIButton *redoButton;

@property (retain) UIDatePicker *datePicker;
@property (retain) NSDate *pickedDate;

@end
