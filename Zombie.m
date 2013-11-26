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


-(id)initWithCellLocation:(GridCell*)cellLocation
               identifier:(NSInteger)identifier andPathfindingSystem:(PathfindingSystem *)pathfindingSystem{
    self = [super init];
    if(self){
        _cellLocation = cellLocation;
        [self initializeAIStates];
        [self setIdentifier:identifier];
        [self setPerceptLocation:nil];
        _thinkCountdown = THINK_INTERVAL;
    }
    return self;
}


-(void)think:(double)deltaTime{
    int choosenStrategyIdentifier = ROAM;
    // if it is time to think, do so
    _thinkCountdown -= deltaTime;
    if(_thinkCountdown < 0){
        // time to think again
        // as bayesian network for a strategy
        _thinkCountdown = THINK_INTERVAL;
    }
    
    // choose strategy
    [self changeToStrategy:choosenStrategyIdentifier];
    
    // execute strategy
    [self executeCurrentStrategy:deltaTime];
}


-(void)executeCurrentStrategy:(double)deltaTime{
    [_currentState executeFor:self withDelta:deltaTime];
}

-(void)changeToState:(NSInteger)strategyIdentifier{
    id<ZombieAIState> strategy = [_zombieStates objectForKey:[NSNumber numberWithInt:strategyIdentifier]];
    NSAssert(strategy, @"Attempting strategychange to non existing strategy!");
    // Did we choose the strategy which we have already been executing?
    // If so, then continue as before
    if(strategy == _currentState){
        return;
    }
    
    // If we changed strategy, be sure to reset it and set it up to be the current,
    // so that we execute it
    [strategy resetState];
    _currentState = strategy;
}

# pragma mark - private methods

// Add all distinct AI states to the internal dictionary.
-(void)initializeAIStates{
    [_zombieStates setObject:[[ZombieAIRoam alloc]init] forKey:[NSNumber numberWithInteger:ROAM]];
}


@end
