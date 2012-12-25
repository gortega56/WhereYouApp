//
//  UIView+AlertAnimations.h
//  WhereYouApp
//
//  Created by Gabriel Ortega on 5/22/12.
//  This class uses code from: 
//      iphonedevelopment.blogspot.com/2010/05/custom-alert-views.html
//

#import <UIKit/UIKit.h>

#define kAnimationDuration      0.2555

@interface UIView (AlertAnimations)

-(void)doPopInAnimation;
-(void)doPopInAnimationWithDelegate:(id)animationDelegate;
-(void)doFadeInAnimation;
-(void)doFadeInAnimationWithDelegate:(id)animationDelegate;

@end
