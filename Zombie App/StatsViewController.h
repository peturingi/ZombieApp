//
//  StatsViewController.h
//  Zombie App
//
//  Created by Pétur Ingi Egilsson on 17/10/13.
//  Copyright (c) 2013 Aalborg Universitet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StatsViewController : UIViewController {
    
    __weak IBOutlet UILabel *_totalTime;
}

@property NSDictionary *stats;

@end
