//
//  MathUtilities.h
//  Zombie App
//
//  Created by Brian Pedersen on 08/11/13.
//  Copyright (c) 2013 Aalborg Universitet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MathUtilities : NSObject

+(double)randomBaseCoord;
+(NSArray*)randomBaseVector;
+(double)randomDoubleNumberBetween:(double)from and:(double)to;
+(int)randomNumberBetween:(int)from and:(int)to;
@end
