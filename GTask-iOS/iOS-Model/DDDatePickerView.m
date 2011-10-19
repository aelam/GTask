//
//  DDDatePickerView.m
//  DDCheckin
//
//  Created by ryan on 11-7-12.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DDDatePickerView.h"
#import "UIImage+Categories.h"

@interface DDDatePickerView (Private)

- (void)setDefaultValues;
- (void)dismiss;

@end


@implementation DDDatePickerView

- (id)initWithDelegate:(id)aDelegate {
	if (self = [super init]) {
        _delegate = aDelegate;
        
        [self setDefaultValues];

	}
	return self;
}

- (id)initWithDelegate:(id)aDelegate date:(NSDate *)date {
	if (self = [super init]) {
        _delegate = aDelegate;
        
        [self setDefaultValues];
        if (date) {            
            datePicker.date = date;
        }
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	if (self = [super initWithCoder:aDecoder]) {
        [self setDefaultValues];
	}
	return self;
}

- (void)setDefaultValues {
//    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];

    self.frame = [UIScreen mainScreen].bounds;
    self.backgroundColor = [UIColor clearColor];
    datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 244, 320, 216)];
    datePicker.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:datePicker];
    
    datePicker.datePickerMode = UIDatePickerModeDate;
    datePicker.timeZone = [NSTimeZone localTimeZone];
    datePicker.maximumDate = [NSDate date];
	
	NSString *dateString = @"1900-01-01";
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setDateFormat:@"yyyy-MM-dd"];
	NSDate *date = [formatter dateFromString:dateString];
	[formatter release];	
	datePicker.minimumDate = date;
	
    
    UIView *datePickerHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 200, 320, 44)];
    datePicker.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    datePickerHeader.backgroundColor = [UIColor darkGrayColor];
    [self addSubview:datePickerHeader];
    [datePickerHeader release];
    
    UIButton *canelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [canelButton setBackgroundImage:[[UIImage bundleImageNamed:@"button.png"]stretchableImageWithLeftCapWidth:6 topCapHeight:0] forState:UIControlStateNormal];
    [canelButton setTitle:@"取消" forState:UIControlStateNormal];
    canelButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    canelButton.frame = CGRectMake(14, 7, 60, 30);
    [canelButton addTarget:self action:@selector(cancelButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [datePickerHeader addSubview:canelButton];

    UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [doneButton setBackgroundImage:[[UIImage bundleImageNamed:@"button.png"]stretchableImageWithLeftCapWidth:6 topCapHeight:0] forState:UIControlStateNormal];
    canelButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
    [doneButton setTitle:@"确认" forState:UIControlStateNormal];
    doneButton.frame = CGRectMake(246, 7, 60, 30);
    [doneButton addTarget:self action:@selector(doneButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [datePickerHeader addSubview:doneButton];
	
}

- (void)setNeedsLayout {
    NIF_INFO();
}


- (void)showInView:(UIView *)aView {
    
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    NSInteger heightOffset = 0;
    if (keyWindow != aView) {
        heightOffset = keyWindow.frame.origin.y - aView.frame.origin.y + 20;
    }
    
	[keyWindow addSubview:self];
    self.transform = CGAffineTransformMakeTranslation(0, self.frame.size.height);
	[UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.2];
    self.transform = CGAffineTransformMakeTranslation(0, heightOffset);
	[UIView commitAnimations];	
}

- (void)cancelButtonAction {
    if ([_delegate respondsToSelector:@selector(datePickerViewCancel:)]) {
        [_delegate datePickerViewCancel:self];
    }
    [self dismiss];
}

- (void)doneButtonAction {
    if ([_delegate respondsToSelector:@selector(datePickerView:didConfirmWithDate:)]) {
        [_delegate datePickerView:self didConfirmWithDate:datePicker.date];
    }
    [self dismiss];
}

- (void)dismiss {
	[UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.2];
    self.transform = CGAffineTransformMakeTranslation(0, self.frame.size.height);
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(removeFromSuperview)];
	[UIView commitAnimations];	
}



- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [datePicker release];
    [super dealloc];
}


@end
