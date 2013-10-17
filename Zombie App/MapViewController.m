//
//  MapViewController.m
//  Zombie App
//
//  Created by Pétur Ingi Egilsson on 14/10/13.
//  Copyright (c) 2013 Aalborg Universitet. All rights reserved.
//

#import "MapViewController.h"
#import "StatsViewController.h"

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
 }

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
        [gc start]; // Start the game loop.
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

#pragma mark - Seague

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:@"endGame"]) {
        [gc stop];
        NSDictionary *stats = [gc stats];
        id destination = [segue destinationViewController];

        NSAssert([destination isKindOfClass:[StatsViewController class]],
                 @"Wrong destination controller.");
        
        [destination setStats:stats];
    }
}

#pragma mark - MapView Delegate
// Zooms in to the users current location, the map the first time the map is shown.
- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    // Zoom logic begin
    NSAssert(userLocation,
             @"userLocation was nil");
    
    CLLocationCoordinate2D currentCoordinate = [userLocation coordinate];
    
    // Zoom in on he map, once - the first time the users location is received.
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        const NSInteger mapLongMeters = 20;
        const NSInteger mapLatMeters = 20;
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(currentCoordinate,
                                                                       mapLongMeters,
                                                                       mapLatMeters);
        [mapView setRegion:region];
    });
    [mapView setCenterCoordinate:currentCoordinate animated:YES];
    // Zoom logic end
    
    // Speed Logic
    CLLocation *speedLocation = [userLocation location];
    CLLocationSpeed speed = [speedLocation speed];
    if (speed < 0) speed = 0.0f; // Make sure the user does not see a negative value due to inaccuracy.
    NSString *speedString = [NSString stringWithFormat:@"%.2f", speed];
    [_speedLabel setText:speedString];
    // Speed logic ends
    
    // Distance logic
    if (!_lastKnownLocation) {
        _lastKnownLocation = [userLocation location];
    } else {
        _distanceInMeters += [_lastKnownLocation distanceFromLocation:[userLocation location]];
        _lastKnownLocation = [userLocation location];
    }
    [distance setText:[NSString stringWithFormat:@"%.2f", _distanceInMeters]];
    // Distance logic ends
    
}

@end
