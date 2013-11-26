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
@property (readonly, getter = isObstacle) BOOL obstacle;
@property GridCell* parent;
@property int h_heu;
@property int g_score;
@property int f_score;

-(id)initWithCoords:(NSInteger)x andY:(NSInteger)y andIsObstacle:(BOOL)isObstacle;


-(NSUInteger)manhattanDistanceToCell:(GridCell*)cell;
-(NSUInteger)euclideanDistanceToCell:(GridCell*)cell;
-(NSUInteger)travelCostToNeighbourCell:(GridCell*)neighbourCell;

-(void)resetPathfindingInfo;
@end
