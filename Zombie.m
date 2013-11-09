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

-(id)initWithLocation:(CLLocation*)location andIdentifier:(NSInteger)identifier{
    self = [super init];
    if(self){
        self.location = location;
        [self initializeAIStates];
        [self setIdentifier:identifier];
    }
    return self;
}

-(void)think:(NSArray*)otherZombies andPlayer:(User*)user forDuration:(double)deltaTime{
    [_currentState processStateFor:self otherZombies:otherZombies andPlayer:user forDuration:deltaTime];
}

#warning use of int instead of NSInteger
-(void)changeToState:(int)stateIdentifier{
#warning use numberWithInteger
    _currentState = [_zombieStates objectForKey:[NSNumber numberWithInt:stateIdentifier]];
    NSAssert(_currentState, @"Attempting statechange to non existing state!");
}

# pragma mark - private methods

// Add all distinct AI states to the internal dictionary.
-(void)initializeAIStates{
#warning use numberWithInteger
    [_zombieStates setObject:[[ZombieAIRoam alloc]init] forKey:[NSNumber numberWithInt:ROAM]];
}
@end
