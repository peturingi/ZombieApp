//
//  GridCellTests.m
//  Zombie App
//
//  Created by Brian Pedersen on 24/11/13.
//  Copyright (c) 2013 Aalborg Universitet. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "GridCell.h"

@interface GridCellTests : XCTestCase

@end

@implementation GridCellTests

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

- (void)testCellHasCorrectCoordsAndPassableProperty{
    int expectedX = 10;
    int expectedY = 12;
    BOOL isObstacle = NO;
    GridCell* cell = [[GridCell alloc]initWithCoords:expectedX andY:expectedY];
    XCTAssertEqual(expectedX, [cell xCoord], @"X was not as expected");
    XCTAssertEqual(expectedY, [cell yCoord], @"Y was not as expected");
    XCTAssertEqual(isObstacle, [cell isObstacle], @"Was expecting obstacle, but was not");
    
}

// Distances are 
-(void)testManhattanDistanceIsCorrect{
    int expectedDistance = (5 + 22) * 10;
    GridCell* cell1 = [[GridCell alloc]initWithCoords:0 andY:0];
    GridCell* cell2 = [[GridCell alloc]initWithCoords:5 andY:22];
    int distance = [cell1 manhattanDistanceToCell:cell2];
    XCTAssertEqual(expectedDistance, distance, @"Distance was not as expected");
}

@end
