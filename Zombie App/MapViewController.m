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
#import "UIImage+UIImage_Extension_h.h"

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
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gameOver) name:@"Game Over" object:nil];
    
#ifdef DRAW_PATHFINDING
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(drawPathfinding:) name:@"DrawPath" object:nil];
#endif


    // Get a reference to the game controller and set this view controller as its delegate.
    _gameController = [GameController sharedInstance];
    [_gameController setDelegate:self];
    
    
 }

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //[self zoomMapOnUserLocation:[_mapView userLocation]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self setupLocationServices];
    
    // Start the game loop.
    [_gameController start];
#ifdef DEV_TOUCH_ZOMBIE
    dev_fieldOfView.hidden = NO;
    dev_seesPlayer.hidden = NO;
    dev_lineOfSight.hidden = NO;
#endif
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.locationManager stopUpdatingLocation];
    [self.locationManager stopUpdatingHeading];
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
#ifdef NEVER_DRAW_ZOMBIES
    return;
#endif
    
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
        NSInteger tag = view.tag;
        Zombie *zombie;
        for (Zombie *z in self.zombiesData) {
            if (z.identifier == tag) {
                zombie = z;
                break;
            }
        }
        CLLocation *coordinates = zombie.gpsLocation;
        // Map can have multiple subviews. Only concern those of UIImageView class as its used to draw the images.
        if (coordinates == nil && [view isKindOfClass:[UIImageView class]]) {
            [view removeFromSuperview];
        }
    }
    
    // 2.
    // Create a new UIImageView for new zombies, add it to the map.
    for (Zombie *z in self.zombiesData) {
        BOOL zombieHasAView = FALSE;
        for (UIImageView *view in _mapView.subviews) {
            if (view.tag == z.identifier) {
                zombieHasAView = YES;
                break;
            }
        }
        if (!zombieHasAView) {

            // Convert the zombies GPS coordinates into coordinates within the MapView.
            
            // Create the zombie view
            UIImage *zombieImage = IMAGE_ZOMBIE
            NSAssert(zombieImage != nil, @"Image not found!");
            
            UIImageView *view = [[UIImageView alloc] initWithImage:zombieImage];
            view.tag = z.identifier;
        
            CGPoint pointInMapView = [_mapView convertCoordinate:z.gpsLocation.coordinate toPointToView:_mapView];
            centerViewAtPointWithAnimationSpeed(view, pointInMapView, 0.0);
            
            [_mapView addSubview:view];
        }
    }
    
    
    
    // 3.
    // Move views to new locations, to match the new location of zombies.
    for (UIImageView *view in _mapView.subviews) {
        if ([view isKindOfClass:[UIImageView class]]) {
            
            // Find zombie mathcing the view.
            Zombie *zombie;
            for (Zombie *z in self.zombiesData) {
                if (z.identifier == view.tag) {
                    zombie = z;
                    break;
                }
            }
            
            //Devmode, adjust the photo
           
#ifdef DEBUG
            UIImage *state;
            switch (zombie.currentStrategy) {
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
            
            // Also update dev labels.
            if (zombie.facingPercept) {
                dev_fieldOfView.text = @"FOV";
            } else {
                dev_fieldOfView.text = @"";
            }
            
            if (zombie.seesPlayer) {
                dev_seesPlayer.text = @"Sees player";
            } else {
                dev_seesPlayer.text = @"";
            }
            
            if (zombie.lineOfSight) {
                dev_lineOfSight.text = @"No obstacles to player";
            } else {
                dev_lineOfSight.text = @"";
            }
            
#endif
             view.image = [view.image imageRotatedByRadians:-zombie.directionAsRadian];
            
            
            CGPoint pointInMapView = [_mapView convertCoordinate:zombie.gpsLocation.coordinate toPointToView:_mapView];
            centerViewAtPointWithAnimationSpeed(view, pointInMapView, zombie.secondsToMoveToTargetCell);
        }
    }
}

/** Moves the center of an UIImageView to a given CGPoint.
 *  @param view UIImageView
 *  @param pointInMap CGPoint
 */
void centerViewAtPointWithAnimationSpeed(UIImageView *view, CGPoint pointInMapView, double animationSpeed) {
    CGRect viewFrame = view.frame;
    viewFrame.origin = pointInMapView;
    [UIView animateWithDuration:animationSpeed
                          delay:0
                        options: UIViewAnimationOptionCurveLinear
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
#pragma mark MKMapView
- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
#ifdef DEBUG
    if (!self.zombiesData)
        NSLog(@"%@ - verbose debugging: zombiesCoordinates is nil.", NSStringFromSelector(_cmd));
#endif
    
    // Redraw zombies.
    if (self.zombiesData) {
        [self displayZombiesOnMap];
    }
#ifdef DRAW_CELLS
    [self drawCells];
#endif
}

-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation{
    if (!userLocation) return;
    
    // Zoom in on the map, once - the first time the users location is received.
   /* static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        const NSInteger mapLongMeters = 1;
        const NSInteger mapLatMeters = 1;
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(currentCoordinate,
                                                                       mapLongMeters,
                                                                       mapLatMeters);
        MKCoordinateSpan span;
        span.longitudeDelta = 0.00001;
        span.latitudeDelta = 0.00001;
        region.span = span;

        [mapView setRegion:region];
        [mapView regionThatFits:region];
    });
    */
    //[self zoomMapOnUserLocation:userLocation];
    //[mapView setCenterCoordinate:currentCoordinate animated:NO];

    
#pragma mark post a notification that the user location has changed.
    
    // Only execute on real device. DEBUG indicates dev mode in simulator.
//#ifndef DEBUG
//    CLLocation *location = [userLocation location];
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"didUpdatePlayerPosition" object:location];
//    NSLog(@"Updated location");
//#endif

}
/*
- (void)zoomMapOnUserLocation:(MKUserLocation *)userLocation {
    if (!userLocation) return;
    
    CLLocationCoordinate2D coord = _mapView.userLocation.location.coordinate;
    CLLocationDistance tenMeters = 10;
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coord, tenMeters, tenMeters);
    MKCoordinateRegion adjustedRegion = [_mapView regionThatFits:region];
    [_mapView setRegion:adjustedRegion animated:NO];
}*/


- (void)mapView:(MKMapView *)mapView didFailToLocateUserWithError:(NSError *)error {
}

#pragma mark - Core Location

- (void)setupLocationServices {
    
    // Handle permission errors with core location services.
    // The location service can not be started unless the user accepts.
    if (![CLLocationManager locationServicesEnabled]) {
        [self errorBox:@"Location Services" andMessage:@"Location services are blocked by user. Aborting."];
    }
    
    switch ([CLLocationManager authorizationStatus]) {
        case kCLAuthorizationStatusDenied:
            [self errorBox:@"Error" andMessage:@"App requires location services. Aborting."];
            break;
            
        case kCLAuthorizationStatusRestricted:
            [self errorBox:@"Error" andMessage:@"App not authorized to use location services. Aborting."];
            break;
 
#ifdef DEV_CL_VERBOSE
        case kCLAuthorizationStatusNotDetermined:
            [self infoBox:@"DEV_CL_VERBOSE" andMessage:@"About to ask user for permission to use location services"];
            break;
#endif
     
        default:
            break;
    }
    
    // Setup location manager
    self.locationManager = [[CLLocationManager alloc] init];
    // attention: NSLocationUsageDescription in plist determines the message shown to the user on request to user location services.
    [self.locationManager setDelegate:self];
    [self.locationManager setDesiredAccuracy:kCLLocationAccuracyBestForNavigation];
#define CL_DISTANCE_FILTER 1 // Meters
    [self.locationManager setDistanceFilter:kCLDistanceFilterNone];
#define CL_HEADING_FILTER 5 // Degrees
    [self.locationManager setHeadingFilter:CL_HEADING_FILTER];
    
    // Start updating location services
    if ([CLLocationManager locationServicesEnabled]) {
        [self.locationManager startUpdatingLocation];
    } else {
        [self errorBox:@"Location Services" andMessage:@"Location Services are Disabled. Aborting"];
    }
    
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    /* from docs:
     locations: An array of CLLocation objects containing the location data. This array always contains at least one object representing the current location. If updates were deferred or if multiple locations arrived before they could be delivered, the array may contain additional entries. The objects in the array are organized in the order in which they occurred. Therefore, the most recent location update is at the end of the array.
     */
    CLLocation *userLocation = [locations lastObject];
    
    // Center the map manually because MapKits location manager is disabled and thus not handling the centering himself.
    MKCoordinateRegion region = {{0.0f,0.0f},{0.0f,0.0f}};
    region.center = userLocation.coordinate;
    region.span.longitudeDelta = 0.0001f;
    region.span.latitudeDelta = 0.0001f;
    [_mapView setRegion:region animated:NO];
#ifndef DEV_TOUCH_MODE
    // Alert game controller that player has changed position.
    [[NSNotificationCenter defaultCenter] postNotificationName:@"didUpdatePlayerPosition" object:userLocation];

#ifdef DEV_CL_VERBOSE
    static NSDate *date;
    if (!date) date=userLocation.timestamp;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains
    (NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    //make a file name to write the data to using the documents directory:
    NSString *fileName = [NSString stringWithFormat:@"%@/gpsaccuracy.txt",
                          documentsDirectory];
    //create content - four lines of text
    NSString *content = [NSString stringWithFormat:@"%lf,%lf,%lf,%lf\n", userLocation.horizontalAccuracy, userLocation.verticalAccuracy, userLocation.speed, [userLocation.timestamp timeIntervalSinceDate:date]];    //save content to the documents directory
    NSLog(@"DidupdateLocation");
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:fileName];
    [fileHandle seekToEndOfFile];
    [fileHandle writeData:[content dataUsingEncoding:NSUTF8StringEncoding]];
    [fileHandle closeFile];
#endif
#endif
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    [self errorBox:error.localizedDescription andMessage:error.localizedFailureReason];
}

#pragma mark - Setters & Getters
- (void)setZombiesData:(NSArray *)zombiesData {
    _zombiesData = zombiesData;
    
    [self displayZombiesOnMap];
}

-(void)renderZombies:(NSArray*)zombies{
    [self setZombiesData:zombies];
    [self displayZombiesOnMap];
}

- (CLLocation *)playerLocation {
    return _mapView.userLocation.location;
}
- (IBAction)dev_placePlayerWithTouch:(id)sender {
#ifdef DEV_TOUCH_MODE
    
    // Get the GPS coordinates where the press occured.
    UILongPressGestureRecognizer *gr = sender;
    //if (gr.state == UIGestureRecognizerStateBegan) { // Only act on first press. This is a continious event.
        MKMapView *grMapView = (MKMapView *)gr.view;
        CGPoint location = [gr locationInView:grMapView];
        CLLocationCoordinate2D location2d = [grMapView convertPoint:location toCoordinateFromView:grMapView];
        CLLocation *gestureLocation = [[CLLocation alloc] initWithLatitude:location2d.latitude longitude:location2d.longitude];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"didUpdatePlayerPosition" object:gestureLocation];
        NSLog(@"Dev mode: notification posted: didUpdatePlayerPosition");
    //}

#endif
}

#ifdef DRAW_CELLS
- (void)drawCells {
    for (UIImageView *img in _mapView.subviews) {
        if (img.tag == 100) [img removeFromSuperview];
    }
    

    for (int x = 0; x < MAP_WIDTH; x++)
        for (int y = 0; y < MAP_HEIGHT; y++) {
            UIImage *img = [UIImage imageNamed:@"cell"];
            UIImageView *imageView = [[UIImageView alloc] initWithImage:img];
            imageView.tag = 100; // fake its a zombie so not deleted by zombie update.
            GridCell *cell = [[_gameController gridMap] cellAt:x andY:y];
            CLLocation *cellLocation = [[_gameController gridMap] coreLocationForCell:cell];
            CLLocationCoordinate2D location = cellLocation.coordinate;
            CGPoint pointInMapView = [_mapView convertCoordinate:location toPointToView:_mapView];
            centerViewAtPointWithAnimationSpeed(imageView, pointInMapView,0.0);
            
            [_mapView addSubview:imageView];

        }
}
#endif

#ifdef DRAW_PATHFINDING
- (void)drawPathfinding:(NSNotification *)cellArray {
    NSArray *gridCells = [cellArray object];
    
    for (UIImageView *img in _mapView.subviews) {
        //if (img.tag == 200) [img removeFromSuperview];
    }
    
    for (GridCell *cell in gridCells) {
        UIImage *img = [UIImage imageNamed:@"cell"];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:img];
        imageView.tag = 200;
        CLLocation *cellLocation = [[_gameController gridMap] coreLocationForCell:cell];
        CLLocationCoordinate2D location = cellLocation.coordinate;
        CGPoint pointInMapView = [_mapView convertCoordinate:location toPointToView:_mapView];
        centerViewAtPointWithAnimationSpeed(imageView, pointInMapView, 0.0);
        [_mapView addSubview:imageView];
    }
    
    
}
#endif

- (void)gameOver{
    [_gameController stop]; // Stop here cuz alert boxes can end the game.
    [self performSegueWithIdentifier:@"endGame" sender:self];
}

#pragma mark - Alerts

#define ALERTBOX_ERROR  1
#define ALERTBOX_INFO   2

- (void)errorBox:(NSString* )withTitle andMessage:(NSString *)message {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:withTitle message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Acknowledge", nil];
    alert.tag = ALERTBOX_ERROR;
    [alert show];
}

- (void)infoBox:(NSString *)withTitle andMessage:(NSString *)message {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:withTitle message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Acknowledge", nil];
    alert.tag = ALERTBOX_INFO;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    switch (alertView.tag) {
            
        case ALERTBOX_ERROR:
            [self gameOver];
            break;
            
        case ALERTBOX_INFO:
            break;
            
        default:
            NSLog(@"\nWarning: Unhandled Alert:\nTitle:%@\nMessage:%@\n", alertView.title, alertView.message);
            break;
    }
}



@end
