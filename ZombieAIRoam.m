//
//  ZombieAIRoam.m
//  Zombie App
//
//  Created by Brian Pedersen on 07/11/13.
//  Copyright (c) 2013 Aalborg Universitet. All rights reserved.
//

#import "ZombieAIRoam.h"
#import "Zombie.h"
#import "GridMap.h"

#define ROAM_INTERVAL 0.5f

@implementation ZombieAIRoam

-(id)init{
    self = [super init];
    if(self){
        _roamPath = nil;
        _roamPathIndex = 0;
        _roamInterval = ROAM_INTERVAL;
    }
    return self;
}

-(void)executeFor:(Zombie*)zombie withDelta:(double)deltaTime{
    // do something for this zombie when it roams
    
    // if we have not requested a path yet
    if(_roamPath == nil){
        GridMap* map = [[zombie pathfindingSystem]gridMap];
        GridCell* goal = [map cellAt:199 andY:0];
        NSArray* path = [[zombie pathfindingSystem] pathFromCell:[zombie cellLocation] toCell:goal];
        _roamPath = path;
        NSLog(@"new path requested");
        _roamPathIndex = 0;
    }
    
    // if we depleted the path
    if(_roamPathIndex == [_roamPath count]){
        GridMap* map = [[zombie pathfindingSystem]gridMap];
        NSArray* path = nil;
        GridCell* goal = nil;
        if([[zombie cellLocation] xCoord] == 199){
            goal = [map cellAt:0 andY:42];
        }else{
            goal = [map cellAt:199 andY:0];
        }
        path = [[zombie pathfindingSystem] pathFromCell:[zombie cellLocation] toCell:goal];
        _roamPath = path;
        _roamPathIndex = 0;
        NSLog(@"Path depleted, requesting new");
    }
    
    
    _roamInterval -= deltaTime;
    if(_roamInterval < 0){
        // find next location in path
        GridCell* location = _roamPath[_roamPathIndex];
        _roamPathIndex++;
        GridCell* currentLocation = [zombie cellLocation];
        
        // decrease energy
        // cost will be 10 if horizontal or vertical move, 14 if diagonal
        int cost = [currentLocation travelCostToNeighbourCell:location];
        [zombie decreaseEnergyBy:cost];
        
        // move to the location
        [zombie moveToLocation:location];
        
        // reset countdown
        _roamInterval = ROAM_INTERVAL;
    }
}

-(void)resetState{
    // do whatever it takes to reset the state
    _roamPath = nil;
}
@end
