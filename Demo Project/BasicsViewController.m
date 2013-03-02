//
//  BasicsViewController.m
//  Demo Project
//
//  Created by Peyton Randolph on 7/10/12.
//

#import "BasicsViewController.h"

#import "MOOMessageSwipeAlert.h"

@implementation BasicsViewController
@synthesize alertView = _alertView;
@synthesize noDismissalAlertView = _noDisappearAlertView;
@synthesize dismissButton = _dismissButton;

- (void)viewWillAppear:(BOOL)animated;
{
    [super viewWillAppear:animated];
    
    // Configure alert dismiss button
    [self.dismissButton removeFromSuperview];
}

#pragma mark - Button event handling

- (IBAction)titleAndMessageButtonPressed:(id)sender;
{
    self.alertView = [[MOOMessageSwipeAlert alloc] initWithTitle:@"Test alert" message:@"This is a test of the alert system. There is no cause for alarm." delegate:self];
    [self.alertView show];
}

- (void)titleOnlyButtonPressed:(id)sender;
{
    self.alertView = [[MOOMessageSwipeAlert alloc] initWithTitle:@"Test alert" message:nil delegate:self];
    [self.alertView show];
}

- (IBAction)messageOnlyButtonPressed:(id)sender;
{
    self.alertView = [[MOOMessageSwipeAlert alloc] initWithTitle:nil message:@"This is a test of the alert system. There is no cause for alarm." delegate:self];
    [self.alertView show];
}

- (IBAction)blockCallbackButtonPressed:(id)sender;
{
    self.alertView = [[MOOMessageSwipeAlert alloc] initWithTitle:@"Test alert" message:@"This is a test of the alert system. There is no cause for alarm." delegate:nil];
    
    __weak BasicsViewController *weakSelf = self;
    _alertView.dismissBlock = ^(MOOSwipeAlert *alert, BOOL animated) {
        NSLog(@"dismissal block called!");
        weakSelf.alertView = nil;
    };
    
    [self.alertView show];
}

- (IBAction)noDismissalButtonPressed:(id)sender;
{
    self.noDismissalAlertView = [[MOOMessageSwipeAlert alloc] initWithTitle:@"Test alert" message:@"You will never dismiss me!!!" delegate:self];
    
    // Add button to allow for dismissal regardless
    [self.noDismissalAlertView addSubview:self.dismissButton];
    CGRect dismissButtonFrame = self.dismissButton.frame;
    CGRect statusBarFrame = [UIApplication sharedApplication].statusBarFrame;
    dismissButtonFrame.origin = CGPointMake(20.f, fminf(CGRectGetHeight(statusBarFrame), CGRectGetWidth(statusBarFrame)) + 20.f);
    self.dismissButton.frame = dismissButtonFrame;
    
    
    [self.noDismissalAlertView show];
}

- (IBAction)alternateBackgroundButtonPressed:(id)sender;
{
    self.alertView = [[MOOMessageSwipeAlert alloc] initWithTitle:@"Test alert" message:@"This is a test of the alert system. There is no cause for alarm." delegate:self];
    self.alertView.backgroundStyle = (self.alertView.backgroundStyle == kMOOSwipeAlertBackgroundStyleFlat) ? kMOOSwipeAlertBackgroundStyleVignette : kMOOSwipeAlertBackgroundStyleFlat;
    [self.alertView show];
}

- (IBAction)dismissButtonPressed:(id)sender;
{
    if (!self.dismissButton || !self.noDismissalAlertView)
        return;
    [self.dismissButton removeFromSuperview];
    [self.noDismissalAlertView dismissAnimated:YES];
}

#pragma mark - MOOSwipeAlertDelegate methods

- (BOOL)alertViewShouldDismiss:(MOOSwipeAlert *)alertView;
{
    return alertView != self.noDismissalAlertView;
}

- (void)alertViewDidDismiss:(MOOSwipeAlert *)alertView animated:(BOOL)animated;
{
    // Clean up
    if (alertView == self.alertView)
        self.alertView = nil;
    else if (alertView == self.noDismissalAlertView)
    {
        [self.dismissButton removeFromSuperview];
        self.noDismissalAlertView = nil;
    }
}

@end
