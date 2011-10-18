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

@interface GEditViewController (Plus)

- (void)addCancelAndDoneItems;
- (void)removeItems;
- (void)hideKeyboard:(id)sender;

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

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    [_task release];
    [_tempTask release];
    [_titleLabel release];
    [_textView release];
    [_titleField release];
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
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardWillHideNotification object:nil];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
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
            
            cell.textField.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            cell.textField.placeholder = NSLocalizedString(@"Add title", @"Add title");
            cell.textField.font = [UIFont boldSystemFontOfSize:17];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.textField.delegate = self;
        }
        
        cell.textField.frame = CGRectMake(5, 11, CGRectGetWidth(cell.bounds) - 7, CGRectGetHeight(cell.frame)-5);

        cell.textField.text = self.tempTask.title;

    } else if (indexPath.row == 2) {
        cell = (GTableViewCell *)[tableView dequeueReusableCellWithIdentifier:kDateChooseCellIndentifier];
        if(cell == nil) {
            cell = [[[GTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:kDateChooseCellIndentifier] autorelease];
            
            cell.textField.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            cell.textField.placeholder = NSLocalizedString(@"Headline", @"Headline");
            cell.textField.font = [UIFont boldSystemFontOfSize:17];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.textField.delegate = self;
        }
        
        cell.textField.frame = CGRectMake(5, 11, CGRectGetWidth(cell.bounds) - 7, CGRectGetHeight(cell.frame)-5);
        cell.textField.text = self.tempTask.title;

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
//        cell.textView.backgroundColor = [UIColor greenColor];

        cell.textView.text = self.tempTask.notes;
        self.textView = cell.textView;
        
    }
    return cell;
}

#pragma mark -
#pragma mark UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    NIF_INFO(@"self.navigationController.navigationBarHidden : %d", self.navigationController.navigationBarHidden);
    BOOL isHidden = self.navigationController.navigationBarHidden;
    [self.navigationController setNavigationBarHidden:YES animated:!isHidden];        
    [self addCancelAndDoneItems];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
//    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [self removeItems];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField.tag == TASK_TITLE_TEXT_FIELD_TAG) {
        self.tempTask.title = textField.text;        
    }
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
//    [self.titleField resignFirstResponder];
//    [self.textView resignFirstResponder];    
    [self hideKeyboard:sender];
}

- (void)doneAction:(id)sender {
//    [self.titleField resignFirstResponder];
//    [self.textView resignFirstResponder];
    [self hideKeyboard:sender];
}

- (void)hideKeyboard:(id)sender {
    [self.titleField resignFirstResponder];
    [self.textView resignFirstResponder];    
    [self.navigationController setNavigationBarHidden:NO animated:YES];        
}

- (void)keyboardDidShow:(NSNotification *)note
{
    NSDictionary *info = [note userInfo];
//    NSValue *keyBounds = [info objectForKey:UIKeyboardBoundsUserInfoKey];
    NSValue *keyBounds1 = [info objectForKey:UIKeyboardFrameBeginUserInfoKey];
    NSValue *keyBounds = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
        
    NIF_INFO(@"%@", keyBounds);
    NIF_INFO(@"%@", keyBounds1);
//    NIF_INFO(@"%@", keyBounds2);
    
    CGRect bndKey;
    [keyBounds getValue:&bndKey];
        
    
    NSArray *windows = [[UIApplication sharedApplication] windows];
    for(UIView *tempWindow in windows) {
        for(int i = 0; i < [tempWindow.subviews count]; i++)
        {
            //Get a reference of the current view 
            UIView *keyboard = [tempWindow.subviews objectAtIndex:i];
            NIF_INFO(@"%@", [keyboard description]);
            
            if([[keyboard description] hasPrefix:@"<UIPeripheralHostView"] == YES)
            {
//                [UIView beginAnimations:nil context:nil];
                UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, -40, keyboard.frame.size.width, 40)];
                UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Hide" style:UIBarButtonItemStyleBordered target:self action:@selector(hideKeyboard:)];
                NSArray *items = [[NSArray alloc] initWithObjects:barButtonItem, nil];
                [toolbar setItems:items];
                [items release];

                [keyboard addSubview:toolbar];
                bndKey = keyboard.frame;
            }
        }
    }
    
    [UIView animateWithDuration:0.2 animations:^{
        CGRect oldFrame = self.tableView.frame;
        self.tableView.frame = CGRectMake(CGRectGetMinX(oldFrame), CGRectGetMinY(oldFrame),bndKey.size.width, CGRectGetHeight(oldFrame) - MIN(CGRectGetHeight(bndKey), CGRectGetWidth(bndKey))); 
    }];
}

- (void)keyboardDidHide:(NSNotification *)note {
    self.tableView.frame = self.view.frame;
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
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
