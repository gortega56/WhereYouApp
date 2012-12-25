//
//  YahooLocalSearchObject.m
//  WhereYouApp
//
//  Created by Gabriel Ortega on 4/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "YahooLocalSearchObject.h"

@implementation YahooLocalSearchObject
@synthesize receivedData, xmlParser, resultsArray, locationObject, currentElementValue, searchDelegate, previousElement;

- (id) initWithDelegate:(id)delegate
{
    self.searchDelegate = delegate;
    return self;
}

- (void)searchFor:(NSString *)localBusiness near:(CLLocation *)location
{
    NSInteger resultsParameter = 20;
    float radiusParameter = 10;
    
    NSString *URLstring = [NSString stringWithFormat:@"http://local.yahooapis.com/LocalSearchService/V3/localSearch?appid=i5CZM036&query=%@&latitude=%f&longitude=%f&results=%i&radius=%f",localBusiness,location.coordinate.latitude, location.coordinate.longitude, resultsParameter, radiusParameter];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:URLstring]];
    NSURLConnection *connection = [[NSURLConnection alloc]initWithRequest:request delegate:self];
    
    if (connection)
    {
        receivedData = [NSMutableData new];
    }
    else {
        NSLog(@"yahoo connection Failed");
        [self.searchDelegate yahooConnectionDidFail];
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

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [self.searchDelegate yahooConnectionDidFail];
    NSLog(@"Yahoo Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
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
        [self.searchDelegate yahooResultsParsingError];
    }

}

- (void)parserDidStartDocument:(NSXMLParser *)parser
{
    resultsArray = [NSMutableArray new];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    if ([elementName isEqualToString:@"Result"])
    {
        locationObject = [MyLocationObject new];
        [locationObject setLocationID:[[attributeDict objectForKey:@"id"] integerValue]];
        
        NSLog(@"Reading id value :%i", [locationObject locationID]);
    }
    
    
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
    if ([elementName isEqualToString:@"Result"]) {
        [resultsArray addObject:locationObject];
        return;
    } else if ([elementName isEqualToString:@"Title"]) {
        [locationObject setTitle:currentElementValue];
        currentElementValue = nil;
        return;
    } else if ([elementName isEqualToString:@"Address"]) {
        [locationObject setAddress:currentElementValue];
        currentElementValue = nil;
        return;
    } else if ([elementName isEqualToString:@"City"]) {
        [locationObject setCity:currentElementValue];
        currentElementValue = nil;
        return;
    } else if ([elementName isEqualToString:@"State"]) {
        [locationObject setState:currentElementValue];
        currentElementValue = nil;
        return;
    } else if ([elementName isEqualToString:@"Phone"]) {
        [locationObject setPhone:currentElementValue];
        currentElementValue = nil;
        return;
    } else if (([elementName isEqualToString:@"Latitude"]) ||
               ([elementName isEqualToString:@"latitude"])) {
        [locationObject setLatitude:currentElementValue];
        currentElementValue = nil;
        return;
    } else if (([elementName isEqualToString:@"Longitude"]) ||
               ([elementName isEqualToString:@"longitude"])) {
        [locationObject setLongitude:currentElementValue];
        currentElementValue = nil;
        return;
    } else 
        currentElementValue = nil;
    return;

}

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
    if ([resultsArray count] > 0)
    {
        for (int i=0; i<[resultsArray count]; i++)
        {
            NSLog(@"Title: %@",[[resultsArray objectAtIndex:i] title]);
            NSLog(@"Address: %@",[[resultsArray objectAtIndex:i] address]);
            NSLog(@"City: %@",[[resultsArray objectAtIndex:i] city]);
        }
    
        [self.searchDelegate yahooSearchCompletedWithResults:resultsArray];
    }
    else
        [self.searchDelegate yahooSearchCompletedWithZeroResults];
}

@end
