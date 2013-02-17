//
//  ViewController.m
//  Demo Project
//
//  Created by Peyton Randolph on 7/10/12.
//

#import "AlertViewController.h"

#import "MOOMessageAlertView.h"

@interface AlertViewController ()

@end

@interface AlertViewController (MOOAlertViewDelegate) <MOOAlertViewDelegate>

@end

@implementation AlertViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil;
{
    if (!(self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]))
        return nil;
    
    // Configure tab bar
    self.title = NSLocalizedString(@"Alerts", @"Alerts");
    self.tabBarItem.image = [UIImage imageNamed:@"Alert.png"];
    
    return self;
}

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
    
    
    _dismissButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [_dismissButton addTarget:self action:@selector(_dismissButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [_dismissButton setTitle:@"Dismiss" forState:UIControlStateNormal];
    [_dismissButton sizeToFit];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark - Button event handling

- (void)_showButtonPressed1:(id)sender;
{
    _alertView = [[MOOMessageAlertView alloc] initWithTitle:@"Test alert" message:@"This is a test of the alert system. There is no cause for alarm." delegate:self];
    [_alertView show];
}

- (void)_showButtonPressed2:(id)sender;
{
    _alertView = [[MOOMessageAlertView alloc] initWithTitle:nil message:@"This is a test of the alert system. There is no cause for alarm." delegate:self];
    [_alertView show];
}

- (void)_showButtonPressed3:(id)sender;
{
    _alertView = [[MOOMessageAlertView alloc] initWithTitle:@"Test alert" message:nil delegate:self];
    [_alertView show];
}

- (void)_showButtonPressed4:(id)sender;
{
    _alertView = [[MOOMessageAlertView alloc] initWithTitle:@"Test alert" message:@"This is a test of the alert system. There is no cause for alarm." delegate:self];
    _alertView.showsCloseButton = YES;
    [_alertView show];
}

- (void)_showButtonPressed5:(id)sender;
{
    _noDisappearAlertView = [[MOOMessageAlertView alloc] initWithTitle:@"Test alert" message:@"You will never dismiss me!!!" delegate:self];
    [_noDisappearAlertView show];
    [_noDisappearAlertView addSubview:_dismissButton];
}

- (void)_dismissButtonPressed:(id)sender;
{
    [_dismissButton removeFromSuperview];
    [_noDisappearAlertView dismissAnimated:YES];
}

#pragma mark - MOOAlertViewDelegate methods

- (BOOL)alertViewShouldDismiss:(MOOAlertView *)alertView;
{
    return alertView != _noDisappearAlertView;
}

- (void)alertViewDidDismiss:(MOOAlertView *)alertView animated:(BOOL)animated;
{
    if (alertView == _alertView)
        _alertView = nil;
    else if (alertView == _noDisappearAlertView)
        _noDisappearAlertView = nil;
}

@end
