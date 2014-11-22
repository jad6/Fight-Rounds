//
//  FRSettingsViewController.m
//  Fight Rounds
//
//  Created by Jad Osseiran on 14/06/13.
//  Copyright (c) 2013 Jad Osseiran. All rights reserved.
//

@import MessageUI;

#import "FRSettingsViewController.h"

#import "FRStoreManager.h"

@interface FRSettingsViewController () <MFMailComposeViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableViewCell *feedbackCell, *upgradeCell, *restoreCell;

@property (weak, nonatomic) IBOutlet UISwitch *soundSwitch, *iCloudSwitch;

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;

@end

@implementation FRSettingsViewController

- (id)initWithStyle:(UITableViewStyle)style {
	self = [super initWithStyle:style];
	if (self) {
		// Custom initialization
	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];

	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	self.soundSwitch.on = [defaults boolForKey:DEFAULTS_SOUND_OPTION];
	self.iCloudSwitch.on = [defaults boolForKey:DEFAULTS_ICLOUD_OPTION];
	self.segmentedControl.selectedSegmentIndex = [[defaults valueForKey:DEFAULTS_FAV_ORDERING_OPTION] integerValue];
	self.feedbackCell.textLabel.textColor = [FRTintColorHelper tinitColor];
	[self refreshPurchaseCells];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];

	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setBool:self.soundSwitch.on forKey:DEFAULTS_SOUND_OPTION];
	[defaults setBool:self.iCloudSwitch.on forKey:DEFAULTS_ICLOUD_OPTION];
	[defaults setValue:@(self.segmentedControl.selectedSegmentIndex) forKey:DEFAULTS_FAV_ORDERING_OPTION];
	[defaults synchronize];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

#pragma mark - Logic

- (void)refreshPurchaseCells {
	if (PAID_VERSION) {
		self.restoreCell.textLabel.textColor = [FRTintColorHelper tinitColor];
		self.upgradeCell.textLabel.textColor = [FRTintColorHelper disabledColor];

		self.upgradeCell.userInteractionEnabled = NO;
		self.restoreCell.userInteractionEnabled = YES;
	}
	else {
		self.upgradeCell.textLabel.textColor = [FRTintColorHelper tinitColor];
		self.restoreCell.textLabel.textColor = [FRTintColorHelper disabledColor];

		self.restoreCell.userInteractionEnabled = NO;
		self.upgradeCell.userInteractionEnabled = YES;
	}
}

#pragma mark - Action

- (IBAction)done:(id)sender {
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)favoriteOrderingChanged:(id)sender {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setValue:@(self.segmentedControl.selectedSegmentIndex) forKey:DEFAULTS_FAV_ORDERING_OPTION];
	[defaults synchronize];

	if ([self.delegate respondsToSelector:@selector(settingsVC:didChangeOrdering:)]) {
		[self.delegate settingsVC:self didChangeOrdering:self.segmentedControl.selectedSegmentIndex];
	}
}

- (IBAction)iCloud:(UISwitch *)iCloudSwitch {
	if (!PAID_VERSION) {
		UIAlertView *iCloudUpgradeAlertView = [[UIAlertView alloc] initWithTitle:@"iCloud Syncing" message:@"In order to use iCloud syncing you need to upgrade Fight Rounds. You can do so by selecting the \"Upgrade to Paid Version\"." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[iCloudUpgradeAlertView show];

		iCloudSwitch.on = !iCloudSwitch.on;
		return;
	}

	if (iCloudSwitch.on) {
		// TODO: Turn on iCloud sync
	}
	else {
		// TODO: Turn off iCloud sync
	}
}

#pragma mark - In-App Purchase

- (void)upgradeToPro {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setBool:YES forKey:DEFAULTS_IN_APP_PURCHASED];
	[defaults synchronize];
	[self refreshPurchaseCells];

//    if (![[FRStoreManager sharedManager] upgradeToFullVersion]) {
//        UIAlertView *storeAlertView = [[UIAlertView alloc] initWithTitle:@"Cannot Make Payment"
//                                                                 message:@"This device is not entitled to make this payment."
//                                                                delegate:self
//                                                       cancelButtonTitle:@"OK"
//                                                       otherButtonTitles:nil];
//        [storeAlertView show];
//    } else {
//        [self refreshPurchaseCells];
//    }
}

- (void)restorePurchases {
#warning temp for testing only
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setBool:NO forKey:DEFAULTS_IN_APP_PURCHASED];
	[defaults synchronize];

	[self refreshPurchaseCells];
}

#pragma mark - Feedback

- (void)sendFeedback:(id)sender {
	if ([MFMailComposeViewController canSendMail]) {
		MFMailComposeViewController *composer = [[MFMailComposeViewController alloc] init];
		composer.mailComposeDelegate = self;
		composer.view.tintColor = [FRTintColorHelper tinitColor];
		[composer setToRecipients:@[@"jad6@icloud.com"]];
		[composer setSubject:@"Fight Rounds Feedback"];
		[composer setMessageBody:@"Something constructive right here..." isHTML:NO];

		[self presentViewController:composer animated:YES completion:nil];
	}
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
	[self dismissViewControllerAnimated:YES completion: ^{
	}];
}

#pragma mark - Table view

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];

	if ([cell isEqual:self.feedbackCell]) {
		[self sendFeedback:cell];
	}
	else if ([cell isEqual:self.upgradeCell]) {
		[self upgradeToPro];
	}
	else if ([cell isEqual:self.restoreCell]) {
		[self restorePurchases];
	}

	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
