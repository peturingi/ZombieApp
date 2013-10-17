//
//  MapViewController.m
//  Zombie App
//
//  Created by Pétur Ingi Egilsson on 14/10/13.
//  Copyright (c) 2013 Aalborg Universitet. All rights reserved.
//

#import "MapViewController.h"

@interface MapViewController ()

@end

@implementation MapViewController

#pragma mark - View Setup

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    // Assuming that all subviews have loaded.
    gc = [GameController sharedInstance];
    [gc setDelegate:self];
    
    [gc start]; // Start the game loop.
    
    [self addObserver:gc forKeyPath:@"hp" options:NSKeyValueObservingOptionNew context:nil];
        
    
 }

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - game controller delegate methods

-(void)elapsedTimeUpdated:(NSTimeInterval)elapsedTime
{
    NSUInteger elapsed = elapsedTime;
    NSAssert(elapsed >= 0,
             @"Elapsed time can not be in the future. The prime directive has been borken, it is in violation of the law to break the timespace continium!");
    NSAssert(elapsed <= 172800,
             @"Elapsed time was too high. More than 2 days, error?");
    
    NSUInteger seconds = elapsed % 60;
    NSUInteger minutes = (elapsed / 60) % 60;
    NSUInteger hours = (elapsed / 3600) % 24;
    
    NSString *elapsedTimeString = [NSString stringWithFormat:@"%.2ld:%.2ld:%.2ld",
                                   (unsigned long)hours,
                                   (unsigned long)minutes,
                                   (unsigned long)seconds];
    
    [_elapsedtimeLabel setText:elapsedTimeString];

    
}
-(void)playerHealthUpdated{
#warning not implemented

}
-(void)playerScoreUpdated{
#warning not implemented

}
-(void)playerSpeedUpdated{
#warning not implemented

}
@end
