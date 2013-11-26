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
    GridCell* start = [map cellAt:10 andY:10];
    GridCell* goal = [map cellAt:150 andY:40];
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

-(void)testPathfindingIsReentrant{
    GridMap* map = [[GridMap alloc]init];
    PathfindingSystem* pathfindingSystem = [[PathfindingSystem alloc]initWithMap:map];
    GridCell* start1 = [map cellAt:10 andY:10];
    GridCell* goal1 = [map cellAt:20 andY:20];
    GridCell* start2 = [map cellAt:10 andY:20];
    GridCell* goal2 = [map cellAt:20 andY:10];
    NSArray* path1 = [pathfindingSystem pathFromCell:start1 toCell:goal1];
    NSArray* path2 = [pathfindingSystem pathFromCell:start2 toCell:goal2];
    
    NSLog(@"Path to 1: %@", path1);
    NSLog(@"Path to 2: %@", path2);
}

@end
