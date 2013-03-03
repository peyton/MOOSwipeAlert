//
//  ButtonsViewController.h
//  Demo Project
//
//  Created by Peyton Randolph on 3/2/13.
//

#import "ViewController.h"

#import "MOOButtonSwipeAlert.h"

@interface ButtonsViewController : ViewController <MOOSwipeAlertDelegate>

@property (nonatomic, strong) MOOButtonSwipeAlert *alertView;
@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;

- (IBAction)showButtonPressed1:(id)sender;
- (IBAction)showButtonPressed2:(id)sender;
- (IBAction)showButtonPressed3:(id)sender;
- (IBAction)showButtonPressed4:(id)sender;
- (IBAction)showButtonPressed5:(id)sender;

@end
