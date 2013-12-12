//
//  ZombieAIIdle.m
//  Zombie App
//
//  Created by Brian Pedersen on 26/11/13.
//  Copyright (c) 2013 Aalborg Universitet. All rights reserved.
//

#import "ZombieAIIdle.h"
#import "Zombie.h"

#define IDLE_INTERVAL 2.0f
#define IDLE_COST 5

@implementation ZombieAIIdle

-(id)init{
    self = [super init];
    if(self){
        _idleInterval = IDLE_INTERVAL;
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
}

-(void)resetState{
}
@end
