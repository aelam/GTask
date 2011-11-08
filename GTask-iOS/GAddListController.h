//
//  GAddListController.h
//  GTask-iOS
//
//  Created by Vivien Ni on 11-11-8.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class RWMasterViewController;

@interface GAddListController : UIViewController {
    
    RWMasterViewController *actionViewController;
    UITextField *_listField;
}

@property (nonatomic,retain) RWMasterViewController *actionViewController;
@property (nonatomic,retain) IBOutlet UITextField *listField; 

@end
