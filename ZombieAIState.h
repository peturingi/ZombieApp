//
//  ZombieAIState.h
//  Zombie App
//
//  Created by Brian Pedersen on 07/11/13.
//  Copyright (c) 2013 Aalborg Universitet. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Zombie;
@class User;

@protocol ZombieAIState <NSObject>
-(void)processStateFor:(Zombie*)zombie otherZombies:(NSArray*)zombies andPlayer:(User*)user for:(double)deltaTime;


@end

enum {
    ROAM,
    FOLLOW_ZOMBIE,
    CHASE_PLAYER
};