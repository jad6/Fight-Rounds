//
//  FRRoundsInfo+Extension.m
//  Fight Rounds
//
//  Created by Jad Osseiran on 15/06/13.
//  Copyright (c) 2013 Jad Osseiran. All rights reserved.
//

#import "FRRoundsInfo+Extension.h"

@implementation FRRoundsInfo (Extension)

- (NSTimeInterval)totalRoundsTime {
	return ([self.numRounds integerValue] * [self.roundLength doubleValue]) + (([self.numRounds integerValue] - 1) * [self.breakLength doubleValue]);
}

- (NSTimeInterval)startOfFightRoundAtIndex:(NSInteger)index {
	if (index > [self.numRounds integerValue]) {
		return -1;
	}

	return (index - 1) * ([self.roundLength doubleValue] + [self.breakLength doubleValue]);
}

- (NSTimeInterval)startOfBreakRoundAtIndex:(NSInteger)index {
	if (index > [self.numRounds integerValue] - 1) {
		return -1;
	}

	return (index * [self.roundLength doubleValue]) + ((index - 1) * [self.breakLength doubleValue]);
}

- (NSTimeInterval)endOfFightRoundAtIndex:(NSInteger)index {
	NSTimeInterval startOfFightRound = [self startOfFightRoundAtIndex:index];
	if (startOfFightRound < 0) {
		return -1;
	}

	return startOfFightRound + [self.roundLength doubleValue];
}

- (NSTimeInterval)endOfBreakRoundAtIndex:(NSInteger)index {
	NSTimeInterval startOfBreakRound = [self startOfBreakRoundAtIndex:index];
	if (startOfBreakRound < 0) {
		return -1;
	}

	return startOfBreakRound + [self.breakLength doubleValue];
}

- (NSInteger)numberOfRoundsLapsedAtTime:(NSTimeInterval)time {
	if (time > [self totalRoundsTime]) {
		return -1;
	}

	return time / ([self.roundLength doubleValue] + [self.breakLength doubleValue]);
}

- (NSTimeInterval)secondsIntoCurrentRoundAtTime:(NSTimeInterval)time {
	if (time > [self totalRoundsTime]) {
		return FRRoundsCurrentStateInactive;
	}

	NSTimeInterval fightAndBreakTimeInstance = [self.roundLength doubleValue] + [self.breakLength doubleValue];

	return (time < fightAndBreakTimeInstance) ? time : modf(time, &fightAndBreakTimeInstance);
}

- (NSInteger)numberOfFightRoundsLapsedAtTime:(NSTimeInterval)time {
	return [self numberOfRoundsLapsedAtTime:time];
}

- (NSInteger)numberOfBreakRoundsLapsedAtTime:(NSTimeInterval)time {
	return [self numberOfRoundsLapsedAtTime:time];
}

- (FRRoundsCurrentState)roundsStateAtTime:(NSTimeInterval)time {
	if (time > [self totalRoundsTime]) {
		return FRRoundsCurrentStateInactive;
	}

	NSTimeInterval fightAndBreakTimeInstance = [self.roundLength doubleValue] + [self.breakLength doubleValue];

	if (time < fightAndBreakTimeInstance) {
		if (time < [self.roundLength doubleValue]) {
			return FRRoundsCurrentStateFight;
		}
		else {
			return FRRoundsCurrentStateBreak;
		}
	}

	NSTimeInterval timeIntoNextRound = modf(time, &fightAndBreakTimeInstance);

	if (timeIntoNextRound < [self.roundLength doubleValue]) {
		return FRRoundsCurrentStateFight;
	}
	else {
		return FRRoundsCurrentStateBreak;
	}
}

@end
