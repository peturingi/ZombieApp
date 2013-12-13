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

#define THINK_INTERVAL 0.5f
#define ZOMBIE_ENERGY 100000



@implementation Zombie


-(id)initWithCellLocation:(GridCell*)cellLocation
               identifier:(NSInteger)identifier
        pathfindingSystem:(PathfindingSystem *)pathfindingSystem
       andGameEnvironment:(id<GameEnvironment>)gameEnvironment
             hearingSkill:(NSInteger)hearingSkill
              visionSkill:(NSInteger)visionSkill
{
    self = [super init];
    if(self){
        _visionSkill = visionSkill;
        _hearingSkill = hearingSkill;
        self.alive = YES;
        _direction = RIGHT;
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
        NSAssert(gameEnvironment, @"No game environment. nil.");
        _gameEnvironment = gameEnvironment;
    }
    return self;
}


-(void)think:(double)deltaTime
{
#ifdef VERBOSE_ZOMBIES
    NSLog(@"%@", self);
#endif
    NSAssert(self.alive, @"Should not think if dead");
    // if it is time to think, do so
    _thinkInterval -= deltaTime;
    
    // blocks game engine, cuz not own thread.
    if(_thinkInterval < 0){
        
        // never out of range : if (distanceToPlayer == -1) distanceToPlayer = 2;
        BOOL isDay = [_gameEnvironment isDay];
        
        NSInteger energyLevel;
        if (self.energy >= 0 && self.energy < 33333) {
            energyLevel = 0;
        }
        if (self.energy >= 333 && self.energy < 66666)
            energyLevel = 1;
        else
            energyLevel = 2;
        

        // using can hear player as distance to player to not have to execute A* each time this is called.
        // Safe to assume player is out of sight if I cannot hear the player.
        if (!self.isExecutingStrategy) {
            self.currentStrategy = [_gameEnvironment selectStrategyForSoundLevel:self.soundLevelOfHearingPercept
                                                                distanceToPlayer:self.distanceToHearingPercept
                                                              visibilutyDistance:self.distanceToVisualPercept
                                                             zombieFacingPercept:self.facingPercept
                                                               obstacleInBetween:self.obstaclesBetweenZombieAndPlayer
                                                                      dayOrNight:isDay
                                                                    hearingSkill:self.hearingSkill
                                                                     visionSkill:self.visionSkill
                                                                          energy:energyLevel
                                                      travelingDistanceToPercept:self.distanceToHearingPercept];

            
#ifdef FORCE_STRATEGY
            self.currentStrategy = FORCE_STRATEGY;
#endif
            
            [self changeToStrategy:self.currentStrategy];
            self.isExecutingStrategy = YES;
#ifdef VERBOSE_STRATEGY
            NSLog(@"Started executing strategy: %d", self.currentStrategy);
#endif
        }
        
        NSAssert(self.currentStrategy > -1, @"Could not select a strategy. Must be in range of -1 to 3.");
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
        self.alive = NO;
    }
}

-(void)increaseEnergyBy:(int)amount{
    _energy += amount;
    
    // zombies can only have so much energy
    if(_energy > ZOMBIE_ENERGY){
        _energy = ZOMBIE_ENERGY;
    }
}

- (double)directionAsRadian {
    
    switch (_direction){
        case LEFT:
            return M_PI;
        case RIGHT:
            return 0.0;
        case UP:
            return M_PI / 2.0;
        case UP_LEFT:
            return 3.0 * M_PI / 4.0;
        case UP_RIGHT:
            return M_PI / 4.0;
        case DOWN:
            return 6.0 * M_PI / 4.0;
        case DOWN_LEFT:
            return 5.0 * M_PI / 4.0;
        case DOWN_RIGHT:
            return 7 * M_PI / 4.0;
        default:
            @throw [NSException exceptionWithName:@"Failed to determine zombie direction" reason:[NSString stringWithFormat:@"Value of direction was %ld", (unsigned long)_direction] userInfo:nil];
            
    }

}

#warning not fully implemented.
- (NSString *)description {
    return [NSString stringWithFormat:@"Identifier: %ld\nDirection: %u\nRadians: %.2lf\nisExecuting:%d\nvision skill:%d\nhearingSkill: %d",(long)self.identifier, self.direction, self.directionAsRadian, self.isExecutingStrategy, self.visionSkill, self.hearingSkill];
}

// Player disappearing from view should not cancel the current strategy.
- (void)setSeesPlayer:(BOOL)seesPlayer {
    if (_seesPlayer == NO && seesPlayer == YES) {
        self.isExecutingStrategy = NO;
    } else {
        // Choose stop executing current strategy if you see and saw the player and he has moved.
        if (_seesPlayer == YES && seesPlayer == YES && _perceptHasMoved) {
            self.isExecutingStrategy = NO;
        }
    }
    _seesPlayer = seesPlayer;
}


- (void)setDistanceToHearingPercept:(NSInteger)distanceToHearingPercept {
    if (_distanceToHearingPercept != distanceToHearingPercept) {
        self.isExecutingStrategy = NO;
    }
    _distanceToHearingPercept = distanceToHearingPercept;
}

- (void)setDistanceToVisualPercept:(NSInteger)distanceToVisualPercept {
    if (_distanceToVisualPercept != distanceToVisualPercept) {
        self.isExecutingStrategy = NO;
    }
    _distanceToVisualPercept = distanceToVisualPercept;
}

// Mark the percept as moved if it has changed.
- (void)setPerceptLocation:(GridCell *)perceptLocation {
    //NSAssert(perceptLocation, @"Perceptlocation should never be nil");
    if (_perceptLocation != perceptLocation) {
        _perceptLocation = perceptLocation;
        _perceptHasMoved = YES;
    } else {
        _perceptHasMoved = NO;
    }
}


@end
