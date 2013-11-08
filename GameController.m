//
//  GameController.m
//  Zombie App
//
//  Copyright (c) 2013 Aalborg Universitet. All rights reserved.
//

#import "GameController.h"
#import "MapViewController.h"
#import "Zombie.h"
#import "MathUtilities.h"

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
    _user = [[User alloc] init];
    _zombies = [[NSMutableArray alloc] init];
    [self generateZombies:MAX_ZOMBIES];
    
    return self;
}

-(void)generateZombies:(int)amount{
    for (int index = 0; index < amount; index++) {
        CLLocation* newLoc = [self generateLocationNearPlayer];
        Zombie* zomb = [[Zombie alloc]initWithLocation:newLoc andIdentifier:index];
        [_zombies addObject:zomb];
    }
}

-(CLLocation*)generateLocationNearPlayer{
    NSArray* randomVector = [MathUtilities randomBaseVector];
    double randomModifier = [MathUtilities randomDoubleNumberBetween:0.0005f and:0.001f];
    CLLocationDegrees longitude = [[randomVector objectAtIndex:0] doubleValue] * randomModifier;
    CLLocationDegrees latitude = [[randomVector objectAtIndex:1] doubleValue] * randomModifier;
    longitude += [[_user location]coordinate].longitude;
    latitude += [[_user location]coordinate].latitude;
    CLLocation* location = [[CLLocation alloc]initWithLatitude:latitude longitude:longitude];
    NSLog(@"A location was created %.fmeters away from the player", [[_user location] distanceFromLocation:location]);
    return location;
}
- (NSDictionary *)stats{
    NSMutableDictionary *statistics = [NSMutableDictionary dictionary];
    
    NSNumber* elapsedGameTime = [NSNumber numberWithDouble:[_engineTimer elapsedGameTime]];
    [statistics setValue:elapsedGameTime forKey:@"elapsedGameTime"];
    
    NSNumber* userSpeed = [NSNumber numberWithDouble:[_user speed]];
    [statistics setValue:userSpeed forKey:@"userSpeed"];
    
    NSNumber* userDistance = [NSNumber numberWithDouble:[_user distanceTravelledInMeters]];
    [statistics setObject:userDistance forKey:@"userDistance"];
    
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
    for(Zombie* zombie in _zombies){
        [zombie think:_zombies andPlayer:_user forDuration:deltaTime];
    }
    // check if any zombies got too far away
    [self checkZombieLocations];
    // update display (mapview) with zombie locations
    // update UI stat labels
    [self updateUI:deltaTime];
    
}

// check for each zombie 
-(void)checkZombieLocations{
    for(Zombie* zomb in _zombies){
        if ([[zomb location] distanceFromLocation:[_user location]] > DISTANCE_FROM_PLAYER_ALLOWED) {
            // if zombie is too far away from the player, create a new location near
            // the player, for that zombie
            [zomb setLocation:[self generateLocationNearPlayer]];
        }
    }
}


// notifies the delegate, game info has updated.
-(void)updateUI:(double)deltaTime{
    static double timeTillUpdate = UPDATE_UI_INTERVAL;
    timeTillUpdate -= deltaTime;
    if (timeTillUpdate < 0) {
        [_delegate didUpdateGameInfo:[self stats]];
        timeTillUpdate = UPDATE_UI_INTERVAL;
    }
}

#pragma mark - Start/Stop/Restart.

// start the game engine main loop
- (void)start {
    // initialize the internal timer and thread
    _engineTimer = [[EngineTimer alloc]init];
    _gameloopThread = [NSTimer scheduledTimerWithTimeInterval:UPDATE_GAME_INTERVAL target:self selector:@selector(gameloop) userInfo:nil repeats:YES];
}

// stop the main loop, invalidate thread and stop timer
- (void)stop {
    // stop the internal timer and thread
    [_gameloopThread invalidate];
    [_engineTimer stop];
}


@end
