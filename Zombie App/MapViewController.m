//
//  MapViewController.m
//  Zombie App
//
//  Created by Pétur Ingi Egilsson on 14/10/13.
//  Copyright (c) 2013 Aalborg Universitet. All rights reserved.
//

#import "MapViewController.h"
#import "StatsViewController.h"
#import "MapViewDelegate.h"
#import "NSString+stringFromTimeInterval.h"

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
    _notificationCenter = [NSNotificationCenter defaultCenter];
	// Do any additional setup after loading the view.
    
    // Assuming that all subviews have loaded.
    _gameController = [GameController sharedInstance];
    
    //[_mapView setDelegate:self];
    [_gameController setDelegate:self];
 }

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
        [_gameController start]; // Start the game loop.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - Seague

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:@"endGame"]) {
        [_gameController stop];
        NSDictionary *stats = [_gameController stats];
        id destination = [segue destinationViewController];

        NSAssert([destination isKindOfClass:[StatsViewController class]],
                 @"Wrong destination controller.");
        
        [destination setStats:stats];
    }
}


#pragma mark - private methods

-(void)updateSpeedLabel:(CLLocationSpeed)speed{
    [_speedLabel setText:[NSString stringWithFormat:@"%.2f", speed]];
}

-(void)updateDistanceLabel:(CLLocationDistance)aDistance{
    [_distanceLabel setText:[NSString stringWithFormat:@"%.2f", aDistance]];
}

-(void)updateElapsedTimeLabel:(NSTimeInterval)elapsedTime
{
    NSString* intervalString = [NSString stringFromTimeInterval:elapsedTime];
    [_elapsedtimeLabel setText:intervalString];
}


#pragma mark - game controller delegate methods

-(void)didUpdateGameInfo:(NSDictionary*)infoDictionary{
    NSTimeInterval elapsedGameTime = [[infoDictionary valueForKey:@"elapsedGameTime"] doubleValue];
    [self updateElapsedTimeLabel:elapsedGameTime];
    
    CLLocationDistance userDistance = [[infoDictionary valueForKey:@"userDistance"] doubleValue];
    [self updateDistanceLabel:userDistance];
    
    CLLocationSpeed userSpeed = [[infoDictionary valueForKey:@"userSpeed"] doubleValue];
    [self updateSpeedLabel:userSpeed];
}


@end
