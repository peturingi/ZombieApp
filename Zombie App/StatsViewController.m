//
//  StatsViewController.m
//  Zombie App
//
//  Created by Pétur Ingi Egilsson on 17/10/13.
//  Copyright (c) 2013 Aalborg Universitet. All rights reserved.
//

#import "StatsViewController.h"

@interface StatsViewController ()

@end

@implementation StatsViewController

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
    //[[self navigationItem] setHidesBackButton:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    NSNumber *number = [[self stats] valueForKey:@"playingTime"];
    NSUInteger playingtime = [number doubleValue];
    NSUInteger seconds = playingtime % 60;
    NSUInteger minutes = (playingtime / 60) % 60;
    NSUInteger hours = (playingtime / 3600) % 24;
    
    NSString *elapsedTimeString = [NSString stringWithFormat:@"%.2ld:%.2ld:%.2ld",
                                   (unsigned long)hours,
                                   (unsigned long)minutes,
                                   (unsigned long)seconds];
    
    [_totalTime setText:elapsedTimeString];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)exitToMenu:(id)sender {
    [[self navigationController] popToRootViewControllerAnimated:YES];
}

@end
