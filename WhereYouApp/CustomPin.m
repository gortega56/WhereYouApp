//
//  CustomPin.m
//  WhereYouApp
//
//  Created by Gabriel Ortega on 3/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CustomPin.h"

@implementation CustomPin
@synthesize coordinate, myTitle, mySubtitle;

- (id) initWithCoordinate:(CLLocationCoordinate2D)point
{
    coordinate = point;
    return self;
}

- (NSString *) title
{
    return myTitle;
}
- (NSString *) subtitle
{
    return mySubtitle;
}
@end
