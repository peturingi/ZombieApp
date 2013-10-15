//
//  GameControllerProtocol.h
//  Zombie App
//
//  Created by Pétur Ingi Egilsson on 15/10/13.
//  Copyright (c) 2013 Aalborg Universitet. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol GameControllerDelegate <NSObject>
-(void)updateElapsedTime:(NSInteger)elapsedTime;
-(void)updatePlayerScore;
-(void)updatePlayerSpeed;
-(void)updatePlayerHealth;
@end
