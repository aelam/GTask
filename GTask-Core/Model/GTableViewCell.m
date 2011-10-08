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
        [self addGestureRecognizer:leftGestureRecognizer];
        [leftGestureRecognizer release];

        UISwipeGestureRecognizer *gestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeAction:)];
        leftGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
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
    NIF_INFO(@"%@", sender);
    UITableView *tableView = (UITableView *)self.superview;
	NSObject *delegate = tableView.nextResponder; // Hopefully this is a TISwipeableTableViewController.

	if ([delegate respondsToSelector:@selector(tableView:shouldSwipeCellAtIndexPath:)]){
		
		NSIndexPath * myIndexPath = [tableView indexPathForCell:self];
		
		if ([delegate tableView:tableView shouldSwipeCellAtIndexPath:myIndexPath]){
						
			if ([delegate respondsToSelector:@selector(tableView:didSwipeCellAtIndexPath:)]){
				[delegate tableView:tableView didSwipeCellAtIndexPath:myIndexPath];
			}
		}
	}

}

- (void)dealloc {
    
    [super dealloc];
}

@end
