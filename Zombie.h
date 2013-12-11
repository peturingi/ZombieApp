//
//  Zombie.h
//  Zombie App
//
//  Created by Brian Pedersen on 04/11/13.
//  Copyright (c) 2013 Aalborg Universitet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "GameEnvironment.h"
#import "ZombieAIState.h"
#import "GridCell.h"
#import "PathfindingSystem.h"



@class User;

@interface Zombie : NSObject{
    // Dictionary containing distinct AI states for the zombie. Each state corrosponds to a field in the enum
    // in the ZombieAIState protocol
    NSMutableDictionary* _zombieStates;
    // This is the current state. State changes should preferebly happend throught the changeToState: method
    id<ZombieAIState> _currentState;
    id<GameEnvironment> _gameEnvironment;
    double _thinkInterval;
}

@property NSInteger identifier;
@property (readonly) GridCell* cellLocation;
@property (readonly) PathfindingSystem* pathfindingSystem;
@property (readonly) NSInteger energy;
@property (readonly) NSUInteger direction;
@property GridCell* perceptLocation;
@property (readonly) NSInteger visionSkill;
@property (readonly) NSInteger hearingSkill;


-(id)initWithCellLocation:(GridCell*)cellLocation
               identifier:(NSInteger)identifier pathfindingSystem:(PathfindingSystem*)pathfindingSystem andGameEnvironment:(id<GameEnvironment>)gameEnvironment;

// 'think' method invoked by the game controller.
// This chooses the correct strategy based on the current percept.
-(void)think:(double)deltaTime;

// Invoked internally by the zombie's internal AI state whenever a AI state change should happend.
// eg. zombie is currently roaming and sees the player - it should then change state to chasing player (as well
// as alarming other zombies and so on.)
-(void)changeToStrategy:(NSInteger)strategyIdentifier;


-(void)moveToLocation:(GridCell*)cellLocation;

// decrease energy is used by actions performed by strategies, ie. moving, turning and standing still.
-(void)decreaseEnergyBy:(int)amount;

// increase energy whenever the zombie 'touches' the player
-(void)increaseEnergyBy:(int)amount;

@end
