//
//  GameEnvironment.h
//  Zombie App
//
//  Created by Pétur Ingi Egilsson on 07/12/13.
//  Copyright (c) 2013 Aalborg Universitet. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Zombie; // replace with id
@protocol GameEnvironment <NSObject>

-(NSInteger)canSeePlayer:(id)sender;
-(NSInteger)canHearPlayer:(id)sender;
-(BOOL)isDay;
-(BOOL)obstaclesBetweenZombieAndPlayer:(id)sender;
-(NSInteger)soundLevel;

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

- (BOOL)isPlayerInMyLineOfSight:(NSInteger)myXCoordinate andMyYCoordinate:(NSInteger)myYcoordinate myDirection:(double)directionAsRadian myFieldOfView:(double)fieldOfView;

@end
