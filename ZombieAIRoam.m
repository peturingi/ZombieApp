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
#import "MathUtilities.h"

#define ROAM_INTERVAL 0.2f

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
    
    // 3 lines below is ONLY for debugging and simple testing
    //static BOOL alternate = YES;
    //if([[zombie cellLocation] xCoord] == 199) alternate = NO;
    //if([[zombie cellLocation] xCoord] == 0) alternate = YES;
    
    // if we have not requested a path yet
    if(_roamPath == nil || _roamPathIndex == [_roamPath count]){
        GridMap* map = [[zombie pathfindingSystem]gridMap];
        GridCell* goal = nil;
        
        /*
        if(alternate == NO){
            goal = [map cellAt:0 andY:42];
        }else{
            goal = [map cellAt:199 andY:0];
        }*/
        
        // Find random cell to roam to
        NSInteger xCoord = [[zombie cellLocation] xCoord];
        NSInteger yCoord = [[zombie cellLocation] yCoord];
        NSInteger roamDistance = 20;
        while (!goal || goal.obstacle) {
            goal = [map cellAt:[MathUtilities randomNumberBetween:xCoord-roamDistance and:xCoord+roamDistance] andY:[MathUtilities randomNumberBetween:yCoord-roamDistance and:yCoord+roamDistance]];
        }
        
        NSArray* path = [[zombie pathfindingSystem] pathFromCell:[zombie cellLocation] toCell:goal];
        _roamPath = path;
        NSAssert(_roamPath, @"_roamPath is nil");
        _roamPathIndex = 0;
        //NSLog(@"new path requested");
        
    }
    
    _roamInterval -= deltaTime;
    if(_roamInterval < 0){
#ifndef ZOMBIES_NEVER_MOVE
        // find next location in path
        GridCell* location = _roamPath[_roamPathIndex];
        NSAssert(location, @"Location was nil");
        _roamPathIndex++;
        GridCell* currentLocation = [zombie cellLocation];
        
        // decrease energy
        // cost will be 10 if horizontal or vertical move, 14 if diagonal
        int cost = [currentLocation travelCostToNeighbourCell:location];
        [zombie decreaseEnergyBy:cost];

        // move to the location
        [zombie moveToLocation:location];
        if (_roamPathIndex == _roamPath.count) {
            zombie.isExecutingStrategy = NO; // Finished, goal reached.
        }
#endif
        // reset countdown
        _roamInterval = ROAM_INTERVAL;
    }
}

-(void)resetState{
    // do whatever it takes to reset the state
    _roamPath = nil;
}
@end
