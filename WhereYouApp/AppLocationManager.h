//
//  AppLocationManager.h
//  WhereYouApp
//
//  Created by Gabriel Ortega on 3/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
// Description:  This is a singleton class used for location managment.  

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@protocol AppLocationManagerDelegate
@required
- (void)locationDidUpdate:(CLLocation *)location;
@end


@interface AppLocationManager : NSObject <CLLocationManagerDelegate>

@property (nonatomic, retain) CLLocation *lastLocation;
@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, retain) NSDate *locationManagerStartDate;
@property (nonatomic, retain) id  <AppLocationManagerDelegate> delegate;

+ (AppLocationManager *)sharedAppLocationManager;
- (void)startUpdatingLocation;
- (void)stopUpdatingLocation;
- (BOOL)isValidLocation:(CLLocation *)newLocation withOldLocation:(CLLocation *)oldLocation;
@end
