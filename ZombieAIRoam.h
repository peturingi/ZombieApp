//
//  ZombieAIRoam.h
//  Zombie App
//
//  Created by Brian Pedersen on 07/11/13.
//  Copyright (c) 2013 Aalborg Universitet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZombieAIState.h"

// This is an example of an implementation of a ZombieAIState
@interface ZombieAIRoam : NSObject <ZombieAIState>{
    NSArray* _roamPath;
}

@end
