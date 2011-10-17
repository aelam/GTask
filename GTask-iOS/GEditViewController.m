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

@implementation GEditViewController

@synthesize task = _task;
@synthesize titleLabel = _titleLabel;
@synthesize tempTask = _tempTask;
@synthesize textView = _textView;
@synthesize textViewHeight = _textViewHeight;

- (void)dealloc {
    [_task release];
    [_tempTask release];
    [_titleLabel release];
    [_textView release];
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
        
    self.titleLabel.text = self.task.title;
    NIF_INFO(@"%@", self.task);
    [self.tableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
//    self.navigationItem.rightBarButtonItem = self.editButtonItem;

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

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    [self.tableView setEditing:editing animated:animated];
    
    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < 3) {
        return 44;
    } else {
//        return CGRectGetHeight(self.tableView.frame) - 3 * 44;
        return [self textViewHeight];
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
            cell.textField.placeholder = NSLocalizedString(@"Headline", @"Headline");
            cell.textField.font = [UIFont boldSystemFontOfSize:17];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        cell.textField.frame = CGRectMake(5, 11, CGRectGetWidth(cell.bounds) - 7, CGRectGetHeight(cell.frame)-5);
        cell.textLabel.textColor = [UIColor lightGrayColor];
        cell.detailTextLabel.textAlignment = UITextAlignmentLeft;
        
        cell.textField.text = self.tempTask.title;
                
    } else if(indexPath.row == 1){
        cell = (GTableViewCell *)[tableView dequeueReusableCellWithIdentifier:kListChooseCellIndentifier];
        if(cell == nil) {
            cell = [[[GTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:kListChooseCellIndentifier] autorelease];
            
            cell.textField.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            cell.textField.placeholder = NSLocalizedString(@"Headline", @"Headline");
            cell.textField.font = [UIFont boldSystemFontOfSize:17];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
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
}
        
        cell.textField.frame = CGRectMake(5, 11, CGRectGetWidth(cell.bounds) - 7, CGRectGetHeight(cell.frame)-5);
        cell.textField.text = self.tempTask.title;

    } else if (indexPath.row == 3) {
        cell = (GTableViewCell *)[tableView dequeueReusableCellWithIdentifier:kTextViewCellIndentifier];
        if(cell == nil) {
            cell = [[[GTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:kTextViewCellIndentifier] autorelease];
            
            cell.textView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            
            cell.textView.font = [UIFont systemFontOfSize:17];
            cell.textView.delegate = self;
            cell.textView.scrollEnabled = NO;
        }
        cell.textView.frame = CGRectMake(0, 0, CGRectGetWidth(cell.bounds), CGRectGetHeight(cell.frame));
        cell.textView.placeholder = NSLocalizedString(@"Click here to edit", @"Click here to edit");
        cell.textView.backgroundColor = [UIColor greenColor];

        cell.textView.text = self.tempTask.notes;
        self.textView = cell.textView;
        
    }
    
    
    return cell;
}

- (void)textViewDidChange:(UITextView *)textView {
    self.tempTask.notes = textView.text;
    UITableViewCell *cell = (UITableViewCell *)[self.textView superview];
    [cell layoutSubviews];
    
    [self textViewHeight];
}


- (float) textViewHeight {
    NSString *content = self.tempTask.notes;    
    if (content) {
        CGSize contentSize = [content sizeWithFont:[UIFont systemFontOfSize:17] constrainedToSize:CGSizeMake(CGRectGetWidth(self.tableView.frame), 10000)];
        UITableViewCell *cell = (UITableViewCell *)[self.textView superview];
        NIF_INFO(@"%@", cell);
        if (contentSize.height > CGRectGetHeight(cell.frame)) {
            cell.frame = CGRectMake(0, 0, CGRectGetWidth(cell.bounds), CGRectGetHeight(cell.frame));            
            _textViewHeight = contentSize.height;
        } else {
            _textViewHeight = CGRectGetHeight(self.tableView.frame) - 44 * 3;
        }
    } else {
        _textViewHeight = CGRectGetHeight(self.tableView.frame) - 44 * 3;
    }
    return _textViewHeight;
}

- (void)setTextViewHeight:(float)textViewHeight {
    NSString *content = self.tempTask.notes;    
    if (content) {
        CGSize contentSize = [content sizeWithFont:[UIFont systemFontOfSize:17] constrainedToSize:CGSizeMake(CGRectGetWidth(self.tableView.frame), 10000)];
        UITableViewCell *cell = (UITableViewCell *)[self.textView superview];
        NIF_INFO(@"%@", cell);
        if (contentSize.height > CGRectGetHeight(cell.frame)) {
            cell.frame = CGRectMake(0, 0, CGRectGetWidth(cell.bounds), CGRectGetHeight(cell.frame));            
            _textViewHeight = contentSize.height;
        } else {
            _textViewHeight = CGRectGetHeight(self.tableView.frame) - 44 * 3;
        }
    } else {
        _textViewHeight = CGRectGetHeight(self.tableView.frame) - 44 * 3;
    }    
}


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
