//
//  Zombie.m
//  Zombie App
//
//  Created by Brian Pedersen on 04/11/13.
//  Copyright (c) 2013 Aalborg Universitet. All rights reserved.
//

#import "Zombie.h"

@implementation Zombie

-(id)initWithLocation:(CLLocation*)location{
    self = [super init];
    if(self){
        self.location = location;
    }
    return self;
}


-(void)think:(NSArray*)otherZombies andPlayer:(User*)user for:(double)deltaTime{
    
}
@end
