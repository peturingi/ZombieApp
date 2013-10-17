//
//  GameController.h
//  Zombie App
//
//  Copyright (c) 2013 Aalborg Universitet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GameControllerDelegate.h"
#import "User.h"

/**
*   Manages agents and game logic.
*/
@interface GameController : NSObject
{
    // The loop which updates the elapsed time.
    NSTimer* timer_updateTime;
    
    // The player.
    User *_user;
}

/**
 *  Creates a new GameController if one does not already excist.
 *  @return A singleton instance of the GameController
 */
+(id)sharedInstance;

// See GameControllerDelegate for the responsabilities of the delegate.
@property (weak, readwrite, nonatomic) id<GameControllerDelegate> delegate;

- (void)start;
//- (void)stop;

//- (void)restart;

//- (void)pause;
//- (void)unpause;

@end
