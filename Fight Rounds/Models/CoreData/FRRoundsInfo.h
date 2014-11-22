//
//  FRRoundsInfo.h
//  Fight Rounds
//
//  Created by Jad Osseiran on 22/11/2014.
//  Copyright (c) 2014 Jad Osseiran. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface FRRoundsInfo : NSManagedObject

@property (nonatomic, retain) NSNumber * alertExit;
@property (nonatomic, retain) NSNumber * breakLength;
@property (nonatomic, retain) NSDate * identifier;
@property (nonatomic, retain) NSNumber * isFavorite;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * numRounds;
@property (nonatomic, retain) NSNumber * numUsed;
@property (nonatomic, retain) NSNumber * roundLength;
@property (nonatomic, retain) NSNumber * tenSecondsWarning;

@end
