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
    }
    return self;
}


-(void)didUpdatePosition:(NSNotification*)aNotification{
    NSAssert([[aNotification object] isKindOfClass:[CLLocation class]],
             @"Expected CLLocation, received:%@", NSStringFromClass([[aNotification object] class]));
    
    CLLocation* location = [aNotification object];
    NSAssert(location, @"location cannot be nil!");
    // update location
    [self setLocation:location];
    
#warning not needed. The speed is already stored as part of self.location. Remove?
    // update speed
    CLLocationSpeed speed = [location speed];
    // Make sure the user does not see a negative value due to inaccuracy.
    if(speed < 0){
        [self setSpeed:0];
    }else{
        [self setSpeed:speed];
    }
        
    // update distance travelled
    if (!_previousLocation) {
        _previousLocation = location;
    }else{
        self.distanceTravelledInMeters += [_previousLocation distanceFromLocation:location];
        _previousLocation = location;
    }
}


@end
