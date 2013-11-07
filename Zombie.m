//
//  Zombie.m
//  Zombie App
//
//  Created by Brian Pedersen on 04/11/13.
//  Copyright (c) 2013 Aalborg Universitet. All rights reserved.
//

#import "Zombie.h"
#import "ZombieAIRoam.h"

@implementation Zombie

-(id)initWithLocation:(CLLocation*)location{
    self = [super init];
    if(self){
        self.location = location;
    }
    return self;
}

-(void)initializeAIStates{
    [_zombieStates setObject:[[ZombieAIRoam alloc]init] forKey:[NSNumber numberWithInt:ROAM]];
}

-(void)think:(NSArray*)otherZombies andPlayer:(User*)user for:(double)deltaTime{
    [_currentState processStateFor:self otherZombies:otherZombies andPlayer:user for:deltaTime];
}

-(void)changeToState:(int)stateIdentifier{
    _currentState = [_zombieStates objectForKey:[NSNumber numberWithInt:stateIdentifier]];
    NSAssert(_currentState, @"Attempting statechange to non existing state!");
}
@end
