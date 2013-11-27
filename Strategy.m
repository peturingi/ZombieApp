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
     soundLevel,distanceToPlayer,visibilityDistance,zombieFacingPercept,obstacleInBetween,dayOrNight,hearingSkill,visionSkill,energy,travlingDistanceToPercept,strategy
     */
    
    NSArray *rows = [fileAsString componentsSeparatedByString:@"\n"];
    
    for (int currentRow = 0; currentRow < rows.count; currentRow++) {
        NSString *row = [rows objectAtIndex:currentRow];
        NSMutableArray *columns = [NSMutableArray arrayWithArray:[row componentsSeparatedByString:@","]];
        
        // Select the strategy
        NSInteger strategy = [[columns lastObject] integerValue];
        
        // The strategy is not part of the key, since its unknown by the agent. Agent is interested in knowing it.
        // Remove the strategy, construct the key.
#warning This only allows 10 different possabilities per setting (0-9).
        [columns removeObjectAtIndex:columns.count-1];
        NSMutableString *key = [[NSMutableString alloc] init];
        for (NSString *component in columns) {
            [key appendString:component];
        }
        
        // Add the key/strategy pair to the dictionary.
        [offlineKb setObject:[NSNumber numberWithInteger:strategy] forKey:key];
        
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
    
    NSString *key = [NSString stringWithFormat:@"%01d%01d%01d%01d%01d%01d%01d%01d%01d%01d",
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
    
    NSNumber *strategy = [offlineKb valueForKey:key];
    if (strategy == nil) return -1;
    
    return [strategy integerValue];
}

@end
