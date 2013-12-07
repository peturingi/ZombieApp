//
//  GameEnvironment.h
//  Zombie App
//
//  Created by Pétur Ingi Egilsson on 07/12/13.
//  Copyright (c) 2013 Aalborg Universitet. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol GameEnvironment <NSObject>

-(BOOL)canSeePlayer:(id)sender;

@end
