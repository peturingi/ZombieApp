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

        [self setGridMap:map];
    }
    return self;
}

// Returns a list of cells in the path found from 'start' to 'goal'.
// If no path is found, either due to inaccesible or invalid cells as input,
// nil is returned.
-(NSArray*)pathFromCell:(GridCell*)start toCell:(GridCell*)goal{
    // sane check to see if either start or goal are valid cell locations
    if(start == nil || goal == nil){
        NSAssert(start, @"Was nil");
        NSAssert(goal, @"Was nil");
        return nil;
    }
    
    if ([self.gridMap unobstructedLineOfSightFrom:start to:goal]) {
        NSArray *neighbours = [self.gridMap neighboursForCell:start];
        NSAssert(neighbours, @"Failed to get neighbours");
        NSAssert(neighbours.count > 0, @"No neighbours");
        GridCell *shortestPathToGoal = [neighbours firstObject];
        for (GridCell *cell in neighbours) {
            if ([cell euclideanDistanceToCell:goal] < [shortestPathToGoal euclideanDistanceToCell:goal])
                shortestPathToGoal = cell;
        }
        return [NSArray arrayWithObject:shortestPathToGoal];
    }

    
    // initialize our lists
    [self initializeLists];
        NSAssert(openSetEmpty, @"not empty");
    // initially, add the start node to the openSet
    [self addToOpenSet:start];
    NSAssert(openSetIndex > 0, @"open set was 0 or lower");

    
    // g() for the start cell is 0, as there is no cost associated
    // with traveling to the start cell
    [start resetPathfindingInfo];
    
    
    // the effective cost is f() = g() + h(). In this case 0 + heuristic cost to the goal cell.
    [start setF_score:[start g_score] + [start euclideanDistanceToCell:goal]];
    
    // while openSet is not empty
    while(![self openSetIsEmpty]){
        GridCell* current = [self cellWithLowestFScoreInOpenSet];
        NSAssert(current, @"nil");
        
        // goal check
        if([self closedSetContains:goal]){
            return [self constructPath:goal];
        }
        
        // remove current cell from the frontier
        [self removeFromOpenSet:current];
        
        // add the current cell to the list of checked cells
        [self addToClosedSet:current];
        
        
        
        NSUInteger tentative_g_score = 0;
        NSUInteger tentative_f_score = 0;
        // Evaluate each neighbour and add it to the open list.
        // If a neighbour is in the closed list, ignore it, unless an smaller f() can be achieved
        // from the current cell.
        for(GridCell* neighbour in [_gridMap neighboursForCell:current]){

            // if neighbour is not present in any of the lists, reset so that the pathfinding is idempotent
            if(![self closedSetContains:neighbour] && ![self openSetContains:neighbour]){
                [neighbour resetPathfindingInfo];
            }
            
            tentative_g_score = [current g_score] + [current travelCostToNeighbourCell:neighbour];
            tentative_f_score = tentative_g_score + [neighbour euclideanDistanceToCell:goal];
            
            if([self closedSetContains:neighbour] && tentative_f_score >= [neighbour f_score]){
                continue;
            }
            
            if(![self openSetContains:neighbour] || tentative_f_score < [neighbour f_score]){
                [neighbour setParent:current];
                [neighbour setG_score:tentative_g_score];
                [neighbour setF_score:tentative_f_score];
                
                if(![self openSetContains:neighbour]){
                    [self addToOpenSet:neighbour];
                }
            }
        }
    }
    return nil;
}

-(NSArray*)constructPath:(GridCell*)goal{
    GridCell* current = goal;
    NSMutableArray* path = [[NSMutableArray alloc]init];
    
    // it is [current parent] we are interrested in, as we
    // do not want to add our current location (start) to the path
    while([current parent] != nil){
        [path insertObject:current atIndex:0];
        current = [current parent];
    }
    return path;
}

-(void)initializeLists{
    //_openSetDict = [[NSMutableDictionary alloc]init];
    openSetIndex = 0;
    openSetEmpty = YES;
    
    _closedSetDict = [[NSMutableDictionary alloc]init];
    _openSetSize = 0;
    
    for (NSUInteger row = 0; row < MAP_WIDTH; row++)
        for (NSUInteger column = 0; column < MAP_HEIGHT; column++) {
            openSetContains[row][column]=NO;
            closedSetContains[row][column]=NO;
        }
}

-(void)addToOpenSet:(GridCell*)cell{
    NSAssert(cell, @"cannot add nil cell");
    //NSAssert(_openSetDict, @"the openset was not instantiated before calling this function!");
    //[_openSetDict setValue:cell forKey:[cell stringEncoding]];
    //[_openSetDict setObject:cell forKey:[NSNumber numberWithInteger:[cell identifier]]];
    openSet[openSetIndex] = cell;
    openSetIndex++;
    openSetEmpty = NO;
    
    openSetContains[cell.xCoord][cell.yCoord] = YES;
    _openSetSize++;
}

-(void)removeFromOpenSet:(GridCell*)cell{
    NSAssert(cell, @"cannot add nil cell");
    //NSAssert(_openSetDict, @"the openset was not instantiated before calling this function!");
    //[_openSetDict removeObjectForKey:[NSNumber numberWithInteger:[cell identifier]]];
    for (NSUInteger index = 0; index < openSetIndex; index++) {
        if (openSet[index].identifier == cell.identifier) {
            openSet[index] = openSet[openSetIndex-1];
            openSetIndex--;
            if (openSetIndex <= 0) {
                openSetIndex = 0;
                openSetEmpty = YES;
            }
            openSetContains[cell.xCoord][cell.yCoord] = NO;
            _openSetSize--;
            return;
        }

    }
    @throw [NSException exceptionWithName:@"Tried to remove a nonexcisting cell" reason:@"Cell not found" userInfo:nil];

}

-(void)addToClosedSet:(GridCell*)cell{
    //NSAssert(cell, @"cannot add nil cell");
    //NSAssert(_closedSetDict, @"the openset was not instantiated before calling this function!");
    //[_closedSetDict setObject:cell forKey:[NSNumber numberWithInteger:[cell identifier]]];
    closedSetContains[cell.xCoord][cell.yCoord] = YES;
}

-(void)removeFromClosedSet:(GridCell*)cell{
    //NSAssert(cell, @"cannot add nil cell");
    //NSAssert(_openSetDict, @"the openset was not instantiated before calling this function!");
    //[_closedSetDict removeObjectForKey:[NSNumber numberWithInteger:[cell identifier]]];
    closedSetContains[cell.xCoord][cell.yCoord] = NO;
}



-(BOOL)closedSetContains:(GridCell*)cell{
    NSAssert(cell, @"cannot add nil cell");
    //NSAssert(_closedSetDict, @"the openset was not instantiated before calling this function!");
    //GridCell* obj = [_closedSetDict objectForKey:[NSNumber numberWithInteger:[cell identifier]]];
    //if(obj) return YES;
    //return NO;
    return closedSetContains[cell.xCoord][cell.yCoord];
}

-(BOOL)openSetContains:(GridCell*)cell{
    NSAssert(cell, @"cannot add nil cell");
    //NSAssert(_openSetDict, @"the openset was not instantiated before calling this function!");
    //GridCell* obj = [_openSetDict objectForKey:[NSNumber numberWithInteger:[cell identifier]]];
    //if(obj) return YES;
    //return NO;
    return openSetContains[cell.xCoord][cell.yCoord];
}

-(BOOL)openSetIsEmpty{
    return openSetEmpty;
}

// this method is called instead of sorting the array each iteration.
// This resulted in an enormeous performance increase.
// Whether the list is sorted or not is not important - getting the element with
// the highes f score is!
-(GridCell*)cellWithLowestFScoreInOpenSet{
    //NSAssert(_openSetDict, @"the openset was not instantiated before calling this function!");
    //NSArray* openSet = [_openSetDict allValues];
    //GridCell* cell = [openSet firstObject];
    //for(GridCell* cellIt in openSet){
    //    if([cellIt f_score] < [cell f_score]){
    //        cell = cellIt;
    //    }
    //}
    if (openSetEmpty) return nil;
    
    GridCell *cell = openSet[0];
    for (NSUInteger index = 0; index < openSetIndex; index++)
        if (openSet[index].f_score < cell.f_score)
            cell = openSet[index];
    
    NSAssert(cell, @"Cell was nil");
    
    return cell;
}
@end
