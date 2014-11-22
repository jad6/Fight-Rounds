//
//  FRTintColorHelper.m
//  Fight Rounds
//
//  Created by Jad Osseiran on 14/06/13.
//  Copyright (c) 2013 Jad Osseiran. All rights reserved.
//

#import "FRTintColorHelper.h"

@implementation FRTintColorHelper

+ (UIColor *)tinitColor {
	return [UIColor redColor];
}

+ (UIColor *)alternativeTintColor {
	return [UIColor colorWithRed:75.0 / 255.0 green:215.0 / 255.0 blue:99.0 / 255.0 alpha:1.0];
}

+ (UIColor *)disabledColor {
	return [UIColor darkGrayColor];
}

@end
