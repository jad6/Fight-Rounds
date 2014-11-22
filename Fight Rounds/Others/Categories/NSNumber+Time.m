//
//  NSNumber+Time.m
//  Fight Rounds
//
//  Created by Jad Osseiran on 12/06/13.
//  Copyright (c) 2013 Jad Osseiran. All rights reserved.
//

#import "NSNumber+Time.h"

@implementation NSNumber (Time)

- (NSString *)minutesTimeString {
	NSInteger seconds = [self integerValue];

	NSInteger formattedSeconds = (seconds % 60);
	NSInteger formattedMinutes = (seconds / 60);

	return [[NSString alloc] initWithFormat:(formattedSeconds < 10) ? @"%li:0%li":@"%li:%li", (long)formattedMinutes, (long)formattedSeconds];
}

- (NSInteger)convertToMinutes {
	return [self integerValue] / 60;
}

- (NSInteger)convertToSeconds {
	return [self integerValue] * 60;
}

@end
