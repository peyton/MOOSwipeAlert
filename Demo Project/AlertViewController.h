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
@property (nonatomic, strong) IBOutlet UIButton *dismissButton;

- (IBAction)showButtonPressed1:(id)sender;
- (IBAction)showButtonPressed2:(id)sender;
- (IBAction)showButtonPressed3:(id)sender;
- (IBAction)showButtonPressed4:(id)sender;
- (IBAction)showButtonPressed5:(id)sender;
- (IBAction)dismissButtonPressed:(id)sender;


@end
