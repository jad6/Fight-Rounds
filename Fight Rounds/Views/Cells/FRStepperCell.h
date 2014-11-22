//
//  FRStepperCell.h
//  Fight Rounds
//
//  Created by Jad Osseiran on 13/06/13.
//  Copyright (c) 2013 Jad Osseiran. All rights reserved.
//

@import UIKit;

@interface FRStepperCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *stepperTextLabel, *stepperDetailLabel, *limitLabel;
@property (weak, nonatomic) IBOutlet UIStepper *stepper;

@end
