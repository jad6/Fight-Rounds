//
//  UIApplication+Extensions.m
//  Fight Rounds
//
//  Created by Jad Osseiran on 6/02/2014.
//  Copyright (c) 2014 Jad Osseiran. All rights reserved.
//

#import "UIApplication+Extensions.h"

@implementation UIApplication (Extensions)

+ (NSString *)version {
	return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
}

+ (NSString *)build;
{
	return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
}

+ (NSString *)versionInformation {
	return [NSString stringWithFormat:@"Version: %@ (%@)", [self version], [self build]];
}

@end
