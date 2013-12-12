//
//  GridMap.h
//  Zombie App
//
//  Created by Brian Pedersen on 24/11/13.
//  Copyright (c) 2013 Aalborg Universitet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GridCell.h"
#import <CoreLocation/CoreLocation.h>

// the width of each tile
#define TILE_WIDTH 56

// the height of each tile
#define TILE_HEIGHT 30

// the width of the map in terms of tiles
#define MAP_WIDTH 100

// the height of the map in terms of tiles
#define MAP_HEIGHT 43

// the origin of the map in terms of latitude and longitude
// multiplied by the conversion factor
// Latitude is y-axis
// Longitude is x-axis

// longitude
#define MAP_X_ORIGIN 9984137

// latitude
#define MAP_Y_ORIGIN 57013643

// conversion factor. This is to get rid of floating-point numbers
#define COORD_CONV_FACTOR 1000000

@interface GridMap : NSObject{
    GridCell* _grid_map[MAP_WIDTH][MAP_HEIGHT];
}

// returns a cell at a specific coordinate
-(GridCell*)cellAt:(NSInteger)x andY:(NSInteger)y;

// returns a list/array of cells, neighbouring a specific cell
-(NSArray*)neighboursForCell:(GridCell*)cell;

// returns a CLLocation object corrosponding to a real-world location, based on
// the location of a cell in the grid map
-(CLLocation*)coreLocationForCell:(GridCell*)cell;

// returns the cell in the grid map corrosponding to a real-world location
-(GridCell*)cellForCoreLocation:(CLLocation*)coreLocation;

-(BOOL)unobstructedLineOfSightFrom:(GridCell*)cellA to:(GridCell*)cellB;
@end
