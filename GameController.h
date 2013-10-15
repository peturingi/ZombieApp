//
//  GameController.h
//  Zombie App
//
//  Created by Pétur Ingi Egilsson on 15/10/13.
//  Copyright (c) 2013 Aalborg Universitet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GameControllerDelegate.h"

@interface GameController : NSObject{
    int time;
    NSTimer* timer;
    
}

@property int hp;


+(id)sharedInstance;

-(void)updatetime;

@property (weak, readwrite, nonatomic) id<GameControllerDelegate> delegate;
-(int)getTime;

@end
