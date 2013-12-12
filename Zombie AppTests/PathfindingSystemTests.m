//
//  PathfindingSystemTests.m
//  Zombie App
//
//  Created by Brian Pedersen on 24/11/13.
//  Copyright (c) 2013 Aalborg Universitet. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "GridMap.h"
#import "PathfindingSystem.h"

@interface PathfindingSystemTests : XCTestCase

@end

@implementation PathfindingSystemTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testPathfinding{
    
    GridMap* map = [[GridMap alloc]init];
    PathfindingSystem* pathfindingSystem = [[PathfindingSystem alloc]initWithMap:map];
    GridCell* start = [map cellAt:10 andY:23];
    GridCell* goal = [map cellAt:150 andY:18];
    NSArray* path = [pathfindingSystem pathFromCell:start toCell:goal];
    
    XCTAssert([path count], @"great success");
}

-(void)testUnreachablePathReturnsNil{
    GridMap* map = [[GridMap alloc]init];
    PathfindingSystem* pathfindingSystem = [[PathfindingSystem alloc]initWithMap:map];
    GridCell* start = [map cellAt:10 andY:10];
    GridCell* invalidGoal = [map cellAt:10 andY:1000];
    NSArray* path = [pathfindingSystem pathFromCell:start toCell:invalidGoal];
    XCTAssertNil(path, @"Path was not nil as expected");
}

// Pathfinding can be applied multiple times on the same grid map with no sideeffects
/* Wikipedia:
    Idempotence is the property of certain operations in mathematics and computer science, that can be applied multiple
    times without changing theresult beyond the initial application.
 */
// Test does not check a criteria. Instead the path is manually (humanly) checked. This should be fixed and made automatic!
-(void)testPathfindingIsIdempotent{
    GridMap* map = [[GridMap alloc]init];
    PathfindingSystem* pathfindingSystem = [[PathfindingSystem alloc]initWithMap:map];
    GridCell* start1 = [map cellAt:0 andY:0];
    GridCell* goal1 = [map cellAt:199 andY:42];
    //GridCell* start2 = [map cellAt:0 andY:42];
    //GridCell* goal2 = [map cellAt:199 andY:0];
    for(int i = 0; i < 50; i++){
        NSArray* path1 = [pathfindingSystem pathFromCell:start1 toCell:goal1];
        //NSArray* path2 = [pathfindingSystem pathFromCell:start2 toCell:goal2];
    }
    
}

@end
