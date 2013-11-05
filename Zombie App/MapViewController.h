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


@interface MapViewController : UIViewController <MKMapViewDelegate, GameControllerDelegate>{
    NSNotificationCenter* _notificationCenter;
    GameController* _gameController;
    __weak IBOutlet MKMapView *_mapView;
    __weak IBOutlet UILabel *_elapsedtimeLabel;
    __weak IBOutlet UILabel *_speedLabel;
    __weak IBOutlet UILabel *_distanceLabel;
}
@end
