//
//  GridMapTests.m
//  Zombie App
//
//  Created by Brian Pedersen on 24/11/13.
//  Copyright (c) 2013 Aalborg Universitet. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "GridMap.h"

@interface GridMapTests : XCTestCase

@end

@implementation GridMapTests

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

- (void)testCellAtHasCorrectCoords{
    GridMap* map = [[GridMap alloc]init];
    int expectedX = 10;
    int expectedY = 20;
    GridCell* cell = [map cellAt:expectedX andY:expectedY];
    XCTAssertEqual(expectedX, [cell xCoord], @"X was not as expected");
    XCTAssertEqual(expectedY, [cell yCoord], @"Y was not as expected");
}

-(void)testCornerCellHasCorrectNeighbourCount{
    GridMap* map = [[GridMap alloc]init];
    NSArray* neighbours = [map neighboursForCell:[map cellAt:0 andY:0]];
    int expectedNeighbourCount = 2;
    int result = [neighbours count];
    XCTAssertEqual(expectedNeighbourCount, result, @"Did not have the expected count of neighbours");
    
}

-(void)testNonCornerCellHasCorrectNeighbourCount{
    GridMap* map = [[GridMap alloc]init];
    NSArray* neighbours = [map neighboursForCell:[map cellAt:10 andY:10]];
    int expectedNeighbourCount = 4;
    int result = [neighbours count];
    XCTAssertEqual(expectedNeighbourCount, result, @"Did not have the expected count of neighbours");
}

@end
