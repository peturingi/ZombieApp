//
//  MathUtilities.m
//  Zombie App
//
//  Created by Brian Pedersen on 08/11/13.
//  Copyright (c) 2013 Aalborg Universitet. All rights reserved.
//

#import "MathUtilities.h"

#define MULTIPLIER_CONSTANT 100000.f
#define PI_INTEGER (M_PI * MULTIPLIER_CONSTANT)
@implementation MathUtilities

#warning use NSInteger.
+(int)randomNumberBetween:(int)from and:(int)to{
    return (int)from + arc4random() % (to-from+1);
}

#warning use NSInteger. Also, possible overflow?
+(double)randomDoubleNumberBetween:(double)from and:(double)to{
    int fromAsInt = from * MULTIPLIER_CONSTANT;
    int toAsInt = to * MULTIPLIER_CONSTANT;
    double result = [self randomNumberBetween:fromAsInt and:toAsInt];
    result = result / MULTIPLIER_CONSTANT;
    return result;
}

+(double)randomBaseCoord{
    return [self randomNumberBetween:0 and:2 * PI_INTEGER] / MULTIPLIER_CONSTANT;
}

+(NSArray*)randomBaseVector{
    double randBC = [self randomBaseCoord];
    NSNumber* rand_x = [NSNumber numberWithDouble:cos(randBC)];
    NSNumber* rand_y = [NSNumber numberWithDouble:sin(randBC)];
    NSArray* vect = [NSArray arrayWithObjects:rand_x, rand_y, nil];
    return vect;
}
@end


