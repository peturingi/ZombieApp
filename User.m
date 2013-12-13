//
//  User.m
//  Zombie App
//
//  Created by Pétur Ingi Egilsson on 14/10/13.
//  Copyright (c) 2013 Aalborg Universitet. All rights reserved.
//

#import "User.h"

@implementation User


- (void)registerObservers {
    // listen for updates on position from the notification center
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didUpdatePosition:) name:@"didUpdatePlayerPosition" object:nil];
}

/**
 *  Creates a new instance of the object. The startedPlaying time is set to the current date.
 *  @return A new instance of User.
 */
- (id)init{
    self = [super init];
    if(self){
        [self registerObservers];
        self.speed = 0.0f;
    }
    return self;
}


-(void)didUpdatePosition:(NSNotification*)aNotification{
    NSAssert([[aNotification object] isKindOfClass:[CLLocation class]],
             @"Expected CLLocation, received:%@", NSStringFromClass([[aNotification object] class]));
    
    CLLocation* location = [aNotification object];
    NSAssert(location, @"location cannot be nil!");
    
    CLLocationDistance distanceTraveled = [self.location distanceFromLocation:location];
    NSTimeInterval travelDuration = [location.timestamp timeIntervalSinceDate:self.location.timestamp];
    
    // Speed in KM/H
    NSInteger speed = distanceTraveled*0.001 / travelDuration * 3600.0;
    if (speed >= 0) self.speed = speed;
    
    // update location
    [self setLocation:location];
        
    // update distance travelled
    if (!_previousLocation) {
        _previousLocation = location;
    }else{
        self.distanceTravelledInMeters += [_previousLocation distanceFromLocation:location];
        _previousLocation = location;
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)reset {
    self.cellLocation = nil;
    self.speed = 0.0f;
    self.distanceTravelledInMeters = 0.0f;
    self.location = nil;
    _previousLocation = nil;
}

@end
