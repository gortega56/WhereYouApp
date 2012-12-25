//
//  ViewController.h
//  WhereYouApp
//
//  Created by Gabriel Ortega on 3/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import <MapKit/MapKit.h>
#import "AppLocationManager.h"
#import "CustomPin.h"
#import "GoogleResultPin.h"
#import "GoogleMapSearchObject.h"
#import "YahooLocalSearchObject.h"
#import "InfoViewController.h"
#import "CustomAlertView.h"

#define kHintViewKey        @"hintView"

@interface ViewController : UIViewController <MFMessageComposeViewControllerDelegate, ABPeoplePickerNavigationControllerDelegate, MFMailComposeViewControllerDelegate,MKMapViewDelegate, AppLocationManagerDelegate,UISearchBarDelegate, UITextFieldDelegate, GoogleMapSearchDelegate, YahooLocalSearchDelegate,CustomAlertViewDelegate>

@property (nonatomic, strong) MFMessageComposeViewController *locationMessageViewController;
@property (nonatomic, strong) MFMailComposeViewController *locationMailViewController;
@property (nonatomic, strong) NSString *stringLocation;
@property (nonatomic, strong) ABPeoplePickerNavigationController *peoplePickerNavigationController;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *shareLocationButton;
@property (nonatomic, strong) IBOutlet MKMapView *miniMapView;
@property (nonatomic, strong) IBOutlet UILabel *mapLabel;
@property (nonatomic, strong) IBOutlet UITextField *searchText;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *searchActivityIndicator;
@property (nonatomic, strong) NSString *userLocationString;
@property (nonatomic, strong) NSString *locationTitleString;
@property (nonatomic, strong) NSString *messageBodyString;
@property (nonatomic, strong) UIControl *transparentView;
@property (nonatomic, strong) MKAnnotationView *activePin;
@property (nonatomic, strong) GoogleMapSearchObject *googleMapSearchObject;
@property (nonatomic, strong) YahooLocalSearchObject *yahooLocalSearchObject;
@property (nonatomic, strong) UIAlertView *alertViewIMadeBecauseISuck;
@property (nonatomic, strong) InfoViewController *infoViewController;
@property (nonatomic) BOOL showHintView;
@property (nonatomic, retain) CustomAlertView *customAlert;

- (IBAction)info_Click:(id)sender;
- (IBAction)backgroundTap:(id)sender;
- (IBAction)shareLocation_Click:(id)sender;
- (IBAction)updateLocation_Click:(id)sender;
- (IBAction)clearMap_Click:(id)sender;
- (IBAction)sendToGoogle_Click:(id)sender;
- (void)regionThatFitsAnnotations:(MKMapView *)mapView;
- (void)loadSettings;

@end
