//
//  Los.h
//  LineOfSight
//
//  Created by Pétur Ingi Egilsson on 10/12/13.
//  Copyright (c) 2013 Pétur Ingi Egilsson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Los : NSObject
+ (BOOL)playerIsInLineOfSight:(double)zombieX zombieY:(double)zombieY playerX:(double)playerX playerY:(double)playerY directionAsRadian:(double)direction fieldOfViewAsRadian:(double)radians;
@end
