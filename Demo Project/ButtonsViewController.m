//
//  ButtonsViewController.m
//  Demo Project
//
//  Created by Peyton Randolph on 3/2/13.
//

#import "ButtonsViewController.h"

@implementation ButtonsViewController
@synthesize alertView = _alertView;

#pragma mark - Button event handling

- (IBAction)closeButton:(id)sender;
{
    self.alertView = [[MOOButtonSwipeAlert alloc] initWithTitle:@"Test alert" message:@"This is a test of the alert system. There is no cause for alarm." delegate:self];
    self.alertView.showCloseButton = YES;
    [self.alertView show];
}

- (IBAction)oneButtonsPressed:(id)sender;
{
    self.alertView = [[MOOButtonSwipeAlert alloc] initWithTitle:@"Test alert" message:@"This is a test of the alert system. There is no cause for alarm." delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    [self.alertView show];
}

- (IBAction)twoButtonsPressed:(id)sender;
{
    self.alertView = [[MOOButtonSwipeAlert alloc] initWithTitle:@"Test alert" message:@"This is a test of the alert system. There is no cause for alarm." delegate:self cancelButtonTitle:@"No thanks\u2026" otherButtonTitles:@"Learn more\u2026", nil];
    [self.alertView show];
}

- (IBAction)threeButtonsPressed:(id)sender;
{
    self.alertView = [[MOOButtonSwipeAlert alloc] initWithTitle:@"Test alert" message:@"This is a test of the alert system. There is no cause for alarm." delegate:self cancelButtonTitle:@"No thanks\u2026" otherButtonTitles:@"OK", @"Learn more\u2026", nil];
    [self.alertView setButtonStyle:kMOOSwipeAlertButtonStyleOK atIndex:0];
    [self.alertView show];
}

- (IBAction)sideBySideButtonPressed:(id)sender;
{
    self.alertView = [[MOOButtonSwipeAlert alloc] initWithTitle:@"Test alert" message:@"This is a test of the alert system. There is no cause for alarm." delegate:self cancelButtonTitle:nil otherButtonTitles:@"Delete", @"Keep", nil];
    [self.alertView setButtonStyle:kMOOSwipeAlertButtonStyleDanger atIndex:0];
    [self.alertView setButtonStyle:kMOOSwipeAlertButtonStyleOK atIndex:1];
    [self.alertView setSideBySideIndices:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 2)]];
    [self.alertView show];
}

#pragma mark - MOOSwipeAlertDelegate methods

- (void)alertViewDidDismiss:(MOOSwipeAlert *)alertView animated:(BOOL)animated;
{
    // Clean up
    if (alertView == self.alertView)
        self.alertView = nil;
}

@end
