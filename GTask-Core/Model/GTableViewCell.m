//
//  GTableViewCell.m
//  GTask-iOS
//
//  Created by ryan on 11-10-8.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "GTableViewCell.h"

@implementation GTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code

        UISwipeGestureRecognizer *leftGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeAction:)];
        leftGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
        [self addGestureRecognizer:leftGestureRecognizer];
        [leftGestureRecognizer release];

        UISwipeGestureRecognizer *gestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeAction:)];
        [self addGestureRecognizer:gestureRecognizer];
        [gestureRecognizer release];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)swipeAction:(UISwipeGestureRecognizer *)sender {
    if (sender.direction == UISwipeGestureRecognizerDirectionLeft) {
        NIF_INFO(@"left %d", sender.direction);        
    } else if (sender.direction == UISwipeGestureRecognizerDirectionRight) {
        NIF_INFO(@"Right %d", sender.direction);        
    }
    
    UITableView *tableView = (UITableView *)self.superview;
        
    UIViewController *delegate = nil;//tableView.nextResponder; // Hopefully this is a TISwipeableTableViewController.
    UIResponder *nextResponder = tableView.nextResponder;
    while ([nextResponder isKindOfClass:[UIView class]]) {
        nextResponder = nextResponder.nextResponder;
    }
    delegate = (UIViewController *)nextResponder;
    
	if ([delegate respondsToSelector:@selector(tableView:shouldSwipeCellAtIndexPath:)]){
		
		NSIndexPath * myIndexPath = [tableView indexPathForCell:self];
		
		if ([delegate tableView:tableView shouldSwipeCellAtIndexPath:myIndexPath]){
						
			if ([delegate respondsToSelector:@selector(tableView:didSwipeCellAtIndexPath:direction:)]){
				[delegate tableView:tableView didSwipeCellAtIndexPath:myIndexPath direction:sender.direction];
			}
		}
        
	}

}

- (void)willTransitionToState:(UITableViewCellStateMask)state {
    [super willTransitionToState:state];
}


- (void)dealloc {
    
    [super dealloc];
}

@end
