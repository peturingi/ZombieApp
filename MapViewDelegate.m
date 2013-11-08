//
//  MapViewDelegate.m
//  Zombie App
//
//  Created by Brian Pedersen on 05/11/13.
//  Copyright (c) 2013 Aalborg Universitet. All rights reserved.
//

#import "MapViewDelegate.h"

@implementation MapViewDelegate

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
    
    // post a notification that the user location has changed.
    CLLocation *location = [userLocation location];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"didUpdatePlayerPosition" object:location];
}

@end
