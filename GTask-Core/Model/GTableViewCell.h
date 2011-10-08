//
//  GTableViewCell.h
//  GTask-iOS
//
//  Created by ryan on 11-10-8.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    GTableViewCellStyleDefault,	// Simple cell with text label and optional image view (behavior of UITableViewCell in iPhoneOS 2.x)
    GTableViewCellStyleCheckBox,
    

} GTableViewCellStyle;             // available in iPhone OS 3.0


@interface GTableViewCell : UITableViewCell



@end
