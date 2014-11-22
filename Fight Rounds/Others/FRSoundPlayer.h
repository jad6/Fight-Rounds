//
//  FRSoundPlayer.h
//  Fight Rounds
//
//  Created by Jad Osseiran on 12/06/13.
//  Copyright (c) 2013 Jad Osseiran. All rights reserved.
//

@import Foundation;

@interface FRSoundPlayer : NSObject

+ (BOOL)shouldPlaySound;

+ (void)playTenSecondsWarning;
+ (void)playEndBell;
+ (void)playBell;
+ (void)playPauseBeep;

@end
