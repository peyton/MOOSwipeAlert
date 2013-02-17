//
//  ViewController.h
//  Demo Project
//
//  Created by Peyton Randolph on 7/10/12.
//

#import "MOOSwipeAlert.h"

@class MOOMessageSwipeAlert;

@interface AlertViewController : UIViewController <MOOSwipeAlertDelegate>

@property (nonatomic, strong) MOOMessageSwipeAlert *alertView;
@property (nonatomic, strong) MOOMessageSwipeAlert *noDisappearAlertView;
@property (nonatomic, strong) UIButton *dismissButton;


@end
