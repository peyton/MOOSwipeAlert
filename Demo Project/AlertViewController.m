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

- (void)loadView;
{
    [super loadView];
    
    _dismissButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [_dismissButton addTarget:self action:@selector(_dismissButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [_dismissButton setTitle:@"Dismiss" forState:UIControlStateNormal];
    [_dismissButton sizeToFit];
    _dismissButton.frame = CGRectMake(30.0f, 44.0f, CGRectGetWidth(_dismissButton.frame), CGRectGetHeight(_dismissButton.frame));
}

- (void)viewWillAppear:(BOOL)animated;
{
    self.view.alpha = 0.0f;
    [UIView animateWithDuration:0.3 delay:0.3 options:UIViewAnimationCurveEaseOut animations:^{
        self.view.alpha = 1.0f;
    } completion:NULL];
}

#pragma mark - Button event handling

- (void)_showButtonPressed1:(id)sender;
{
    _alertView = [[MOOMessageSwipeAlert alloc] initWithTitle:@"Test alert" message:@"This is a test of the alert system. There is no cause for alarm." delegate:self];
    [_alertView show];
}

- (void)_showButtonPressed2:(id)sender;
{
    _alertView = [[MOOMessageSwipeAlert alloc] initWithTitle:nil message:@"This is a test of the alert system. There is no cause for alarm." delegate:self];
    [_alertView show];
}

- (void)_showButtonPressed3:(id)sender;
{
    _alertView = [[MOOMessageSwipeAlert alloc] initWithTitle:@"Test alert" message:nil delegate:self];
    [_alertView show];
}

- (void)_showButtonPressed4:(id)sender;
{
    _alertView = [[MOOMessageSwipeAlert alloc] initWithTitle:@"Test alert" message:@"This is a test of the alert system. There is no cause for alarm." delegate:self];
    _alertView.showCloseButton = YES;
    [_alertView show];
}

- (void)_showButtonPressed5:(id)sender;
{
    _noDisappearAlertView = [[MOOMessageSwipeAlert alloc] initWithTitle:@"Test alert" message:@"You will never dismiss me!!!" delegate:self];
    [_noDisappearAlertView show];
    [_noDisappearAlertView addSubview:_dismissButton];
}

- (void)_showButtonPressed6:(id)sender;
{
    self.alertView = [[MOOMessageSwipeAlert alloc] initWithTitle:@"Test alert" message:@"This is a test of the alert system. There is no cause for alarm." delegate:nil];
    
    __weak AlertViewController *weakSelf = self;
    _alertView.dismissBlock = ^(MOOSwipeAlert *alert, BOOL animated) {
        NSLog(@"dismissal block called!");
        weakSelf.alertView = nil;
    };
    
    [self.alertView show];
}

- (void)_dismissButtonPressed:(id)sender;
{
    [_dismissButton removeFromSuperview];
    [_noDisappearAlertView dismissAnimated:YES];
}

#pragma mark - MOOSwipeAlertDelegate methods

- (BOOL)alertViewShouldDismiss:(MOOSwipeAlert *)alertView;
{
    return alertView != _noDisappearAlertView;
}

- (void)alertViewDidDismiss:(MOOSwipeAlert *)alertView animated:(BOOL)animated;
{
    if (alertView == _alertView)
        _alertView = nil;
    else if (alertView == _noDisappearAlertView)
        _noDisappearAlertView = nil;
}

@end
