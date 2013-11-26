//
//  ZombieAIState.h
//  Zombie App
//
//  Created by Brian Pedersen on 07/11/13.
//  Copyright (c) 2013 Aalborg Universitet. All rights reserved.
//

#import <Foundation/Foundation.h>


// This protocol dictates one method which all zombie AI states must implement as well
// as an enum identifying particular states.
@class Zombie;
@class User;

@protocol ZombieAIState <NSObject>

-(void)executeFor:(Zombie*)zombie withDelta:(double)deltaTime;
-(void)resetState;
@end

enum {
    IDLE,
    ROAM,
    WALK_TO_PLAYER,
    RUN_TO_PLAYER
};