//
//  FRViewController.m
//  Fight Rounds
//
//  Created by Jad Osseiran on 12/06/13.
//  Copyright (c) 2013 Jad Osseiran. All rights reserved.
//

#import "FRRoundsSettingsViewController.h"
#import "FRRoundsViewController.h"

#import "FRRoundsInfo+Extension.h"

#import "FRTextFieldCell.h"
#import "FRStepperCell.h"
#import "FRPickerCell.h"
#import "FRSwitchCell.h"

#import "FRCoreDataManager.h"

#define MAX_ROUND_LENGTH_LOCKED 5
#define MAX_ROUND_LENGTH_UNLOCKED 60

#define MAX_NUM_ROUNDS_LOCKED 5
#define MAX_NUM_ROUNDS_UNLOCKED 50

#define SECONDS_INCREMENT 10

#define TEXT_FIELD_CELL_ID @"TextField Cell"
#define STEPPER_CELL_ID @"Stepper Cell"
#define PICKER_CELL_ID @"Picker Cell"
#define SWITCH_CELL_ID @"Switch Cell"
#define LENGTH_CELL_ID @"Length Cell"
#define ACTION_CELL_ID @"Action Cell"

typedef NS_ENUM (NSInteger, FRTablePickerSelection) {
	FRTablePickerSelectionNone              = 0,
	FRTablePickerSelectionRoundLength       = 11,
	FRTablePickerSelectionBreakLength       = 12
};

typedef NS_ENUM (NSInteger, FRDequeuedCell) {
	FRDequeuedCellNone                      = 0,
	FRDequeuedCellRoundLength               = 11,
	FRDequeuedCellBreakLength               = 12,
	FRDequeuedCellTenSecondsSwitch          = 13,
	FRDequeuedCellExitSwitch                = 14
};

@interface FRRoundsSettingsViewController () <UITableViewDataSource, UITableViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate>

@property (strong, nonatomic) NSArray *lengthOptions;

@property (strong, nonatomic) NSIndexPath *lastSelectedIndexPath, *visiblePickerIndexPath;

@property (strong, nonatomic) UITextField *activeField;

@property (nonatomic) FRTablePickerSelection tablePickerSelection;

@end

@implementation FRRoundsSettingsViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

	if (self.roundsInfo.isFavorite && !self.editingRounds) {
		self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editRounds:)];
	}

	NSInteger maxRoundLength = (PAID_VERSION) ? MAX_ROUND_LENGTH_UNLOCKED : MAX_ROUND_LENGTH_LOCKED;
	NSMutableArray *lengthOptions = [[NSMutableArray alloc] init];
	for (NSInteger i = 1; i <= maxRoundLength; i++) {
		[lengthOptions addObject:[[NSString alloc] initWithFormat:(i == 1) ? @"%li min":@"%li mins", (long)i]];
	}
	if (!PAID_VERSION) {
		[lengthOptions addObject:@"Unlock paid version for more"];
	}
	self.lengthOptions = lengthOptions;

	self.navigationItem.title = self.roundsInfo.name;

//    self.canDisplayBannerAds = !PAID_VERSION;
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];

	if ([self.roundsInfo.isFavorite boolValue]) {
		[[FRCoreDataManager sharedManager].dataStore save: ^(NSError *error) {
		    [error handle];
		}];
	}
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([segue.identifier isEqualToString:@"Rounds Segue"]) {
		FRRoundsViewController *roundsVC = [segue destinationViewController];
		roundsVC.roundsInfo = self.roundsInfo;
	}
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

//#warning I feel like iAd is broken, look into that in future seeds
//- (UITableView *)tableView
//{
//    return (PAID_VERSION) ? (UITableView *)self.view : (UITableView *)self.originalContentView;
//}

#pragma mark - Actions

- (void)editRounds:(id)sender {
	if (self.editingRounds) {
		if (self.tablePickerSelection != FRTablePickerSelectionNone) {
			[self deleteVisiblePickerCell];
		}

		[self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editRounds:)] animated:YES];
	}
	else {
		[self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(editRounds:)] animated:YES];
	}

	self.editingRounds = !self.editingRounds;

	NSRange range = NSMakeRange(0, 2);
	[self.tableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:range] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - Num Rounds

- (void)switchItemChangedValue:(UISwitch *)switchItem {
	switch (switchItem.tag) {
		case FRDequeuedCellTenSecondsSwitch :
			self.roundsInfo.tenSecondsWarning = @(switchItem.on);
			break;

		case FRDequeuedCellExitSwitch:
			self.roundsInfo.alertExit = @(switchItem.on);
			break;

		default:
			break;
	}
}

- (void)stepperValueChanged:(UIStepper *)stepper {
	if (self.tablePickerSelection != FRTablePickerSelectionNone) {
		[self deleteVisiblePickerCell];
	}

	FRStepperCell *stepperCell = (FRStepperCell *)[[[stepper superview] superview] superview];

	stepperCell.stepperDetailLabel.text = [[NSString alloc] initWithFormat:@"%li", (long)stepper.value];

	if (!PAID_VERSION && stepper.value == MAX_NUM_ROUNDS_LOCKED) {
		stepperCell.limitLabel.hidden = NO;
	}
	else {
		stepperCell.limitLabel.hidden = YES;
	}

	self.roundsInfo.numRounds = @(stepper.value);
}

#pragma mark - Logic

- (void)addSecondsLengthOptions {
	NSMutableArray *lengthOptions = [[NSMutableArray alloc] initWithArray:self.lengthOptions];
	for (NSInteger seconds = 50; seconds >= 0; seconds -= SECONDS_INCREMENT) {
		[lengthOptions insertObject:[[NSString alloc] initWithFormat:@"%li secs", (long)seconds] atIndex:0];
	}

	self.lengthOptions = lengthOptions;
}

- (void)removeSecondsLengthOptions {
	NSMutableArray *lengthOptions = [[NSMutableArray alloc] initWithArray:self.lengthOptions];
	[lengthOptions removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, (MINUTE / SECONDS_INCREMENT))]];

	self.lengthOptions = lengthOptions;
}

- (void)saveRoundsName {
	FRTextFieldCell *textFieldCell = (FRTextFieldCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
	if ([textFieldCell.textField.text length] == 0 && !self.roundsInfo.name) {
		self.roundsInfo.name = @"Unnamed Favourite";
	}
	else {
		self.roundsInfo.name = textFieldCell.textField.text;
	}

	[[FRCoreDataManager sharedManager].dataStore save: ^(NSError *error) {
	    [error handle];
	}];
}

- (FRDequeuedCell)handleTableViewCellIdentifier:(NSString **)CellIdentifier
                                   forIndexPath:(NSIndexPath *)indexPath {
	FRDequeuedCell dequeuedCell = FRDequeuedCellNone;

	switch (indexPath.row) {
		case 0:
			*CellIdentifier = STEPPER_CELL_ID;
			break;

		case 1:
			*CellIdentifier = LENGTH_CELL_ID;
			dequeuedCell = FRDequeuedCellRoundLength;
			break;

		case 2:
			switch (self.tablePickerSelection) {
				case FRTablePickerSelectionRoundLength:
					*CellIdentifier = PICKER_CELL_ID;
					break;

				default:
					*CellIdentifier = LENGTH_CELL_ID;
					dequeuedCell = FRDequeuedCellBreakLength;
					break;
			}
			break;

		case 3:
			switch (self.tablePickerSelection) {
				case FRTablePickerSelectionRoundLength:
					*CellIdentifier = LENGTH_CELL_ID;
					dequeuedCell = FRDequeuedCellBreakLength;
					break;

				case FRTablePickerSelectionBreakLength:
					*CellIdentifier = PICKER_CELL_ID;
					break;

				default:
					*CellIdentifier = SWITCH_CELL_ID;
					dequeuedCell = FRDequeuedCellTenSecondsSwitch;
					break;
			}
			break;

		case 4:
			*CellIdentifier = SWITCH_CELL_ID;

			if (self.tablePickerSelection != FRTablePickerSelectionNone) {
				dequeuedCell = FRDequeuedCellTenSecondsSwitch;
			}
			else {
				dequeuedCell = FRDequeuedCellExitSwitch;
			}
			break;

		case 5:
			*CellIdentifier = SWITCH_CELL_ID;
			dequeuedCell = FRDequeuedCellExitSwitch;
			break;

		default:
			break;
	}

	return dequeuedCell;
}

- (void)insertPickerViewUnderCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
	if (cell.tag == FRDequeuedCellBreakLength) {
		[self addSecondsLengthOptions];

		self.tablePickerSelection = FRTablePickerSelectionBreakLength;
	}
	else if (cell.tag == FRDequeuedCellRoundLength) {
		self.tablePickerSelection = FRTablePickerSelectionRoundLength;
	}

	self.visiblePickerIndexPath = [NSIndexPath indexPathForRow:indexPath.row + 1 inSection:indexPath.section];

	[self.tableView insertRowsAtIndexPaths:@[self.visiblePickerIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];

	FRPickerCell *pickerCell = (FRPickerCell *)[self.tableView cellForRowAtIndexPath:self.visiblePickerIndexPath];
	[pickerCell.picker reloadAllComponents];
	pickerCell.picker.hidden = NO;

	if (self.tablePickerSelection == FRTablePickerSelectionBreakLength) {
		NSInteger selectRow = 0;
		if (selectRow >= MINUTE) {
			selectRow = (([self.roundsInfo.breakLength doubleValue] / MINUTE) - 1);
		}
		else {
			selectRow = ([self.roundsInfo.breakLength doubleValue] / SECONDS_INCREMENT);
		}

		[pickerCell.picker selectRow:selectRow
		                 inComponent:0
		                    animated:NO];
	}
	else {
		[pickerCell.picker selectRow:(([self.roundsInfo.roundLength doubleValue] / MINUTE) - 1)
		                 inComponent:0
		                    animated:NO];
	}

	[self.tableView scrollToRowAtIndexPath:self.visiblePickerIndexPath
	                      atScrollPosition:UITableViewScrollPositionMiddle
	                              animated:YES];
}

- (void)deleteVisiblePickerCell {
	[self.tableView deselectRowAtIndexPath:self.lastSelectedIndexPath animated:YES];

	FRPickerCell *cell = (FRPickerCell *)[self.tableView cellForRowAtIndexPath:self.visiblePickerIndexPath];
	cell.picker.hidden = YES;

	if (self.tablePickerSelection == FRTablePickerSelectionBreakLength) {
		[self removeSecondsLengthOptions];
	}

	self.tablePickerSelection = FRTablePickerSelectionNone;
	[self.tableView deleteRowsAtIndexPaths:@[self.visiblePickerIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
	self.visiblePickerIndexPath = nil;
}

#pragma mark - Text field

- (IBAction)textFieldEditingChanged:(UITextField *)textField {
	self.navigationItem.title = textField.text;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
	self.activeField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
	[self saveRoundsName];

	self.activeField = nil;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	self.roundsInfo.name = textField.text;

	[[FRCoreDataManager sharedManager].dataStore save: ^(NSError *error) {
	    [error handle];

	    [textField resignFirstResponder];
	}];

	return YES;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
	[self.activeField resignFirstResponder];
}

#pragma mark - Table view

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	NSString *footer = @"Turning this on will alert you if you manualy opt to exit the timer. It is a good idea to turn it on to avoid accidentally exiting.";

	if (self.editingRounds) {
		if (section == 1) {
			return footer;
		}
	}
	else {
		if (section == 0) {
			return footer;
		}
	}

	return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (self.editingRounds) {
		if (indexPath.section == 1 && indexPath.row == 0) {
			return 88.0;
		}
	}
	else {
		if (indexPath.section == 0 && indexPath.row == 0) {
			return 88.0;
		}
	}

	if ([self.visiblePickerIndexPath isEqual:indexPath]
	    && self.tablePickerSelection != FRTablePickerSelectionNone) {
		return 162.0;
	}

	return 44.0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	switch (section) {
		case 0:
			if (self.editingRounds) {
				return 1;
			}
			else {
				return (self.tablePickerSelection == FRTablePickerSelectionNone) ? 5 : 6;
			}
			break;

		case 1:
			if (self.editingRounds) {
				return (self.tablePickerSelection == FRTablePickerSelectionNone) ? 5 : 6;
			}
			else {
				return 1;
			}
			break;

		default:
			break;
	}

	return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *CellIdentifier = nil;
	static FRDequeuedCell dequeuedCell;

	switch (indexPath.section) {
		case 0: {
			if (self.editingRounds) {
				CellIdentifier = TEXT_FIELD_CELL_ID;
			}
			else {
				dequeuedCell = [self handleTableViewCellIdentifier:&CellIdentifier
				                                      forIndexPath:indexPath];
			}

			break;
		}

		case 1: {
			if (self.editingRounds) {
				dequeuedCell = [self handleTableViewCellIdentifier:&CellIdentifier
				                                      forIndexPath:indexPath];
			}
			else {
				CellIdentifier = ACTION_CELL_ID;
			}
			break;
		}

		default:
			break;
	}

	id cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];

	if ([CellIdentifier isEqualToString:TEXT_FIELD_CELL_ID]) {
		FRTextFieldCell *textFieldCell = (FRTextFieldCell *)cell;
		if (![self.roundsInfo.name isEqualToString:@"New Favourite"]) {
			textFieldCell.textField.text = self.roundsInfo.name;
		}

		textFieldCell.textField.placeholder = @"Rounds Settings Name";
	}
	else if ([CellIdentifier isEqualToString:STEPPER_CELL_ID]) {
		FRStepperCell *stepperCell = (FRStepperCell *)cell;
		stepperCell.stepperTextLabel.text = @"Number of Rounds";
		stepperCell.stepperDetailLabel.text = [[NSString alloc] initWithFormat:@"%li", (long)[self.roundsInfo.numRounds integerValue]];

		[stepperCell.stepper addTarget:self
		                        action:@selector(stepperValueChanged:)
		              forControlEvents:UIControlEventValueChanged];

		stepperCell.stepper.maximumValue = (PAID_VERSION) ? MAX_NUM_ROUNDS_UNLOCKED : MAX_NUM_ROUNDS_LOCKED;

		if (self.roundsInfo.isFavorite && !self.editingRounds) {
			stepperCell.stepper.enabled = NO;
			stepperCell.tintColor = [FRTintColorHelper disabledColor];
			stepperCell.stepperDetailLabel.textColor = [FRTintColorHelper disabledColor];
		}
		else {
			stepperCell.stepperDetailLabel.textColor = [FRTintColorHelper tinitColor];
		}
	}
	else if ([CellIdentifier isEqualToString:LENGTH_CELL_ID]) {
		UITableViewCell *tableCell = (UITableViewCell *)cell;
		if (self.roundsInfo.isFavorite && !self.editingRounds) {
			tableCell.detailTextLabel.textColor = [FRTintColorHelper disabledColor];
		}
		else {
			tableCell.detailTextLabel.textColor = [FRTintColorHelper tinitColor];
		}

		switch (dequeuedCell) {
			case FRDequeuedCellBreakLength:
				tableCell.textLabel.text = @"Break Length";
				tableCell.detailTextLabel.text = [[NSString alloc] initWithFormat:@"%li", [self.roundsInfo.breakLength integerValue] / MINUTE];
				tableCell.tag = FRTablePickerSelectionBreakLength;

				break;

			case FRDequeuedCellRoundLength:
				tableCell.textLabel.text = @"Round Length";
				tableCell.detailTextLabel.text = [[NSString alloc] initWithFormat:@"%li", [self.roundsInfo.roundLength integerValue] / MINUTE];
				tableCell.tag = FRTablePickerSelectionRoundLength;

				break;

			default:

				break;
		}
	}
	else if ([CellIdentifier isEqualToString:SWITCH_CELL_ID]) {
		FRSwitchCell *switchCell = (FRSwitchCell *)cell;
		[switchCell.switchItem addTarget:self
		                          action:@selector(switchItemChangedValue:)
		                forControlEvents:UIControlEventValueChanged];

		switch (dequeuedCell) {
			case FRDequeuedCellTenSecondsSwitch:
				switchCell.switchTextLabel.text = @"Play 10 Seconds Warning";
				switchCell.switchItem.on = [self.roundsInfo.tenSecondsWarning boolValue];
				switchCell.switchItem.tag = FRDequeuedCellTenSecondsSwitch;
				break;

			case FRDequeuedCellExitSwitch:
				switchCell.switchTextLabel.text = @"Alert On Manual Exit";
				switchCell.switchItem.on = [self.roundsInfo.alertExit boolValue];
				switchCell.switchItem.tag = FRDequeuedCellExitSwitch;
				break;

			default:
				break;
		}
	}
	else if ([CellIdentifier isEqualToString:ACTION_CELL_ID]) {
		UITableViewCell *tableCell = (UITableViewCell *)cell;
		tableCell.textLabel.text = @"Start Rounds!";
		tableCell.textLabel.textColor = [FRTintColorHelper tinitColor];
	}

	return cell;
}

- (void)    tableView:(UITableView *)tableView
      willDisplayCell:(UITableViewCell *)cell
    forRowAtIndexPath:(NSIndexPath *)indexPath {
	cell.userInteractionEnabled = !(self.roundsInfo.isFavorite &&
	                                !self.editingRounds &&
	                                !([cell.reuseIdentifier isEqualToString:ACTION_CELL_ID] || [cell.reuseIdentifier isEqualToString:SWITCH_CELL_ID]));
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];

	if ([cell.reuseIdentifier isEqualToString:LENGTH_CELL_ID]) {
		if (self.tablePickerSelection == FRTablePickerSelectionNone) {
			[self insertPickerViewUnderCell:cell atIndexPath:indexPath];
		}
		else {
			[self deleteVisiblePickerCell];

			if (![indexPath isEqual:self.lastSelectedIndexPath]) {
				if (cell.tag == FRDequeuedCellBreakLength) {
					indexPath = [NSIndexPath indexPathForRow:indexPath.row - 1 inSection:indexPath.section];
				}

				[self insertPickerViewUnderCell:cell atIndexPath:indexPath];
			}
			else {
				[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
			}
		}
	}
	else {
		if (self.tablePickerSelection != FRTablePickerSelectionNone) {
			[self deleteVisiblePickerCell];
		}
	}

	if ([cell.reuseIdentifier isEqualToString:TEXT_FIELD_CELL_ID]) {
		[((FRTextFieldCell *)cell).textField becomeFirstResponder];
	}

	self.lastSelectedIndexPath = indexPath;
}

#pragma mark - UIPicker

// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
	return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
	return [self.lengthOptions count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component {
	return self.lengthOptions[row];
}

- (void)pickerView:(UIPickerView *)pickerView
      didSelectRow:(NSInteger)row
       inComponent:(NSInteger)component {
	FRPickerCell *pickerCell = (FRPickerCell *)[self.tableView cellForRowAtIndexPath:self.visiblePickerIndexPath];
	if ([pickerCell.picker isEqual:pickerView]) {
		if (!PAID_VERSION && (row + 1) == [pickerView numberOfRowsInComponent:component]) {
			[pickerView selectRow:(row - 1) inComponent:component animated:YES];
			return;
		}

		NSString *selectedLengthString = nil;

		// There are 12 increments of 5 seconds from 0s to 55s.
		if (self.tablePickerSelection == FRTablePickerSelectionBreakLength && row < 12) {
			selectedLengthString = [[NSString alloc] initWithFormat:@"%lis", row * SECONDS_INCREMENT];
		}
		else {
			selectedLengthString = [[NSString alloc] initWithFormat:@"%li", row + 1];
		}

		NSIndexPath *lengthCellIndexPath = [NSIndexPath indexPathForRow:self.visiblePickerIndexPath.row - 1 inSection:self.visiblePickerIndexPath.section];
		UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:lengthCellIndexPath];

		cell.detailTextLabel.text = selectedLengthString;

		if (self.tablePickerSelection == FRTablePickerSelectionBreakLength) {
			self.roundsInfo.breakLength = (row < (MINUTE / SECONDS_INCREMENT)) ? @(row * SECONDS_INCREMENT) : @((row + 1) * MINUTE);
		}
		else {
			self.roundsInfo.roundLength = @((row + 1) * MINUTE);
		}
	}
}

@end
