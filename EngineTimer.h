//
//  EngineTimer.h
//  Zombie App
//
//  Created by Brian Pedersen on 04/11/13.
//  Copyright (c) 2013 Aalborg Universitet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EngineTimer : NSObject{
    double _deltaTime;
    double _lastTime;
    double _newTime;
    NSDate* _gameStartedAtDate;
    NSDate* _gameStoppedAtDate;
}

-(id)init;

-(void)update;
-(double)currentDeltaInSeconds;
-(void)stop;

-(NSTimeInterval)elapsedGameTime;

@end
