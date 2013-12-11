//
//  Los.m
//  LineOfSight
//
//  Created by Pétur Ingi Egilsson on 10/12/13.
//  Copyright (c) 2013 Pétur Ingi Egilsson. All rights reserved.
//

#import "Los.h"
#import <math.h>

@implementation Los

+ (BOOL)playerIsInLineOfSight:(double)zombieX zombieY:(double)zombieY playerX:(double)playerX playerY:(double)playerY directionAsRadian:(double)direction fieldOfViewAsRadian:(double)fieldOfView{
    
    // Error checking.
    if (direction > 2.0 * M_PI || direction < 0) @throw [NSException exceptionWithName:@"Invalid argument" reason:@"Direction must be between 0 and 2PI" userInfo:nil];
    if (fieldOfView > 2.0 * M_PI || fieldOfView < 0) @throw [NSException exceptionWithName:@"Invalid argument" reason:@"Field of view must between 0 and 2PI" userInfo:nil];
    
    // Trivial case. Can always see zombie if in same location.
    if (zombieX == playerX && zombieY == playerY) {
        return YES;
    }
    
    // Create two radians. Each representing the a point on the unit circle. The visual field of view spans between the two points.
    double leftMostPoint = direction + fieldOfView / 2.0;
    double rightMostPoint = direction - fieldOfView / 2.0;
    
    // Math stuff.
    double hypotenuse = sqrt( pow((zombieX-playerX),2.0) + pow((zombieY-playerY),2.0) ); // Eucledian distance
    double adjacent = (double)playerX-zombieX;
    double opposite = (double)playerY-zombieY;
    double playerCosine = adjacent / hypotenuse; // Range -1 to 1
    double playerSine = opposite / hypotenuse; // Range -1 to 1
    
    // Where on the unit circle is the player?
    // Represent the angle towards the player, from the zombie, as a radiain.
    double playerRadian = 0;
    if (playerSine >= 0) {
        // Upper part of the unit circle
        playerRadian = acos(playerCosine);
    } else {
        if (playerSine <= 0) {
            // Lower part of the unit circle
            playerRadian = 2 * M_PI - acos(playerCosine);
        }
    }
    
    // Is the player within the zombies visual field?
    if (leftMostPoint >= playerRadian && playerRadian >= rightMostPoint) {
        return YES;
    } else {
        return NO;
    }
}
@end
