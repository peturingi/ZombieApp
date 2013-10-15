//
//  GameController.m
//  Zombie App
//
//  Created by Pétur Ingi Egilsson on 15/10/13.
//  Copyright (c) 2013 Aalborg Universitet. All rights reserved.
//

#import "GameController.h"
#import "MapViewController.h"

@implementation GameController

+(id)sharedInstance{

    __strong static id _sharedObject = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedObject = [[self alloc]init];
        
        
    });
    return _sharedObject;
}


-(id)init{
    self = [super init];
    time = 0;
    [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(updatetime) userInfo:nil repeats:YES];

    
    return self;
}




-(void)updatetime{
    NSLog(@"updated");
    time++;
    self.hp = time;
    [_delegate updateElapsedTime:time];
}


-(int)getTime{
    return time;
}


@end
