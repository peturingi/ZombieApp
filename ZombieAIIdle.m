//
//  ZombieAIIdle.m
//  Zombie App
//
//  Created by Brian Pedersen on 26/11/13.
//  Copyright (c) 2013 Aalborg Universitet. All rights reserved.
//

#import "ZombieAIIdle.h"
#import "Zombie.h"
#import "MathUtilities.h"

#define IDLE_INTERVAL 1.0f
#define IDLE_COST 5

// In seconds
#define MAX_IDLE_TIME 3
#define MIN_IDLE_TIME 3

@implementation ZombieAIIdle

-(id)init{
    self = [super init];
    if(self){
        _idleInterval = IDLE_INTERVAL;
        [self chooseRandomIdleTime];
    }
    return self;
}


-(void)executeFor:(Zombie *)zombie withDelta:(double)deltaTime{
    // Idle, ie. do nothing
    
    // if enough time has passed, reduce energy levels
    _idleInterval -= deltaTime;
    if(_idleInterval < 0){
        // decrease energy by a bitŒ
        [zombie decreaseEnergyBy:IDLE_COST];
        // reset countdown
        _idleInterval = IDLE_INTERVAL;
    }
#ifdef VERBOSE_STRATEGY
    NSLog(@"time to idle: %.2lf", _idleTime);
#endif
    _idleTime -= deltaTime;
    if (_idleTime <= 0) {
#ifdef VERBOSE_STRATEGY
        NSLog(@"Finished Idle");
#endif
        [self resetState];
        [self chooseRandomIdleTime];
        zombie.isExecutingStrategy = NO;
    }

}

-(void)resetState{
    _idleInterval = IDLE_INTERVAL;
}

- (void)chooseRandomIdleTime {
    _idleTime = [MathUtilities randomNumberBetween:MIN_IDLE_TIME and:MAX_IDLE_TIME];
}
@end
