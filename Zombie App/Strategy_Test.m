//
//  Strategy_Test.m
//  Zombie App
//
//  Created by Pétur Ingi Egilsson on 26/11/13.
//  Copyright (c) 2013 Aalborg Universitet. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Strategy.h"

@interface Strategy_Test : XCTestCase {
    Strategy *_strategy;
}
@end

@implementation Strategy_Test

- (void)setUp
{
    [super setUp];
    
   
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)testExample
{
    _strategy = [[Strategy alloc] init];

    NSLog(@"go");
    //0,0,0,0,1,1,3,1,1,0,3
    NSInteger strategy2 = [_strategy selectStrategyForSoundLevel:0 distanceToPlayer:0 visibilutyDistance:0 zombieFacingPercept:0 obstacleInBetween:1 dayOrNight:1 hearingSkill:3 visionSkill:1 energy:1 travelingDistanceToPercept:0];
    NSAssert(strategy2 == 3, @"Wrong strategy selected");
    NSLog(@"expecting 3, got %d", strategy2);
    
    // 2,2,2,1,1,1,3,2,2,2,1
    NSInteger strategy = [_strategy selectStrategyForSoundLevel:2 distanceToPlayer:2 visibilutyDistance:2 zombieFacingPercept:1 obstacleInBetween:1 dayOrNight:1 hearingSkill:3 visionSkill:2 energy:2 travelingDistanceToPercept:2];
    NSLog(@"Expecting 1, got %d", strategy);
    NSAssert(strategy == 1, @"Wrong strategy selected");
    NSLog(@"%d", strategy);
    NSLog(@"stop");
    

    
    
}

@end
