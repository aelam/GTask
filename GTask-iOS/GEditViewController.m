 //
//  GEditViewController.m
//  GTask-iOS
//
//  Created by Ryan Wang on 11-10-9.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

/**
 *  
 * 两种编辑模式
 *  1. 添加一个新任务， 这个时候点击DONE的时候更新数组同时加入数据库，
 *  2. 修改子任务
 *     - 未修改分组： 在textFieldDidEndEditing/textViewDidEndEditing/dateDidPick里面更新数据库
 *     - 修改了分组： 在textFieldDidEndEditing/textViewDidEndEditing/dateDidPick里面更新数据库
 *                   在修改了所属List的时候需要更新所有排序
 *      
 */


#import "GEditViewController.h"
#import "Task.h"
#import "GTableViewCell.h"
#import "NSObject+Runtime.h"
#import "UIPlaceHolderTextView.h"
#import "NSDate+RFC3339.h"
#import "UICheckBox.h"
#import "GListChooseController.h"
#import "TaskList.h"
#import "RWDetailViewController.h"

@interface GEditViewController (Plus)

- (void)updateUndoButtons;

- (void)clearDate;
- (void)confirmDate;

- (void)updateDate:(id)sender;

@end

#define TASK_TITLE_TEXT_FIELD_TAG   10101
#define TASK_DATE_FIELD_TAG         10201


@implementation GEditViewController

@synthesize task = _task;
@synthesize titleLabel = _titleLabel;
@synthesize tempTask = _tempTask;
@synthesize textView = _textView;
@synthesize textViewHeight = _textViewHeight;
@synthesize titleField = _titleField;
@synthesize dateField = _dateField;
@synthesize undoButton = _undoButton;
@synthesize redoButton = _redoButton;
@synthesize datePicker = _datePicker;
@synthesize pickedDate = _pickedDate;
@synthesize listChooseController = _listChooseController;
@synthesize type = _type;
@synthesize editDelegate = _editDelegate;
@synthesize dateLabel = _dateLabel;

@synthesize firstResponder = _firstResponder;

- (void)dealloc {
    
    [_task release];
    [_tempTask release];
    [_titleLabel release];
    [_dateField release];
    [_dateLabel release];
    [_textView release];
    [_titleField release];
    [_pickedDate release];
    [_listChooseController release];
    [_firstResponder release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
        
    self.titleLabel.text = self.tempTask.title;
    
    [self.tableView reloadData];

    if (self.type == TaskEditTypeAddNewTask) {
        
        UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", @"Cancel") style:UIBarButtonItemStylePlain target:self action:@selector(cancelAction:)];
        [self.navigationItem setLeftBarButtonItem:cancelItem animated:YES];
        [cancelItem release];
        
        UIBarButtonItem *doneItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", @"Done") style:UIBarButtonItemStyleDone target:self action:@selector(doneAction:)];
        [self.navigationItem setRightBarButtonItem:doneItem animated:YES];
        [doneItem release];
    } else if (self.type == TaskEditTypeModifyOldTask) {
        [self.navigationItem setLeftBarButtonItem:nil animated:NO];
        [self.navigationItem setRightBarButtonItem:nil animated:NO];
    }

}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter]removeObserver:self];

}

- (void)viewDidLoad
{
    [super viewDidLoad];    
    
    UIMenuController *menuController = [UIMenuController sharedMenuController];
    UIMenuItem *item = [[[UIMenuItem alloc] initWithTitle: @"Do Something"
                                                   action: @selector(doSomething:)] autorelease];
    [menuController setMenuItems: [NSArray arrayWithObject: item]];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration {

}


- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    [self.tableView setEditing:editing animated:animated];
    
    
}

#pragma mark -
#pragma mark UITableDelegate and UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < 3) {
        return 40;
    } else {
        NSInteger realHeight = 0;
        NSInteger height = CGRectGetHeight(self.tableView.frame) - 3 * 40;
        NSString *content = self.tempTask.notes;    
        if (content && content.length) {
            CGSize contentSize = [content sizeWithFont:[UIFont systemFontOfSize:17] constrainedToSize:CGSizeMake(CGRectGetWidth(self.tableView.frame), 10000)];
            if (contentSize.height  + 40 > height) {
                realHeight = contentSize.height + 40;
            } else {
                realHeight = height;
            }
        }
        realHeight = height > 130?height:130;
        
        return realHeight;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *kCellIndentifier = @"kTextFieldCellIndentifier";
    static NSString *kListChooseCellIndentifier = @"kListChooseCellIndentifier";
    static NSString *kDateChooseCellIndentifier = @"kDateChooseCellIndentifier";
    static NSString *kTextViewCellIndentifier = @"kTextViewCellIndentifier";
    
    GTableViewCell *cell = nil;
    if (indexPath.row == 0) {
        cell = (GTableViewCell *)[tableView dequeueReusableCellWithIdentifier:kCellIndentifier];
        if(cell == nil) {
            cell = [[[GTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:kCellIndentifier] autorelease];
            
            
            cell.textField.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            cell.textField.placeholder = NSLocalizedString(@"Add title", @"Add title");
            cell.textField.font = [UIFont boldSystemFontOfSize:17];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.textField.returnKeyType = UIReturnKeyDone;
            cell.textField.delegate = self;
            
            cell.checkBox.checked = NO;
            cell.checkBox.frame = CGRectMake(8, 12, 20, 20);
            
        }
        
        [cell.checkBox handleCheckEventWithBlock:^{
            self.tempTask.isCompleted = !self.tempTask.isCompleted;
            cell.checkBox.checked = self.tempTask.isCompleted;
            
            [self.task setIsCompleted:!self.task.isCompleted updateDB:YES];
            
            cell.textField.textColor = self.tempTask.isCompleted?[UIColor lightGrayColor]:[UIColor blackColor];
        }];

        cell.checkBox.checked = self.tempTask.isCompleted;
        cell.textField.textColor = self.tempTask.isCompleted?[UIColor lightGrayColor]:[UIColor blackColor];
        
        cell.textField.frame = CGRectMake(35, 12, cell.frame.size.width - 60 - 20, 25);
        cell.textField.tag = TASK_TITLE_TEXT_FIELD_TAG;
        self.titleField = cell.textField;
        
        cell.textField.text = self.tempTask.title;
                
    } else if(indexPath.row == 1){
        cell = (GTableViewCell *)[tableView dequeueReusableCellWithIdentifier:kListChooseCellIndentifier];
        if(cell == nil) {
            cell = [[[GTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:kListChooseCellIndentifier] autorelease];
            cell.textLabel.text = NSLocalizedString(@"Due Date", @"Due Date");
            cell.textLabel.font = [UIFont systemFontOfSize:14];
            cell.textLabel.textColor = [UIColor lightGrayColor];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
            cell.textField.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            cell.textField.font = [UIFont boldSystemFontOfSize:17];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.textField.returnKeyType = UIReturnKeyDone;
            cell.textField.delegate = self;
            cell.textField.frame = cell.contentView.bounds;
            cell.textField.textAlignment = UITextAlignmentCenter;            
        
            cell.textField.alpha = 0.02;
            cell.detailTextLabel.frame = CGRectMake(80, 10, 240, 30);
            cell.detailTextLabel.textAlignment = UITextAlignmentCenter;    
            
            cell.textField.tag = TASK_DATE_FIELD_TAG;
        }
        
        self.dateField = cell.textField;
        self.dateLabel = cell.detailTextLabel;
    
        if (self.tempTask.due == nil || [self.tempTask.due timeIntervalSince1970] <= 0) {
            cell.detailTextLabel.text = NSLocalizedString(@"None",@"None");            //[self.tempTask.due locateTimeDescription];
       } else {
            cell.detailTextLabel.text = [self.tempTask.due locateTimeDescription];
        }
        
    } else if (indexPath.row == 2) {
        cell = (GTableViewCell *)[tableView dequeueReusableCellWithIdentifier:kDateChooseCellIndentifier];
        if(cell == nil) {
            cell = [[[GTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:kDateChooseCellIndentifier] autorelease];
            cell.textLabel.text = NSLocalizedString(@"List", @"List");

            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        cell.detailTextLabel.text = self.tempTask.list.title;

    } else if (indexPath.row == 3) {
        cell = (GTableViewCell *)[tableView dequeueReusableCellWithIdentifier:kTextViewCellIndentifier];
        if(cell == nil) {
            cell = [[[GTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:kTextViewCellIndentifier] autorelease];
            
            cell.textView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            
            cell.textView.font = [UIFont systemFontOfSize:17];
            cell.textView.scrollEnabled = NO;
        }
        cell.textView.delegate = self;
        cell.textView.frame = CGRectMake(0, 0, CGRectGetWidth(cell.bounds), CGRectGetHeight(cell.frame));
        cell.textView.placeholder = NSLocalizedString(@"Click here to edit", @"Click here to edit");

        cell.textView.text = self.tempTask.notes;
        self.textView = cell.textView;
        
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 1 ) {

        [self.dateField becomeFirstResponder];
        return;
    }
        if (!self.listChooseController) {
            self.listChooseController = [self.storyboard instantiateViewControllerWithIdentifier:@"kGListChoose"];
        }
        self.listChooseController.chooseDelegate = self;
        self.listChooseController.selectedList = self.tempTask.list;
        [self.navigationController pushViewController:self.listChooseController animated:YES];
}

#pragma mark -
#pragma mark UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField.tag == TASK_TITLE_TEXT_FIELD_TAG) {
        self.tempTask.title = textField.text;        
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField.tag == TASK_TITLE_TEXT_FIELD_TAG) {
        [textField endEditing:YES];        
    }

    return YES;
}

- (BOOL)textFieldMustReturn:(id)sender{
    [self.titleField resignFirstResponder];
    [self.dateField resignFirstResponder];
    return NO;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    
    self.firstResponder = textField;
    
    if (textField == self.titleField) {
        if (textField.inputAccessoryView == nil) {
            
        }

    } else if (textField == self.dateField) {
        textField.inputView = self.datePicker;
        [self updateDate:nil];
        
        if (textField.inputAccessoryView == nil) {
            
            UIToolbar *_actionBar = [[UIToolbar alloc] init];
            _actionBar.translucent = YES;
            [_actionBar sizeToFit];
            _actionBar.barStyle = UIBarStyleBlackTranslucent;
            
            
            
            UIBarButtonItem *clearButton = [[UIBarButtonItem alloc] initWithTitle:@"Clear"
                                                                            style:UIBarButtonItemStyleDone target:self
                                                                           action:@selector(clearDate)];
            
            
            UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                           style:UIBarButtonItemStyleDone target:self
                                                                          action:@selector(confirmDate)];
            
            UIBarButtonItem *flexible = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
            [_actionBar setItems:[NSArray arrayWithObjects:/*prevNextWrapper,*/clearButton, flexible, doneButton, nil]];
            
            textField.inputAccessoryView = _actionBar;
            
            [clearButton release];
            [doneButton release];
            [flexible release];
            [_actionBar release];        
        }
    }
    

    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    // Title 编辑完成
    
    self.firstResponder = nil;
    if (textField.tag == TASK_TITLE_TEXT_FIELD_TAG) {
        self.tempTask.title = textField.text;
        self.task.title = textField.text;

        if (self.type == TaskEditTypeAddNewTask) {
        
        } else if (self.type == TaskEditTypeModifyOldTask) {
            [self.task update];            
        }
    }
}



#pragma mark -
#pragma mark UITextViewDelegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    
    self.firstResponder = textView;
    
    if (textView.inputAccessoryView == nil) {
        
        UIToolbar *_actionBar = [[UIToolbar alloc] init];
        _actionBar.translucent = YES;
        [_actionBar sizeToFit];
        _actionBar.barStyle = UIBarStyleBlackTranslucent;
        
        
        
        UISegmentedControl *prevNext = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"Undo", @"Redo", nil]];
        prevNext.momentary = YES;
        prevNext.segmentedControlStyle = UISegmentedControlStyleBar;
        prevNext.tintColor = [UIColor darkGrayColor];
        [prevNext addTarget:self action:@selector(undoAction:) forControlEvents:UIControlEventValueChanged];
        _undoControl = prevNext;
        UIBarButtonItem *prevNextWrapper = [[UIBarButtonItem alloc] initWithCustomView:prevNext];
        
        
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                       style:UIBarButtonItemStyleDone target:textView
                                                                      action:@selector(resignFirstResponder)];
        
        UIBarButtonItem *flexible = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        [_actionBar setItems:[NSArray arrayWithObjects:prevNextWrapper, flexible, doneButton, nil]];
        
        textView.inputAccessoryView = _actionBar;
        
        [prevNext release];
        [doneButton release];
        [flexible release];
        [prevNextWrapper release];
        [_actionBar release];        
        
    }

    [self updateUndoButtons];

    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
//    [self.tableView beginUpdates];
//    [self.tableView endUpdates];   
    
}

- (void)textViewDidEndEditing:(UIPlaceHolderTextView *)textView{
    self.textView.bounds = self.textView.superview.bounds;
//    [self.tableView beginUpdates];
//    [self.tableView endUpdates];
    self.firstResponder = nil;

    self.tempTask.notes = textView.text;

    // UPDATE to DB
    if (self.type == TaskEditTypeAddNewTask) {
        self.task.notes = textView.text;
   
    } else if (self.type == TaskEditTypeModifyOldTask) {
        if (![self.task.notes isEqualToString:textView.text]) {
            self.task.notes = textView.text;
            [self.task update];                        
        }
    }
    

}

- (void)textViewDidChange:(UITextView *)textView {
    
    self.tempTask.notes = textView.text;
    self.textView.bounds = self.textView.superview.bounds;
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    
    [self updateUndoButtons];
}

- (void)addCancelAndDoneItems {
    UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", @"Cancel") style:UIBarButtonItemStylePlain target:self action:@selector(cancelAction:)];
    [self.navigationItem setLeftBarButtonItem:cancelItem animated:YES];
    [cancelItem release];
    
    UIBarButtonItem *doneItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", @"Done") style:UIBarButtonItemStyleDone target:self action:@selector(doneAction:)];
    [self.navigationItem setRightBarButtonItem:doneItem animated:YES];
    [doneItem release];
}

- (void)removeItems {
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    [self.navigationItem setRightBarButtonItem:nil animated:YES];
}


// TODO, HOW TO HIDE UIMenuController 
// Hide cut/copy/paste menu
//- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
//
//    return NO;
//}


#pragma mark -
#pragma mark IBAction
- (void)cancelAction:(id)sender {

    if (self.type == TaskEditTypeAddNewTask) {
        [self.navigationController dismissModalViewControllerAnimated:YES];
    }
}

- (void)doneAction:(id)sender {
    if (self.type == TaskEditTypeAddNewTask) {
        /// SAVE THIS TASK;
        
        [self.navigationController dismissViewControllerAnimated:YES completion:^{
            if (!self.tempTask.title || self.tempTask.title.length == 0) {
                self.tempTask.title = NSLocalizedString(@"Untitled", @"Untitled");
            }

            self.tempTask.displayOrder = 0;
            self.tempTask.isUpdated = NO;
//            self.tempTask.isCompleted = NO;
            self.tempTask.localModifyTime = [NSDate date];
            self.tempTask.localParentId = -1;
            for (int i = 0; i < [self.tempTask.list.tasks count]; i++) {
                Task *e = [self.tempTask.list.tasks objectAtIndex:i];
                [e setDisplayOrder:i+1 updateDB:YES];
            }
            
            [self.tempTask.list insertTask:self.tempTask];

            if([self.editDelegate respondsToSelector:@selector(editControllerDidAddNewTask:)]) {
                [self.editDelegate editControllerDidAddNewTask:self];
            }
            
        }];
    }
}

- (void)undoAction:(UISegmentedControl *)sender {
    if (sender.selectedSegmentIndex == 0) {
        [self.textView.undoManager undo];       // Undo
    } else {
        [self.textView.undoManager redo];       // Redo
    }
    
    [self updateUndoButtons];
}

- (void)updateDate:(id)sender {
    self.tempTask.due = self.datePicker.date;
    self.dateLabel.text = [self.tempTask.due locateTimeDescription];
}

- (void)updateUndoButtons {
    [_undoControl setEnabled:[self.textView.undoManager canUndo] forSegmentAtIndex:0];
    [_undoControl setEnabled:[self.textView.undoManager canRedo] forSegmentAtIndex:1];
}


- (UIDatePicker *)datePicker {
    if (_datePicker == nil) {
        _datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 480, self.tableView.frame.size.width, 216)];
        
        if (self.tempTask.due == nil || [self.tempTask.due timeIntervalSince1970] <= 0) {
            _datePicker.date = [NSDate date];
        } else {
            _datePicker.date = self.tempTask.due;
        }

        _datePicker.datePickerMode = UIDatePickerModeDate;
        _datePicker.timeZone = [NSTimeZone localTimeZone];
        _datePicker.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
        [self.view addSubview:_datePicker];
        [_datePicker addTarget:self action:@selector(updateDate:) forControlEvents:UIControlEventValueChanged];
        
    }
    return _datePicker;
}

- (void)setDatePicker:(UIDatePicker *)datePicker {
    if (_datePicker != datePicker) {
        [_datePicker release];
        _datePicker = [datePicker retain];
    }
}

- (void)clearDate {
    self.tempTask.due = nil;
    self.dateLabel.text = @"";
    [self.dateField endEditing:YES];
    
    if (self.type == TaskEditTypeAddNewTask) {
        
    } else if (self.type == TaskEditTypeModifyOldTask) {
        self.task.due = nil;
        [self.task update];
    }

    
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)confirmDate {
    [self.titleField endEditing:YES];
    [self.dateField endEditing:YES];
    self.tempTask.due = self.datePicker.date;
    self.task.due = self.datePicker.date;
    
    if (self.type == TaskEditTypeAddNewTask) {
        
    } else if (self.type == TaskEditTypeModifyOldTask) {
        [self.task update];
    }

}

- (void)saveTask {
    
}


#pragma mark - 
#pragma mark - GListChooseDelegate
- (void)listChooseController:(GListChooseController *)listController didChooseList:(TaskList *)aList {
    // move from old list to new list
    if (self.type == TaskEditTypeAddNewTask) {
        self.tempTask.list = aList;        
    } else if (self.type == TaskEditTypeModifyOldTask) {
        self.tempTask.list = aList;
        if (self.tempTask.list != self.task.list) {
            [self.task.list moveTaskWithSubTasks:self.task toList:self.tempTask.list];
            self.task.list = self.tempTask.list;
        }
    }
    [self.navigationController popToViewController:self animated:YES];
    [self.tableView reloadData];
}


#pragma mark -
#pragma mark Setter And Getter
- (Task *)tempTask {
    return _tempTask;
}

- (void)setTempTask:(Task *)aTask {
        [_tempTask release];
        _tempTask = [aTask copy];        
}

@end
