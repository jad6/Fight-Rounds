//
//  FRFightRoundsViewController.m
//  Fight Rounds
//
//  Created by Jad Osseiran on 13/06/13.
//  Copyright (c) 2013 Jad Osseiran. All rights reserved.
//

@import CoreData;

#import "FRFightRoundsViewController.h"

#import "FRRoundsSettingsViewController.h"
#import "FRSettingsViewController.h"

#import "FRCoreDataManager.h"

#import "FRRoundsInfo+Extension.h"
#import "UIApplication+Extensions.h"

#define MAX_FAVORITES_FREE_VERSION 3

@interface FRFightRoundsViewController () <NSFetchedResultsControllerDelegate, FRSettingsViewControllerDelegate>

@property (strong, nonatomic) DataStore *dataStore;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

@property (strong, nonatomic) FRRoundsInfo *roundsInfoNewFavorite;

@end

@implementation FRFightRoundsViewController

- (void)viewDidLoad {
	[super viewDidLoad];

	// Hide separators for empty cells
	self.tableView.tableFooterView = [[UIView alloc] init];

	self.dataStore = [FRCoreDataManager sharedManager].dataStore;

	self.fetchedResultsController = [self defaultFetchResultsController];

	[self handleEditButtonAnimated:NO];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

	[self presentWelcomeIfNeeded];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([segue.identifier isEqualToString:@"Rounds Settings Segue"]) {
		FRRoundsSettingsViewController *roundsSettingsVC = [segue destinationViewController];
		NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];

		if (selectedIndexPath.section == 0) {
			roundsSettingsVC.roundsInfo = [self lastSavedRoundsInfo];
		}
		else if (selectedIndexPath.section == 1) {
			roundsSettingsVC.roundsInfo = self.fetchedResultsController.fetchedObjects[selectedIndexPath.row];
		}
	}

	if ([segue.identifier isEqualToString:@"Settings Segue"]) {
		FRSettingsViewController *settingsVC = (FRSettingsViewController *)[((UINavigationController *)[segue destinationViewController])topViewController];
		settingsVC.delegate = self;
	}
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (IBAction)addFavorite:(id)sender {
	if ([self.fetchedResultsController.fetchedObjects count] == MAX_FAVORITES_FREE_VERSION &&
	    !PAID_VERSION) {
		UIAlertView *favoritesUpgradeAlertView = [[UIAlertView alloc] initWithTitle:@"Limited to 3 Favorites" message:@"In order to unlock unlimited favorites you need to upgrade Fight Rounds. You can do so by selecting the \"Upgrade to Paid Version\" in the settings." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[favoritesUpgradeAlertView show];
		return;
	}

	self.roundsInfoNewFavorite = [self defaultRoundsInfoWithName:@"New Favourite"];

	FRRoundsSettingsViewController *roundsSettingsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"FRRoundsSettingViewController"];
	roundsSettingsVC.roundsInfo = self.roundsInfoNewFavorite;
	roundsSettingsVC.editingRounds = YES;

	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:roundsSettingsVC];
	navigationController.navigationBar.translucent = NO;
	roundsSettingsVC.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(saveFavorite:)];
	roundsSettingsVC.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelFavorite:)];

	[self presentViewController:navigationController animated:YES completion:nil];
}

- (void)saveFavorite:(id)sender {
	[self.dataStore save: ^(NSError *error) {
	    [error handle];
	    [self dismissViewControllerAnimated:YES completion:nil];
	}];
}

- (void)cancelFavorite:(id)sender {
	[self.dataStore performClosureAndSave: ^(NSManagedObjectContext *context) {
	    [context deleteObject:self.roundsInfoNewFavorite];
	    self.roundsInfoNewFavorite = nil;
	} completion: ^(NSManagedObjectContext *context, NSError *error) {
	    [error handle];
	    [self dismissViewControllerAnimated:YES completion:nil];
	}];
}

#pragma mark - Logic

- (void)presentWelcomeIfNeeded {
	NSString *applicationVersionInfo = [UIApplication versionInformation];
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	if (![[defaults objectForKey:DEFAULTS_LAST_WELCOME_VERSION] isEqualToString:applicationVersionInfo]) {
		UINavigationController *welcomeNC = [self.storyboard instantiateViewControllerWithIdentifier:@"FRWelcomeNavigationController"];
		[self presentViewController:welcomeNC animated:YES completion:nil];

		[defaults setObject:applicationVersionInfo forKey:DEFAULTS_LAST_WELCOME_VERSION];
	}
}

- (FRRoundsInfo *)lastSavedRoundsInfo {
	__block FRRoundsInfo *lastSaved = nil;
	[self.dataStore performBackgroundClosureAndWait: ^(NSManagedObjectContext *context) {
	    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isFavorite == NO"];
	    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"identifier" ascending:NO];

	    NSString *entityName = [self.dataStore entityNameForObjectClass:[FRRoundsInfo class] withClassPrefix:CLASS_PREFIX];

	    NSError *error = nil;

	    NSArray *results = [context findEntitiesForEntityName:entityName withPredicate:predicate andSortDescriptors:@[sortDescriptor] error:&error];

	    [error handle];

	    lastSaved = results.firstObject;

	    if (!lastSaved) {
	        lastSaved = [self defaultRoundsInfoWithName:@"New Rounds"];
	        lastSaved.isFavorite = @(NO);
		}
	}];

	return lastSaved;
}

- (FRRoundsInfo *)defaultRoundsInfoWithName:(NSString *)name {
	__block FRRoundsInfo *newRound = nil;

	NSError *error = nil;
	[self.dataStore performClosureWaitAndSave: ^(NSManagedObjectContext *context) {
	    NSString *entityName = [self.dataStore entityNameForObjectClass:[FRRoundsInfo class] withClassPrefix:CLASS_PREFIX];
	    [context insertObjectWithEntityName:entityName insertion: ^(FRRoundsInfo *round) {
	        round.identifier = [NSDate date];
	        round.numRounds = @(3);
	        round.roundLength = @(3 * MINUTE);
	        round.breakLength = @(MINUTE);
	        round.name = name;
	        round.alertExit = @(YES);

	        newRound = round;
		}];
	} error:&error];

	return newRound;
}

- (void)handleEditButtonAnimated:(BOOL)animated {
	if ([self.fetchedResultsController.fetchedObjects count] == 0) {
		[self setEditing:NO animated:animated];
		[self.navigationItem setLeftBarButtonItem:nil animated:animated];
	}
	else {
		[self.navigationItem setLeftBarButtonItem:self.editButtonItem animated:animated];
	}
}

- (void)setupSettingsCell:(UITableViewCell *)cell {
	cell.textLabel.text = @"Fight Rounds Settings";
	cell.textLabel.textColor = [FRTintColorHelper tinitColor];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
	switch (indexPath.section) {
		case 0:
			cell.textLabel.text = @"Start Rounds";
			break;

		case 1:
			if ([self hasFavorites]) {
				FRRoundsInfo *roundsInfo = self.fetchedResultsController.fetchedObjects[indexPath.row];
				cell.textLabel.text = roundsInfo.name;
			}
			else {
				[self setupSettingsCell:cell];
			}
			break;

		case 2:
			[self setupSettingsCell:cell];

		default:
			break;
	}
}

#pragma mark - Settings delegate

- (void)   settingsVC:(FRSettingsViewController *)settingsVC
    didChangeOrdering:(FRFavoritesOrdering)ordering {
	self.fetchedResultsController = [self defaultFetchResultsController];
	[self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	switch (section) {
		case 1:
			return ([self hasFavorites]) ? @"Favorites" : @"Settings";
			break;

		case 2:
			return @"Settings";
			break;

		default:
			break;
	}

	return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return ([self hasFavorites]) ? 3 : 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	// Return the number of rows in the section.
	switch (section) {
		case 0:
		case 2:
			return 1;
			break;

		case 1:
			if ([self hasFavorites]) {
				return [self.fetchedResultsController.fetchedObjects count];
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
	static NSString *CellIdentifier = nil;

	if ([self hasFavorites]) {
		CellIdentifier = (indexPath.section == 2) ? @"Action Cell" : @"Rounds Cell";
	}
	else {
		CellIdentifier = (indexPath.section == 1) ? @"Action Cell" : @"Rounds Cell";
	}

	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];

	[self configureCell:cell atIndexPath:indexPath];

	return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	// Return NO if you do not want the specified item to be editable.
	return ([self hasFavorites]) ? indexPath.section == 1 : NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		NSError *error = nil;
		[self.dataStore performClosureWaitAndSave: ^(NSManagedObjectContext *context) {
		    [context deleteObject:self.fetchedResultsController.fetchedObjects[indexPath.row]];
		} error:&error];
	}
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 2) {
		cell.accessoryType = UITableViewCellAccessoryNone;
		cell.textLabel.textAlignment = NSTextAlignmentCenter;
		cell.textLabel.textColor = [FRTintColorHelper tinitColor];
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if ([self hasFavorites]) {
		if (indexPath.section == 2) {
			[self performSegueWithIdentifier:@"Settings Segue" sender:self];
		}
		else {
			[self performSegueWithIdentifier:@"Rounds Settings Segue" sender:self];
		}
	}
	else {
		if (indexPath.section == 1) {
			[self performSegueWithIdentifier:@"Settings Segue" sender:self];
		}
		else {
			[self performSegueWithIdentifier:@"Rounds Settings Segue" sender:self];
		}
	}

	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Fetched results controller

- (BOOL)hasFavorites {
	return ([self.fetchedResultsController.fetchedObjects count] > 0);
}

- (NSFetchedResultsController *)defaultFetchResultsController {
	NSFetchedResultsController *fetchResultsController = [self fetchedResultsControllerWithRequest: ^(NSFetchRequest *request) {
	    NSSortDescriptor *alphabetSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];

	    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	    if ([[defaults valueForKey:DEFAULTS_FAV_ORDERING_OPTION] integerValue] == FRFavoritesOrderingFrequencyUsed) {
	        NSSortDescriptor *usedSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"numUsed" ascending:NO];
	        request.sortDescriptors = @[usedSortDescriptor, alphabetSortDescriptor];
		}
	    else {
	        request.sortDescriptors = @[alphabetSortDescriptor];
		}

	    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isFavorite == YES"];
	    request.predicate = predicate;
	} entityName:@"RoundsInfo" sectionNameKeyPath:nil cacheName:nil];

	fetchResultsController.delegate = self;

	NSError *error = nil;
	if (![fetchResultsController performFetch:&error]) {
		// Handle error here.
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	}

	return fetchResultsController;
}

- (NSFetchedResultsController *)fetchedResultsControllerWithRequest:(void (^)(NSFetchRequest *request))fetchRequestBlock
                                                         entityName:(NSString *)entityName
                                                 sectionNameKeyPath:(NSString *)sectionNameKeyPath
                                                          cacheName:(NSString *)cacheName {
	NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:entityName];
	if (fetchRequestBlock) {
		fetchRequestBlock(request);
	}

	return [[NSFetchedResultsController alloc] initWithFetchRequest:request
	                                           managedObjectContext:self.dataStore.mainManagedObjectContext
	                                             sectionNameKeyPath:sectionNameKeyPath
	                                                      cacheName:cacheName];
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
	[self.tableView beginUpdates];
}

- (void)  controller:(NSFetchedResultsController *)controller
    didChangeSection:(id <NSFetchedResultsSectionInfo> )sectionInfo
             atIndex:(NSUInteger)sectionIndex
       forChangeType:(NSFetchedResultsChangeType)type {
	switch (type) {
		case NSFetchedResultsChangeInsert:
			[self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
			break;

		case NSFetchedResultsChangeDelete:
			[self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
			break;

		default:
			break;
	}
}

- (void) controller:(NSFetchedResultsController *)controller
    didChangeObject:(id)anObject
        atIndexPath:(NSIndexPath *)indexPath
      forChangeType:(NSFetchedResultsChangeType)type
       newIndexPath:(NSIndexPath *)newIndexPath {
	UITableView *tableView = self.tableView;

	indexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:1];
	newIndexPath = [NSIndexPath indexPathForRow:newIndexPath.row inSection:1];

	switch (type) {
		case NSFetchedResultsChangeInsert:
			if ([controller.fetchedObjects count] == 1) {
				[tableView insertSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
			}

			[tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
			break;

		case NSFetchedResultsChangeDelete:
			[tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];

			if ([controller.fetchedObjects count] == 0) {
				[tableView deleteSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
			}

			break;

		case NSFetchedResultsChangeUpdate:
			[self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
			break;

		case NSFetchedResultsChangeMove:
			[tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
			[tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
			break;
	}
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
	[self.tableView endUpdates];

	[self handleEditButtonAnimated:YES];
}

@end
