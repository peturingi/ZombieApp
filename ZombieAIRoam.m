//
//  ZombieAIRoam.m
//  Zombie App
//
//  Created by Brian Pedersen on 07/11/13.
//  Copyright (c) 2013 Aalborg Universitet. All rights reserved.
//

#import "ZombieAIRoam.h"
#import "Zombie.h"

@implementation ZombieAIRoam

-(id)init{
    self = [super init];
    if(self){
        _roamPath = [[NSArray alloc]init];
    }
    return self;
}

-(void)executeFor:(Zombie*)zombie withDelta:(double)deltaTime{
    // do something for this zombie when it roams
    
    // if roampath is empty
        // we have either reached our goal or never gotten a path
        // request a random location not too far away
        // get the path from our current location to the goal
    
    // if it is time to move, do so
        // move zombie to next cell in the roampath
        // deduce energy from the zombie depending on the movement
        // ie. diagonal consumes 1.4 times more enegy than vertical or horizontal movement
}

-(void)resetState{
    // do whatever it takes to reset the state
    _roamPath = [[NSArray alloc]init];
}
@end
