//
//  GEditViewController.h
//  GTask-iOS
//
//  Created by Ryan Wang on 11-10-9.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GListChooseController.h"

typedef enum{
    TaskEditTypeModifyOldTask,
    TaskEditTypeAddNewTask
}TaskEditType;

@class Task;
@class UIPlaceHolderTextView;
@class GListChooseController;
@protocol EditProtocol;


@interface GEditViewController : UITableViewController <UITextFieldDelegate,UITextViewDelegate,UITableViewDelegate,UITableViewDataSource,GListChooseDelegate> {
    
    UISegmentedControl *_undoControl;    // weak;
}


@property (assign) TaskEditType type;
@property (retain) Task *task;
@property (copy)   Task *tempTask;
@property (retain) UITextField  *titleField;
@property (retain) UITextField  *dateField; //fake
@property (retain) UILabel      *dateLabel;
@property (retain) UIPlaceHolderTextView *textView;

// First response
@property (retain) UIResponder *firstResponder;

@property (assign) float textViewHeight;

@property (retain) IBOutlet UILabel *titleLabel;

@property (assign) UIButton *undoButton;
@property (assign) UIButton *redoButton;

@property (retain) UIDatePicker *datePicker;
@property (retain) NSDate *pickedDate;

@property (strong, nonatomic) GListChooseController *listChooseController;

@property (assign) id <EditProtocol> editDelegate;

@end
