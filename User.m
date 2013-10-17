//
//  User.m
//  Zombie App
//
//  Created by Pétur Ingi Egilsson on 14/10/13.
//  Copyright (c) 2013 Aalborg Universitet. All rights reserved.
//

#import "User.h"

@implementation User


/**
 *  Creates a new instance of the object. The startedPlaying time is set to the current date.
 *  @throw NSException if the object could not be initialized.
 *  @return A new instance of User.
 */
- (id)init
{
    self = [super init];
    
    if (!self) {
        @throw [NSException exceptionWithName:@"Initialization failiure."
                                       reason:@"Super initializer returned nil."
                                     userInfo:nil];
    }
    
    return self;
}

- (NSTimeInterval)elapsedPlayingTime
{
    if (_startedPlaying == nil)
    {
        @throw [NSException exceptionWithName:@"Invalid time interval."
                                       reason:@"startedPlaying is nil."
                                     userInfo:nil];
    }
    
    NSTimeInterval elapsedTime;
    
    if (_stoppedPlaying == nil) { // The game has not yet ended.
        elapsedTime = [[NSDate date] timeIntervalSinceDate:_startedPlaying];
    } else { // The game has ended.
        elapsedTime = [_stoppedPlaying timeIntervalSinceDate:_startedPlaying];
    }
    
    NSAssert(elapsedTime >= 0,
             @"Playing time can never be negative!");
    
    return elapsedTime;
}

@end
