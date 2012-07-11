//
//  ViewController.m
//  Demo Project
//
//  Created by Peyton Randolph on 7/10/12.
//

#import "ViewController.h"

#import "MOOMessageAlertView.h"

@interface ViewController ()

@end

@interface ViewController (MOOAlertViewDelegate) <MOOAlertViewDelegate>

@end

@implementation ViewController

- (void)loadView;
{
    [super loadView];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    // Create buttons
    NSArray *buttonTitles = [NSArray arrayWithObjects:@"Alert", @"Alert without title", @"Alert without message", @"Alert with close button", @"Alert without dismissal", nil];
    
    NSUInteger index = 1;
    UIButton *button;
    for (NSString *title in buttonTitles)
    {
        button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        SEL action = NSSelectorFromString([NSString stringWithFormat:@"_showButtonPressed%u:", index]);
        if ([self respondsToSelector:action])
            [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
        [button setTitle:title forState:UIControlStateNormal];
        [button sizeToFit];
        button.center = CGPointMake(CGRectGetMidX(self.view.bounds), index * 50.0f);
        button.frame = CGRectIntegral(button.frame);
        [self.view addSubview:button];
        
        ++index;
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark - Button event handling

- (void)_showButtonPressed1:(id)sender;
{
    _alertView = [[MOOMessageAlertView alloc] initWithTitle:@"A test of alert" message:@"This is a test of the alert system. There is no cause for alarm." delegate:self];
    [_alertView show];
}

- (void)_showButtonPressed2:(id)sender;
{
    _alertView = [[MOOMessageAlertView alloc] initWithTitle:nil message:@"This is a test of the alert system. There is no cause for alarm." delegate:self];
    [_alertView show];
}

- (void)_showButtonPressed3:(id)sender;
{
    _alertView = [[MOOMessageAlertView alloc] initWithTitle:@"A test of alert" message:nil delegate:self];
    [_alertView show];
}

- (void)_showButtonPressed4:(id)sender;
{
    _alertView = [[MOOMessageAlertView alloc] initWithTitle:@"A test of alert" message:@"This is a test of the alert system. There is no cause for alarm." delegate:self];
    _alertView.showCloseButton = YES;
    [_alertView show];
}

- (void)_showButtonPressed5:(id)sender;
{
    _noDisappearAlertView = [[MOOMessageAlertView alloc] initWithTitle:@"A test of alert" message:@"You will never dismiss me!!!" delegate:self];
    [_noDisappearAlertView show];
}

#pragma mark - MOOAlertViewDelegate methods

- (BOOL)shouldDismissAlertView:(MOOAlertView *)alertView;
{
    return alertView != _noDisappearAlertView;
}

- (void)didDismissAlertView:(MOOAlertView *)alertView;
{
    if (alertView == _alertView)
        _alertView = nil;
    else if (alertView == _noDisappearAlertView)
        _noDisappearAlertView = nil;
}

@end
