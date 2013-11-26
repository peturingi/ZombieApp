//
//  Zombie.h
//  Zombie App
//
//  Created by Brian Pedersen on 04/11/13.
//  Copyright (c) 2013 Aalborg Universitet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "ZombieAIState.h"
#import "GridCell.h"
#import "PathfindingSystem.h"

#define THINK_INTERVAL 5.0f

@class User;

@interface Zombie : NSObject{
    // Dictionary containing distinct AI states for the zombie. Each state corrosponds to a field in the enum
    // in the ZombieAIState protocol
    NSMutableDictionary* _zombieStates;
    // This is the current state. State changes should preferebly happend throught the changeToState: method
    id<ZombieAIState> _currentState;
    
    double _thinkCountdown;
}

//@property CLLocation* location;
@property NSInteger identifier;
@property (readonly) GridCell* cellLocation;
@property (readonly) PathfindingSystem* pathfindingSystem;
@property GridCell* perceptLocation;

-(id)initWithCellLocation:(GridCell*)cellLocation
               identifier:(NSInteger)identifier andPathfindingSystem:(PathfindingSystem*)pathfindingSystem;

// 'think' method invoked by the game controller.
// This chooses the correct strategy based on the current percept.
-(void)think:(double)deltaTime;

// Invoked internally by the zombie's internal AI state whenever a AI state change should happend.
// eg. zombie is currently roaming and sees the player - it should then change state to chasing player (as well
// as alarming other zombies and so on.)
-(void)changeToStrategy:(NSInteger)strategyIdentifier;

@end
