//
//  CustomAlertView.m
//  WhereYouApp
//
//  Created by Gabriel Ortega on 5/23/12.
//  This class uses code from: 
//      iphonedevelopment.blogspot.com/2010/05/custom-alert-views.html

#import "CustomAlertView.h"
#import "UIView+AlertAnimations.h"
#import <QuartzCore/QuartzCore.h>

@interface CustomAlertView ()
- (void)alertDidFadeOut;
@end

@implementation CustomAlertView
@synthesize alertView;
@synthesize backgroundView;
@synthesize delegate;

#pragma mark -
#pragma mark IBActions
- (IBAction)show
{
    // Add to window
    id appDelegate = [[UIApplication sharedApplication] delegate];
    UIWindow *window = [appDelegate window];
    [window addSubview:self.view];
    
    // Set frame to cover entire window
    self.view.frame = window.frame;
    self.view.center = window.center;
    
    // "Pop in" animation
    [alertView doPopInAnimationWithDelegate:self];
    
    // "Fade in" animation
    [backgroundView doFadeInAnimation];
}

- (IBAction)dismiss:(id)sender
{
    [UIView beginAnimations:nil context:nil];
    self.view.alpha = 0.0;
    [UIView commitAnimations];
    
    [self performSelector:@selector(alertDidFadeOut) withObject:nil afterDelay:0.5];
    
    [delegate customAlertView:self wasDismissedWithValue:[sender tag]];
}

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
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.alertView = nil;
    self.backgroundView = nil;
}

- (void)alertDidFadeOut
{
    [self.view removeFromSuperview];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
