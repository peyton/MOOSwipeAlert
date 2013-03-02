//
//  ViewController.m
//  Demo Project
//
//  Created by Peyton Randolph on 7/10/12.
//

#import "AlertViewController.h"

#import "MOOMessageSwipeAlert.h"

@interface AlertViewController ()

@end

@implementation AlertViewController
@synthesize alertView = _alertView;
@synthesize noDisappearAlertView = _noDisappearAlertView;
@synthesize dismissButton = _dismissButton;

- (void)viewWillAppear:(BOOL)animated;
{
    [self.dismissButton removeFromSuperview];
    self.view.alpha = 0.0f;
    [UIView animateWithDuration:0.3 delay:0.3 options:UIViewAnimationCurveEaseOut animations:^{
        self.view.alpha = 1.0f;
    } completion:NULL];
}

#pragma mark - Button event handling

- (IBAction)showButtonPressed1:(id)sender;
{
    self.alertView = [[MOOMessageSwipeAlert alloc] initWithTitle:@"Test alert" message:@"This is a test of the alert system. There is no cause for alarm." delegate:self];
    [self.alertView show];
}

- (void)showButtonPressed2:(id)sender;
{
    self.alertView = [[MOOMessageSwipeAlert alloc] initWithTitle:@"Test alert" message:nil delegate:self];
    [self.alertView show];
}

- (IBAction)showButtonPressed3:(id)sender;
{
    self.alertView = [[MOOMessageSwipeAlert alloc] initWithTitle:nil message:@"This is a test of the alert system. There is no cause for alarm." delegate:self];
    [self.alertView show];
}

- (IBAction)showButtonPressedCloseButton:(id)sender;
{
    self.alertView = [[MOOMessageSwipeAlert alloc] initWithTitle:@"Test alert" message:@"This is a test of the alert system. There is no cause for alarm." delegate:self];
    self.alertView.showCloseButton = YES;
    [self.alertView show];
}

- (IBAction)showButtonPressed4:(id)sender;
{
    self.alertView = [[MOOMessageSwipeAlert alloc] initWithTitle:@"Test alert" message:@"This is a test of the alert system. There is no cause for alarm." delegate:nil];
    
    __weak AlertViewController *weakSelf = self;
    _alertView.dismissBlock = ^(MOOSwipeAlert *alert, BOOL animated) {
        NSLog(@"dismissal block called!");
        weakSelf.alertView = nil;
    };
    
    [self.alertView show];
}

- (IBAction)showButtonPressed5:(id)sender;
{
    self.noDisappearAlertView = [[MOOMessageSwipeAlert alloc] initWithTitle:@"Test alert" message:@"You will never dismiss me!!!" delegate:self];
    
    // Add button to allow for dismissal regardless
    [self.noDisappearAlertView addSubview:self.dismissButton];
    CGRect dismissButtonFrame = self.dismissButton.frame;
    CGRect statusBarFrame = [UIApplication sharedApplication].statusBarFrame;
    dismissButtonFrame.origin = CGPointMake(20.f, fminf(CGRectGetHeight(statusBarFrame), CGRectGetWidth(statusBarFrame)) + 20.f);
    self.dismissButton.frame = dismissButtonFrame;
    
    
    [self.noDisappearAlertView show];
}

- (IBAction)dismissButtonPressed:(id)sender;
{
    if (!self.dismissButton || !self.noDisappearAlertView)
        return;
    [self.dismissButton removeFromSuperview];
    [self.noDisappearAlertView dismissAnimated:YES];
}

#pragma mark - MOOSwipeAlertDelegate methods

- (BOOL)alertViewShouldDismiss:(MOOSwipeAlert *)alertView;
{
    return alertView != self.noDisappearAlertView;
}

- (void)alertViewDidDismiss:(MOOSwipeAlert *)alertView animated:(BOOL)animated;
{
    // Clean up
    if (alertView == self.alertView)
        self.alertView = nil;
    else if (alertView == self.noDisappearAlertView)
    {
        [self.dismissButton removeFromSuperview];
        self.noDisappearAlertView = nil;
    }
}

@end
