//
//  EngineTimer.m
//  Zombie App
//
//  Created by Brian Pedersen on 04/11/13.
//  Copyright (c) 2013 Aalborg Universitet. All rights reserved.
//

#import "EngineTimer.h"

@implementation EngineTimer


-(id)init{
    self = [super init];
    if(self){
        [self reset];
    }
    return self;
}

-(void)stop{
    _gameStoppedAtDate = [NSDate date];
}

-(void)reset{
    _lastTime = 0.0f;
    _newTime = 0.0f;
    _deltaTime = 0.0f;
    _gameStartedAtDate = [NSDate date];
}
-(void)update{
    _newTime = CFAbsoluteTimeGetCurrent();
    _deltaTime = (_newTime - _lastTime);
    _lastTime = _newTime;
}
-(double)currentDeltaInSeconds{
    return _deltaTime;
}


- (NSTimeInterval)elapsedGameTime{
    if (_gameStartedAtDate == nil){
        @throw [NSException exceptionWithName:@"Invalid time interval."
                                       reason:@"startedPlaying is nil."
                                     userInfo:nil];
    }

    NSTimeInterval elapsedTime;
    // The game has not yet ended.
    if(_gameStoppedAtDate == nil){
        elapsedTime = [[NSDate date] timeIntervalSinceDate:_gameStartedAtDate];
        // The game has ended.
    }else{
        elapsedTime = [_gameStoppedAtDate timeIntervalSinceDate:_gameStartedAtDate];
    }
    NSAssert(elapsedTime >= 0, @"Playing time can never be negative!");
    return elapsedTime;
}

@end
