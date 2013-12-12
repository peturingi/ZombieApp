//
//  GameControllerProtocol.h
//  Zombie App
//
//  Created by Pétur Ingi Egilsson on 15/10/13.
//  Copyright (c) 2013 Aalborg Universitet. All rights reserved.
//

#import <Foundation/Foundation.h>
@class CLLocation;
@class Zombie;

@protocol GameControllerDelegate <NSObject>

/**
 *  Sent whenever the GameController has new information about the elapsed time.
 */

-(void)didUpdateGameInfo:(NSDictionary*)infoDictionary;
-(void)renderZombies:(NSArray*)zombies;
-(CLLocation *)playerLocation;
@end
