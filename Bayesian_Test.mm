//
//  Bayesian_Test.m
//  Zombie App
//
//  Created by Pétur Ingi Egilsson on 24/11/13.
//  Copyright (c) 2013 Aalborg Universitet. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Bayesian.h"

@interface Bayesian_Test : XCTestCase

@end

@implementation Bayesian_Test

- (void)setUp
{
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)testBayesian
{
    Bayesian *bn = [[Bayesian alloc] init];
    [bn run];
}

@end
