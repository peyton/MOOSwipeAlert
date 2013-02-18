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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil;
{
    if (!(self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]))
        return nil;
    
    // Configure tab bar
    self.title = NSLocalizedString(@"Message", @"Message");
    self.tabBarItem.image = [UIImage imageNamed:@"Alert.png"];
    
    return self;
}

- (void)loadView;
{
    [super loadView];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    // Create buttons
    NSArray *buttonTitles = [NSArray arrayWithObjects:@"Alert", @"Alert without title", @"Alert without message", @"Alert with close button", @"Alert without dismissal", @"Alert with block callback", nil];
    
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
    _dismissButton.frame = CGRectMake(30.0f, 44.0f, CGRectGetWidth(_dismissButton.frame), CGRectGetHeight(_dismissButton.frame));
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
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
    _alertView.showsCloseButton = YES;
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
