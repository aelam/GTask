//
//  UIImage+Categories.m
//  GTask-iOS
//
//  Created by ryan on 11-10-19.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "UIImage+Categories.h"

@implementation UIImage (Categories)

+ (UIImage *)bundleImageNamed:(NSString *)imageName {
	NSString *path = [[NSBundle mainBundle] pathForResource:[imageName stringByDeletingPathExtension] ofType:[imageName pathExtension]];
	UIImage *image = [[UIImage alloc] initWithContentsOfFile:path];
	
	return [image autorelease];
}

@end
