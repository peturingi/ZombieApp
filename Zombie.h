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
enum{
    LEFT = 1,
    RIGHT = 2,
    UP = 10,
    UP_LEFT = 11,
    UP_RIGHT = 12,
    DOWN = 20,
    DOWN_LEFT = 21,
    DOWN_RIGHT = 22
};


@class User;

@interface Zombie : NSObject{
    // Dictionary containing distinct AI states for the zombie. Each state corrosponds to a field in the enum
    // in the ZombieAIState protocol
    NSMutableDictionary* _zombieStates;
    // This is the current state. State changes should preferebly happend throught the changeToState: method
    id<ZombieAIState> _currentState;
    id<GameEnvironment> _gameEnvironment;
    double _thinkInterval;
    
    BOOL _perceptHasMoved;
}

@property NSInteger identifier;
@property (readonly) GridCell* cellLocation;
@property (readwrite) CLLocation *gpsLocation;
@property (readonly) PathfindingSystem* pathfindingSystem;
@property (readonly) NSInteger energy;
@property (readonly) NSUInteger direction;
@property (nonatomic) BOOL hasMovedSinceLastTimeHeThought;
@property (nonatomic)GridCell* perceptLocation;
@property (nonatomic) double secondsToMoveToTargetCell;
@property (readonly) NSInteger visionSkill;
@property (readonly) NSInteger hearingSkill;
@property BOOL facingPercept;
@property NSInteger currentStrategy;
@property BOOL isExecutingStrategy;
@property BOOL obstaclesBetweenZombieAndPlayer;
@property (nonatomic) NSInteger distanceToHearingPercept;
@property (nonatomic) NSInteger soundLevelOfHearingPercept;
@property (nonatomic) NSInteger distanceToVisualPercept;
#ifdef DEV_TOUCH_MODE
@property (nonatomic) BOOL seesPlayer;
@property BOOL lineOfSight;
@property BOOL alive;
#endif
-(id)initWithCellLocation:(GridCell*)cellLocation
               identifier:(NSInteger)identifier
        pathfindingSystem:(PathfindingSystem*)pathfindingSystem
       andGameEnvironment:(id<GameEnvironment>)gameEnvironment
             hearingSkill:(NSInteger)hearingSkill
              visionSkill:(NSInteger)visionSkill;


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

-(double)directionAsRadian;



@end
