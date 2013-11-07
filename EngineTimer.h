//
//  EngineTimer.h
//  Zombie App
//
//  Created by Brian Pedersen on 04/11/13.
//  Copyright (c) 2013 Aalborg Universitet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EngineTimer : NSObject{
    // These variables are important for calculation frame delta time
    NSTimeInterval _deltaTime;
    NSTimeInterval _lastTime;
    NSTimeInterval _newTime;
    
    // Time and date for when the game is started and stopped.
    NSDate* _gameStartedAtDate;
    NSDate* _gameStoppedAtDate;
}

// Invoking the init method implicitly sets the _gameStartedAtDate.
// Instantiate a new EngineTimer object whenever the game is restarted.
-(id)init;

// Recalculate the current delta time. Should only be called once per game cycle.
-(void)update;

// Returns the recently calculated delta time. This has no sideeffects, and can
// called often each cycle if nessesary.
-(NSTimeInterval)currentDeltaInSeconds;

// This implicitly sets the _gameStoppedAtDate to 'now'.
-(void)stop;

// Returns the currently elapsed time. If the timer has been stopped, it then returns
// for how long the game elapsed.
-(NSTimeInterval)elapsedGameTime;

@end
