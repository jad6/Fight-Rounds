//
//  FRSoundPlayer.m
//  Fight Rounds
//
//  Created by Jad Osseiran on 12/06/13.
//  Copyright (c) 2013 Jad Osseiran. All rights reserved.
//

@import AudioToolbox;

#import "FRSoundPlayer.h"

@implementation FRSoundPlayer

+ (BOOL)shouldPlaySound {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

	if (![defaults valueForKey:DEFAULTS_SOUND_OPTION]) {
		[defaults setBool:YES forKey:DEFAULTS_SOUND_OPTION];
		[defaults synchronize];
	}

	return [defaults boolForKey:DEFAULTS_SOUND_OPTION];
}

+ (void)playTenSecondsWarning {
	[self playSoundWithURL:[[NSBundle mainBundle] URLForResource:@"Wood_Clapping" withExtension:@"m4a"]];
}

+ (void)playEndBell {
	[self playSoundWithURL:[[NSBundle mainBundle] URLForResource:@"Bell_End" withExtension:@"m4a"]];
}

+ (void)playBell {
	[self playSoundWithURL:[[NSBundle mainBundle] URLForResource:@"Bell" withExtension:@"m4a"]];
}

+ (void)playPauseBeep {
	[self playSoundWithURL:[[NSBundle mainBundle] URLForResource:@"Pause_Beep" withExtension:@"m4a"]];
}

+ (void)playSoundWithURL:(NSURL *)url {
	CFURLRef soundFileURL = (__bridge CFURLRef)url;
	SystemSoundID soundID;
	AudioServicesCreateSystemSoundID(soundFileURL, &soundID);
	AudioServicesPlayAlertSound(soundID);
}

@end
