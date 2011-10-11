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
#import "GTaskEngine.h"
#import "GTableViewCell.h"

@interface RWDetailViewController ()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
- (void)configureView;
- (void)reloadRowsAtIndexPaths:(NSArray *)indexPaths;
@end

@implementation RWDetailViewController

@synthesize detailItem = _detailItem;
@synthesize detailDescriptionLabel = _detailDescriptionLabel;
@synthesize tableView = _tableView;
@synthesize masterPopoverController = _masterPopoverController;
@synthesize tasks = _tasks;
@synthesize taskList = _taskList;
@synthesize editViewController = _editViewController;

- (void)dealloc
{
    [_detailItem release];
    [_detailDescriptionLabel release];
    [_tableView release];
    [_masterPopoverController release];
    [_tasks release];
    [_taskList release];
    [_editViewController release];
    [super dealloc];
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
	// Do any additional setup after loading the view, typically from a nib.
    [self configureView];    
    self.tableView.editing = YES;
    self.tableView.allowsSelectionDuringEditing = YES;
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIndentifier];
    if(cell == nil) {
        cell = [[[GTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kCellIndentifier] autorelease];
    }
    
    Task *task = [self.tasks objectAtIndex:indexPath.row];
    
    
    NSArray *subTasks = [task allDescendantsAtTasks:self.tasks];
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:task.serverModifyTime];

    cell.textLabel.text = [NSString stringWithFormat:@"%d - %@ ",[subTasks count],task.title];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"order:%d id: %d parent :%d  - %@", task.displayOrder,task.localTaskId,task.localParentId,[date description]];
    //cell.detailTextLabel.text = task.serverTaskId;
    return cell;
}




// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleNone;
}


- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath {
/*
    Task *task = [self.tasks objectAtIndex:indexPath.row];
    if (task.localParentId == -2 ||task.localParentId == -2 ) {
        return 0;
    } else if (indexPath.row > 0) {
        Task *task_ = [self.tasks objectAtIndex:indexPath.row -1];
        NSIndexPath *preIndexPath = [NSIndexPath indexPathForRow:(indexPath.row - 1) inSection:indexPath.section];
        if (task.localParentId == task_.localParentId) {
            return [self tableView:tableView indentationLevelForRowAtIndexPath:preIndexPath];
        } else if(task.localParentId == task_.localTaskId) {
            return [self tableView:tableView indentationLevelForRowAtIndexPath:preIndexPath] + 1;
        } else {
            return 0;
        }
    } else {
        return 0;
    }
*/
    Task *task = [self.tasks objectAtIndex:indexPath.row];
    Task *parent = [task parentTaskAtTasks:self.tasks];
    if (task.localParentId == -2 ||task.localParentId == -1 ) {
        return 0;
    } else if(parent && [self.tasks containsObject:parent]) {
        NSInteger parentIndex = [self.tasks indexOfObject:parent];
        NSIndexPath *parentIndexPath = [NSIndexPath indexPathForRow:parentIndex inSection:indexPath.section];
        return [self tableView:tableView indentationLevelForRowAtIndexPath:parentIndexPath] + 1;
    } else {
        return 0;
    }

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (!self.editViewController) {
        self.editViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"kGEditViewController"];
    }
    NIF_INFO(@"%@", self.editViewController);
    self.editViewController.task = [self.tasks objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:self.editViewController animated:YES];
}

//
//
//
//// Override to support editing the table view.
//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if (editingStyle == UITableViewCellEditingStyleDelete) {
//        // Delete the row from the data source.
//        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
//    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
//        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
//    }   
//}


// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    
    [[GTaskEngine engine]moveTaskAtIndex:fromIndexPath.row toIndex:toIndexPath.row forTasks:self.tasks];
    [self performSelector:@selector(reloadRowsAtIndexPaths:) withObject:[tableView indexPathsForVisibleRows] afterDelay:0.3];
}

- (void)reloadRowsAtIndexPaths:(NSArray *)indexPaths {
    [self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
}

// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}

#pragma mark -
#pragma mark Swipe
- (BOOL)tableView:(UITableView *)tableView shouldSwipeCellAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}

- (void)tableView:(UITableView *)tableView didSwipeCellAtIndexPath:(NSIndexPath *)indexPath direction:(UISwipeGestureRecognizerDirection) direction{
    NIF_INFO(@"%@ -- %d",indexPath,direction);
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    if (direction == UISwipeGestureRecognizerDirectionLeft) {
        if([[GTaskEngine engine] upgradeTaskLevel:TaskUpgradeLevelUpLevel atIndex:indexPath.row forTasks:self.tasks]){
            cell.indentationLevel--;   
            [self.tableView reloadData];
        }
    } else if(direction == UISwipeGestureRecognizerDirectionRight) {
        if([[GTaskEngine engine] upgradeTaskLevel:TaskUpgradeLevelDownLevel atIndex:indexPath.row forTasks:self.tasks]) {
            cell.indentationLevel++;            
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


@end
