//
//  FRRoundsViewController.m
//  Fight Rounds
//
//  Created by Jad Osseiran on 12/06/13.
//  Copyright (c) 2013 Jad Osseiran. All rights reserved.
//

#import "FRRoundsViewController.h"

#import "FRSoundPlayer.h"

#import "FRRoundsInfo+Extension.h"
#import "NSNumber+Time.h"

#define STATUS_RESUME_TEXT @"Double tap to resume the round. \nLong press to exit."
#define STATUS_PAUSE_TEXT @"Double tap to pause the round. \nLong press to exit."

#define MIN_ALPHA 0.3
#define INFO_HIDE_TIME 10.0

@interface FRRoundsViewController () <UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *timeLabel, *statusLabel, *roundLabel;

@property (weak, nonatomic) IBOutlet UIButton *infoButton;

@property (strong, nonatomic) NSTimer *timer;

@property (nonatomic) NSTimeInterval secondsLapsed;
@property (nonatomic) NSInteger numRoundsLapsed, numBreaksLapsed;
@property (nonatomic) BOOL paused, restoring, presentingAd;
@property (nonatomic) FRRoundsCurrentState timerState;

@property (strong, nonatomic) UIColor *lastColorBeforePause;

#warning Remove this with new versions of the seed. Might be a GR bug.
@property (nonatomic) BOOL recievedFirstGR;

@end

@implementation FRRoundsViewController

- (void)viewDidLoad {
	[super viewDidLoad];

#warning in progress, must learn more about multitasking in iOS 7
	if (PAID_VERSION) {
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setLocalNotification) name:UIApplicationDidEnterBackgroundNotification object:nil];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(unsetLocalNotification) name:UIApplicationDidBecomeActiveNotification object:nil];
	}
	else {
//        self.interstitialPresentationPolicy = ADInterstitialPresentationPolicyManual;
	}

	self.timeLabel.textColor = [FRTintColorHelper tinitColor];
	self.roundLabel.textColor = [FRTintColorHelper tinitColor];
	self.timeLabel.text = [@([self.roundsInfo.roundLength doubleValue] - self.secondsLapsed)minutesTimeString];
	self.statusLabel.text = STATUS_PAUSE_TEXT;

	self.infoButton.alpha = MIN_ALPHA;
	self.infoButton.hidden = YES;

	self.numRoundsLapsed = -1;
	self.numBreaksLapsed = -1;
	self.timerState = FRRoundsCurrentStateFight;

	[self startTimer];

	[[UIApplication sharedApplication] setIdleTimerDisabled:YES];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

	if (self.presentingAd) {
		[self dismissViewControllerAnimated:YES completion:nil];
	}
	else {
		[self performSelector:@selector(showInfo:) withObject:nil afterDelay:10.0];
	}
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

#pragma mark - Setters

- (void)setTimerState:(FRRoundsCurrentState)timerState {
	if (_timerState != timerState) {
		_timerState = timerState;
	}

	switch (timerState) {
		case FRRoundsCurrentStateFight:
			if ([FRSoundPlayer shouldPlaySound] && !self.restoring) {
				[FRSoundPlayer playBell];
			}

			self.numRoundsLapsed++;
			self.secondsLapsed = 0;

			self.view.tintColor = [FRTintColorHelper tinitColor];
			self.timeLabel.textColor = [FRTintColorHelper tinitColor];
			self.roundLabel.textColor = [FRTintColorHelper tinitColor];
			self.roundLabel.text = [[NSString alloc] initWithFormat:@"Round %li of %li", (self.numRoundsLapsed + 1), (long)[self.roundsInfo.numRounds integerValue]];
			break;

		case FRRoundsCurrentStateBreak:

			if ((self.numRoundsLapsed + 1) == [self.roundsInfo.numRounds integerValue] &&
			    [FRSoundPlayer shouldPlaySound]) {
				[FRSoundPlayer playEndBell];

				self.roundsInfo.numUsed = @([self.roundsInfo.numUsed integerValue] + 1);

				[self endRoundsShowingAd:!PAID_VERSION];
				return;
			}

			if ([FRSoundPlayer shouldPlaySound] && !self.restoring) {
				[FRSoundPlayer playBell];
			}

			self.numBreaksLapsed++;
			self.secondsLapsed = 0;

			self.view.tintColor = [FRTintColorHelper alternativeTintColor];
			self.timeLabel.textColor = [FRTintColorHelper alternativeTintColor];
			self.roundLabel.textColor = [FRTintColorHelper alternativeTintColor];
			self.roundLabel.text = [[NSString alloc] initWithFormat:@"Break %li of %li", (self.numBreaksLapsed + 1), ([self.roundsInfo.numRounds integerValue] - 1)];
			break;

		default:
			break;
	}
}

#pragma mark - Logic

- (void)restoreTimerAtTime:(NSTimeInterval)time {
	self.restoring = YES;

	if (time > [self.roundsInfo totalRoundsTime]) {
		// NSLog timer is finished.
		self.roundsInfo.numUsed = @([self.roundsInfo.numUsed integerValue] + 1);
		[self endRoundsShowingAd:!PAID_VERSION];
	}
	else {
		self.timerState = [self.roundsInfo roundsStateAtTime:time];
		self.numBreaksLapsed = [self.roundsInfo numberOfBreakRoundsLapsedAtTime:time];
		self.numRoundsLapsed = [self.roundsInfo numberOfFightRoundsLapsedAtTime:time];
		self.secondsLapsed = [self.roundsInfo secondsIntoCurrentRoundAtTime:time];

		[self startTimer];
	}

	self.restoring = NO;
}

- (NSTimeInterval)totalTimeLeft {
	NSTimeInterval totalTime = [self.roundsInfo totalRoundsTime];

	NSTimeInterval fightRoundLapsed = self.numRoundsLapsed * [self.roundsInfo.roundLength doubleValue];
	NSTimeInterval breakLapsed = self.numBreaksLapsed * [self.roundsInfo.roundLength doubleValue];
	NSTimeInterval totalLapsed = fightRoundLapsed + breakLapsed + self.secondsLapsed;

	return totalTime - totalLapsed;
}

- (void)startTimer {
	self.timer = [NSTimer scheduledTimerWithTimeInterval:1
	                                              target:self
	                                            selector:@selector(updateTime:)
	                                            userInfo:nil
	                                             repeats:YES];

	self.statusLabel.text = STATUS_PAUSE_TEXT;
}

- (void)stopTimer {
	[self.timer invalidate];
	self.timer = nil;
	self.statusLabel.text = STATUS_RESUME_TEXT;
}

- (void)endRoundsShowingAd:(BOOL)showAd {
	[self stopTimer];

//    if (showAd && [self requestInterstitialAdPresentation]) {
//        self.presentingAd = YES;
//    } else {
	[self dismissViewControllerAnimated:YES completion:nil];
//    }

	[[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}

#pragma mark - Actions

- (IBAction)showInfo:(id)sender {
	if (self.statusLabel.hidden) {
		self.statusLabel.hidden = NO;
		[UIView animateWithDuration:0.3 animations: ^{
		    self.statusLabel.alpha = 1.0;
		}];
	}
	else {
		[UIView animateWithDuration:0.3 animations: ^{
		    if (self.infoButton.hidden) {
		        self.infoButton.hidden = NO;
		        self.infoButton.alpha = 1.0;
			}
		    self.statusLabel.alpha = MIN_ALPHA;
		} completion: ^(BOOL finished) {
		    if (finished) {
		        self.statusLabel.hidden = YES;
			}
		}];
	}
}

- (IBAction)finish:(id)sender {
	if ([self.roundsInfo.alertExit boolValue]) {
		if (!self.recievedFirstGR) {
			UIAlertView *finishAlertView = [[UIAlertView alloc] initWithTitle:@"Stop Fight?" message:@"You are about to end the fight. Exit the timer?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
			self.recievedFirstGR = YES;
			[finishAlertView show];
		}
	}
	else {
		if (!self.recievedFirstGR) {
			self.recievedFirstGR = YES;
			[self endRoundsShowingAd:NO];
		}
	}
}

- (IBAction)pause:(id)sender {
	if (self.paused) {
		self.timeLabel.textColor = self.lastColorBeforePause;
		self.roundLabel.textColor = self.lastColorBeforePause;

		[self startTimer];
	}
	else {
		[self stopTimer];

		self.lastColorBeforePause = self.timeLabel.textColor;

		self.timeLabel.textColor = [FRTintColorHelper disabledColor];
		self.roundLabel.textColor = [FRTintColorHelper disabledColor];
	}

	self.paused = !self.paused;
}

#pragma mark - AlertView

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	self.recievedFirstGR = NO;

	if (buttonIndex == 1) {
		[self endRoundsShowingAd:NO];
	}
}

#pragma mark - Timer

- (void)updateTime:(id)sender {
	self.secondsLapsed++;

	switch (self.timerState) {
		case FRRoundsCurrentStateFight:
			self.timeLabel.text = [@([self.roundsInfo.roundLength doubleValue] - self.secondsLapsed)minutesTimeString];

			if ([self.roundsInfo.roundLength integerValue] - self.secondsLapsed == 10 &&
			    [FRSoundPlayer shouldPlaySound] && [self.roundsInfo.tenSecondsWarning boolValue]) {
				[FRSoundPlayer playTenSecondsWarning];
			}

			if ([self.roundsInfo.roundLength doubleValue] == self.secondsLapsed) {
				if ([self.roundsInfo.breakLength doubleValue] > 0.0) {
					self.timerState = FRRoundsCurrentStateBreak;
				}
				else {
					if (self.numRoundsLapsed + 1 == [self.roundsInfo.numRounds integerValue]) {
						if ([FRSoundPlayer shouldPlaySound]) {
							[FRSoundPlayer playEndBell];
						}
						[self endRoundsShowingAd:!PAID_VERSION];
					}
					else {
						self.timerState = FRRoundsCurrentStateFight;
					}
				}
			}

			break;

		case FRRoundsCurrentStateBreak:
			self.timeLabel.text = [@([self.roundsInfo.breakLength doubleValue] - self.secondsLapsed)minutesTimeString];

			if ([self.roundsInfo.breakLength doubleValue] == self.secondsLapsed) {
				self.timerState = FRRoundsCurrentStateFight;
			}
			else if ([self.roundsInfo.breakLength doubleValue] - self.secondsLapsed < 4 && [FRSoundPlayer shouldPlaySound]) {
				[FRSoundPlayer playPauseBeep];
			}

			break;

		default:
			break;
	}
}

#pragma mark - Local Notification

- (void)setLocalNotification {
	UILocalNotification *notification = [[UILocalNotification alloc] init];

	NSTimeInterval timeLeft = [self totalTimeLeft];

	notification.fireDate = [[NSDate date] dateByAddingTimeInterval:timeLeft];
	if ([notification.fireDate timeIntervalSinceNow] < 0) {
		// already done
		return;
	}
	notification.timeZone = [NSTimeZone systemTimeZone];
	notification.alertBody = @"The rounds have finished";
	notification.alertAction = @"OK";
	notification.soundName = UILocalNotificationDefaultSoundName;

	[[UIApplication sharedApplication] scheduleLocalNotification:notification];

	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setValue:@(timeLeft) forKey:DEFAULTS_TIMER_TIME_LEFT];
	[defaults synchronize];
}

- (void)unsetLocalNotification {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSTimeInterval timeLeft = [[defaults valueForKey:DEFAULTS_TIMER_TIME_LEFT] doubleValue];

	[self restoreTimerAtTime:[self.roundsInfo totalRoundsTime] - timeLeft];
}

@end
