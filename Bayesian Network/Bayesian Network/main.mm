//
//  main.m
//  Bayesian Network
//
//  Created by Pétur Ingi Egilsson on 25/11/13.
//  Copyright (c) 2013 Pétur Ingi Egilsson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Bayesian.h"

int main(int argc, const char * argv[])
{

    @autoreleasepool {
        Bayesian *bn = [[Bayesian alloc] init];
        [bn createOfflineTable];
        
    }
    return 0;
}

