//
//  PathfindingSystem.h
//  Zombie App
//
//  Created by Brian Pedersen on 24/11/13.
//  Copyright (c) 2013 Aalborg Universitet. All rights reserved.
//

#import <Foundation/Foundation.h>
@class GridCell;
#import "GridMap.h"


@interface PathfindingSystem : NSObject{
    // these are the open and closed sets
    // dictionaries are primarily used over arrays as an optimization.
    // looking up in the dictionary to see if a particular object
    // has been added to the open or closed list, is O(n). However, it
    // is more often O(1), thus often faster than linear array search O(n).
    NSMutableDictionary* _openSetDict;
    NSMutableDictionary* _closedSetDict;
    
    BOOL openSetEmpty;
    NSInteger openSetIndex;
    GridCell *openSet[MAP_HEIGHT * MAP_WIDTH];

    
    BOOL openSetContains[MAP_WIDTH][MAP_HEIGHT];
    BOOL closedSetContains[MAP_WIDTH][MAP_HEIGHT];
    
    int _openSetSize;
}

-(id)initWithMap:(GridMap*)map;
@property GridMap* gridMap;

-(NSArray*)pathFromCell:(GridCell*)start toCell:(GridCell*)goal;
@end
