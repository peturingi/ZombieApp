//
//  ZombieAIRun.m
//  Zombie App
//
//  Created by Brian Pedersen on 27/11/13.
//  Copyright (c) 2013 Aalborg Universitet. All rights reserved.
//

#import "ZombieAIRun.h"
#import "Zombie.h"
#import <math.h>
@implementation ZombieAIRun

#define RUN_INTERVAL 1.5f
#define RUN_INTERVAL_DIAGONAL sqrt(2.0*pow(RUN_INTERVAL,2))

-(id)init{
    self = [super init];
    if(self){
        _runPath = nil;
        _runPathIndex = 0;
        _runInterval = RUN_INTERVAL;

    }
    return self;
}

-(void)executeFor:(Zombie *)zombie withDelta:(double)deltaTime{
    GridCell* player = [zombie perceptLocation];
    

    // if we have not requested a path yet, get a path to the player
        if(_runPath == nil || _runPathIndex >= [_runPath count]){
            
            // in the case the player is nil (player is outside map bounds), do nothing,
            // return, and hope for another strategy to be choosen, or that the player enters the map
            // again at some point.
            if(player == nil){
                zombie.isExecutingStrategy = NO;
                return;
            }
            
            NSArray* path = [[zombie pathfindingSystem] pathFromCell:[zombie cellLocation] toCell:player];
            _runPath = path;
            NSLog(@"new path to the player requested");
            _runPathIndex = 0;
        }


    
    _runInterval -= deltaTime;
    if(_runInterval < 0){
#ifndef ZOMBIES_NEVER_MOVE
        // find next location in path
        GridCell* location = _runPath[_runPathIndex];
        _runPathIndex++;
        GridCell* currentLocation = [zombie cellLocation];
        
        // decrease energy
        // cost will be 10 if horizontal or vertical move, 14 if diagonal
        int cost = [currentLocation travelCostToNeighbourCell:location];
        [zombie decreaseEnergyBy:cost];
        
        // move to the location
        [zombie moveToLocation:location];
#endif
        // Timer is set based on zombies speed. He moves faster in diagonal.
        switch (zombie.direction) {
            case UP:
            case DOWN:
            case RIGHT:
            case LEFT:
                _runInterval = RUN_INTERVAL;
                break;
                
            case UP_RIGHT:
            case UP_LEFT:
            case DOWN_RIGHT:
            case DOWN_LEFT:
                _runInterval = RUN_INTERVAL_DIAGONAL;
                break;
                
            default:
                @throw [NSException exceptionWithName:@"Could not set new run interval" reason:[NSString stringWithFormat:@"Invalid Direction %d", zombie.direction] userInfo:nil];
        }
    }
}

-(void)resetState{
    // reset the state
    _runPath = nil;
}
@end
