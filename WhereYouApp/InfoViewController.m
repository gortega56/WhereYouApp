//
//  InfoViewController.m
//  WhereYouApp
//
//  Created by Gabriel Ortega on 4/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "InfoViewController.h"

@interface InfoViewController ()

@end

@implementation InfoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.navigationBar.topItem.title = @"Where You @pp";
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = NO;
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)googleButton_Click:(id)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"http://www.google.com/intl/en/policies/terms/"]];
}
- (IBAction)yahooButton_Click:(id)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"http://info.yahoo.com/legal/us/yahoo/utos/utos-173.html"]];
}
@end
