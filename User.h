//
//  User.h
//  Zombie App
//
//  Created by Pétur Ingi Egilsson on 14/10/13.
//  Copyright (c) 2013 Aalborg Universitet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject

/**
 *  Indicates when the user started playing the current session of the game.
 *  @return The time when the game started.
 */
@property (strong, atomic, readonly) NSDate *startedPlaying;

/**
 *  When did the player stop the last session of the game.
 *  @return The time the game stopped.
 */
@property (strong, atomic, readonly) NSDate *stoppedPlaying;

/**
 *  How long the player has been playing the current session.
 *  @return The elpased time.
 */
- (NSTimeInterval)elapsedPlayingTime;

@end
