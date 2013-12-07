//
//  GameEnvironment.h
//  Zombie App
//
//  Created by Pétur Ingi Egilsson on 07/12/13.
//  Copyright (c) 2013 Aalborg Universitet. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol GameEnvironment <NSObject>

-(NSInteger)canSeePlayer:(id)sender;
-(NSInteger)canHearPlayer:(id)sender;

@end
