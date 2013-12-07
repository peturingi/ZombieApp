//
//  PIE_BinomialHeapWrapper.h
//  Zombie App
//
//  Created by Pétur Ingi Egilsson on 06/12/13.
//  Copyright (c) 2013 Aalborg Universitet. All rights reserved.
//
#import <cstdlib>
#include "boost/heap/binomial_heap.hpp"
#include "boost/tuple/tuple.hpp"

#import <Foundation/Foundation.h>
#import "GridCell.h"
#import "GridMap.h"
#import "PathfindingSystem.h"


typedef boost::tuple<int, int, int> triple_t;

@interface PIE_BinomialHeapWrapper : NSObject {
    boost::heap::binomial_heap<triple_t> *pq;
}

- (void)pushWithX:(int)x withY:(int)y withValue:(int)value;
- (GridCell *)pop;
@property (weak) PathfindingSystem *delegate;

@end
