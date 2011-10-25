 //
//  GEditViewController.m
//  GTask-iOS
//
//  Created by Ryan Wang on 11-10-9.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "GEditViewController.h"
#import "Task.h"
#import "GTableViewCell.h"
#import "NSObject+Runtime.h"
#import "UIPlaceHolderTextView.h"
#import "NSDate+RFC3339.h"
#import "UICheckBox.h"
#import "GListChooseController.h"
#import "TaskList.h"

@interface GEditViewController (Plus)

- (void)addCancelAndDoneItems;
- (void)removeItems;
- (void)hideKeyboard:(id)sender;
- (void)appendToolbarAboveKeyboard:(UIView *)keyboard;
- (void)updateUndoButtons;

- (void)showDatePicker;
- (void)hideDatePicker;

@end

#define TASK_TITLE_TEXT_FIELD_TAG   10101


@implementation GEditViewController

@synthesize task = _task;
@synthesize titleLabel = _titleLabel;
@synthesize tempTask = _tempTask;
@synthesize textView = _textView;
@synthesize textViewHeight = _textViewHeight;
@synthesize titleField = _titleField;
@synthesize tableView = _tableView;
@synthesize undoButton = _undoButton;
@synthesize redoButton = _redoButton;
@synthesize datePicker = _datePicker;
@synthesize pickedDate = _pickedDate;
//@synthesize taskLists = _taskLists;
@synthesize listChooseController = _listChooseController;

- (void)dealloc {
    
    [_task release];
    [_tempTask release];
    [_titleLabel release];
    [_textView release];
    [_titleField release];
    [_pickedDate release];
//    [_taskLists release];
    [_listChooseController release];
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
    NIF_INFO(@"%@", self.task);

    [self.tableView reloadData];
    
    isKeyboardHidden = YES;
    isPickerShown = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardWillHideNotification object:nil];    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    [self hideKeyboard:nil];
    [self hideDatePicker];
}

- (void)viewDidLoad
{
    [super viewDidLoad];    
//    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (isPickerShown) {
        
        [self.tableView beginUpdates];
        [self.tableView endUpdates];
        self.datePicker.frame = CGRectMake(0, CGRectGetMaxY(self.view.frame) - 216, self.view.frame.size.width, 216);
    }
    
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
        NSInteger height = CGRectGetHeight(self.tableView.frame) - 3 * 40;
        NSString *content = self.tempTask.notes;    
        if (content && content.length) {
            CGSize contentSize = [content sizeWithFont:[UIFont systemFontOfSize:17] constrainedToSize:CGSizeMake(CGRectGetWidth(self.tableView.frame), 10000)];
            if (contentSize.height  + 40 > height) {
                return contentSize.height + 40;
            } else {
                return height;
            }
        }
        return height > 130?height:130;
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
//            UIButton *dateButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//            dateButton.frame = CGRectMake(80, 5, 200, 30);
//            dateButton.tag = 101010;
//            [cell.contentView addSubview:dateButton];
        }
        
//        UIButton *dateButton = (UIButton *)[self.tableView viewWithTag:101010];
//        [dateButton setTitle:[self.pickedDate locateTimeDescription] forState:UIControlStateNormal];
        cell.detailTextLabel.text = [self.pickedDate locateTimeDescription];
        
    } else if (indexPath.row == 2) {
        cell = (GTableViewCell *)[tableView dequeueReusableCellWithIdentifier:kDateChooseCellIndentifier];
        if(cell == nil) {
            cell = [[[GTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:kDateChooseCellIndentifier] autorelease];
            cell.textLabel.text = NSLocalizedString(@"List", @"List");
//            cell.textLabel.textColor = [UIColor lightGrayColor];
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
    
    if (indexPath.row == 1 && !isPickerShown) {
        [self showDatePicker];
    } else if(indexPath.row == 2) {
        if (!self.listChooseController) {
            self.listChooseController = [self.storyboard instantiateViewControllerWithIdentifier:@"kGListChoose"];
        }
        self.listChooseController.chooseDelegate = self;
        self.listChooseController.selectedList = self.tempTask.list;
        [self.navigationController pushViewController:self.listChooseController animated:YES];
    }
}

#pragma mark -
#pragma mark UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    BOOL isHidden = self.navigationController.navigationBarHidden;
    [self.navigationController setNavigationBarHidden:YES animated:!isHidden];        
    [self addCancelAndDoneItems];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self removeItems];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField.tag == TASK_TITLE_TEXT_FIELD_TAG) {
        self.tempTask.title = textField.text;        
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self hideKeyboard:textField];
    return YES;
}


#pragma mark -
#pragma mark UITextViewDelegate
- (void)textViewDidBeginEditing:(UIPlaceHolderTextView *)textView {
    [self.navigationController setNavigationBarHidden:YES animated:!self.navigationController.navigationBarHidden];        
    [self addCancelAndDoneItems];
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    [UIView beginAnimations:nil context:NULL];
    self.textView.bounds = self.textView.superview.bounds;
    [UIView commitAnimations];
}

- (void)textViewDidEndEditing:(UIPlaceHolderTextView *)textView{
    [self removeItems];
    self.textView.bounds = self.textView.superview.bounds;
    [self.tableView beginUpdates];
    [self.tableView endUpdates];

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
    [self.navigationItem setLeftBarButtonItem:cancelItem animated:NO];
    [cancelItem release];
    
    UIBarButtonItem *doneItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", @"Done") style:UIBarButtonItemStyleDone target:self action:@selector(doneAction:)];
    [self.navigationItem setRightBarButtonItem:doneItem animated:YES];
    [doneItem release];
}

- (void)removeItems {
    [self.navigationItem setLeftBarButtonItem:nil animated:NO];
    [self.navigationItem setRightBarButtonItem:nil animated:YES];
}


#pragma mark -
#pragma mark IBAction
- (void)cancelAction:(id)sender {
    [self hideKeyboard:sender];
}

- (void)doneAction:(id)sender {
    [self hideKeyboard:sender];
}

- (void)hideKeyboard:(id)sender {
    isKeyboardHidden = YES;
    
    [self.titleField resignFirstResponder];
    [self.textView resignFirstResponder];    
    [self.navigationController setNavigationBarHidden:NO animated:YES];        
}

- (void)undoAction:(UIButton *)sender {
    [self.textView.undoManager undo];
    [self updateUndoButtons];
}

- (void)redoAction:(UIButton *)sender {
    [self.textView.undoManager redo];
    [self updateUndoButtons];
}

#pragma mark -
#pragma mark keyboard Notification
- (void)keyboardDidShow:(NSNotification *)note
{
    [self hideDatePicker];
    
    NSDictionary *info = [note userInfo];    
    NSValue *keyBounds = [info objectForKey:UIKeyboardFrameBeginUserInfoKey];
    
    CGRect bndKey;
    [keyBounds getValue:&bndKey];
        
    
    NSArray *windows = [[UIApplication sharedApplication] windows];
    for(UIView *tempWindow in windows) {
        for(int i = 0; i < [tempWindow.subviews count]; i++)
        {
            //Get a reference of the current view 
            UIView *keyboard = [tempWindow.subviews objectAtIndex:i];
            
            if([[keyboard description] hasPrefix:@"<UIPeripheralHostView"] == YES)
            {
                [self appendToolbarAboveKeyboard:keyboard];

                bndKey = keyboard.frame;
                
                [UIView animateWithDuration:0.2 animations:^{
                    CGRect oldFrame = self.tableView.frame;
                    self.tableView.frame = CGRectMake(CGRectGetMinX(oldFrame), CGRectGetMinY(oldFrame),bndKey.size.width, CGRectGetMinY(bndKey)-60); 
                }];

            }
        }
    }    
}

- (void)keyboardDidHide:(NSNotification *)note {
    isKeyboardHidden = YES;
    self.tableView.frame = self.view.frame;
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}


#pragma mark - 
#pragma mark ToolBar above keyboard
- (void)appendToolbarAboveKeyboard:(UIView *)keyboard {
    
    UIView *toolbar = [[UIView alloc] initWithFrame:CGRectMake(0, -40, keyboard.frame.size.width, 40)];
    toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth |UIViewAutoresizingFlexibleBottomMargin;
    toolbar.backgroundColor = RGB_COLOR(223,223,227);
    
    // Undo Button
    _undoButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _undoButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    _undoButton.frame = CGRectMake(5, 5, 50, 30);
    [_undoButton setTitle:@"undo" forState:UIControlStateNormal];
    [_undoButton addTarget:self action:@selector(undoAction:) forControlEvents:UIControlEventTouchUpInside];
    [toolbar addSubview:_undoButton];
    
    // Redo Button
    _redoButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _redoButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    _redoButton.frame = CGRectMake(60, 5, 60, 30);
    [_redoButton setTitle:@"redo" forState:UIControlStateNormal];
    [_redoButton addTarget:self action:@selector(redoAction:) forControlEvents:UIControlEventTouchUpInside];
    [toolbar addSubview:_redoButton];

    [self updateUndoButtons];
    
    // Hide Keyboard Button
    UIButton *hideKeyboardButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    hideKeyboardButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
    hideKeyboardButton.frame = CGRectMake(CGRectGetWidth(toolbar.frame) - 80, 5, 60, 30);
    [hideKeyboardButton setTitle:@"Hide" forState:UIControlStateNormal];
    [hideKeyboardButton addTarget:self action:@selector(hideKeyboard:) forControlEvents:UIControlEventTouchUpInside];
    [toolbar addSubview:hideKeyboardButton];
    
    [keyboard addSubview:toolbar];
    [toolbar release];
    
//    [UIView commitAnimations];

}

- (void)updateUndoButtons {
    _undoButton.enabled =[self.textView.undoManager canUndo];
    _redoButton.enabled = [self.textView.undoManager canRedo];
}

- (void)updateDate:(id)sender {
    self.pickedDate = self.datePicker.date;
//    UIButton *dateButton = (UIButton *)[self.tableView viewWithTag:101010];
//    [dateButton setTitle:[self.pickedDate locateTimeDescription] forState:UIControlStateNormal];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
}

- (UIDatePicker *)datePicker {
    if (_datePicker == nil) {
        _datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 480, self.tableView.frame.size.width, 216)];
        
        _datePicker.datePickerMode = UIDatePickerModeDateAndTime;
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

- (void)showDatePicker {
    [self hideKeyboard:nil];
    CGRect oldFrame = self.tableView.frame;
    self.navigationController.toolbarHidden = YES;
    
    self.datePicker.frame = CGRectMake(0, 480, CGRectGetWidth(self.tableView.frame), 216);

    self.tableView.frame = CGRectMake(0,0,CGRectGetWidth(self.view.frame), 216);
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    
    [UIView beginAnimations:nil context:NULL];
    self.datePicker.frame = CGRectMake(CGRectGetMinX(oldFrame), self.view.frame.size.height - 216, self.view.frame.size.width, 216);
    [UIView commitAnimations];
    
    isPickerShown = YES;
    
    UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(hideDatePicker)];
    [self.navigationItem setRightBarButtonItem:cancelItem animated:YES];
}

- (void)hideDatePicker {
    self.navigationController.toolbarHidden = NO;
    [self.navigationItem setRightBarButtonItem:nil animated:YES];
    isPickerShown = NO;
    self.tableView.frame = self.view.frame;
    [self.tableView beginUpdates];
    [self.tableView endUpdates];

    [UIView beginAnimations:nil context:NULL];
    self.datePicker.frame = CGRectMake(0, 480, CGRectGetWidth(self.datePicker.frame), CGRectGetHeight(self.datePicker.frame));
    [UIView commitAnimations];

}

#pragma mark - 
#pragma mark 
- (void)listChooseController:(GListChooseController *)listController didChooseList:(TaskList *)aList {
    self.tempTask.list = aList;
    [self.navigationController popToViewController:self animated:YES];
    [self.tableView reloadData];
}


#pragma mark -
#pragma mark Setter And Getter
- (Task *)tempTask {
    if (_tempTask == nil) {
        _tempTask = [self.task copy];
    }
    return _tempTask;
}

- (void)setTempTask:(Task *)aTask {
    if (_tempTask != aTask) {
        [_tempTask release];
        _tempTask = [aTask copy];        
    }
}

@end
