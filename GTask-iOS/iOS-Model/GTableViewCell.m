//
//  GTableViewCell.m
//  GTask-iOS
//
//  Created by ryan on 11-10-8.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "GTableViewCell.h"
#import "UICheckBox.h"
#import "UIPlaceHolderTextView.h"

@implementation GTableViewCell

@synthesize textField = _textField;
@synthesize textView = _textView;
@synthesize firstButton = _firstButton;
@synthesize firstLabel = _firstLabel;
@synthesize secondLabel = _secondLabel;
@synthesize checkBox = _checkBox;


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

- (UICheckBox *)checkBox {
    if (_checkBox == nil) {
        _checkBox = [[UICheckBox alloc] initWithFrame:CGRectMake(10, 5, 20, 20)];
        [self.contentView addSubview:_checkBox];
    }
    return _checkBox;
}

- (UITextField *)textField {
    if (_textField == nil) {
        _textField = [[UITextField alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:_textField];
    }
    return _textField;
}

- (UIPlaceHolderTextView *)textView {
    if (_textView == nil) {
        _textView = [[UIPlaceHolderTextView alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:_textView];
    }
    return _textView;
}


- (UITextField *)firstButton {
    if (_firstButton == nil) {
        _firstButton = [[UIButton alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:_firstButton];
    }
    return _textField;
}


- (UILabel *)firstLabel {
    if (_firstLabel == nil) {
        _firstLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:_firstLabel];
    }
    return _firstLabel;
}

- (UILabel *)secondLabel {
    if (_secondLabel == nil) {
        _secondLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:_secondLabel];
    }
    return _secondLabel;
}


- (void)layoutSubviews {
    [super layoutSubviews];
    
}


- (void)dealloc {
    [_textField release];
    [_textView release];
    [_firstButton release];
    [_firstLabel release];
    [_secondLabel release];
    [_checkBox release];
    [super dealloc];
}

@end
