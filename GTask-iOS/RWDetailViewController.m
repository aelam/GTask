//
//  RWDetailViewController.m
//  GTask-iOS
//
//  Created by ryan on 11-9-19.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "RWDetailViewController.h"
#import "GEditViewController.h"
#import "Task.h"
#import "TaskList.h"
#import "GTaskEngine.h"
#import "GTableViewCell.h"
#import "NSObject+Runtime.h"
#import "UICheckBox.h"

@interface RWDetailViewController ()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
- (void)configureView;
- (void)reloadRowsAtIndexPaths:(NSArray *)indexPaths;
- (void)updateEditStatuItem;
@end

@implementation RWDetailViewController

@synthesize detailItem = _detailItem;
@synthesize detailDescriptionLabel = _detailDescriptionLabel;
@synthesize tableView = _tableView;
@synthesize masterPopoverController = _masterPopoverController;
@synthesize tasks = _tasks;
@synthesize taskList = _taskList;
@synthesize editViewController = _editViewController;
@synthesize editStatus = _editStatus;
@synthesize statusItem = _statusItem;
@synthesize quickInputField = _quickInputField;

- (void)dealloc
{
    [_detailItem release];
    [_detailDescriptionLabel release];
    [_tableView release];
    [_masterPopoverController release];
    [_tasks release];
    [_taskList release];
    [_editViewController release];
    [_statusItem release];
    [_quickInputField release];
    [super dealloc];
}

- (void)awakeFromNib {
}


#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        [_detailItem release]; 
        _detailItem = [newDetailItem retain]; 

        // Update the view.
        [self configureView];
    }

    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }        
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    [self.tableView setEditing:editing animated:animated];
    
    [self.navigationItem setRightBarButtonItem:editing?self.editButtonItem:nil animated:YES];
}

- (void)configureView
{
    // Update the user interface for the detail item.

    if (self.detailItem) {
        self.detailDescriptionLabel.text = [self.detailItem description];
    }
    if (!self.tableView) {
        UITableView *aTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];
        aTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        aTableView.delegate = self;
        aTableView.dataSource = self;
        self.tableView = aTableView;
        [self.view addSubview:self.tableView];

        [aTableView release];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self configureView];    

    self.editStatus = EditStatusMoving;    
    [self updateEditStatuItem];

    self.tableView.editing = YES;
    self.tableView.allowsSelectionDuringEditing = YES;
    
    self.quickInputField.placeholder = NSLocalizedString(@"Quick Input", @"Quick Input");
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    self.tasks = [[GTaskEngine engine] localTasksForList:self.taskList];
    [self.tableView reloadData];
    if (!self.tasks) {
        [[GTaskEngine engine] fetchServerTasksForList:self.taskList resultHander:^(GTaskEngine *engine, NSMutableArray *result) {
            self.tasks = result;
            [self.tableView reloadData];
        }];
    }

//    NIF_INFO(@"%@",self.tasks);
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.tasks count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *kCellIndentifier = @"kCellIndentifier";
    
    GTableViewCell *cell = (GTableViewCell *)[tableView dequeueReusableCellWithIdentifier:kCellIndentifier];
    if(cell == nil) {
        cell = [[[GTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kCellIndentifier] autorelease];
        cell.checkBox.checked = NO;
        cell.firstLabel.font = [UIFont boldSystemFontOfSize:15];
    }
    
    Task *task = [self.tasks objectAtIndex:indexPath.row];

    [cell.checkBox handleCheckEventWithBlock:^{
        
        [task setIsCompleted:!task.isCompleted updateDB:YES];
        cell.checkBox.checked = task.isCompleted;
        cell.firstLabel.textColor = task.isCompleted?[UIColor lightGrayColor]:[UIColor blackColor];
    }];
            
    task.generationLevel = [task generationLevelAtTasks:self.tasks];
    cell.checkBox.frame = CGRectMake(10 + 20 *task.generationLevel, 7, 20, 20);
    cell.firstLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    cell.firstLabel.frame = CGRectMake(44 + 20 *task.generationLevel, 5, cell.frame.size.width - 60 - 20 *task.generationLevel, 20);
    
    cell.checkBox.checked = task.isCompleted;
    cell.firstLabel.textColor = task.isCompleted?[UIColor lightGrayColor]:[UIColor blackColor];
    
    NSArray *subTasks = [task allDescendantsAtTasks:self.tasks];
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:task.serverModifyTime];

    cell.firstLabel.text = [NSString stringWithFormat:@"%d - %@ ",[subTasks count],task.title];
//    cell.detailTextLabel.text = [NSString stringWithFormat:@"order:%d id: %d parent :%d  - %@", task.displayOrder,task.localTaskId,task.localParentId,[date description]];
    
    return cell;
}




// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.editStatus == EditStatusMoving || self.editStatus == EditStatusNone) {
        return NO;
    } else if (self.editStatus == EditStatusDeleting) {
        return YES;        
    } else {
        return NO;
    }
}

- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath {
    Task *task = [self.tasks objectAtIndex:indexPath.row];
    
    task.generationLevel = [task generationLevelAtTasks:self.tasks];
    return task.generationLevel * 2;    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (!self.editViewController) {
        self.editViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"kGEditViewController"];
    }

    self.editViewController.task = [self.tasks objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:self.editViewController animated:YES];
}


- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath {
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:sourceIndexPath];
    cell.textLabel.backgroundColor = [UIColor redColor];
    
    Task *fromTask = [self.tasks objectAtIndex:sourceIndexPath.row];
    Task *toTask = [self.tasks objectAtIndex:proposedDestinationIndexPath.row];
    NSArray *fromSubtasks = [fromTask allDescendantsAtTasks:self.tasks];
    
    if (sourceIndexPath.row >=  proposedDestinationIndexPath.row) { //**上移**
        return proposedDestinationIndexPath;
    } else {    // **下移**
        if ([fromSubtasks containsObject:toTask]) {
            NSInteger targetIndex = [fromTask nextSiblingOrUncleIndexAtTask:self.tasks];
            if (targetIndex != -1 && targetIndex != 0) {
                NSIndexPath *supportedIndexPath = [NSIndexPath indexPathForRow:targetIndex inSection:sourceIndexPath.section];
                // fixed a bug, when cell in supportedIndexPath is nil, it would raise a exception of NSArray out of bound
                UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:supportedIndexPath];
                if (cell) {
                    return supportedIndexPath;
                } else {
                    return sourceIndexPath;                    
                }
            } else {
                return sourceIndexPath;
            }
        } else {
            return proposedDestinationIndexPath;
        }
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.editStatus == EditStatusDeleting) {
        return UITableViewCellEditingStyleDelete;
    } else {
        return UITableViewCellEditingStyleNone;
    }
}

- (void)tableView:(UITableView*)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    NIF_INFO();
}

- (void)tableView:(UITableView*)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    NIF_INFO();
}

//
//
//
//// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source.
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }   
}

// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    if ([fromIndexPath isEqual:toIndexPath]) {
        return;
    }

    [[GTaskEngine engine]moveTaskAtIndex:fromIndexPath.row toIndex:toIndexPath.row forTasks:self.tasks];
    [self performSelector:@selector(reloadRowsAtIndexPaths:) withObject:[tableView indexPathsForVisibleRows] afterDelay:0.3];
}

- (void)reloadRowsAtIndexPaths:(NSArray *)indexPaths {
    [self.tableView beginUpdates];
    [self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
}

// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.editStatus == EditStatusMoving) {
        return YES;        
    } else {
        return NO;
    }
}

#pragma mark -
#pragma mark Swipe
- (BOOL)tableView:(UITableView *)tableView shouldSwipeCellAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}

- (void)tableView:(UITableView *)tableView didSwipeCellAtIndexPath:(NSIndexPath *)indexPath direction:(UISwipeGestureRecognizerDirection) direction{
    if (direction == UISwipeGestureRecognizerDirectionLeft) {
        if([[GTaskEngine engine] upgradeTaskLevel:TaskUpgradeLevelUpLevel atIndex:indexPath.row forTasks:self.tasks]){
            [self.tableView reloadData];
        }
    } else if(direction == UISwipeGestureRecognizerDirectionRight) {
        if([[GTaskEngine engine] upgradeTaskLevel:TaskUpgradeLevelDownLevel atIndex:indexPath.row forTasks:self.tasks]) {
            [self.tableView reloadData];
        }
    }
}



#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"Master", @"Master");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

#pragma mark - 
#pragma mark UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    if (textField.text && textField.text.length) {
        [self addQuickTaskWithText:textField.text];
        textField.text = nil;        
    }
    return YES;
}

- (void)addQuickTaskWithText:(NSString *)text {
    
    Task *task = [[Task alloc] init];
    task.displayOrder = 0;
    task.localListId = self.taskList.localListId;
    task.isUpdated = NO;
    task.isCompleted = NO;
    task.localModifyTime = [[NSDate date] timeIntervalSince1970];
    task.localParentId = -1;
    task.title = text;
    
    for (int i = 0; i < [self.tasks count]; i++) {
        Task *e = [self.tasks objectAtIndex:i];
         [e setDisplayOrder:i+1 updateDB:YES];
    }
    
    [self.tasks insertObject:task atIndex:0];
    [[GTaskEngine engine] insertTask:task]; 
    [task release];
    
    [self.tableView beginUpdates];
    [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
    [self.tableView endUpdates];
}


- (IBAction)changeEditStatus:(UIBarButtonItem *)sender {
    _editStatus ++;
    if (_editStatus == 3) {
        _editStatus = EditStatusNone;
    }
    [self updateEditStatuItem];
}

- (void)updateEditStatuItem {
    switch (_editStatus) {
        case EditStatusNone:
            self.statusItem.title = NSLocalizedString(@"None", @"None");
            [self setEditing:NO animated:YES];            
            break;
        case EditStatusDeleting:
            self.statusItem.title = NSLocalizedString(@"Delete", @"Delete");
            [self setEditing:NO animated:NO];            
            [self setEditing:YES animated:YES];            
            break;
        case EditStatusMoving:
            self.statusItem.title = NSLocalizedString(@"Move", @"Move");
            [self setEditing:YES animated:YES];            
            break;
        default:
            break;
    }

}

@end
