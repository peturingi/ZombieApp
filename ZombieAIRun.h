//
//  ZombieAIRun.h
//  Zombie App
//
//  Created by Brian Pedersen on 27/11/13.
//  Copyright (c) 2013 Aalborg Universitet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZombieAIState.h"

@interface ZombieAIRun : NSObject <ZombieAIState>{
    NSArray* _runPath;
    int _runPathIndex;
    double _runInterval;
}

@end
