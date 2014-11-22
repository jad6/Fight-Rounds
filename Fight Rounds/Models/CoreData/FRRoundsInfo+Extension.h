//
//  FRRoundsInfo+Extension.h
//  Fight Rounds
//
//  Created by Jad Osseiran on 15/06/13.
//  Copyright (c) 2013 Jad Osseiran. All rights reserved.
//

#import "FRRoundsInfo.h"

typedef NS_ENUM (NSInteger, FRRoundsCurrentState) {
	FRRoundsCurrentStateInactive,
	FRRoundsCurrentStateFight,
	FRRoundsCurrentStateBreak
};

@interface FRRoundsInfo (Extension)

- (NSTimeInterval)totalRoundsTime;

- (NSTimeInterval)startOfFightRoundAtIndex:(NSInteger)index;
- (NSTimeInterval)startOfBreakRoundAtIndex:(NSInteger)index;

- (NSTimeInterval)endOfFightRoundAtIndex:(NSInteger)index;
- (NSTimeInterval)endOfBreakRoundAtIndex:(NSInteger)index;

- (NSTimeInterval)secondsIntoCurrentRoundAtTime:(NSTimeInterval)time;
- (NSInteger)numberOfFightRoundsLapsedAtTime:(NSTimeInterval)time;
- (NSInteger)numberOfBreakRoundsLapsedAtTime:(NSTimeInterval)time;
- (FRRoundsCurrentState)roundsStateAtTime:(NSTimeInterval)time;

@end
