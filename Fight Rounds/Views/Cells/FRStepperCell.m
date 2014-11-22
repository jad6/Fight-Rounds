//
//  FRStepperCell.m
//  Fight Rounds
//
//  Created by Jad Osseiran on 13/06/13.
//  Copyright (c) 2013 Jad Osseiran. All rights reserved.
//

#import "FRStepperCell.h"

@implementation FRStepperCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	if (self) {
		// Initialization code
		[self awakeFromNib];
	}
	return self;
}

- (void)awakeFromNib {
	[super awakeFromNib];

	self.limitLabel.textColor = [FRTintColorHelper tinitColor];

	self.limitLabel.hidden = YES;
}

@end
