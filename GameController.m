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
#import "GridCell.h"



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
#ifdef SINGLE_ZOMBIE
    amount = 1;
#endif
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
        GridCell* cell;
        while (!cell || cell.isObstacle) {
            cell = [_gridMap cellAt:[MathUtilities randomNumberBetween:0 and:199] andY:[MathUtilities randomNumberBetween:0 and:41]];

        }
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
    
    if (playerLoc) {
    // think for the zombies
    for(Zombie* zombie in _zombies){
        [zombie setPerceptLocation:[_user cellLocation]];
        zombie.facingPercept = [self isPlayerWithinFieldOfView:zombie.cellLocation.xCoord andMyYCoordinate:zombie.cellLocation.yCoord myDirection:zombie.directionAsRadian myFieldOfView:2.0 * M_PI / 3.0];
        zombie.obstaclesBetweenZombieAndPlayer = [self obstaclesBetweenZombieAndPlayer:zombie];
        zombie.lineOfSight = !zombie.obstaclesBetweenZombieAndPlayer;
        zombie.distanceToHearingPercept = [self canHearPlayer:zombie];
        zombie.soundLevelOfHearingPercept = [self soundLevel];
        zombie.distanceToVisualPercept = [self visualRangeToPlayer:zombie];
        
        [zombie think:deltaTime];
        
        if (playerLoc == zombie.cellLocation)
        {
            // Game over!
            [_delegate gameOver];
        }
    }
    }
    
    [self renderZombies];
    // update UI stat labels
    
    [self updateUI:deltaTime];
    
}

/**
 *  Sends the list of zombies and their current location over to the view controller.
 */
-(void)renderZombies{
    [self updateGPSLocationOfEveryZombie];
    [[self delegate] renderZombies:_zombies];
}

- (void)updateGPSLocationOfEveryZombie {
    for (Zombie *z in _zombies) {
        z.gpsLocation = [_gridMap coreLocationForCell:z.cellLocation];
    }
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

-(NSInteger)visualRangeToPlayer:(id)sender{
    NSInteger distanceFromPercept = [[_gridMap cellAt:199 andY:0] euclideanDistanceToCell:[(Zombie*)sender cellLocation]];
    
#ifdef DEV_TOUCH_MODE
    distanceFromPercept = [[_gridMap cellForCoreLocation:[_user location]] euclideanDistanceToCell:[(Zombie*)sender cellLocation]];
#endif
    
    if (distanceFromPercept <= 50 * 10)
        if ([_gridMap unobstructedLineOfSightFrom:[_gridMap cellAt:199 andY:0] to:[(Zombie*)sender cellLocation]] ) {
            return CLOSE;
        }
    
    
    if (distanceFromPercept <= 60 * 10)
        if ([_gridMap unobstructedLineOfSightFrom:[_gridMap cellAt:199 andY:0] to:[(Zombie*)sender cellLocation]] ) {
            return MEDIUM;
        }
    
    if (distanceFromPercept <= 70 * 10)
        if ([_gridMap unobstructedLineOfSightFrom:[_gridMap cellAt:199 andY:0] to:[(Zombie*)sender cellLocation]] ) {
            return FAR;
        }

    return FAR;
}

-(BOOL)obstaclesBetweenZombieAndPlayer:(id)sender {
#ifdef DEV_TOUCH_MODE
    return ![_gridMap unobstructedLineOfSightFrom:[_user cellLocation] to:[(Zombie*)sender cellLocation]];
#endif
    return ![_gridMap unobstructedLineOfSightFrom:[_gridMap cellAt:199 andY:0] to:[(Zombie*)sender cellLocation]];
}

-(NSInteger)canHearPlayer:(id)sender{
    NSInteger distanceFromPercept = [[_user cellLocation] euclideanDistanceToCell:[(Zombie*)sender cellLocation]];
    
    if (distanceFromPercept <= 100)
        return CLOSE;
    
    if (distanceFromPercept <= 2 * 200)
        return MEDIUM;
    
    // else far.
    return FAR;
}

-(BOOL)isDay {
    NSDateFormatter *timeFormat = [[NSDateFormatter alloc] init];
    [timeFormat setDateFormat:@"HH"];
    NSString *theTime = [timeFormat stringFromDate:[NSDate date]];
    //NSLog(@"time, %@",theTime);
    
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

- (BOOL)isPlayerWithinFieldOfView:(NSInteger)myXCoordinate andMyYCoordinate:(NSInteger)myYcoordinate myDirection:(double)directionAsRadian myFieldOfView:(double)fieldOfView {
    
    GridCell *playerCell = [_gridMap cellForCoreLocation:_user.location];
    NSAssert(playerCell, @"Failed to get player cell");
    
    BOOL value = [self playerIsInLineOfSight:myXCoordinate zombieY:myYcoordinate playerX:playerCell.xCoord playerY:playerCell.yCoord directionAsRadian:directionAsRadian fieldOfViewAsRadian:fieldOfView];
    
    return value;
}

- (BOOL)playerIsInLineOfSight:(double)zombieX zombieY:(double)zombieY playerX:(double)playerX playerY:(double)playerY directionAsRadian:(double)direction fieldOfViewAsRadian:(double)fieldOfView{
    
    // Error checking.
    if (direction > 2.0 * M_PI || direction < 0) @throw [NSException exceptionWithName:@"Invalid argument" reason:@"Direction must be between 0 and 2PI" userInfo:nil];
    if (fieldOfView > 2.0 * M_PI || fieldOfView < 0) @throw [NSException exceptionWithName:@"Invalid argument" reason:@"Field of view must between 0 and 2PI" userInfo:nil];
    
    // Trivial case. Can always see zombie if in same location.
    if (zombieX == playerX && zombieY == playerY) {
        return YES;
    }
    
    // Create two radians. Each representing the a point on the unit circle. The visual field of view spans between the two points.
    double leftMostPoint = direction + fieldOfView / 2.0;
    double rightMostPoint = direction - fieldOfView / 2.0;

    
    // Math stuff.
    double hypotenuse = sqrt( pow((zombieX-playerX),2.0) + pow((zombieY-playerY),2.0) ); // Eucledian distance
    double adjacent = (double)playerX-zombieX;
    double opposite = (double)playerY-zombieY;
    double playerCosine = adjacent / hypotenuse; // Range -1 to 1
    double playerSine = opposite / hypotenuse; // Range -1 to 1
    
    // Where on the unit circle is the player?
    // Represent the angle towards the player, from the zombie, as a radiain.
    double playerRadian = 0;
    if (playerSine >= 0) {
        // Upper part of the unit circle
        playerRadian = acos(playerCosine);
    } else {
        if (playerSine <= 0) {
            // Lower part of the unit circle
            playerRadian = 2 * M_PI - acos(playerCosine);
        }
    }
    if (rightMostPoint < 0.0) {
        rightMostPoint += 2.0 * M_PI;
        leftMostPoint += 2.0 * M_PI;
    }
    if ((rightMostPoint > 2.0 * M_PI || leftMostPoint > 2.0 * M_PI) && playerRadian < M_PI)
        playerRadian += 2.0 * M_PI;
    
    // Is the player within the zombies visual field?
    if (leftMostPoint >= playerRadian && playerRadian >= rightMostPoint) {
        NSLog(@"I see the player!");
        return YES;
    } else {
        return NO;
    }
}


@end
