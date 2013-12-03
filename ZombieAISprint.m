//
//  ZombieAISprint.m
//  Zombie App
//
//  Created by Brian Pedersen on 27/11/13.
//  Copyright (c) 2013 Aalborg Universitet. All rights reserved.
//

#import "ZombieAISprint.h"
#import "Zombie.h"

#define SPRINT_INTERVAL 0.2f

@implementation ZombieAISprint



-(id)init{
    self = [super init];
    if(self){
        _sprintPath = nil;
        _sprintPathIndex = 0;
        _sprintInterval = SPRINT_INTERVAL;
    }
    return self;
}

-(void)executeFor:(Zombie *)zombie withDelta:(double)deltaTime{
    // if we have not requested a path yet, get a path to the player
    if(_sprintPath == nil || _sprintPathIndex == [_sprintPath count]){
        GridCell* player = [zombie perceptLocation];
        // in the case the player is nil (player is outside map bounds), do nothing,
        // return, and hope for another strategy to be choosen, or that the player enters the map
        // again at some point.
        if(player == nil){
            return;
        }
        
        NSArray* path = [[zombie pathfindingSystem] pathFromCell:[zombie cellLocation] toCell:player];
        _sprintPath = path;
        NSLog(@"new path to the player requested");
        _sprintPathIndex = 0;
    }
    
    _sprintInterval -= deltaTime;
    if(_sprintInterval < 0){
        // find next location in path
        GridCell* location = _sprintPath[_sprintPathIndex];
        _sprintPathIndex++;
        GridCell* currentLocation = [zombie cellLocation];
        
        // decrease energy
        // cost will be 10 if horizontal or vertical move, 14 if diagonal
        int cost = [currentLocation travelCostToNeighbourCell:location];
        [zombie decreaseEnergyBy:cost];
        
        // move to the location
        [zombie moveToLocation:location];
        
        // reset countdown
        _sprintInterval = SPRINT_INTERVAL;
    }
}

-(void)resetState{
    // reset the state
    _sprintPath = nil;
}
@end
