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
    
    GameController* gc;
    
    __weak IBOutlet UILabel *_elapsedtimeLabel;
}

@end
