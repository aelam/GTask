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
#import "NSDate+RFC3339.h"

@implementation GEditViewController

@synthesize task = _task;
@synthesize titleLabel = _titleLabel;
@synthesize tempTask = _tempTask;

- (void)dealloc {
    [_task release];
    [_tempTask release];
    [_titleLabel release];
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
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < 3) {
        return 44;
    } else {
        return 55;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *kCellIndentifier = @"kTextFieldCellIndentifier";
    static NSString *kTextViewCellIndentifier = @"kTextViewCellIndentifier";
    
    
//    static char hashKey;
    
    GTableViewCell *cell = (GTableViewCell *)[tableView dequeueReusableCellWithIdentifier:kCellIndentifier];
    if(cell == nil) {
        cell = [[[GTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:kCellIndentifier] autorelease];
                

        cell.textField.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        cell.textField.placeholder = NSLocalizedString(@"Headline", @"Headline");
        cell.textField.font = [UIFont systemFontOfSize:17];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    cell.textField.frame = CGRectMake(5, 11, CGRectGetWidth(cell.bounds) - 7, CGRectGetHeight(cell.frame)-5);
    cell.textLabel.textColor = [UIColor lightGrayColor];
    cell.detailTextLabel.textAlignment = UITextAlignmentLeft;


    switch (indexPath.row) {
        case 0:
            //cell.textLabel.text = NSLocalizedString(@"title", @"title");
            //cell.detailTextLabel.text = self.task.title;        
            cell.textField.text = self.tempTask.title;
            break;
        case 1:
            //cell.textLabel.text = NSLocalizedString(@"due", @"due");
            //cell.detailTextLabel.text = [[NSDate dateWithTimeIntervalSince1970:self.task.due]locateTimeDescriptionWithFormatter:@"yyyy-MM-dd"];
            break;
        case 2:
            //cell.textLabel.text = NSLocalizedString(@"title", @"title");
            break;
        case 3:
            //cell.textLabel.text = NSLocalizedString(@"title", @"title");
            break;
        default:
            break;
    }
    
    
    return cell;
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
