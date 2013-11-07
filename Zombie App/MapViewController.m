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
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
#warning development code - remove before release.
    CLLocation *loc = [[CLLocation alloc] initWithLatitude:37.334256 longitude:-122.032168];
    [_map setCenterCoordinate:loc.coordinate];
    _map.region = MKCoordinateRegionMakeWithDistance(loc.coordinate, 100, 100);
    CLLocation *z1Coord = loc;
    CLLocation *z2Coord = [[CLLocation alloc] initWithLatitude:37.334276 longitude:-122.032188];
    NSNumber *z1Id = [NSNumber numberWithInteger:1];
    NSNumber *z2Id = [NSNumber numberWithInteger:2];
    self.zombiesCoordinates = [NSDictionary dictionaryWithObjectsAndKeys:z1Coord, z1Id, z2Coord, z2Id, nil];
    
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

#pragma mark - Zombie Drawing

/** Draws the zombies found in self.zombiesCoordinates onto the map.
 *  @remark Not the most efficient code but it is very readable. Uses less than 1% cpu on iPhone 4s.
 */
- (void)displayZombiesOnMap {
    // 1. Ensure the zombies have a pairing uiimageview, if not create one.
    // 2. Detect if zombie has been deleted, then remove his uiimageview.
    // 3. Redraw at correct coordinates.
    
    NSAssert(_map != nil, @"Map was nil!");
    NSAssert(self.zombiesCoordinates != nil, @"zombieCoordinates dictionary was nil");
#ifdef DEBUG
    if (self.zombiesCoordinates.count == 0) {
        NSLog(@"%@ : Warning, dictionary empty", NSStringFromSelector(_cmd));
    }
#endif
    // 1.
    // Handle deletion of zombies, by removing UIImageViews which do not belong to any zombie identifier.
    for (UIImageView *view in _map.subviews) {
        NSNumber *tagOfView = [NSNumber numberWithInteger:view.tag];
        CLLocation *coordinates = [self.zombiesCoordinates objectForKey:tagOfView];
        // Map can have multiple subviews. Only concern those of UIImageView class as its used to draw the images.
        if (coordinates == nil && [view isKindOfClass:[UIImageView class]]) {
            [view removeFromSuperview];
        }
    }
    
    // 2.
    // Create a new UIImageView for new zombies, add it to the map.
    NSEnumerator *zombiesKeyEnumerator = self.zombiesCoordinates.keyEnumerator;
    id key;
    while ((key = zombiesKeyEnumerator.nextObject)) {
        BOOL zombieHasAView = FALSE;
        NSInteger zombieID = [key integerValue];
        for (UIImageView *view in _map.subviews) {
            if (view.tag == zombieID) {
                zombieHasAView = YES;
                break;
            }
        }
        
        // Create a UIImageView if one does not excist for the current zombie.
        if (!zombieHasAView) {
            // Convert the zombies GPS coordinates into coordinates within the MapView.
            CLLocation *geoCoords = [self.zombiesCoordinates objectForKey:key];
            NSAssert (geoCoords != nil, @"geoCoords are nil!");
            
            // Create the zombie view
            UIImage *zombieImage = IMAGE_ZOMBIE
            NSAssert(zombieImage != nil, @"Image not found!");
            UIImageView *view = [[UIImageView alloc] initWithImage:zombieImage];
            view.tag = zombieID;
            
            CGPoint pointInMapView = [_map convertCoordinate:geoCoords.coordinate toPointToView:_map];
            centerViewAtPoint(view, pointInMapView);
            
            [_map addSubview:view];
        }
    }
    
    // 3.
    // Move views to new locations, to match the new location of zombies.
    for (UIImageView *view in _map.subviews) {
        if ([view isKindOfClass:[UIImageView class]]) {
            NSNumber *zombieID = [NSNumber numberWithInteger:view.tag];
            NSAssert (zombieID != nil, @"zombieID is nil");
        
            CLLocation *geoCoords = [self.zombiesCoordinates objectForKey:zombieID];
            NSAssert(geoCoords != nil, @"geoCoords are nil!");
        
            CGPoint pointInMapView = [_map convertCoordinate:geoCoords.coordinate toPointToView:_map];
            centerViewAtPoint(view, pointInMapView);
        }
    }
}

/** Moves the center of an UIImageView to a given CGPoint.
 *  @param view UIImageView
 *  @param pointInMap CGPoint
 */
void centerViewAtPoint(UIImageView *view, CGPoint pointInMapView) {
    CGRect viewFrame = view.frame;
    viewFrame.origin = pointInMapView;
    viewFrame.origin.x -= viewFrame.size.width / 2;
    viewFrame.origin.y -= viewFrame.size.height / 2;
    view.frame = viewFrame;
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
    // -- Zoom logic begin
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
    // animation causes problems when syncing zombie location because the didUpdateLocatoinMethod does not get called each time the animation moves the screen.
    // this could be investigated but from initial analysis it appears that the displayzombiesOnMap method would need to implement its own animation to
    // math the one provided by setCenterCoordinate. Too hard and outside the scope of the project?
    [mapView setCenterCoordinate:currentCoordinate animated:NO];

    // -- Speed Logic
    CLLocation *speedLocation = [userLocation location];
    CLLocationSpeed speed = [speedLocation speed];
    if (speed < 0) speed = 0.0f; // Make sure the user does not see a negative value due to inaccuracy.
    NSString *speedString = [NSString stringWithFormat:@"%.2f", speed];
    [_speedLabel setText:speedString];
    
    // -- Distance logic
    if (!_lastKnownLocation) {
        _lastKnownLocation = [userLocation location];
    } else {
        _distanceInMeters += [_lastKnownLocation distanceFromLocation:[userLocation location]];
        _lastKnownLocation = [userLocation location];
    }
    [distance setText:[NSString stringWithFormat:@"%.2f", _distanceInMeters]];
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
#ifdef DEBUG
    if (!self.zombiesCoordinates)
        NSLog(@"%@ - verbose debugging: zombiesCoordinates is nil.", NSStringFromSelector(_cmd));
#endif
    
    // Redraw zombies.
    if (self.zombiesCoordinates) {
        [self displayZombiesOnMap];
    }
}

- (void)mapView:(MKMapView *)mapView didFailToLocateUserWithError:(NSError *)error {
#warning not implemented
}

#pragma mark - Setters & Getters
- (void)setZombiesCoordinates:(NSDictionary *)zombiesCoordinates {
    _zombiesCoordinates = zombiesCoordinates;
    
    [self displayZombiesOnMap];
}


@end
