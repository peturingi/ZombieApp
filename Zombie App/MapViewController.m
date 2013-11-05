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
    NSString* intervalString = [self timeIntervalToString:elapsedTime];
    [_elapsedtimeLabel setText:intervalString];
}

-(NSString*)timeIntervalToString:(NSTimeInterval)timeInSeconds{
    NSUInteger elapsed = timeInSeconds;
    NSUInteger seconds = elapsed % 60;
    NSUInteger minutes = (elapsed / 60) % 60;
    NSUInteger hours = (elapsed / 3600) % 24;
    
    NSString* timeIntervalString = [NSString stringWithFormat:@"%.2ld:%.2ld:%.2ld",
                                    (unsigned long)hours,
                                    (unsigned long)minutes,
                                    (unsigned long)seconds];
    return timeIntervalString;
}


#pragma mark - game controller delegate methods

-(void)didUpdateGameInfo:(NSDictionary*)infoDictionary{
        NSTimeInterval elapsedTime = [[infoDictionary valueForKey:@"elapsedGameTime"] doubleValue];
    [self updateElapsedTimeLabel:elapsedTime];
    
    CLLocationDistance distance = [[infoDictionary valueForKey:@"distance"] doubleValue];
    [self updateDistanceLabel:distance];
    
    CLLocationSpeed speed = [[infoDictionary valueForKey:@"speed"] doubleValue];
    [self updateSpeedLabel:speed];
}


@end
