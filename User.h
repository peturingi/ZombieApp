//
//  User.h
//  Zombie App
//
//  Created by Pétur Ingi Egilsson on 14/10/13.
//  Copyright (c) 2013 Aalborg Universitet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface User : NSObject{
    CLLocation* _previousLocation;
}


@property (atomic) CLLocation* location;
@property (atomic) CLLocationDistance distanceTravelledInMeters;
@property (atomic) CLLocationSpeed speed;

@end
