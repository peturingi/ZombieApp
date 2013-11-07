//
//  StatsViewController.m
//  Zombie App
//
//  Created by Pétur Ingi Egilsson on 17/10/13.
//  Copyright (c) 2013 Aalborg Universitet. All rights reserved.
//

#import "StatsViewController.h"
#import "NSString+stringFromTimeInterval.h"

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
}

- (void)viewWillAppear:(BOOL)animated {
    NSNumber *elapsedGameTime = [[self stats] valueForKey:@"elapsedGameTime"];
    NSString* elapsedTimeString = [NSString stringFromTimeInterval:[elapsedGameTime doubleValue]];
    [_totalGameTimeLabel setText:elapsedTimeString];
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
