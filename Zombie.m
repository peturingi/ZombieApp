//
//  Zombie.m
//  Zombie App
//
//  Created by Brian Pedersen on 04/11/13.
//  Copyright (c) 2013 Aalborg Universitet. All rights reserved.
//

#import "Zombie.h"
#import "ZombieAIIdle.h"
#import "ZombieAIRoam.h"
#import "ZombieAIRun.h"
#import "ZombieAISprint.h"

#define THINK_INTERVAL 5.0f
#define ZOMBIE_ENERGY 1000

@implementation Zombie


-(id)initWithCellLocation:(GridCell*)cellLocation
               identifier:(NSInteger)identifier andPathfindingSystem:(PathfindingSystem *)pathfindingSystem{
    self = [super init];
    if(self){
        _zombieStates = [[NSMutableDictionary alloc]init];
        _cellLocation = cellLocation;
        [self initializeAIStates];
        [self setIdentifier:identifier];
        [self setPerceptLocation:nil];
        // begin in default state
        [self changeToStrategy:IDLE];
        
        _pathfindingSystem = pathfindingSystem;
        _thinkInterval = THINK_INTERVAL;
        _energy = ZOMBIE_ENERGY;
    }
    return self;
}


-(void)think:(double)deltaTime{
    // variable below is for debugging
    int choosenStrategyIdentifier = ROAM;
    // if it is time to think, do so
    _thinkInterval -= deltaTime;
    if(_thinkInterval < 0){
        // time to think again
        // ask bayesian network for a strategy
        NSLog(@"thinking...");
        // choose strategy
        [self changeToStrategy:choosenStrategyIdentifier];
        
        // reset counter
        _thinkInterval = THINK_INTERVAL;
    }
    

    // execute strategy
    [self executeCurrentStrategy:deltaTime];
}


-(void)executeCurrentStrategy:(double)deltaTime{
    [_currentState executeFor:self withDelta:deltaTime];
}

-(void)changeToStrategy:(NSInteger)strategyIdentifier{
    id<ZombieAIState> strategy = [_zombieStates objectForKey:[NSNumber numberWithInt:strategyIdentifier]];
    NSAssert(strategy, @"Attempting strategychange to non existing strategy!");
    
    // When changing strategy, be sure to reset it and set it up to be the current,
    // so that we execute it
    [strategy resetState];
    _currentState = strategy;
}

# pragma mark - private methods

// Add all distinct AI states to the internal dictionary.
-(void)initializeAIStates{
    [_zombieStates setObject:[[ZombieAIIdle alloc]init] forKey:[NSNumber numberWithInteger:IDLE]];
    [_zombieStates setObject:[[ZombieAIRoam alloc]init] forKey:[NSNumber numberWithInteger:ROAM]];
    [_zombieStates setObject:[[ZombieAIRun alloc]init] forKey:[NSNumber numberWithInteger:RUN]];
    [_zombieStates setObject:[[ZombieAISprint alloc]init] forKey:[NSNumber numberWithInteger:SPRINT]];
}

-(void)moveToLocation:(GridCell*)cellLocation{
    NSAssert(cellLocation, @"Cannot move to a nil location");
    _cellLocation = cellLocation;
}

-(void)decreaseEnergyBy:(int)amount{
    _energy -= amount;
    if(_energy < 0){
        _energy = 0;
    }
}

-(void)increaseEnergyBy:(int)amount{
    _energy += amount;
    
    // zombies can only have so much energy
    if(_energy > ZOMBIE_ENERGY){
        _energy = ZOMBIE_ENERGY;
    }
}
@end
