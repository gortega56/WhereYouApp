//
//  CustomPin.h
//  WhereYouApp
//
//  Created by Gabriel Ortega on 3/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
//  Description:  This pin is dropped for a search result returned from Yahoo!
#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface CustomPin : NSObject <MKAnnotation>
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
