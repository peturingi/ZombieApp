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

// how often to update the game loop
#define UPDATE_INTERVAL 0.1f

// how often to notify the UI that important game stats updated
#define UPDATE_UI 1.0f

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
}

/**
 *  Creates a new GameController if one does not already excist.
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

- (NSDictionary *)stats;

@end
