//
//  DDDatePickerView.h
//  DDCheckin
//
//  Created by ryan on 11-7-12.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DDDatePickerViewDelegate;

@interface DDDatePickerView : UIView{
	UIDatePicker *datePicker;
    
    id<DDDatePickerViewDelegate> _delegate; //weak
}

- (id)initWithDelegate:(id)aDelegate;
- (id)initWithDelegate:(id)aDelegate date:(NSDate *)date;
- (void)showInView:(UIView *)aView;

@end

@protocol DDDatePickerViewDelegate <NSObject> 

@optional
- (void)datePickerViewCancel:(DDDatePickerView *)datePickerView;
- (void)datePickerView:(DDDatePickerView *)datePickerView didConfirmWithDate:(NSDate *)date;

//　NOT IMPLEMENT
- (void)willPresentDatePickerView:(DDDatePickerView *)datePickerView;  // before animation and showing view
- (void)didPresentDatePickerView:(DDDatePickerView *)datePickerView;  // after animation

- (void)datePickerView:(DDDatePickerView *)datePickerView willDismissWithDate:(NSDate *)date; // before animation and hiding view
- (void)datePickerView:(DDDatePickerView *)datePickerView didDismissWithDate:(NSDate *)date;  // after animation


@end