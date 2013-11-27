//
//  GameController.h
//  Zombie App
//
//  Copyright (c) 2013 Aalborg Universitet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GameControllerDelegate.h"
#import "User.h"
#import "EngineTimer.h"
#import "GridMap.h"

// how often to update the game loop
#define UPDATE_GAME_INTERVAL 0.1f

// how often to notify the UI that important game stats updated
#define UPDATE_UI_INTERVAL 0.2f

// This is the amount of zombies to spawn. As it is now, this number is constant
// throughout the game.
#define MAX_ZOMBIES 3

// Maximum distance from player which is allowed for zombies. Distances larger than this
// results in generating a new location for the zombie in the vacinity of the player.
#define DISTANCE_FROM_PLAYER_ALLOWED 100
/**
*   Manages agents and game logic.
*/
@interface GameController : NSObject
{
    // scheduled game loop thread
    NSTimer* _gameloopThread;
    // Internal timer, responsible for updating deltatime and
    // keeping track of for how long the game has been running
    EngineTimer* _engineTimer;
    // Game entities, the player and zombies
    User *_user;
    NSMutableArray* _zombies;
    
    // The game map grid system
    GridMap* _gridMap;
}

/**
 *  Creates a new GameController if one does not already exist.
 *  @return A singleton instance of the GameController
 */
+(id)sharedInstance;

// See GameControllerDelegate for the responsabilities of the delegate.
@property (weak, readwrite, nonatomic) id<GameControllerDelegate> delegate;

- (void)start;
- (void)stop;

//- (void)restart;

//- (void)pause;
//- (void)unpause;


/** Returns information about the current state of the game, such as distances, speed and elapsed time.
 @return Current state of game.
 */
- (NSDictionary *)stats;

@end
