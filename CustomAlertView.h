//
//  CustomAlertView.h
//  WhereYouApp
//
//  Created by Gabriel Ortega on 5/23/12.
// This class uses code from: 
//      iphonedevelopment.blogspot.com/2010/05/custom-alert-views.html

#import <UIKit/UIKit.h>

enum
{
    CustomAlertViewButtonTag = 1,
    CustomAlertViewButtonTagDoNotShowAgain = 0
};
@class CustomAlertView;

@protocol CustomAlertViewDelegate
@required
- (void)customAlertView:(CustomAlertView *)alert wasDismissedWithValue:(BOOL)value;
@optional
- (void)customAlertViewWasCancelled:(CustomAlertView *)alert;
@end

@interface CustomAlertView : UIViewController

@property (nonatomic, retain) IBOutlet UIView *alertView;
@property (nonatomic, retain) IBOutlet UIView *backgroundView;
@property (nonatomic, assign) id <CustomAlertViewDelegate> delegate;

- (IBAction)show;
- (IBAction)dismiss:(id)sender;
@end
