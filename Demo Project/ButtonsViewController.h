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

- (IBAction)closeButton:(id)sender;
- (IBAction)oneButtonsPressed:(id)sender;
- (IBAction)twoButtonsPressed:(id)sender;
- (IBAction)threeButtonsPressed:(id)sender;
- (IBAction)sideBySideButtonPressed:(id)sender;

@end
