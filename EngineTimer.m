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
        _lastTime = 0.0f;
        _newTime = 0.0f;
        _deltaTime = 0.0f;
        _gameStartedAtDate = [NSDate date];
    }
    return self;
}

-(void)stop{
    _gameStoppedAtDate = [NSDate date];
}

-(void)update{
    // CFAbsoluteTimeGetCurrent get the current system time. It is important that
    // this is accurate in relation to some specific moment in time - only the relative time
    // between two measurements are important. I have not been able to find any documentation
    // on the resolution, but I assume it's about 50-100ms, which is more that precise enough for
    // our purposes.
    _newTime = CFAbsoluteTimeGetCurrent();
    _deltaTime = (_newTime - _lastTime);
    _lastTime = _newTime;
}
-(NSTimeInterval)currentDeltaInSeconds{
    return _deltaTime;
}


- (NSTimeInterval)elapsedGameTime{
    NSAssert(_gameStartedAtDate, @"_gameStartedAtDate was unexpectedly nil!");

    NSTimeInterval elapsedTime;
    // The game has not yet ended.
    if(_gameStoppedAtDate == nil){
        elapsedTime = [[NSDate date] timeIntervalSinceDate:_gameStartedAtDate];
    // The game has ended.
    }else{
        elapsedTime = [_gameStoppedAtDate timeIntervalSinceDate:_gameStartedAtDate];
    }
    NSAssert(elapsedTime >= 0, @"elapsedTime was unexpectedly negative!");
    return elapsedTime;
}

@end
