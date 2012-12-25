//
//  GoogleMapSearchObject.h
//  WhereYouApp
//
//  Created by Gabriel Ortega on 4/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
//  Description:  This class sends an address string as a query to Google Geocoding Web Service.  Then it parses the results and returns an array.

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "MyLocationObject.h"
@protocol GoogleMapSearchDelegate
@required
- (void)googleConnectionDidFail;
- (void)googleResultsParsingError;
- (void)googleSearchCompletedWithResults:(NSMutableArray *) results;
- (void)googleSearchCompletedWithZeroResults;
@end

@interface GoogleMapSearchObject : NSObject <NSURLConnectionDataDelegate, NSXMLParserDelegate>

@property (nonatomic, strong) NSMutableData *receivedData;
@property (nonatomic, strong) NSXMLParser *xmlParser;
@property (nonatomic, strong) NSMutableArray *resultsArray;
@property (nonatomic, strong) MyLocationObject *locationObject;
@property (nonatomic, strong) NSMutableString *currentElementValue;
@property (nonatomic, strong) NSString *previousElement;
@property (nonatomic, strong) id <GoogleMapSearchDelegate> searchDelegate;

- (id)initWithDelegate:(id)delegate;
- (void)searchFor:(NSString *)address withIn:(MKMapView *)mapView;

@end
