//
//  NSNumber+Time.h
//  Fight Rounds
//
//  Created by Jad Osseiran on 12/06/13.
//  Copyright (c) 2013 Jad Osseiran. All rights reserved.
//

@import Foundation;

@interface NSNumber (Time)

- (NSString *)minutesTimeString;

- (NSInteger)convertToMinutes;
- (NSInteger)convertToSeconds;

@end
