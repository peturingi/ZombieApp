//
//  PathfindingSystem.m
//  Zombie App
//
//  Created by Brian Pedersen on 24/11/13.
//  Copyright (c) 2013 Aalborg Universitet. All rights reserved.
//

#import "PathfindingSystem.h"
#import "GridMap.h"


@implementation PathfindingSystem


-(id)initWithMap:(GridMap*)map{
    self = [super init];
    if(self){
        NSAssert(map, @"Map was null!");
        _gridMap = map;
    }
    return self;
}

// Returns a list of cells in the path found from 'start' to 'goal'.
// If no path is found, either due to inaccesible or invalid cells as input,
// nil is returned.
-(NSArray*)pathFromCell:(GridCell*)start toCell:(GridCell*)goal{
    // sane check to see if either start or goal are valid cell locations
    if(start == nil || goal == nil){
        return nil;
    }
    // Cells which have been checked
    NSMutableArray* closedSet = [[NSMutableArray alloc]init];
    // Cells currently in the frontier
    NSMutableArray* openSet = [[NSMutableArray alloc]init];
    
    // initially, add the start node to the openSet
    [openSet addObject:start];
    
    // g() for the start cell is 0, as there is no cost associated
    // with traveling to the start cell
    [start resetPathfindingInfo];
    
    // the effective cost is f() = g() + h(). In this case 0 + heuristic cost to the goal cell.
    [start setF_score:[start g_score] + [start euclideanDistanceToCell:goal]];
    
    // while openSet is not empty
    while([openSet count] > 0){
        openSet = [self sortOpenSet:openSet];
        GridCell* current = [openSet firstObject];
        
        // goal check
        /*
        if([current isEqual:goal]){
            // construct path and return
            return [self constructPath:current];
        }
         */
        if([closedSet containsObject:goal]){
            return [self constructPath:goal];
        }
        
        
        // remove current cell from the frontier
        [openSet removeObject:current];
        // add the current cell to the list of checked cells
        [closedSet addObject:current];
        
        
        
        int tentative_g_score = 0;
        int tentative_f_score = 0;
        // Evaluate each neighbour and add it to the open list.
        // If a neighbour is in the closed list, ignore it, unless an smaller f() can be achieved
        // from the current cell.
        for(GridCell* neighbour in [_gridMap neighboursForCell:current]){
            // if neighbour is not present in any of the lists, reset it for reentrancy
            if(![closedSet containsObject:neighbour] && ![openSet containsObject:neighbour]){
                [neighbour resetPathfindingInfo];
            }
            tentative_g_score = [current g_score] + [current travelCostToNeighbourCell:neighbour];
            tentative_f_score = tentative_g_score + [neighbour euclideanDistanceToCell:goal];
            
            if([closedSet containsObject:neighbour] && tentative_f_score >= [neighbour f_score]){
                continue;
            }
            
            if(![openSet containsObject:neighbour] || tentative_f_score < [neighbour f_score]){
                [neighbour setParent:current];
                [neighbour setG_score:tentative_g_score];
                [neighbour setF_score:tentative_f_score];
                
                if(![openSet containsObject:neighbour]){
                    [openSet addObject:neighbour];
                }
            }
        }
    }
    return nil;
}

-(NSArray*)constructPath:(GridCell*)goal{
    GridCell* current = goal;
    NSMutableArray* path = [[NSMutableArray alloc]init];
    
    while(current != nil){
        [path insertObject:current atIndex:0];
        current = [current parent];
    }
    return path;
}


-(NSMutableArray*)sortOpenSet:(NSMutableArray*)openSet{
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"f_score"
                                                 ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    NSArray *sortedArray;
    sortedArray = [openSet sortedArrayUsingDescriptors:sortDescriptors];
    NSMutableArray* newSet = [NSMutableArray arrayWithArray:sortedArray];
    return newSet;
}
@end
