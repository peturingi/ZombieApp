//
//  ObservableNSMutableDictionary.m
//  Zombie App
//
//  Created by Pétur Ingi Egilsson on 05/11/13.
//  Copyright (c) 2013 Aalborg Universitet. All rights reserved.
//

#import "ObservableNSMutableDictionary.h"

@implementation ObservableNSMutableDictionary

- (id)initWithCapacity:(NSUInteger)numItems {
    self = (ObservableNSMutableDictionary*)[[NSMutableDictionary alloc] initWithCapacity:numItems];
    return self;
}

- (void)setObject:(id)anObject forKey:(id<NSCopying>)aKey {
    BOOL addingNewKey = NO;
    if (![self objectForKey:aKey]) {
        addingNewKey = YES;
        [self willChangeValueForKey:@"allKeys"];
    } else {
        [self willChangeValueForKey:@"allValues"];
    }
    
    [self setObject:anObject forKey:aKey];
    
    if (addingNewKey) { // Alert a KVO that a new key has been added.
        [self didChangeValueForKey:@"allKeys"];
    } else { // Alert a KVO that a value has changed.
        [self didChangeValueForKey:@"allValues"];
    }
}

- (void)removeObjectForKey:(id)aKey {
    [self willChangeValueForKey:@"allKeys"];
    [self removeObjectForKey:aKey];
    [self didChangeValueForKey:@"allKeys"];
}

@end
