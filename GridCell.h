//
//  GridCell.h
//  Zombie App
//
//  Created by Brian Pedersen on 24/11/13.
//  Copyright (c) 2013 Aalborg Universitet. All rights reserved.
//

#import <Foundation/Foundation.h>

#define DISTANCE_FACTOR 10

@interface GridCell : NSObject
@property (readonly) NSInteger xCoord;
@property (readonly) NSInteger yCoord;

// a-star specific info
@property (getter = isObstacle) BOOL obstacle;
@property GridCell* parent;
@property NSUInteger h_heu;
@property NSUInteger g_score;
@property NSUInteger f_score;

-(id)initWithCoords:(NSInteger)x andY:(NSInteger)y;


-(NSUInteger)manhattanDistanceToCell:(GridCell*)cell;
-(NSUInteger)euclideanDistanceToCell:(GridCell*)cell;
-(NSUInteger)travelCostToNeighbourCell:(GridCell*)neighbourCell;

-(void)resetPathfindingInfo;

// An integer identifier for the cell. Used in optimization
// of the pathfinding algorithm
-(NSUInteger)identifier;

@end
