//
//  MapViewController.m
//  Zombie App
//
//  Created by Pétur Ingi Egilsson on 14/10/13.
//  Copyright (c) 2013 Aalborg Universitet. All rights reserved.
//

#import "MapViewController.h"
#import "StatsViewController.h"
// #import "MapViewDelegate.h"
#import "NSString+stringFromTimeInterval.h"

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
    
    // Get a reference to the game controller and set this view controller as its delegate.
    _gameController = [GameController sharedInstance];
    [_gameController setDelegate:self];
 }

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // Start the game loop.
    [_gameController start];
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
    // DevMode: Show adjust zombie image to be of correct color.
    // 3. Redraw at correct coordinates.
    
    NSAssert(_mapView != nil, @"Map was nil!");
    NSAssert(self.zombiesData != nil, @"zombieCoordinates dictionary was nil");
#ifdef DEBUG
    if (self.zombiesData.count == 0) {
        NSLog(@"%@ : Warning, dictionary empty", NSStringFromSelector(_cmd));
    }
#endif
    // 1.
    // Handle deletion of zombies, by removing UIImageViews which do not belong to any zombie identifier.
    for (UIImageView *view in _mapView.subviews) {
        NSNumber *tagOfView = [NSNumber numberWithInteger:view.tag];
        NSArray *data = [self.zombiesData objectForKey:tagOfView];
        CLLocation *coordinates = [data objectAtIndex:1];
        // Map can have multiple subviews. Only concern those of UIImageView class as its used to draw the images.
        if (coordinates == nil && [view isKindOfClass:[UIImageView class]]) {
            [view removeFromSuperview];
        }
    }
    
    // 2.
    // Create a new UIImageView for new zombies, add it to the map.
    NSEnumerator *zombiesKeyEnumerator = self.zombiesData.keyEnumerator;
    id key;
    while ((key = zombiesKeyEnumerator.nextObject)) {
        BOOL zombieHasAView = FALSE;
        NSInteger zombieID = [key integerValue];
        for (UIImageView *view in _mapView.subviews) {
            if (view.tag == zombieID) {
                zombieHasAView = YES;
                break;
            }
        }
        
        // Create a UIImageView if one does not excist for the current zombie.
        if (!zombieHasAView) {
            // Convert the zombies GPS coordinates into coordinates within the MapView.
            NSArray *data = [self.zombiesData objectForKey:key];
            CLLocation *geoCoords = [data objectAtIndex:1];
            NSAssert (geoCoords != nil, @"geoCoords are nil!");
            
            // Create the zombie view
            UIImage *zombieImage = IMAGE_ZOMBIE
            NSAssert(zombieImage != nil, @"Image not found!");
            UIImageView *view = [[UIImageView alloc] initWithImage:zombieImage];
            view.tag = zombieID;
            
            CGPoint pointInMapView = [_mapView convertCoordinate:geoCoords.coordinate toPointToView:_mapView];
            centerViewAtPoint(view, pointInMapView);
            
            [_mapView addSubview:view];
        }
    }
    
    // 3.
    // Move views to new locations, to match the new location of zombies.
    for (UIImageView *view in _mapView.subviews) {
        if ([view isKindOfClass:[UIImageView class]]) {
            NSNumber *zombieID = [NSNumber numberWithInteger:view.tag];
            NSAssert (zombieID != nil, @"zombieID is nil");
        
            NSArray *data = [self.zombiesData objectForKey:zombieID];
            CLLocation *geoCoords = [data objectAtIndex:1];
            NSAssert(geoCoords != nil, @"geoCoords are nil!");
            
            //Devmode, adjust the photo
#ifdef DEBUG
            NSNumber *zombiesStrategyAsNumber = [data objectAtIndex:0];
            NSInteger zombiesStrategy = [zombiesStrategyAsNumber integerValue];
            UIImage *state;
            switch (zombiesStrategy) {
                case 0: // idle
                    state = [UIImage imageNamed:@"zombieIdle"];
                    break;
                case 1: // Roam
                    state = [UIImage imageNamed:@"zombieRoam"];
                    break;
                case 2: // WAlk
                    state = [UIImage imageNamed:@"zombieWalk"];
                    break;
                case 3: // Sprint
                    state = [UIImage imageNamed:@"zombieSprint"];
                    break;
                default:
                    @throw [NSException exceptionWithName:@"Invalid strategy" reason:@"Could not find image for selected strategy" userInfo:nil];
            }
            view.image = state;
#endif
            CGPoint pointInMapView = [_mapView convertCoordinate:geoCoords.coordinate toPointToView:_mapView];
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
    
    [UIView animateWithDuration:0.23
                          delay:0
                        options: UIViewAnimationOptionTransitionNone
                     animations:^{
                         CGRect targetFrame = viewFrame;
                         targetFrame.origin.x -= viewFrame.size.width / 2;
                         targetFrame.origin.y -= viewFrame.size.height / 2;
                         view.frame = targetFrame;
                     }
                     completion:^(BOOL finished){
                        // NSLog(@"Done!");
                     }];
    
    //viewFrame.origin.x -= viewFrame.size.width / 2;
    //viewFrame.origin.y -= viewFrame.size.height / 2;
    //view.frame = viewFrame;
}

#pragma mark - game controller delegate methods


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

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
#ifdef DEBUG
    if (!self.zombiesData)
        NSLog(@"%@ - verbose debugging: zombiesCoordinates is nil.", NSStringFromSelector(_cmd));
#endif
    
    // Redraw zombies.
    if (self.zombiesData) {
        [self displayZombiesOnMap];
    }
}

-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation{
    CLLocationCoordinate2D currentCoordinate = [userLocation coordinate];
    
    // Zoom in on the map, once - the first time the users location is received.
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        const NSInteger mapLongMeters = 100;
        const NSInteger mapLatMeters = 100;
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(currentCoordinate,
                                                                       mapLongMeters,
                                                                       mapLatMeters);
        [mapView setRegion:region];
    });
    
    [mapView setCenterCoordinate:currentCoordinate animated:NO];
    
#pragma mark post a notification that the user location has changed.
    
    // Only execute on real device. DEBUG indicates dev mode in simulator.
#ifndef DEBUG
    CLLocation *location = [userLocation location];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"didUpdatePlayerPosition" object:location];
#endif

}



- (void)mapView:(MKMapView *)mapView didFailToLocateUserWithError:(NSError *)error {
#warning not implemented
}

#pragma mark - Setters & Getters
- (void)setZombiesData:(NSDictionary *)zombiesCoordinates {
    _zombiesData = zombiesCoordinates;
    
    [self displayZombiesOnMap];
}

-(void)renderZombies:(NSDictionary*)zombies{
    [self setZombiesData:zombies];
    [self displayZombiesOnMap];
}

- (CLLocation *)playerLocation {
    return _mapView.userLocation.location;
}
- (IBAction)dev_placePlayerWithTouch:(id)sender {
#ifdef DEBUG
    
    // Get the GPS coordinates where the press occured.
    UILongPressGestureRecognizer *gr = sender;
    if (gr.state == UIGestureRecognizerStateBegan) { // Only act on first press. This is a continious event.
        MKMapView *grMapView = (MKMapView *)gr.view;
        CGPoint location = [gr locationInView:grMapView];
        CLLocationCoordinate2D location2d = [grMapView convertPoint:location toCoordinateFromView:grMapView];
        CLLocation *gestureLocation = [[CLLocation alloc] initWithLatitude:location2d.latitude longitude:location2d.longitude];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"didUpdatePlayerPosition" object:gestureLocation];
        NSLog(@"Dev mode: notification posted: didUpdatePlayerPosition");
    }

#endif
}


@end
