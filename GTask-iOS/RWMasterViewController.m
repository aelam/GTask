//
//  RWMasterViewController.m
//  GTask-iOS
//
//  Created by ryan on 11-9-19.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "RWMasterViewController.h"
#import "RWDetailViewController.h"
//#import "GDataLoginDialog.h"
#import "GDataEngine.h"
#import "TaskList.h"

@implementation RWMasterViewController

@synthesize detailViewController = _detailViewController;
@synthesize taskLists = _taskLists;

- (void)awakeFromNib
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.clearsSelectionOnViewWillAppear = NO;
        self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
    }
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"Login" style:UIBarButtonItemStyleDone target:self action:@selector(test)];
    self.navigationItem.rightBarButtonItem = item;
    [item release];

    UIBarButtonItem *item2 = [[UIBarButtonItem alloc] initWithTitle:@"Logout" style:UIBarButtonItemStyleDone target:[GDataEngine class] action:@selector(logout)];
    self.navigationItem.leftBarButtonItem = item2;
    [item2 release];
    
    [super awakeFromNib];
}

- (void)test {
    
    NSURL *url = [NSURL URLWithString:@"https://www.googleapis.com/tasks/v1/users/@me/lists"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    GDataEngine *engine = [[[GDataEngine alloc] init] autorelease];
    [engine fetchWithRequest:request resultBlock:^(GDataEngine *engine, id result) {
     NIF_TRACE(@"%@",result);
     if ([result isKindOfClass:[NSError class]]) {
     NIF_TRACE(@"--- %d", [(NSError *)result code]);
     } else if ([result isKindOfClass:[NSDictionary class]]) {
         BOOL rs = [TaskList saveTaskListFromJSON:result];
         NIF_INFO(@"%d", rs);
         self.taskLists = [TaskList taskListsFromDBWithSortType:1];
         NIF_TRACE(@"%@", self.taskLists);
         [self.tableView reloadData];
     }
     
     UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Tip" message:[result description] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
     [alert show];
     [alert release];
     }];
/*    [engine authorizeWithResultBlock:^(GDataEngine *engine, id result) {
        NIF_TRACE(@"%@",result);
        if ([result isKindOfClass:[NSError class]]) {
            NIF_TRACE(@"--- %d", [(NSError *)result code]);
        }
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Tip" message:[result description] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
    }];
*/
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
        [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionMiddle];
    }
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
    return [self.taskLists count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *kCellIndentifier = @"kCellIndentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIndentifier];
    if(cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kCellIndentifier] autorelease];
    }
    
    TaskList *list = [self.taskLists objectAtIndex:indexPath.row];
    cell.textLabel.text = list.title;
    cell.detailTextLabel.text = list.kind;
    
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

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

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

@end
