//
//  Strategy.h
//  Zombie App
//
//  Created by Pétur Ingi Egilsson on 26/11/13.
//  Copyright (c) 2013 Aalborg Universitet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Strategy : NSObject {
    __strong NSMutableDictionary *offlineKb;
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
              travelingDistanceToPercept:(NSInteger)travelingDistanceToPercept;

@end
