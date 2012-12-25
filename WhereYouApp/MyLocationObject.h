//
//  MyLocationObject.h
//  WhereYouApp
//
//  Created by Gabriel Ortega on 4/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
//  This is an object used to store location information returned by Google and Yahoo searches

#import <UIKit/UIKit.h>

@interface MyLocationObject : NSObject

@property (nonatomic) NSInteger locationID;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) NSString *state;
@property (nonatomic, strong) NSString *phone;
@property (nonatomic, strong) NSString *latitude;
@property (nonatomic, strong) NSString *longitude;

@end
