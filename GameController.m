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
    __strong static id _sharedObject = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedObject = [[self alloc]init];
    });
    return _sharedObject;
}

-(id)init{
    self = [super init];
    
    _user = [[User alloc] init];
    
    return self;
}

- (NSDictionary *)stats {
    NSMutableDictionary *statistics = [NSMutableDictionary dictionary];
    
    [statistics setValue:[NSNumber numberWithDouble:[_user elapsedPlayingTime]]
                  forKey:@"playingTime"];
    
    return statistics;
}

/**
 *  This is the main gameloop.
 */
- (void)gameloop {
}

/**
 *  Notifies the delegate, that the time has changed.
 */
-(void)updateTime{
    NSAssert(_user,
             @"User was nil! Can not get elapsed time!");
    NSTimeInterval elapsedPlayingTime = [_user elapsedPlayingTime];
    [_delegate elapsedTimeUpdated:elapsedPlayingTime];
}

#pragma mark - Start/Stop/Restart.

- (void)start {
    // User setup.
    NSAssert(_user,
             @"User is nil");
    
    [_user setStartedPlaying:[NSDate date]];
    timer_updateTime = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(updateTime) userInfo:nil repeats:YES];
}

- (void)stop {
    [timer_updateTime invalidate];
    [_user setStoppedPlaying:[NSDate date]];
}


@end
