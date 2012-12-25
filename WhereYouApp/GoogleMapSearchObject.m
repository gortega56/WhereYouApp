//
//  GoogleMapSearchObject.m
//  WhereYouApp
//
//  Created by Gabriel Ortega on 4/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GoogleMapSearchObject.h"

@implementation GoogleMapSearchObject
@synthesize receivedData, xmlParser, resultsArray, locationObject, currentElementValue, searchDelegate, previousElement;

- (id) initWithDelegate:(id)delegate
{
    self.searchDelegate = delegate;
    return self;
}

- (void)searchFor:(NSString *)address withIn:(MKMapView *)mapView
{
    // Calculate the bounds within we conduct our search
    CGPoint upperRight = CGPointMake(mapView.bounds.origin.x + mapView.bounds.size.width, mapView.bounds.origin.y);
    CGPoint bottomLeft = CGPointMake(mapView.bounds.origin.x, mapView.bounds.origin.y + mapView.bounds.size.height);
    
    CLLocationCoordinate2D upperRightBound;
    upperRightBound = [mapView convertPoint:upperRight toCoordinateFromView:mapView];
    
    CLLocationCoordinate2D bottomLeftBound;
    bottomLeftBound = [mapView convertPoint:bottomLeft toCoordinateFromView:mapView];
    
    CLLocationCoordinate2D box;
    box = mapView.userLocation.coordinate;

    // Construct our URL and initiate connection
    //NSString *URLString = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/geocode/xml?address=%@&bounds=%f,%f|%f,%f&sensor=true",address,box.latitude,box.longitude,box.latitude,box.longitude];
    NSString *URLString = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/geocode/xml?address=%@&sensor=true",address];
    
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:URLString]];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    if (connection)
        receivedData = [NSMutableData new];
    else 
    {
        NSLog(@"google connection failed");
        [self.searchDelegate googleConnectionDidFail];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [receivedData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    
    NSLog(@"Succeeded! Received %d bytes of data",[receivedData length]);
    NSString *dataString = [[NSString alloc] initWithData:receivedData encoding:NSASCIIStringEncoding];
    NSLog(@"%@", dataString);
 
    xmlParser = [[NSXMLParser alloc] initWithData:receivedData];
    [xmlParser setDelegate:self];
    
    BOOL success = [xmlParser parse];
    
    if(success)
        NSLog(@"No Errors");
    else
    {
        NSLog(@"Error Error Error!!!");
        [self.searchDelegate googleResultsParsingError];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [self.searchDelegate googleConnectionDidFail];
    NSLog(@"Google Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
}

- (void)parserDidStartDocument:(NSXMLParser *)parser
{
    resultsArray = [NSMutableArray new];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    if ([elementName isEqualToString:@"result"])
        locationObject = [MyLocationObject new];
    else if ([elementName isEqualToString:@"location"])
        previousElement = elementName;
    
    NSLog(@"Processing Element: %@", elementName);
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if (!currentElementValue)
        currentElementValue = [[NSMutableString alloc] initWithString:string];
    else
        [currentElementValue appendString:string];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if ([elementName isEqualToString:@"status"]) {
        NSString *trimmedString = [currentElementValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if (![trimmedString isEqualToString:@"OK"]) {
            [self.searchDelegate googleSearchCompletedWithZeroResults];
            currentElementValue = nil;
            return;
        }
    }else if ([elementName isEqualToString:@"result"]) {
        [resultsArray addObject:locationObject];
        return;
    } else if ([elementName isEqualToString:@"formatted_address"]) {
        NSString *trimmedString = [currentElementValue stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
        [locationObject setTitle:trimmedString];
        currentElementValue = nil;
        return;
    } else if ([elementName isEqualToString:@"lat"]) {
        if ([previousElement isEqualToString:@"location"]) {
            NSString *trimmedString = [currentElementValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            [locationObject setLatitude:trimmedString];
            currentElementValue = nil;
            return;
        }
    } else if ([elementName isEqualToString:@"lng"]) {
        if ([previousElement isEqualToString:@"location"]) {
            NSString *trimmedString = [currentElementValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            [locationObject setLongitude:trimmedString];
            currentElementValue = nil;
            return;
        }
    } else
        currentElementValue = nil;
    return;
}

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
    for (int i=0; i<[resultsArray count]; i++)
    {
        NSLog(@"Title: %@",[[resultsArray objectAtIndex:i] title]);
        NSLog(@"Address: %@",[[resultsArray objectAtIndex:i] address]);
        NSLog(@"City: %@",[[resultsArray objectAtIndex:i] city]);
    }
    
    [self.searchDelegate googleSearchCompletedWithResults:resultsArray];
}
@end
