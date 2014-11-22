//
//  FRCoreDataManager.m
//  Fight Rounds
//
//  Created by Jad Osseiran on 22/11/2014.
//  Copyright (c) 2014 Jad Osseiran. All rights reserved.
//

#import "FRCoreDataManager.h"

@interface FRCoreDataManager ()

@property (nonatomic, strong) DataStore *dataStore;

@end

@implementation FRCoreDataManager

+ (instancetype)sharedManager {
	static __DISPATCH_ONCE__ FRCoreDataManager *singletonObject = nil;

	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
	    singletonObject = [[self alloc] init];

	    NSArray *directories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	    NSString *storePath = [[directories lastObject] stringByAppendingPathComponent:@"fightrounds.sqlite3"];

	    NSManagedObjectModel *model = [DataStore modelForResource:@"Fight Rounds" bundle:[NSBundle mainBundle]];

	    singletonObject.dataStore = [[DataStore alloc] initWithModel:model storePath:storePath];
	});

	return singletonObject;
}

@end
