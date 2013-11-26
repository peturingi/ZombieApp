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
                // default all cell to be non-obstacles
                BOOL isObstacle = NO;
                // if the current location is within the bounds of some obstacle, mark it
                // as an obstacle
                if(x == 15 && y > 0 && y < 40){
                    isObstacle = YES;
                }
                
                // instantiate a cell in the current location
                _grid_map[x][y] = [[GridCell alloc]initWithCoords:x andY:y andIsObstacle:isObstacle];
            }
        }
    }
    return self;
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
    NSMutableArray* neighbourCells = [[NSMutableArray alloc]init];
    
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

@end

