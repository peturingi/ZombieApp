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
    int expectedX = 4;
    int expectedY = 22;
    GridCell* cell = [map cellAt:expectedX andY:expectedY];
    XCTAssertEqual(expectedX, [cell xCoord], @"X was not as expected");
    XCTAssertEqual(expectedY, [cell yCoord], @"Y was not as expected");
}

-(void)testCornerCellHasCorrectNeighbourCount{
    GridMap* map = [[GridMap alloc]init];
    NSArray* neighbours = [map neighboursForCell:[map cellAt:0 andY:0]];
    int expectedNeighbourCount = 3;
    int result = [neighbours count];
    XCTAssertEqual(expectedNeighbourCount, result, @"Did not have the expected count of neighbours");
    
}

-(void)testNonCornerCellHasCorrectNeighbourCount{
    GridMap* map = [[GridMap alloc]init];
    GridCell* cell = [map cellAt:5 andY:22];
    NSArray* neighbours = [map neighboursForCell:cell];
    int expectedNeighbourCount = 6;
    int result = [neighbours count];
    XCTAssertEqual(expectedNeighbourCount, result, @"Did not have the expected count of neighbours");
}

-(void)testVerticalLineOfSightIsUnobstructed{
    GridMap* map = [[GridMap alloc]init];
    GridCell* cell1 = [map cellAt:0 andY:0];
    GridCell* cell2 = [map cellAt:0 andY:10];
    BOOL expectedAnswer = YES;
    BOOL result = [map unobstructedLineOfSightFrom:cell1 to:cell2];
    XCTAssertEqual(expectedAnswer, result, @"Unexpected answer");
}

-(void)testVerticalLineOfSightIsObstructed{
    GridMap* map = [[GridMap alloc]init];
    GridCell* cell1 = [map cellAt:10 andY:0];
    GridCell* cell2 = [map cellAt:10 andY:30];
    BOOL expectedAnswer = NO;
    BOOL result = [map unobstructedLineOfSightFrom:cell1 to:cell2];
    XCTAssertEqual(expectedAnswer, result, @"Unexpected answer");
}

-(void)testHorizontalLineOfSightIsUnobstructed{
    GridMap* map = [[GridMap alloc]init];
    GridCell* cell1 = [map cellAt:0 andY:22];
    GridCell* cell2 = [map cellAt:30 andY:22];
    BOOL expectedAnswer = YES;
    BOOL result = [map unobstructedLineOfSightFrom:cell1 to:cell2];
    XCTAssertEqual(expectedAnswer, result, @"Unexpected answer");
}

-(void)testHorizontalLineOfSightIsObstructed{
    GridMap* map = [[GridMap alloc]init];
    GridCell* cell1 = [map cellAt:0 andY:20];
    GridCell* cell2 = [map cellAt:30 andY:20];
    BOOL expectedAnswer = NO;
    BOOL result = [map unobstructedLineOfSightFrom:cell1 to:cell2];
    XCTAssertEqual(expectedAnswer, result, @"Unexpected answer");
}

-(void)testPositiveSlopeLineOfSightIsUnobstructed{
    GridMap* map = [[GridMap alloc]init];
    GridCell* cell1 = [map cellAt:5 andY:22];
    GridCell* cell2 = [map cellAt:50 andY:25];
    BOOL expectedAnswer = YES;
    BOOL result = [map unobstructedLineOfSightFrom:cell1 to:cell2];
    XCTAssertEqual(expectedAnswer, result, @"Unexpected answer");
}

-(void)testPositiveSlopeLineOfSightIsObstructed{
    GridMap* map = [[GridMap alloc]init];
    GridCell* cell1 = [map cellAt:0 andY:0];
    GridCell* cell2 = [map cellAt:20 andY:21];
    BOOL expectedAnswer = NO;
    BOOL result = [map unobstructedLineOfSightFrom:cell1 to:cell2];
    XCTAssertEqual(expectedAnswer, result, @"Unexpected answer");
}

-(void)testNegativeSlopeLineOfSightIsUnobstructed{
    GridMap* map = [[GridMap alloc]init];
    GridCell* cell1 = [map cellAt:0 andY:30];
    GridCell* cell2 = [map cellAt:50 andY:25];
    BOOL expectedAnswer = YES;
    BOOL result = [map unobstructedLineOfSightFrom:cell1 to:cell2];
    XCTAssertEqual(expectedAnswer, result, @"Unexpected answer");
    
}

-(void)testNegativeSlopeLineOfSightIsObstructed{
    GridMap* map = [[GridMap alloc]init];
    GridCell* cell1 = [map cellAt:0 andY:40];
    GridCell* cell2 = [map cellAt:17 andY:0];
    BOOL expectedAnswer = NO;
    BOOL result = [map unobstructedLineOfSightFrom:cell1 to:cell2];
    XCTAssertEqual(expectedAnswer, result, @"Unexpected answer");
}

@end
