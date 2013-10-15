//
//  MapDelegate.m
//  Zombie App
//
//  Created by Pétur Ingi Egilsson on 14/10/13.
//  Copyright (c) 2013 Aalborg Universitet. All rights reserved.
//

#import "MapDelegate.h"

@implementation MapDelegate

#pragma mark - MapView

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
