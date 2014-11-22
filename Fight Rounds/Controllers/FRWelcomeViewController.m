//
//  FRWelcomeViewController.m
//  Fight Rounds
//
//  Created by Jad Osseiran on 6/02/2014.
//  Copyright (c) 2014 Jad Osseiran. All rights reserved.
//

#import "FRWelcomeViewController.h"

#import "UIApplication+Extensions.h"

@interface FRWelcomeViewController ()

@end

@implementation FRWelcomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
		// Custom initialization
	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view.
	[self setupToolBar];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

#pragma mark - Logic

- (void)setupToolBar {
	UIBarButtonItem *flexibleSpaceBarbutton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
	                                                                                        target:nil
	                                                                                        action:nil];

	UILabel *appInfoLabel = [[UILabel alloc] init];
	appInfoLabel.backgroundColor = [UIColor clearColor];
	appInfoLabel.textColor = [FRTintColorHelper tinitColor];
	appInfoLabel.text = [UIApplication versionInformation];

	CGRect appInfoLabelFrame = appInfoLabel.frame;
	appInfoLabelFrame.size = [appInfoLabel sizeThatFits:CGSizeZero];
	appInfoLabel.frame = appInfoLabelFrame;

	UIBarButtonItem *appInfoBarButton = [[UIBarButtonItem alloc] initWithCustomView:appInfoLabel];

	self.toolbarItems = @[flexibleSpaceBarbutton, appInfoBarButton, flexibleSpaceBarbutton];
}

#pragma mark - Actions

- (IBAction)done:(id)sender {
	[self dismissViewControllerAnimated:YES completion:nil];
}

@end
