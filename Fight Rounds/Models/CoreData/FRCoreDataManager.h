//
//  FRCoreDataManager.h
//  Fight Rounds
//
//  Created by Jad Osseiran on 22/11/2014.
//  Copyright (c) 2014 Jad Osseiran. All rights reserved.
//

@import Foundation;
@import DataStore;

@interface FRCoreDataManager : NSObject

+ (instancetype)sharedManager;

@property (nonatomic, strong, readonly) DataStore *dataStore;

@end
