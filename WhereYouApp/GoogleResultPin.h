//
//  GoogleResultPin.h
//  WhereYouApp
//
//  Created by SSCSIS on 4/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
//  Description:  This pin is dropped for a search result returned from Google.

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface GoogleResultPin : NSObject <MKAnnotation>
{
    CLLocationCoordinate2D coordinate;
    NSString *myTitle;
    NSString *mySubtitle;
}

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, strong) NSString *myTitle;
@property (nonatomic, strong) NSString *mySubtitle;

- (NSString *) title;
- (NSString *) subtitle;

- (id) initWithCoordinate:(CLLocationCoordinate2D)point;


@end
