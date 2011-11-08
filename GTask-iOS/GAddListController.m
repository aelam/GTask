//
//  GAddListController.m
//  GTask-iOS
//
//  Created by Vivien Ni on 11-11-8.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "GAddListController.h"
#import "RWMasterViewController.h"

@implementation GAddListController

@synthesize actionViewController = _actionViewController;
@synthesize listField = _listField;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleDone target:self action:@selector(cancelAction:)];
    
    self.navigationItem.leftBarButtonItem = cancelItem;
    [cancelItem release];
    
    UIBarButtonItem *doneItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneAction:)];
    self.navigationItem.rightBarButtonItem = doneItem;
    [doneItem release];
    
}

- (void)cancelAction:(id)sender {
    [self.actionViewController addListCancelled:self];
    
}

- (void)doneAction:(id)sender {
    [self.actionViewController addListFinished:self];
}


- (void)viewWillAppear:(BOOL)animated {
    [_listField becomeFirstResponder];
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
//    return (interfaceOrientation == UIInterfaceOrientationPortrait);
    return YES;
}

- (void)dealloc {
    [_listField release];
    [_actionViewController release];
    [super dealloc];
}

@end
