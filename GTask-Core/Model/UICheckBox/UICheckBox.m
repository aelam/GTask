//
//  UICheckBox.m
//  GTask-iOS
//
//  Created by ryan on 11-10-16.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "UICheckBox.h"

@implementation UICheckBox 

@synthesize checked = _checked;

-(id)initWithFrame:(CGRect)frame{
    
    if(self == [super initWithFrame:frame]){
        self.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        
        [self setImage:[UIImage imageNamed:@"checkbox_not_selected.png"] forState:UIControlStateNormal];
        
        [self addTarget:self action:@selector(checkBoxClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return self;
    
}

-(IBAction)checkBoxClicked{    
    self.checked = !self.checked;
    
    if (_actionBlock) {
        _actionBlock();
    }
}

- (void)setChecked:(BOOL)check {
    _checked = check;
    if(check == NO) {
        [self setImage:[UIImage imageNamed:@"checkbox_not_selected.png"] forState:UIControlStateNormal];
    } else {
        [self setImage:[UIImage imageNamed:@"checkbox_selected.png"] forState:UIControlStateNormal];
    }

}

-(void) handleCheckEventWithBlock:(ActionBlock) action {
    if (_actionBlock != action) {
        Block_release(_actionBlock);
        _actionBlock = Block_copy(action);        
    }
    [self addTarget:self action:@selector(checkBoxClicked) forControlEvents:UIControlEventTouchUpInside];
    
}

- (void)dealloc {
    Block_release(_actionBlock);
    [super dealloc];
}

@end
