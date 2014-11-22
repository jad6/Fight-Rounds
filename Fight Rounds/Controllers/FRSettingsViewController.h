//
//  FRSettingsViewController.h
//  Fight Rounds
//
//  Created by Jad Osseiran on 14/06/13.
//  Copyright (c) 2013 Jad Osseiran. All rights reserved.
//

@import UIKit;

typedef NS_ENUM (NSInteger, FRFavoritesOrdering) {
	FRFavoritesOrderingAlphabetical,
	FRFavoritesOrderingFrequencyUsed
};

@class FRSettingsViewController;

@protocol FRSettingsViewControllerDelegate <NSObject>

@optional
- (void)settingsVC:(FRSettingsViewController *)settingsVC
    didChangeOrdering:(FRFavoritesOrdering)ordering;

@end

@interface FRSettingsViewController : UITableViewController

@property (weak, nonatomic) id <FRSettingsViewControllerDelegate> delegate;

@end
