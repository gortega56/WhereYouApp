//
//  ViewController.m
//  WhereYouApp
//
//  Created by Gabriel Ortega on 3/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

@synthesize stringLocation;
@synthesize locationMessageViewController;
@synthesize locationMailViewController;
@synthesize peoplePickerNavigationController;
@synthesize shareLocationButton;
@synthesize miniMapView;
@synthesize mapLabel;
@synthesize searchText;
@synthesize userLocationString;
@synthesize locationTitleString;
@synthesize messageBodyString;
@synthesize transparentView;
@synthesize activePin;
@synthesize googleMapSearchObject;
@synthesize yahooLocalSearchObject;
@synthesize searchActivityIndicator;
@synthesize alertViewIMadeBecauseISuck;
@synthesize infoViewController;
@synthesize showHintView;
@synthesize customAlert;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (void)loadSettings
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.showHintView = [defaults boolForKey:kHintViewKey];
}

- (void)customAlertView:(CustomAlertView *)alert wasDismissedWithValue:(BOOL)value
{
    self.showHintView = value;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:self.showHintView forKey:kHintViewKey];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self loadSettings];
    [searchText setDelegate:self];
    self.navigationController.navigationBarHidden = YES;
    [self.searchActivityIndicator setHidden:YES];
    [self.searchActivityIndicator setHidesWhenStopped:YES];
    
    self.miniMapView.delegate = self;
    self.miniMapView.showsUserLocation = TRUE;
    self.miniMapView.userLocation.title = @"You @re Here";
    self.miniMapView.mapType = MKMapTypeHybrid;
    
    [AppLocationManager sharedAppLocationManager].delegate = self;
    [[AppLocationManager sharedAppLocationManager] startUpdatingLocation];
    [shareLocationButton setEnabled:NO];
    
    if (self.showHintView) {
        // Show Hint Screen
        customAlert = [[CustomAlertView alloc] init];
        customAlert.delegate = self;
        [customAlert show];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    [[AppLocationManager sharedAppLocationManager] stopUpdatingLocation];
    
    self.shareLocationButton = nil;
    self.miniMapView = nil;
    self.mapLabel = nil;
    self.searchText = nil;
    self.searchActivityIndicator = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    [[AppLocationManager sharedAppLocationManager] startUpdatingLocation];
    [shareLocationButton setEnabled:NO];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
    [[AppLocationManager sharedAppLocationManager] stopUpdatingLocation];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}


#pragma mark - Search
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (!transparentView)
    {
        transparentView = [[UIControl alloc] initWithFrame:CGRectMake(self.miniMapView.frame.origin.x, self.searchText.frame.origin.y + self.searchText.frame.size.height, self.miniMapView.frame.size.width, self.miniMapView.frame.size.height)];
        [transparentView setBackgroundColor:[UIColor clearColor]];
        [transparentView addTarget:nil action:@selector(backgroundTap:) forControlEvents:UIControlEventTouchDown];
    }
    
    [self.view addSubview:transparentView];
    
}

// User clicks the Search button (RETURN)
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    [self.transparentView removeFromSuperview];
    
    [self.searchActivityIndicator setHidden:NO];
    [self.searchActivityIndicator startAnimating];
    
    NSString *searchableString = [[textField text] stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    
    if (!googleMapSearchObject)
        googleMapSearchObject = [[GoogleMapSearchObject alloc] initWithDelegate:self];
    
    [googleMapSearchObject searchFor:searchableString withIn:self.miniMapView];
    
    return TRUE;
}

// Method to escape from typing in the search field
- (IBAction)backgroundTap:(id)sender
{
    [self.transparentView removeFromSuperview];
    [searchText resignFirstResponder];
}

#pragma mark - Google Delegate
- (void)googleConnectionDidFail
{
    [self.searchActivityIndicator stopAnimating];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Connection Error" message:@"We're sorry, but we were unable to make a connection to the search engine" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

- (void)googleResultsParsingError
{
    NSLog(@"Google Parsing Error");
}

- (void)googleSearchCompletedWithResults:(NSMutableArray *)results
{
    NSArray *searchResults = [[NSArray alloc] initWithArray:results];
    CLLocation *userLocation = [[CLLocation alloc] initWithLatitude:self.miniMapView.userLocation.coordinate.latitude longitude:self.miniMapView.userLocation.coordinate.longitude];
    
    for (MyLocationObject *tempLocationObject in searchResults)
    {
        CLLocation *tempLocation = [[CLLocation alloc] initWithLatitude:[[tempLocationObject latitude] floatValue] longitude:[[tempLocationObject longitude] floatValue]];
        
        
        float distance = [tempLocation distanceFromLocation:userLocation];
        
        if (distance < 80467.2)
        {
            CLLocationCoordinate2D tempCoordinate = CLLocationCoordinate2DMake([[tempLocationObject latitude] floatValue],     [[tempLocationObject longitude] floatValue]);
            
            GoogleResultPin *localPin = [[GoogleResultPin alloc] initWithCoordinate:tempCoordinate];
            [localPin setMyTitle:@"Possible Address Match"];
            [localPin setMySubtitle:[tempLocationObject title]];
            [self.miniMapView addAnnotation:localPin];
        }
        
    }
    
    if ([self.miniMapView.annotations count] > 1) {
        [self regionThatFitsAnnotations:self.miniMapView];
        [self.searchActivityIndicator stopAnimating];
        return;
    } else {
        
        // Pass to YahooSearchObject
        if (!yahooLocalSearchObject)
            yahooLocalSearchObject = [[YahooLocalSearchObject alloc] initWithDelegate:self];
        
        NSString *searchableString = [[searchText text] stringByReplacingOccurrencesOfString:@" " withString:@"+"];
        [yahooLocalSearchObject searchFor:searchableString near:[[AppLocationManager sharedAppLocationManager] lastLocation]];
    }
}

- (void)googleSearchCompletedWithZeroResults
{
    // Pass to YahooSearchObject
    if (!yahooLocalSearchObject)
        yahooLocalSearchObject = [[YahooLocalSearchObject alloc] initWithDelegate:self];
    
    NSString *searchableString = [[searchText text] stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    [yahooLocalSearchObject searchFor:searchableString near:[[AppLocationManager sharedAppLocationManager] lastLocation]];
    
}

#pragma mark - Yahoo Delegate
- (void)yahooConnectionDidFail
{
    [self.searchActivityIndicator stopAnimating];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Connection Error" message:@"We're sorry, but we were unable to make a connection to the search engine" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

- (void)yahooResultsParsingError
{
    NSLog(@"Yahoo Parsing Error");
}

- (void)yahooSearchCompletedWithResults:(NSMutableArray *) results
{
    NSMutableArray *locationArray = results;
    
    for (int i=0;i<[locationArray count];i++)
    {
        MyLocationObject *tempLocationObject = [locationArray objectAtIndex:i];
        CLLocationCoordinate2D tempCoordinate = CLLocationCoordinate2DMake([[tempLocationObject latitude] floatValue],     [[tempLocationObject longitude] floatValue]);
        CustomPin *localPin = [[CustomPin alloc] initWithCoordinate:tempCoordinate];
        [localPin setMyTitle:[tempLocationObject title]];
        [localPin setMySubtitle:[tempLocationObject phone]];
        [self.miniMapView addAnnotation:localPin];
        
        [self regionThatFitsAnnotations:self.miniMapView];
        [self.searchActivityIndicator stopAnimating];
    }
    
}
- (void)yahooSearchCompletedWithZeroResults
{
    [self.searchActivityIndicator stopAnimating];
    
    
    if (!alertViewIMadeBecauseISuck)  {
        alertViewIMadeBecauseISuck = [[UIAlertView alloc] initWithTitle:@"No Matches" message:@"We're sorry, but your query did not produce any results.  Please try adding more info." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertViewIMadeBecauseISuck show];
    }
    
}

#pragma mark - UIAlert
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    alertViewIMadeBecauseISuck = nil;
}

// MKMapView delegate methods
- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    // Empty for now
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    UIButton *rightCalloutButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [rightCalloutButton setFrame:CGRectMake(0, 0, 33, 33)];
    [rightCalloutButton setTitle:@"" forState:UIControlStateNormal];
    [rightCalloutButton setTag:1];
    
    UIImage *rightCalloutButtonImage = [UIImage imageNamed:@"calloutShare.png"];
    [rightCalloutButton setImage:rightCalloutButtonImage forState:UIControlStateNormal];
    
    UIButton *leftCalloutButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [leftCalloutButton setFrame:CGRectMake(0, 0, 33, 33)];
    [leftCalloutButton setTitle:@"" forState:UIControlStateNormal];
    [leftCalloutButton setTag:0];
    
    UIImage *leftCalloutButtonImage = [UIImage imageNamed:@"call.png"];
    [leftCalloutButton setImage:leftCalloutButtonImage forState:UIControlStateNormal];
    
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    else if ([annotation isKindOfClass:[GoogleResultPin class]]) {
        
        GoogleResultPin *googleResultPin;
        googleResultPin = annotation;
        
        MKPinAnnotationView *pin = [[MKPinAnnotationView alloc] initWithAnnotation:googleResultPin reuseIdentifier:nil];
        [pin setAnimatesDrop:YES];
        [pin setCanShowCallout:TRUE];
        [pin setRightCalloutAccessoryView:rightCalloutButton];
        
        return pin;
        
    } else {
        CustomPin *customPin;
        customPin = annotation;
        
        MKPinAnnotationView *pin = [[MKPinAnnotationView alloc] initWithAnnotation:customPin reuseIdentifier:nil];
        [pin setAnimatesDrop:YES];
        [pin setCanShowCallout:TRUE];
        [pin setLeftCalloutAccessoryView:leftCalloutButton];
        [pin setRightCalloutAccessoryView:rightCalloutButton];
        //[pin setRightCalloutAccessoryView:[UIButton buttonWithType:UIButtonTypeRoundedRect]];
        
        return pin;
        
    }
}

#pragma mark - Map functions
- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    if ([view.annotation isKindOfClass:[MKUserLocation class]])
    {
        [mapLabel setText:userLocationString];
        return;
    }
    
    self.activePin = view;
    
    if ([view.annotation isKindOfClass:[GoogleResultPin class]]) {
        stringLocation = view.annotation.subtitle;
        [mapLabel setText:stringLocation];
    }
    else {
        CLLocation *location = [[CLLocation alloc] initWithLatitude:view.annotation.coordinate.latitude longitude:view.annotation.coordinate.longitude];
        
        
        CLGeocoder *geocoder = [CLGeocoder new];
        [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error)
         {
             CLPlacemark *placemark = [placemarks objectAtIndex:0];
             stringLocation = ABCreateStringWithAddressDictionary(placemark.addressDictionary, FALSE);
             [mapLabel setText:stringLocation];
         }];
    }
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view
{
    if (![view.annotation isKindOfClass:[MKUserLocation class]])
        self.activePin = nil;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    if ([control tag] == 0)
    {
        NSString *phoneString = [[view.annotation.subtitle componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]] componentsJoinedByString:@""];
        NSString *strURL =[NSString stringWithFormat:@"tel://%@",phoneString];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:strURL]];
    }
    else
    {
        if ((![locationTitleString isEqualToString:[view.annotation title]]) || (!locationTitleString))
            locationTitleString = [NSString stringWithFormat:@"%@\n", [view.annotation title]];
        messageBodyString = [locationTitleString stringByAppendingString:stringLocation];
        
        //NSString *directionString = [NSString stringWithFormat:@"\n\nDirections:\nhttp://maps.google.com/maps?saddr=Current%%20Location&daddr=%f,%f", view.annotation.coordinate.latitude, view.annotation.coordinate.longitude];
        
        //messageBodyString = [messageBodyString stringByAppendingString:directionString];
        
        peoplePickerNavigationController = [[ABPeoplePickerNavigationController alloc] init];
        peoplePickerNavigationController.peoplePickerDelegate = self;
        [peoplePickerNavigationController setDisplayedProperties:[[NSArray alloc] initWithObjects:[[NSNumber alloc] initWithInt:kABPersonPhoneProperty],[[NSNumber alloc] initWithInt:kABPersonEmailProperty], nil]];
        
        [self presentModalViewController:peoplePickerNavigationController animated:YES];
    }
}

// Method for resizing mapView to fit all annotations placed
- (void)regionThatFitsAnnotations:(MKMapView *)mapView
{
    if ([mapView.annotations count] == 0)
        return;
    
    CLLocationCoordinate2D topLeftBound;
    topLeftBound.latitude = -90;
    topLeftBound.longitude = 180;
    
    CLLocationCoordinate2D bottomRightBound;
    bottomRightBound.latitude = 90;
    bottomRightBound.longitude = -180;
    
    // Find top left  and bottom right coordinate for view bounds box
    for (id<MKAnnotation> annotation in mapView.annotations)
    {
        topLeftBound.longitude = fmin(topLeftBound.longitude, annotation.coordinate.longitude);
        topLeftBound.latitude = fmax(topLeftBound.latitude, annotation.coordinate.latitude);
        bottomRightBound.longitude = fmax(bottomRightBound.longitude, annotation.coordinate.longitude);
        bottomRightBound.latitude = fmin(bottomRightBound.latitude, annotation.coordinate.latitude);
    }
    
    // Create region using view bounds box
    MKCoordinateRegion region;
    region.center.latitude = topLeftBound.latitude - (topLeftBound.latitude - bottomRightBound.latitude) * 0.5;
    region.center.longitude = topLeftBound.longitude + (bottomRightBound.longitude - topLeftBound.longitude) * 0.5;
    
    // Add space so annotations can seen completely
    region.span.latitudeDelta = fabs(topLeftBound.latitude - bottomRightBound.latitude) * 1.1;
    region.span.longitudeDelta  = fabs(bottomRightBound.longitude - topLeftBound.longitude) * 1.1;
    
    region = [mapView regionThatFits:region];
    [mapView setRegion:region animated:YES];
}

#pragma mark - Location Manager
- (void)locationDidUpdate:(CLLocation *)location
{
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    
    span.latitudeDelta = 0.03;
    span.longitudeDelta = 0.03;
    // This sets the how far to zoom in
    
    region.span = span;
    region.center = [location coordinate];
    
    [self.miniMapView setRegion:region animated:TRUE];
    [self.miniMapView regionThatFits:region];
    
    CLGeocoder *geocoder = [CLGeocoder new];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error)
     {
         CLPlacemark *placemark = [placemarks objectAtIndex:0];
         userLocationString = ABCreateStringWithAddressDictionary(placemark.addressDictionary, FALSE);
         [mapLabel setText:userLocationString];
         [shareLocationButton setEnabled:YES];
     }];
    
    
    
    [[AppLocationManager sharedAppLocationManager] stopUpdatingLocation];
    
}


#pragma Contact Book
- (BOOL) peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person
{
    return TRUE;
}

- (BOOL) peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
{
    // User selects email address
    if (property == kABPersonEmailProperty)
    {
        if ([MFMailComposeViewController canSendMail])
        {
            ABMultiValueRef multiEmails = ABRecordCopyValue(person, property);
            NSString *email = (__bridge NSString *)ABMultiValueCopyValueAtIndex(multiEmails, identifier);
            
            locationMailViewController = [MFMailComposeViewController new];
            locationMailViewController.mailComposeDelegate = self;
            [locationMailViewController setToRecipients:[[NSArray alloc] initWithObjects:email, nil]];
            [locationMailViewController setSubject:[NSString stringWithFormat:@"Location Notification from %@",[[UIDevice currentDevice] name]]];
            [locationMailViewController setMessageBody:messageBodyString isHTML:NO];
            
            [peoplePicker presentModalViewController:locationMailViewController animated:YES];
        }
        else {
            NSLog(@"Cannot send Mail");
        }
    }
    // User selects mobile phone
    else if (property == kABPersonPhoneProperty)
    {
        if ([MFMessageComposeViewController canSendText])
        {
            ABMultiValueRef multiPhones = ABRecordCopyValue(person, property);
            NSString *mobileNumber;
            NSString *mobileLabel;
            
            locationMessageViewController = [MFMessageComposeViewController new];
            self.locationMessageViewController.messageComposeDelegate = self;
            
            // if identifier is above 0 it may not match the mobile label and will be found manually.
            // else we can copy the value stored at index:identifier
            if (identifier)
            {
                for (CFIndex i=0;i<ABMultiValueGetCount(multiPhones);i++)
                {
                    mobileLabel = (__bridge NSString *)ABMultiValueCopyLabelAtIndex(multiPhones, i);
                    if ([mobileLabel isEqualToString:@"_$!<Mobile>!$_"])
                        mobileNumber = (__bridge NSString *)ABMultiValueCopyValueAtIndex(multiPhones,i);
                    else
                    {NSLog(@"There is no mobile number");}
                }
            }
            else
            {mobileNumber= (__bridge NSString *)ABMultiValueCopyValueAtIndex(multiPhones, identifier);}
            
            [locationMessageViewController setRecipients:[[NSArray alloc] initWithObjects:mobileNumber, nil]];
            [locationMessageViewController setBody:messageBodyString];
            
            [peoplePicker presentModalViewController:locationMessageViewController animated:YES];
        }
        else
        {
            NSLog(@"Cannot send SMS");
        }
        
    }
    return FALSE;
}

- (void) peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker
{
    [peoplePicker dismissModalViewControllerAnimated:YES];
    messageBodyString = @"";
}


#pragma mark - UIMessage
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    [controller dismissModalViewControllerAnimated:YES];
}

// MFMailComposeViewController Delegate Method
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [controller dismissModalViewControllerAnimated:YES];
}

#pragma mark - Interations
- (IBAction)info_Click:(id)sender
{
    if (!infoViewController)
        infoViewController = [[InfoViewController alloc] initWithNibName:@"InfoViewController" bundle:nil];
    
    [self.navigationController pushViewController:infoViewController animated:YES];
}


// Calls the PeoplePickerViewController
- (IBAction)shareLocation_Click:(id)sender
{
    if (![locationTitleString isEqualToString:@"My Location:\n"])
        locationTitleString = @"My Location:\n";
    
    //CLLocation *currentLocation = [[AppLocationManager sharedAppLocationManager] lastLocation];
    //NSString *directionString = [NSString stringWithFormat:@"\n\nDirections:\nhttp://maps.google.com/maps?saddr=Current%%20Location&daddr=%f,%f", currentLocation.coordinate.latitude, currentLocation.coordinate.longitude];
    
    messageBodyString = [locationTitleString stringByAppendingString:userLocationString];
    //messageBodyString = [messageBodyString stringByAppendingString:directionString];
    
    
    
    peoplePickerNavigationController = [[ABPeoplePickerNavigationController alloc] init];
    peoplePickerNavigationController.peoplePickerDelegate = self;
    [peoplePickerNavigationController setDisplayedProperties:[[NSArray alloc] initWithObjects:[[NSNumber alloc] initWithInt:kABPersonPhoneProperty],[[NSNumber alloc] initWithInt:kABPersonEmailProperty], nil]];
    
    [self presentModalViewController:peoplePickerNavigationController animated:YES];
}

// Updates User location
- (IBAction)updateLocation_Click:(id)sender
{
    [[AppLocationManager sharedAppLocationManager] startUpdatingLocation];
    [shareLocationButton setEnabled:NO];
}

// Clears the map label and all annotations
- (IBAction)clearMap_Click:(id)sender
{
    for (id annotation in self.miniMapView.annotations)
    {
        NSLog(@"%@", annotation);
        if (![annotation isKindOfClass:[MKUserLocation class]])
            [self.miniMapView removeAnnotation:annotation];
        
    }
    self.activePin = nil;
    [self.mapLabel setText:@""];
    [self.searchText setText:@""];
    
}

// Opens Google Maps App with user location
- (IBAction)sendToGoogle_Click:(id)sender
{
    CLLocation *currentLocation = [[AppLocationManager sharedAppLocationManager] lastLocation];
    NSString *URLString;
    
    if (!self.activePin)
    {
        URLString = [NSString stringWithFormat:@"http://maps.google.com/maps?q=%f,%f",currentLocation.coordinate.latitude,currentLocation.coordinate.longitude];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:URLString]];
    }
    else
    {
        URLString = [NSString stringWithFormat:@"http://maps.google.com/maps?saddr=%f,%f&daddr=%f,%f",currentLocation.coordinate.latitude,currentLocation.coordinate.longitude,activePin.annotation.coordinate.latitude, activePin.annotation.coordinate.longitude];
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:URLString]];
    }
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    //return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    return YES;
}

@end
