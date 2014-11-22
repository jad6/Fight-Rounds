//
//  NSError+FightRounds.m
//  Fight Rounds
//
//  Created by Jad Osseiran on 22/11/2014.
//  Copyright (c) 2014 Jad Osseiran. All rights reserved.
//

#import "NSError+FightRounds.h"

@implementation NSError (FightRounds)

- (void)handle {
	NSLog(@"Error detected! {\n\tDescripton: %@\n\tReason: %@\n\tSuggestion: %@\n}", self.localizedDescription, self.localizedFailureReason, self.localizedRecoverySuggestion);
}

@end
