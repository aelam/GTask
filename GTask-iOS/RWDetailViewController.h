//
//  RWDetailViewController.h
//  GTask-iOS
//
//  Created by ryan on 11-9-19.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@class TaskList;
@class GEditViewController;

typedef enum {
    EditStatusNone      =   0,
    EditStatusMoving    =   1,
    EditStatusDeleting  =   2,
}EditStatus;

@protocol EditProtocol <NSObject>

@optional
- (void)editControllerDidAddNewTask:(GEditViewController *)editController;
- (void)editControllerDidModifyOldTask:(GEditViewController *)editController;

@end


@interface RWDetailViewController : UIViewController <UISplitViewControllerDelegate,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,EditProtocol>

@property (strong, nonatomic) id detailItem;

@property (strong, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *statusItem;
@property (strong, nonatomic) IBOutlet UITextField *quickInputField;

@property (strong, nonatomic) NSMutableArray *tasks;
@property (strong, nonatomic) TaskList *taskList;

@property (strong, nonatomic) GEditViewController *editViewController;

@property (nonatomic) EditStatus editStatus;


- (IBAction)changeEditStatus:(id)sender;

- (void)addQuickTaskWithText:(NSString *)text;

@end
