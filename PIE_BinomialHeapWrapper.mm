//
//  PIE_BinomialHeapWrapper.m
//  Zombie App
//
//  Created by Pétur Ingi Egilsson on 06/12/13.
//  Copyright (c) 2013 Aalborg Universitet. All rights reserved.
//

#import "PIE_BinomialHeapWrapper.cpp"



@implementation PIE_BinomialHeapWrapper

- (id)init {
    self = [super init];
    if (self) {
        pq = new boost::heap::binomial_heap<triple_t>;
    }
    
    return self;
}

- (void)pushWithX:(int)x withY:(int)y withValue:(int)value {
    pq->push(boost::make_tuple(x, y, value));
}

- (GridCell *)pop {
    triple_t cell = pq->top();
    int xCoord = cell.get<0>();
    int yCoord = cell.get<1>();

    
    GridCell *result = [_delegate.gridMap cellAt:xCoord andY:yCoord];
    
    return result;
}

@end
