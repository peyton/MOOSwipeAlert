//
//  BasicsViewController.h
//  Demo Project
//
//  Created by Peyton Randolph on 7/10/12.
//

#import "ViewController.h"

#import "MOOSwipeAlert.h"

@class MOOMessageSwipeAlert;

@interface BasicsViewController : ViewController <MOOSwipeAlertDelegate>

@property (nonatomic, strong) MOOMessageSwipeAlert *alertView;
@property (nonatomic, strong) MOOMessageSwipeAlert *noDismissalAlertView;
@property (nonatomic, strong) IBOutlet UIButton *dismissButton;
@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;

- (IBAction)titleAndMessageButtonPressed:(id)sender;
- (IBAction)titleOnlyButtonPressed:(id)sender;
- (IBAction)messageOnlyButtonPressed:(id)sender;
- (IBAction)blockCallbackButtonPressed:(id)sender;
- (IBAction)noDismissalButtonPressed:(id)sender;
- (IBAction)alternateBackgroundButtonPressed:(id)sender;
- (IBAction)dismissButtonPressed:(id)sender;


@end
