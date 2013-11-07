//
//  NSString+stringFromTimeInterval.m
//  Zombie App
//
//  Created by Brian Pedersen on 07/11/13.
//  Copyright (c) 2013 Aalborg Universitet. All rights reserved.
//

#import "NSString+stringFromTimeInterval.h"

@implementation NSString (stringFromTimeInterval)

+(NSString*)stringFromTimeInterval:(NSTimeInterval)timeInterval{
    NSUInteger elapsed = timeInterval;
    NSUInteger seconds = elapsed % 60;
    NSUInteger minutes = (elapsed / 60) % 60;
    NSUInteger hours = (elapsed / 3600) % 24;
    
    NSString* timeIntervalString = [NSString stringWithFormat:@"%.2ld:%.2ld:%.2ld",
                                    (unsigned long)hours,
                                    (unsigned long)minutes,
                                    (unsigned long)seconds];
    return timeIntervalString;
}
@end
