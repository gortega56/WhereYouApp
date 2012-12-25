//
//  YahooLocalSearchObject.h
//  WhereYouApp
//
//  Created by Gabriel Ortega on 4/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
//  Description:  This class sends a string as a query to Yahoo! Local API.  Then it parses the results and returns an array.
//  Yahoo! Local is a business API provided by Yahoo!

/*  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/ 

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "MyLocationObject.h"

@protocol YahooLocalSearchDelegate
@required
- (void)yahooConnectionDidFail;
- (void)yahooResultsParsingError;
- (void)yahooSearchCompletedWithResults:(NSMutableArray *) results;
- (void)yahooSearchCompletedWithZeroResults;
@end

@interface YahooLocalSearchObject : NSObject <NSURLConnectionDataDelegate, NSXMLParserDelegate>

@property (nonatomic, strong) NSMutableData *receivedData;
@property (nonatomic, strong) NSXMLParser *xmlParser;
@property (nonatomic, strong) NSMutableArray *resultsArray;
@property (nonatomic, strong) MyLocationObject *locationObject;
@property (nonatomic, strong) NSMutableString *currentElementValue;
@property (nonatomic, strong) NSString *previousElement;
@property (nonatomic, strong) id <YahooLocalSearchDelegate> searchDelegate;

- (id)initWithDelegate:(id)delegate;
- (void)searchFor:(NSString *)localBusiness near:(CLLocation *)location;

@end
