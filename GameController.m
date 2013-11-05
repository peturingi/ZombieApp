//
//  GameController.m
//  Zombie App
//
//  Copyright (c) 2013 Aalborg Universitet. All rights reserved.
//

#import "GameController.h"
#import "MapViewController.h"

@implementation GameController

+(id)sharedInstance
{
    // boilerplate singleton code
    __strong static id _sharedObject = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedObject = [[self alloc]init];
    });
    return _sharedObject;
}

-(id)init{
    self = [super init];
    
    // initialize game entities
    _zombies = [[NSMutableArray alloc] init];
    _user = [[User alloc] init];
    
    return self;
}


- (NSDictionary *)stats{
    NSMutableDictionary *statistics = [NSMutableDictionary dictionary];
    [statistics setValue:[NSNumber numberWithDouble:[_engineTimer elapsedGameTime]]
                  forKey:@"playingTime"];
    
    return statistics;
}

/**
 *  This is the main gameloop.
 */
-(void)gameloop{
    // update time
    [_engineTimer update];
    double deltaTime = [_engineTimer currentDeltaInSeconds];
    // think for the zombies
    // check if any zombies got too far away
        // if so, then delete that/those zombies and spawn them again at random locations around the player
    // update display (mapview)
    [self updateUI:deltaTime];
}

/**
 *  Notifies the delegate, that the time has changed.
 */
-(void)updateUI:(double)deltaTime{
    static double timeTillUpdate = UPDATE_UI;
    timeTillUpdate -= deltaTime;
    if (timeTillUpdate < 0) {
        NSMutableDictionary* info = [NSMutableDictionary dictionary];
        NSNumber* elapsedGameTime = [NSNumber numberWithDouble:[_engineTimer elapsedGameTime]];
        [info setValue:elapsedGameTime forKey:@"elapsedGameTime"];
        NSNumber* speed = [NSNumber numberWithDouble:[_user speed]];
        [info setValue:speed forKey:@"speed"];
        NSNumber* distance = [NSNumber numberWithDouble:[_user distanceTravelledInMeters]];
        [info setValue:distance forKey:@"distance"];
        [_delegate didUpdateGameInfo:info];
        timeTillUpdate = UPDATE_UI;
    }
}

#pragma mark - Start/Stop/Restart.

- (void)start {
    // initialize the internal timer and thread
    _engineTimer = [[EngineTimer alloc]init];
    _gameloopThread = [NSTimer scheduledTimerWithTimeInterval:UPDATE_INTERVAL target:self selector:@selector(gameloop) userInfo:nil repeats:YES];
}

- (void)stop {
    // stop the internal timer and thread
    [_gameloopThread invalidate];
    [_engineTimer stop];
}


@end
