//
//  AppLocationManager.m
//  WhereYouApp
//
//  Created by Gabriel Ortega on 3/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppLocationManager.h"

static AppLocationManager *sharedAppLocationManager = nil;

@implementation AppLocationManager

@synthesize lastLocation, locationManager,locationManagerStartDate, delegate;

#pragma mark Singleton Methods
 + (AppLocationManager *)sharedAppLocationManager
{
    @synchronized(self)
    {
        if (sharedAppLocationManager==nil)
            sharedAppLocationManager = [[self alloc] init];
    }
    return sharedAppLocationManager;
}

- (id)init
{
    if (self = [super init])
    {
        self.locationManager = [CLLocationManager new];
        self.locationManager.delegate = self;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        self.locationManager.distanceFilter = 100;
        self.locationManagerStartDate = [NSDate date];
    }
        return self;
}

- (void) dealloc
{
    // ARC
}

- (void)startUpdatingLocation
{
    [locationManager startUpdatingLocation];
}

- (void)stopUpdatingLocation
{
    [locationManager stopUpdatingLocation];
}

- (void) locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    if ([sharedAppLocationManager isValidLocation:newLocation withOldLocation:oldLocation]) 
    {
        [self.delegate locationDidUpdate:newLocation];
        [self setLastLocation:newLocation];
        [manager stopUpdatingLocation];
    }
    
}

- (BOOL)isValidLocation:(CLLocation *)newLocation withOldLocation:(CLLocation *)oldLocation
{
    if (!newLocation)
        return NO;
    
    if ([newLocation horizontalAccuracy] < 0)
        return NO;
    
    NSTimeInterval secsSinceLastUpdate = [[newLocation timestamp] timeIntervalSinceDate:[oldLocation timestamp]];
    
    if (secsSinceLastUpdate < 0)
        return NO;
    
    NSTimeInterval secsSinceManagerStarted = [[newLocation timestamp] timeIntervalSinceDate:locationManagerStartDate];
    
    if (secsSinceManagerStarted < 0)
        return NO;
    
    return YES;
}
@end
