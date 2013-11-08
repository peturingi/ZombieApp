//
//  MapViewController.h
//  Zombie App
//
//  Created by Pétur Ingi Egilsson on 14/10/13.
//  Copyright (c) 2013 Aalborg Universitet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "GameController.h"

#define IMAGE_ZOMBIE [UIImage imageNamed:@"Zombie"];


@interface MapViewController : UIViewController <MKMapViewDelegate, GameControllerDelegate>{
    GameController* _gameController;
    __weak IBOutlet MKMapView *_mapView;
    __weak IBOutlet UILabel *_elapsedtimeLabel;
    __weak IBOutlet UILabel *_speedLabel;
    __weak IBOutlet UILabel *_distanceLabel;
}

/** Zombie identifiers and their coordinates.
 *  @param zombieCoordinates
    key: integer wrapped in a NSNumber, represents a specific zombies identifier.
    value: coordinates for the given key as a CLLocation
 *  @note Change strong to weak if another class should be responsible for the property.
 */
@property (strong, nonatomic) NSDictionary *zombiesCoordinates;

@end
