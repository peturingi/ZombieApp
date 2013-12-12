//
//  GridMap.m
//  Zombie App
//
//  Created by Brian Pedersen on 24/11/13.
//  Copyright (c) 2013 Aalborg Universitet. All rights reserved.
//

#import "GridMap.h"

@implementation GridMap
-(id)init{
    self = [super init];
    if(self){
        for(NSUInteger x = 0; x < MAP_WIDTH; x++){
            for(NSUInteger y = 0; y < MAP_HEIGHT; y++){
                // all cells default to be non-obstacles
                // instantiate a cell in the current location
                _grid_map[x][y] = [[GridCell alloc]initWithCoords:x andY:y];
            }
        }
    }
    [self setupObstacles];
    return self;
}

-(void)setupObstacles{
    /*
     Obstacle rectangles
        5,21 - 16,4
        16,21 - 28,16
        39,8 - 55,4
        55,20 - 118,4
        55,39 - 84,23
        90,39 - 118,30
        105,30 - 118,23
        127,39 - 155,23
        161,39 - 192,23
        169,43 - 192,40
        161,18 - 192,4
    */
    /*
    // 5,21 - 16,4
    GridCell* c1 = [self cellAt:5 andY:21];
    GridCell* c2 = [self cellAt:16 andY:4];
    [self markObstacleWithinCorners:c1 and:c2];
    
    // 16,21 - 28,16
    GridCell* c3 = [self cellAt:16 andY:21];
    GridCell* c4 = [self cellAt:28 andY:16];
    [self markObstacleWithinCorners:c3 and:c4];
    
    // 39,8 - 55,4
    GridCell* c5 = [self cellAt:39 andY:8];
    GridCell* c6 = [self cellAt:55 andY:4];
    [self markObstacleWithinCorners:c5 and:c6];
    
    // 55,20 - 118,4
    GridCell* c7 = [self cellAt:55 andY:20];
    GridCell* c8 = [self cellAt:118 andY:4];
    [self markObstacleWithinCorners:c7 and:c8];
    
    // 55,39 - 84,23
    GridCell* c9 = [self cellAt:55 andY:39];
    GridCell* c10 = [self cellAt:84 andY:23];
    [self markObstacleWithinCorners:c9 and:c10];
    
    // 90,39 - 118,30
    GridCell* c11 = [self cellAt:90 andY:39];
    GridCell* c12 = [self cellAt:118 andY:30];
    [self markObstacleWithinCorners:c11 and:c12];
    
    // 105,30 - 118,23
    GridCell* c13 = [self cellAt:105 andY:30];
    GridCell* c14 = [self cellAt:118 andY:23];
    [self markObstacleWithinCorners:c13 and:c14];
    
    // 127,39 - 155,23
    GridCell* c15 = [self cellAt:127 andY:39];
    GridCell* c16 = [self cellAt:155 andY:23];
    [self markObstacleWithinCorners:c15 and:c16];
    
    // 161,39 - 192,23
    GridCell* c17 = [self cellAt:161 andY:39];
    GridCell* c18 = [self cellAt:192 andY:23];
    [self markObstacleWithinCorners:c17 and:c18];
    
    // 169,43 - 192,40
    GridCell* c19 = [self cellAt:169 andY:43];
    GridCell* c20 = [self cellAt:192 andY:40];
    [self markObstacleWithinCorners:c19 and:c20];
    
    // 161,18 - 192,4
    GridCell* c21 = [self cellAt:161 andY:18];
    GridCell* c22 = [self cellAt:192 andY:4];
    [self markObstacleWithinCorners:c21 and:c22];
    */
    
    // used for finetuning overlay when marking areas, 1 point is equal to 1 cell up (as vicualized in red dot if DRAW_CELLS is defined)
    double pointUp = 0.00001;
    double pointRight = pointUp / 2.0;
    
    CLLocation *c01 = [[CLLocation alloc] initWithLatitude:57.014767+pointUp longitude:9.986791];
    CLLocation *c02 = [[CLLocation alloc] initWithLatitude:57.014651+2*pointUp  longitude:9.987445-pointRight];
    [self markObstacleWithCordners:c01 and:c02];
    
    CLLocation *c03 = [[CLLocation alloc] initWithLatitude:57.014633+2*pointUp longitude:9.987223];
    CLLocation *c04 = [[CLLocation alloc] initWithLatitude:57.014574 longitude:9.987625];
    [self markObstacleWithCordners:c03 and:c04];
    
    CLLocation *c05 = [[CLLocation alloc] initWithLatitude:57.014397+3*pointUp longitude:9.987221];
    CLLocation *c06 = [[CLLocation alloc] initWithLatitude:57.014296+3*pointUp longitude:9.987466-4*pointRight];
    [self markObstacleWithCordners:c05 and:c06];
    
    CLLocation *c07 = [[CLLocation alloc] initWithLatitude:57.014552+pointUp longitude:9.987418];
    CLLocation *c08 = [[CLLocation alloc] initWithLatitude: 57.014285+3.0*pointUp longitude:9.987623];
    [self markObstacleWithCordners:c07 and:c08];
    
    CLLocation *c09 = [[CLLocation alloc] initWithLatitude:57.014750+3.0*pointUp longitude:9.985802];
    CLLocation *c10 = [[CLLocation alloc] initWithLatitude:57.014392+3.0*pointUp longitude:9.986626];
    [self markObstacleWithCordners:c09 and:c10];
    
    CLLocation *c11 = [[CLLocation alloc] initWithLatitude:57.014219 longitude: 9.985776];
    CLLocation *c12 = [[CLLocation alloc] initWithLatitude:57.013742 longitude:9.987606];
    [self markObstacleWithCordners:c11 and:c12];
    
}

- (void)markObstacleWithCordners:(CLLocation*)upLeftCorner and:(CLLocation*)downRight {
    GridCell *upRight = [self cellForCoreLocation:upLeftCorner];
    GridCell *downLeft = [self cellForCoreLocation:downRight
                          ];
    [self markObstacleWithinCorners:upRight and:downLeft];
}

/**
 *  The corners are 2 points of a rectangle -- its diagonal.
 *  Mark all of the cells within the rectangle as obstacles.
 */
-(void)markObstacleWithinCorners:(GridCell*)upRightCorner and:(GridCell*)downLeftCorner{
    // maybe check to see up corners are correct
    for(int x = [upRightCorner xCoord]; x <= [downLeftCorner xCoord]; x++){
        for(int y = [downLeftCorner yCoord]; y <= [upRightCorner yCoord]; y++){
            GridCell* cell = _grid_map[x][y];
            [cell setObstacle:YES];
        }
    }
}

// Returns a cell at a specific location in the map.
// If the location is out of bounds or the cell is an obstacle, return nil
-(GridCell*)cellAt:(NSInteger)x andY:(NSInteger)y{
    // are we out of bounds width-wise?
    if(x < 0 || x >= MAP_WIDTH) {
        return nil;
    }
    // are we out of bounds height-wise?
    if(y < 0 || y >= MAP_HEIGHT){
        return nil;
    }
    GridCell* cell = _grid_map[x][y];
    
    // is the cell marked as being an obstacle
    if([cell isObstacle]){
        return nil;
    }
    
    return cell;
}

// Returns a list of neighbours for a specific cell
// Cells counting as neighbours are thos immediatly:
// north, south, east and west of the cell given as parameter
-(NSArray*)neighboursForCell:(GridCell *)cell{
    NSMutableArray* neighbourCells = [[NSMutableArray alloc]initWithCapacity:8];
    
    // exit premature if cell is nil
    if(cell == nil){
        return neighbourCells;
    }
    
    // Add neighbours in all 8 directions. If current location is cell itself,
    // then dont add. Cells returned from cellAt:andY: can be nil if obstacle or
    // out of bounds. In that case, ignore it / do not add.
    for(int x = [cell xCoord] - 1; x <= [cell xCoord] + 1; x++){
        for(int y = [cell yCoord] - 1; y <= [cell yCoord] + 1; y++){
            if(x == [cell xCoord] && y == [cell yCoord]){
                continue;
            }
            GridCell* neighbour = [self cellAt:x andY:y];
            if(neighbour){
                [neighbourCells addObject:neighbour];
            }
        }
    }
    return neighbourCells;
}

-(CLLocation*)coreLocationForCell:(GridCell*)cell{
    int latitudeInteger = MAP_Y_ORIGIN + ([cell yCoord] * TILE_HEIGHT);
    CLLocationDegrees latitude = (double)latitudeInteger / (double)COORD_CONV_FACTOR;
    
    int longitudeInteger = MAP_X_ORIGIN + ([cell xCoord] * TILE_WIDTH);
    CLLocationDegrees longitude = (double)longitudeInteger / (double)COORD_CONV_FACTOR;
    
    CLLocation* location = [[CLLocation alloc]initWithLatitude:latitude longitude:longitude];
    return location;
}

-(GridCell*)cellForCoreLocation:(CLLocation*)coreLocation{
    CLLocationDegrees latitude = [coreLocation coordinate].latitude;
    CLLocationDegrees longitute = [coreLocation coordinate].longitude;
    
    int cellYCoord = ((COORD_CONV_FACTOR * latitude) - MAP_Y_ORIGIN) / TILE_HEIGHT;
    int cellXCoord = ((COORD_CONV_FACTOR * longitute) - MAP_X_ORIGIN) / TILE_WIDTH;
    GridCell* cell = [self cellAt:cellXCoord andY:cellYCoord];
    return cell;
}

-(BOOL)unobstructedLineOfSightFrom:(GridCell*)cellA to:(GridCell*)cellB{
    // use bresenham's line algorithm to determine the cells intersected by the line of sight
    // between point A and B (cellA and cellB)
    
    // trivial cases
    
    // most trivial case - both points are the same
    if([cellA isEqual:cellB]){
        return YES;
    }
    
    // line of sight is vertical
    if([cellA xCoord] == [cellB xCoord]){
        // flip cells if cellA has larger y component than cellB
        if([cellA yCoord] > [cellB yCoord]){
            GridCell* temp = cellA;
            cellA = cellB;
            cellB = temp;
        }
        int x = [cellA xCoord];
        for(int y = [cellA yCoord]; y <= [cellB yCoord]; y++){
            GridCell* cell = _grid_map[x][y];
            if([cell isObstacle]){
                return NO;
            }
        }
        return YES;
    }
    
    // line of sight is horizontal
    if([cellA yCoord] == [cellB yCoord]){
        // flip cells if cellA has larger x component than cellB
        if([cellA xCoord] > [cellB xCoord]){
            GridCell* temp = cellA;
            cellA = cellB;
            cellB = temp;
        }
        int y = [cellA yCoord];
        for(int x = [cellA xCoord]; x <= [cellB xCoord]; x++){
            GridCell* cell = _grid_map[x][y];
            if([cell isObstacle]){
                return NO;
            }
        }
        return YES;
        
    }
    
    // trivial cases end
    
    // special cases
    
    // make sure cellA is the cell which is left-most (has smallest x component)
    if([cellA xCoord] > [cellB xCoord]){
        GridCell* temp = cellA;
        cellA = cellB;
        cellB = temp;
    }
    
    // slope is positive
    int deltaX = [cellB xCoord] - [cellA xCoord];
    int deltaY = [cellB yCoord] - [cellA yCoord];
    
    double slope = (double)deltaY / (double)deltaX;
    
    // slope is greater than 1 (eg. 2.4)
    if(slope > 1){
        slope = (double)deltaX / (double)deltaY;
        double x = [cellA xCoord];
        for(int y = [cellA yCoord]; y <= [cellB yCoord]; y++){
            GridCell* cell = _grid_map[(int)x][y];
            if([cell isObstacle]){
                return NO;
            }
            x += slope;
        }
        return YES;
    }
    
    // slope is between 0 and 1(eg. 0.6)
    if(slope <= 1 && slope > 0){
        double y = [cellA yCoord];
        for(int x = [cellA xCoord]; x <= [cellB xCoord]; x++){
            GridCell* cell = _grid_map[x][(int)y];
            if([cell isObstacle]){
                return NO;
            }
            y += slope;
        }
        return YES;
    }
    
    // slope is negative
    // slope is between 0 and -1 (eg. -0.6)
    if(slope <= 0 && slope >= -1){
        double y = [cellA yCoord];
        for(int x = [cellA xCoord]; x <= [cellB xCoord]; x++){
            GridCell* cell = _grid_map[x][(int)y];
            if([cell isObstacle]){
                return NO;
            }
            y += slope;
        }
        return YES;
    }
    
    // slope is less than -1 (eg. -1.6)
    if(slope < -1){
        slope = (double)deltaX / (double)deltaY;
        slope = -slope;
        double x = [cellA xCoord];
        for(int y = [cellA yCoord]; y >= [cellB yCoord]; y--){
            GridCell* cell = _grid_map[(int)x][y];
            if([cell isObstacle]){
                return NO;
            }
            x += slope;
        }
        return YES;
    }
    
    // should never reach this point!
    return YES;
}
@end

