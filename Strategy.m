//
//  Strategy.m
//  Zombie App
//
//  Created by Pétur Ingi Egilsson on 26/11/13.
//  Copyright (c) 2013 Aalborg Universitet. All rights reserved.
//

#import "Strategy.h"

@implementation Strategy

- (id)init {
    self = [super init];
    if (self) {
        offlineKb = [NSMutableDictionary dictionary];
        [self loadOfflineKb];
    }
    
    return self;
}

- (BOOL)loadOfflineKb {
    
    NSString *fullPath = [[NSBundle mainBundle] pathForResource:@"table" ofType:@"csv"];
    if (!fullPath) {
        @throw [NSException exceptionWithName:@"Offline kb not available" reason:@"It could be missing or corrupted." userInfo:nil];
    }
    NSError *fileReadError;
    NSStringEncoding encoding = NSASCIIStringEncoding;
    NSString *fileAsString = [NSString stringWithContentsOfFile:fullPath encoding:encoding error:&fileReadError];
    /* The file looks like this:
     soundLevel,distanceToPlayer,visibilityDistance,zombieFacingPercept,obstacleInBetween,dayOrNight,hearingSkill,visionSkill,energy,travlingDistanceToPercept,idle,roam,run,sprint
     */
    
    NSArray *rows = [fileAsString componentsSeparatedByString:@"\n"];
    
    for (int currentRow = 0; currentRow < rows.count; currentRow++) {
        NSString *row = [rows objectAtIndex:currentRow];
        NSMutableArray *columns = [NSMutableArray arrayWithArray:[row componentsSeparatedByString:@","]];
        
        NSNumber *idle = [NSNumber numberWithInteger:[[columns objectAtIndex:10] integerValue]];
        NSNumber *roam = [NSNumber numberWithInteger:[[columns objectAtIndex:11] integerValue]];
        NSNumber *walk = [NSNumber numberWithInteger:[[columns objectAtIndex:12] integerValue]];
        NSNumber *sprint = [NSNumber numberWithInteger:[[columns objectAtIndex:13] integerValue]];
        NSArray *strategies = [NSArray arrayWithObjects:idle, roam, walk, sprint, nil];
        
        // The strategy is not part of the key, since its unknown by the agent. Agent is interested in knowing it.
        // Remove the strategy, construct the key.
        for (int i = 0; i < 4; i++) {
            [columns removeObjectAtIndex:columns.count-1];
        }
        
        NSMutableString *key = [[NSMutableString alloc] init];
        for (NSString *component in columns) {
            [key appendString:component];
        }
        
        
        
        // Add the key/strategy pair to the dictionary.
        [offlineKb setObject:strategies forKey:key];
        
    }
    
    return YES;
}

- (NSInteger)selectStrategyForSoundLevel:(NSInteger)soundLevel
                        distanceToPlayer:(NSInteger)distanceToPlayer
                      visibilutyDistance:(NSInteger)visibilityDistance
                     zombieFacingPercept:(NSInteger)zombieFacingPercept
                       obstacleInBetween:(NSInteger)obstacleInBetween
                              dayOrNight:(NSInteger)dayOrNight
                            hearingSkill:(NSInteger)hearingSkill
                             visionSkill:(NSInteger)visionSkill
                                  energy:(NSInteger)energy
              travelingDistanceToPercept:(NSInteger)travelingDistanceToPercept {
    
    NSString *key = [NSString stringWithFormat:@"%01ld%01ld%01ld%01ld%01ld%01ld%01ld%01ld%01ld%01ld",
                     soundLevel,
                     distanceToPlayer,
                     visibilityDistance,
                     zombieFacingPercept,
                     obstacleInBetween,
                     dayOrNight,
                     hearingSkill,
                     visionSkill,
                     energy,
                     travelingDistanceToPercept];
    
    NSArray *strategies = [offlineKb valueForKey:key];
    // Unwrap the NSNumbers
    NSNumber *idleNumber = [strategies objectAtIndex:0];
    NSInteger idle = [idleNumber integerValue];
    NSNumber *roamNumber = [strategies objectAtIndex:1];
    NSInteger roam = [roamNumber integerValue];
    NSNumber *walkNumber = [strategies objectAtIndex:2];
    NSInteger walk = [walkNumber integerValue];
    NSNumber *sprintNumber = [strategies objectAtIndex:3];
    NSInteger sprint = [sprintNumber integerValue];
    
    // Generate a random number
    NSInteger upperBound = idle + roam + walk + sprint;
    NSInteger lowerBound = 0;
    NSInteger allowedRoundingOffsetPercisionLoss = 10; // Used in case there are rounding errors for randomValueBetween method.
    NSInteger randomNumber = [self randomValueBetween:lowerBound and:upperBound];
    
#ifdef DEBUG
    NSLog(@"idle: %ld", idle);
    NSLog(@"roam: %ld", roam);
    NSLog(@"walk: %ld", walk);
    NSLog(@"sprint: %ld", sprint);
    NSLog(@"random: %ld", randomNumber);
#endif
    
    // < instead of <=, so we dont choose idle whenever random number is 0.
    if (randomNumber < idle)
        return 0; // idle
    if (randomNumber < idle + roam)
        return 1; // roam
    if (randomNumber < idle + roam + walk)
        return 2; // walk
    if (randomNumber <= idle + roam + walk + sprint + allowedRoundingOffsetPercisionLoss)
        return 3; // sprint
    

    
    return -1; // should never happen. Error.
}

- (NSInteger)randomValueBetween:(NSInteger)min and:(NSInteger)max {
    return (NSInteger)(min + arc4random_uniform((int)max - (int)min + 1));
}

@end
