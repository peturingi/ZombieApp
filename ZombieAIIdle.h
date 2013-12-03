//
//  ZombieAIIdle.h
//  Zombie App
//
//  Created by Brian Pedersen on 26/11/13.
//  Copyright (c) 2013 Aalborg Universitet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZombieAIState.h"

@interface ZombieAIIdle : NSObject <ZombieAIState>{
    double _idleInterval;
}

@end
