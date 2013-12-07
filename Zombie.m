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

enum{
    LEFT = 1,
    RIGHT = 2,
    UP = 10,
    UP_LEFT = 11,
    UP_RIGHT = 12,
    DOWN = 20,
    DOWN_LEFT = 21,
    DOWM_RIGHT = 22
};

@implementation Zombie


-(id)initWithCellLocation:(GridCell*)cellLocation
               identifier:(NSInteger)identifier pathfindingSystem:(PathfindingSystem *)pathfindingSystem andGameEnvironment:(id<GameEnvironment>)gameEnvironment{
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
        _thinkInterval = 0.0f;
        _energy = ZOMBIE_ENERGY;
        NSAssert(gameEnvironment, @"fskdfh");
        _gameEnvironment = gameEnvironment;
    }
    return self;
}


-(void)think:(double)deltaTime{

    // if it is time to think, do so
    _thinkInterval -= deltaTime;
    
    // blocks game engine, cuz not own thread.
    if(_thinkInterval < 0){
        // time to think again
        // ask bayesian network for a strategy
        //NSLog(@"thinking...");
        //NSLog(@"can we see player?");
        
        
        BOOL obstacles;
        BOOL facingPercept = NO; // intialized to silence a compiler warning.
        NSInteger visibilityDistance = [_gameEnvironment canSeePlayer:self];
        if (visibilityDistance == -1) {
            visibilityDistance = 0;
            obstacles = YES;
            facingPercept = NO;
        } else {
            obstacles = [_gameEnvironment obstaclesBetweenZombieAndPlayer:self];
            if (!obstacles) {
                // check if facing percept.
            }
        }
        NSInteger distanceToPlayer = [_gameEnvironment canHearPlayer:self]; // Hearing distance to percept.
        if (distanceToPlayer == -1) distanceToPlayer = 2;
        BOOL isDay = [_gameEnvironment isDay];
        NSInteger soundLevel = [_gameEnvironment soundLevel];
        
        NSInteger energyLevel;
        if (self.energy >= 0 && self.energy < 333) {
            energyLevel = 0;
        }
        if (self.energy >= 333 && self.energy < 666)
            energyLevel = 1;
        else
            energyLevel = 2;
        

        // using can hear player as distance to player to not have to execute A* each time this is called.
        NSInteger choosenStrategyIdentifier = [_gameEnvironment selectStrategyForSoundLevel:soundLevel distanceToPlayer:distanceToPlayer visibilutyDistance:visibilityDistance zombieFacingPercept:facingPercept obstacleInBetween:obstacles dayOrNight:isDay hearingSkill:self.hearingSkill visionSkill:self.visionSkill energy:energyLevel travelingDistanceToPercept:distanceToPlayer];
        NSLog(@"Choose strategy number %ld", choosenStrategyIdentifier);
        
        if (choosenStrategyIdentifier == 0) choosenStrategyIdentifier=1; // never idle.
        
        NSAssert(choosenStrategyIdentifier > -1, @"Error");
        
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
    
    // determine the direction the zombie will be facing after moving
    int xDirection = [cellLocation xCoord] - [_cellLocation xCoord];
    int yDirection = [cellLocation yCoord] - [_cellLocation yCoord];
    
    int direction = 0;
    // if moving right
    if(xDirection > 0)
        direction += RIGHT;
    // if moving left
    if(xDirection < 0)
        direction += LEFT;
    // if moving up
    if(yDirection > 0)
        direction += UP;
    // if moving down
    if(yDirection < 0)
        direction += DOWN;
    
    _direction = direction;
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
