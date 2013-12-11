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
#import "PerceptConstants.h"
#import <math.h>



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
    if (self) {
        _strategySelectionMechanism = [[Strategy alloc] init];
        // initialize game entities
        _user = [[User alloc] init];
        _zombies = [[NSMutableArray alloc] init];
        _gridMap = [[GridMap alloc]init];
        [self generateZombies:MAX_ZOMBIES];
        
    }
    return self;
}

-(void)generateZombies:(int)amount{
    PathfindingSystem* pathfindingSystem = [[PathfindingSystem alloc]initWithMap:_gridMap];
    
    for (int index = 0; index < amount; index++) {
        /*
        CLLocation* newLoc = [self generateLocationNearPlayer];
        NSAssert(newLoc,
                 @"Failed to generate a new location");
        
        Zombie* zomb = [[Zombie alloc]initWithLocation:newLoc andIdentifier:index];
        NSAssert(zomb,
                 @"Failed to create a zombie");
        
        [_zombies addObject:zomb];
         */
        GridCell* cell = [_gridMap cellAt:0+(index*40)+1 andY:0+(index*10)+1];
        Zombie* zombie = [[Zombie alloc]initWithCellLocation:cell
                                                  identifier:index+1 pathfindingSystem:pathfindingSystem andGameEnvironment:self];
        [_zombies addObject:zombie];
    }
     
}


-(CLLocation*)generateLocationNearPlayer{
    NSArray* randomVector = [MathUtilities randomBaseVector];
//todo: discuss the spawn distance.
    double randomModifier = [MathUtilities randomDoubleNumberBetween:0.0005f and:0.001f];
    CLLocationDegrees longitude = [[randomVector objectAtIndex:0] doubleValue] * randomModifier;
    CLLocationDegrees latitude = [[randomVector objectAtIndex:1] doubleValue] * randomModifier;
    longitude += [[_user location]coordinate].longitude;
    latitude += [[_user location]coordinate].latitude;
    
    // Validate coordinates; make corrections if needed
    if (latitude < -90) {
        latitude += 180;
    } else if (latitude > 90) {
        latitude -= 180;
    }
    if (longitude > 180) {
        longitude -= 360;
    } else if (longitude < -180) {
        longitude += 360;
    }
    
    CLLocation* location = [[CLLocation alloc]initWithLatitude:latitude longitude:longitude];
    
#ifdef DEBUG
    NSLog(@"A location was created %.fmeters away from the player", [[_user location] distanceFromLocation:location]);
#endif
    
    return location;
}

// todo: define those magic strings.
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
    
    // update player position in cell map
    CLLocation* location = [_user location];
    GridCell* playerLoc = [_gridMap cellForCoreLocation:location];
    [_user setCellLocation:playerLoc];
    
    // update percepts for zombies
    for(Zombie* zombie in _zombies){
        [zombie setPerceptLocation:[_user cellLocation]];
    }
    
    // think for the zombies
    for(Zombie* zombie in _zombies){
// todo: according to AI book, the agent himself must be able to determine for how long he wants to think. Maby this is also ok, I dont know.
        [zombie think:deltaTime];
    }
    
    [self renderZombies];
    // update UI stat labels
    
    [self updateUI:deltaTime];
    
}

/**
 *  Sends the list of zombies and their current location over to the view controller.
 */
-(void)renderZombies{
    NSMutableDictionary* zombiesLocations = [NSMutableDictionary dictionary];
    for(Zombie* zombie in _zombies){
        CLLocation* location = [_gridMap coreLocationForCell:[zombie cellLocation]];
        [zombiesLocations setObject:location forKey:[NSNumber numberWithInteger:[zombie identifier]]];
    }
    [[self delegate] renderZombies:zombiesLocations];
}

// check for each zombie
/*
-(void)checkZombieLocations{
    for(Zombie* zomb in _zombies){
        if ([[zomb location] distanceFromLocation:[_user location]] > DISTANCE_FROM_PLAYER_ALLOWED) {
            // if zombie is too far away from the player, create a new location near
            // the player, for that zombie
            [zomb setLocation:[self generateLocationNearPlayer]];
        }
    }
}
 */


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
    
    NSAssert(_engineTimer, @"engine timer is nil");
    NSAssert(_gameloopThread, @"loop is nil");
}

// stop the main loop, invalidate thread and stop timer
- (void)stop {
    // stop the internal timer and thread
    [_gameloopThread invalidate];
    [_engineTimer stop];
}

-(NSInteger)canSeePlayer:(id)sender{
    NSInteger distanceFromPercept = [[_gridMap cellAt:199 andY:0] euclideanDistanceToCell:[(Zombie*)sender cellLocation]];
    
    if (distanceFromPercept <= 5 * 10)
        if ([_gridMap unobstructedLineOfSightFrom:[_gridMap cellAt:199 andY:0] to:[(Zombie*)sender cellLocation]] ) {
            return CLOSE;
        }
    
    
    if (distanceFromPercept <= 10 * 10)
        if ([_gridMap unobstructedLineOfSightFrom:[_gridMap cellAt:199 andY:0] to:[(Zombie*)sender cellLocation]] ) {
            return MEDIUM;
        }
    
    if (distanceFromPercept <= 25 * 10)
        if ([_gridMap unobstructedLineOfSightFrom:[_gridMap cellAt:199 andY:0] to:[(Zombie*)sender cellLocation]] ) {
            return FAR;
        }

    return OUT_OF_RANGE;
}

-(BOOL)obstaclesBetweenZombieAndPlayer:(id)sender {
    return [_gridMap unobstructedLineOfSightFrom:[_gridMap cellAt:199 andY:0] to:[(Zombie*)sender cellLocation]];
}

-(NSInteger)canHearPlayer:(id)sender{
    NSInteger distanceFromPercept = [[_gridMap cellAt:199 andY:0] euclideanDistanceToCell:[(Zombie*)sender cellLocation]];
    
    if (distanceFromPercept <= 10)
        return CLOSE;
    
    if (distanceFromPercept <= 2 * 10)
        return MEDIUM;
    
    if (distanceFromPercept <= 3 * 10)
        return FAR;
    
    return OUT_OF_RANGE;
}

-(BOOL)isDay {
    NSDateFormatter *timeFormat = [[NSDateFormatter alloc] init];
    [timeFormat setDateFormat:@"HH"];
    NSString *theTime = [timeFormat stringFromDate:[NSDate date]];
    NSLog(@"time, %@",theTime);
    
    NSInteger hour = [theTime integerValue];
    if (hour > 8 && hour < 20) {
        return YES;
    }
    else {
        return NO;
    }
}

- (NSInteger)soundLevel{
    //todo finish implementation
    return 2; // running
}

- (NSInteger)selectStrategyForSoundLevel:(NSInteger)soundLevel
                        distanceToPlayer:(NSInteger)distanceToPlayer
                      visibilutyDistance:(NSInteger)visibilityDistance
                     zombieFacingPercept:(NSInteger)zombieFacingPercept
                       obstacleInBetween:(NSInteger)obstacleInBetween
                              dayOrNight:(NSInteger)dayOrNight
                            hearingSkill:(NSInteger)hearingSkill
                             visionSkill:(NSInteger)visionSkill
                                  energy:(NSInteger)energy
              travelingDistanceToPercept:(NSInteger)travelingDistanceToPercept {
    return [self.strategySelectionMechanism selectStrategyForSoundLevel:soundLevel distanceToPlayer:distanceToPlayer visibilutyDistance:visibilityDistance zombieFacingPercept:zombieFacingPercept obstacleInBetween:obstacleInBetween dayOrNight:dayOrNight hearingSkill:hearingSkill visionSkill:visionSkill energy:energy travelingDistanceToPercept:travelingDistanceToPercept];
}

- (BOOL)facingPlayer:(Zombie*)sender {
    const double sixtyDegAsRadians = 1.047;
    
    //NSLog(@"going %d", sender.direction);
    CLLocation *playerLocation = [self.delegate playerLocation];
    GridCell *playerCell = [_gridMap cellForCoreLocation:playerLocation];
    
    NSInteger playerX = 199;//playerCell.xCoord;
    NSInteger playerY = 0;//playerCell.yCoord;
    
    NSInteger zombieX = sender.cellLocation.xCoord;
    NSInteger zombieY = sender.cellLocation.yCoord;
    
    // Player and Zombie on same cell
    if (playerX == zombieX && playerY == zombieY) {
        NSLog(@"Same square, see player");
        return YES;
    }
    
    
    // Zombie facing east
    if (sender.direction == 2) {
        if (playerX < zombieX) return NO; //behind
        NSInteger opposite = playerY-zombieY;
        if (opposite < 0) opposite *= -1;
        double hypotenuse = sqrt(pow(zombieX-playerX,2)+pow(zombieY-playerY,2));
        double radians = asin(opposite / hypotenuse);
        if (radians < sixtyDegAsRadians && radians > -sixtyDegAsRadians) return YES;
    }
    
    // Zombie facing west
    if (sender.direction == 1) {
        if (playerX > zombieX) return NO; //behind
        NSInteger opposite = playerY-zombieY;
        if (opposite < 0) opposite *= -1;
        double hypotenuse = sqrt(pow(zombieX-playerX,2)+pow(zombieY-playerY,2));
        double radians = asin(opposite / hypotenuse);
        if (radians < sixtyDegAsRadians && radians > -sixtyDegAsRadians) return YES;
    }
    
    // Zombie facing north
    if (sender.direction == 10) {
        NSInteger distance = zombieY - playerY;
        if (distance <= 0) return NO; // behind
        
        NSInteger xmax = 2 * ceil(sqrt(3) * distance);
        NSInteger xmin = -xmax;
        
        if (playerX <= xmax && playerX >= xmin) {
            NSLog(@"%ld can see player to north", sender.identifier);
            return YES;
        }
    }
    
    // Zombie facing south
    if (sender.direction == 20) {
        NSInteger distance = playerY - zombieY;
        if (distance <= 0) return NO; // behind
        
        NSInteger xmax = 2 * ceil(sqrt(3) * distance);
        NSInteger xmin = -xmax;
        
        if (playerX <= xmax && playerX >= xmin) {
            NSLog(@"%ld can see player to north", sender.identifier);
            return YES;
        }
    }
    
    // Zombie facing north east
    if (sender.direction == 12) {
        if (playerX < zombieX) // 
            return NO;
    }
    
    /*
     
     
     enum{
     LEFT = 1,
     RIGHT = 2,
     UP = 10,
     UP_LEFT = 11,
     UP_RIGHT = 12,
     DOWN = 20,
     DOWN_LEFT = 21,
     DOWM_RIGHT = 22
     };
     
     */
    return NO;
}


@end
