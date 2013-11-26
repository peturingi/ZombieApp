//
//  PathfindingSystem.h
//  Zombie App
//
//  Created by Brian Pedersen on 24/11/13.
//  Copyright (c) 2013 Aalborg Universitet. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GridMap;
@class GridCell;

@interface PathfindingSystem : NSObject{
    GridMap* _gridMap;
}

-(id)initWithMap:(GridMap*)map;

-(NSArray*)pathFromCell:(GridCell*)start toCell:(GridCell*)goal;
@end
