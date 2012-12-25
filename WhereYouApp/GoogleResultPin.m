//
//  GoogleResultPin.m
//  WhereYouApp
//
//  Created by SSCSIS on 4/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GoogleResultPin.h"

@implementation GoogleResultPin
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
