//
//  GridCell.m
//  Zombie App
//
//  Created by Brian Pedersen on 24/11/13.
//  Copyright (c) 2013 Aalborg Universitet. All rights reserved.
//

#import "GridCell.h"

@implementation GridCell


-(id)initWithCoords:(NSInteger)x andY:(NSInteger)y{
    self = [super init];
    _xCoord = x;
    _yCoord = y;
    [self setObstacle:NO];
    [self resetPathfindingInfo];
    _identifier = (_xCoord * 100) + _yCoord;
    
    return self;
}

-(NSUInteger)manhattanDistanceToCell:(GridCell *)cell{
    NSUInteger distance = 0;
    distance = abs([self xCoord] - [cell xCoord]);
    distance += abs([self yCoord] - [cell yCoord]);
    return distance * DISTANCE_FACTOR;
}

-(NSUInteger)euclideanDistanceToCell:(GridCell*)cell{
    float distance = 0;
    NSUInteger xTot = ([self xCoord] - [cell xCoord]) * ([self xCoord] - [cell xCoord]);
    NSUInteger yTot = ([self yCoord] - [cell yCoord]) * ([self yCoord] - [cell yCoord]);
    distance = sqrt(xTot + yTot);
    return (distance * DISTANCE_FACTOR);
}

-(NSUInteger)travelCostToNeighbourCell:(GridCell*)neighbourCell{
    // be sure it is indeed a neighbour
    NSUInteger distance = [self euclideanDistanceToCell:neighbourCell];
    if(distance >= (2 * DISTANCE_FACTOR)){
        NSAssert(false, @"distance was too great for it to be a neighbour!");
    }
    return distance;
}

-(void)resetPathfindingInfo{
    [self setParent:nil];
    [self setF_score:0];
    [self setG_score:0];
    [self setH_heu:0];
}

@end
