//
//  ZombieAISprint.h
//  Zombie App
//
//  Created by Brian Pedersen on 27/11/13.
//  Copyright (c) 2013 Aalborg Universitet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZombieAIState.h"

@interface ZombieAISprint : NSObject <ZombieAIState>{
    NSArray* _sprintPath;
    int _sprintPathIndex;
    double _sprintInterval;
}

@end
