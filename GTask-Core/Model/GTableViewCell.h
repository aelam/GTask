//
//  GTableViewCell.h
//  GTask-iOS
//
//  Created by ryan on 11-10-8.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UICheckBox;

typedef enum {
    GTableViewCellStyleDefault,	// Simple cell with text label and optional image view (behavior of UITableViewCell in iPhoneOS 2.x)
    GTableViewCellStyleCheckBox,
    

} GTableViewCellStyle;             // available in iPhone OS 3.0


@interface GTableViewCell : UITableViewCell


@property (nonatomic,retain) UICheckBox     *checkBox;
@property (nonatomic,retain) UITextField    *textField;
@property (nonatomic,retain) UIButton       *firstButton;

@property (nonatomic,retain) UILabel        *firstLabel;
@property (nonatomic,retain) UILabel        *secondLabel;

@end
