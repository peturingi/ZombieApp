//
//  Zombie.h
//  Zombie App
//
//  Created by Brian Pedersen on 04/11/13.
//  Copyright (c) 2013 Aalborg Universitet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "User.h"
#import "ZombieState.h"

// distinct zombie states


@interface Zombie : NSObject{
    NSMutableDictionary* _zombieStates;
    //ZombieState* _currentState;
}

@property CLLocation* location;

-(id)initWithLocation:(CLLocation*)location;


-(void)think:(NSArray*)otherZombies andPlayer:(User*)user for:(double)deltaTime;
@end
