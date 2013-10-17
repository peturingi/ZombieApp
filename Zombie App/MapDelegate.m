//
//  MapDelegate.m
//  Zombie App
//
//  Copyright (c) 2013 Aalborg Universitet. All rights reserved.
//

#import "MapDelegate.h"

@implementation MapDelegate

#pragma mark - MapView

// Zooms in to the users current location, the map the first time the map is shown.
- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    NSAssert(userLocation,
             @"userLocation was nil");
    
    CLLocationCoordinate2D currentCoordinate = [userLocation coordinate];
    
    // Zoom in on he map, once - the first time the users location is received.
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        const NSInteger mapLongMeters = 500;
        const NSInteger mapLatMeters = 500;
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(currentCoordinate,
                                                                       mapLongMeters,
                                                                       mapLatMeters);
        [mapView setRegion:region];
    });
    
    [mapView setCenterCoordinate:currentCoordinate];
}

@end
