//
//  RWMasterViewController.m
//  GTask-iOS
//
//  Created by ryan on 11-9-19.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "RWMasterViewController.h"
#import "RWDetailViewController.h"
#import "TaskList.h"
#import "GTaskEngine.h"
#import "GAddListController.h"


//MARK        TODO: add more such conditions to search tasks 


@implementation RWMasterViewController

@synthesize detailViewController = _detailViewController;
@synthesize taskLists = _taskLists;
@synthesize customCategories = _customCategories;

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        _customCategories = [[NSMutableArray alloc] initWithObjects:
                             NSLocalizedString(@"Today's Tasks", @"Today's Tasks"),
                             NSLocalizedString(@"All Tasks",@"All Tasks"),
                             NSLocalizedString(@"Completed Tasks",@"Completed Tasks"),
                             nil];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        _customCategories = [[NSMutableArray alloc] initWithObjects:
                             NSLocalizedString(@"Today's Tasks", @"Today's Tasks"),
                             NSLocalizedString(@"All Tasks",@"All Tasks"),
                             NSLocalizedString(@"Completed Tasks",@"Completed Tasks"),
                             nil];
    }
    return self;
}



- (void)awakeFromNib
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.clearsSelectionOnViewWillAppear = NO;
        self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
    }

    self.navigationController.toolbarHidden = NO;
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"Login" style:UIBarButtonItemStyleDone target:self action:@selector(sync)];
    UIBarButtonItem *item2 = [[UIBarButtonItem alloc] initWithTitle:@"Logout" style:UIBarButtonItemStyleDone target:[GDataEngine class] action:@selector(logout)];
    self.toolbarItems = [NSArray arrayWithObjects:item,item2,nil];
    [item release];
    [item2 release];
 
    [super awakeFromNib];
}

- (void)sync {

    [[GTaskEngine sharedEngine] syncWithSyncHandler:^(GTaskEngine *currentEngine, SyncStep step) {
        NIF_INFO(@"%d", step);
        if (step == SyncStepListsUpdated) {
            self.taskLists = [currentEngine localTaskLists];
            [self.tableView reloadData];
        }
    }];
}

- (void)dealloc
{
    [_detailViewController release];
    [_taskLists release];
    [super dealloc];
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
    self.detailViewController = (RWDetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
        
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        @try {
            [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionMiddle];
        }
        @catch (NSException *exception) {
            
        }
        @finally {
        }
    }
    
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
    [super viewWillAppear:animated];
    self.taskLists = [[GTaskEngine sharedEngine] localTaskLists];
    [self.tableView reloadData];
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

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
 
    if (editing) {
        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"Login" style:UIBarButtonItemStyleDone target:self action:@selector(sync)];
        UIBarButtonItem *item2 = [[UIBarButtonItem alloc] initWithTitle:@"Logout" style:UIBarButtonItemStyleDone target:[GDataEngine class] action:@selector(logout)];
        UIBarButtonItem *addNewListItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"New List", @"New List") style:UIBarButtonItemStyleBordered target:self action:@selector(addNewList:)];
        
        self.toolbarItems = [NSArray arrayWithObjects:item,item2,addNewListItem,nil];

        [item release];
        [item2 release];
        [addNewListItem release];
    } else {
        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"Login" style:UIBarButtonItemStyleDone target:self action:@selector(sync)];
        UIBarButtonItem *item2 = [[UIBarButtonItem alloc] initWithTitle:@"Logout" style:UIBarButtonItemStyleDone target:[GDataEngine class] action:@selector(logout)];
        
        self.toolbarItems = [NSArray arrayWithObjects:item,item2,nil];
        
        [item release];
        [item2 release];
        
    }
    
    
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return [self.taskLists count];
    } else if (section == 1){
        return [self.customCategories count];
    } else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *kCellIndentifier = @"kCellIndentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIndentifier];
    if(cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kCellIndentifier] autorelease];
    }
    
    if (indexPath.section == 0) {
        TaskList *list = [self.taskLists objectAtIndex:indexPath.row];
        cell.textLabel.text = list.title;
//        cell.detailTextLabel.text = list.kind;
    } else if (indexPath.section == 1) {
        cell.textLabel.text = [self.customCategories objectAtIndex:indexPath.row];
        cell.detailTextLabel.text = nil;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if (indexPath.section == 0) {
        @autoreleasepool {
            if (!self.detailViewController) {
                self.detailViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"kDetailViewControllerIdentifier"];
            }
            
            TaskList *list = [self.taskLists objectAtIndex:indexPath.row];
            self.detailViewController.taskList = list;
            [self.navigationController pushViewController:self.detailViewController animated:YES];
        }        
    } else if (indexPath.section == 1) {
        
    }

}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    if (indexPath.section == 0) {
        return YES;        
    } else {
        return NO;
    }
}


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source.
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }   
}
*/


// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{

}


// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}

- (IBAction)addNewList:(id)sender {
//    GAddListController *addListController = [[GAddListController alloc] init];
    UINavigationController *navigator = [self.storyboard instantiateViewControllerWithIdentifier:@"GAddListNavigator"];
    GAddListController *addListController = (GAddListController *)navigator.topViewController;
    addListController.actionViewController = self;
    [self presentModalViewController:navigator animated:YES];
    
}

- (void)addListCancelled:(GAddListController *)addListController {
    [addListController.navigationController dismissModalViewControllerAnimated:YES];
}

- (void)addListFinished:(GAddListController *)addListController {
    
    [addListController.navigationController dismissModalViewControllerAnimated:YES];
}


@end
