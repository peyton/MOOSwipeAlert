//
//  ViewController.m
//  Demo Project
//
//  Created by Peyton Randolph on 3/2/13.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController
@synthesize scrollView = _scrollView;

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    // Set scroll view content size
    CGRect contentFrame = CGRectZero;
    CGFloat contentPadding = FLT_MAX;
    for (UIView *subview in self.scrollView.subviews)
    {
        // Only consider controls, rather than scrollview phantom subviews
        if (![subview isKindOfClass:[UIControl class]])
            continue;
        
        // Accumulate enclosing rectangle.
        if (CGRectEqualToRect(contentFrame, CGRectZero))
            contentFrame = subview.frame;
        else
            contentFrame = CGRectUnion(contentFrame, subview.frame);
        
        // Find minimum padding.
        contentPadding = fminf(CGRectGetMinY(subview.frame), contentPadding);
    }
    self.scrollView.contentSize = CGSizeMake(1.0f, CGRectGetHeight(contentFrame) + 2.0f * contentPadding);
}

- (void)viewWillAppear:(BOOL)animated;
{
    [super viewWillAppear:animated];
    
    // Fade in view
    self.view.alpha = 0.0f;
    [UIView animateWithDuration:0.3 delay:0.3 options:UIViewAnimationCurveEaseOut animations:^{
        self.view.alpha = 1.0f;
    } completion:NULL];
}

- (void)viewDidAppear:(BOOL)animated;
{
    [super viewDidAppear:animated];
    
    [self _configureScrollViewForOrientation:[UIApplication sharedApplication].statusBarOrientation];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation;
{
    [self _configureScrollViewForOrientation:fromInterfaceOrientation];
}

- (void)_configureScrollViewForOrientation:(UIInterfaceOrientation)orientation;
{
    if (CGRectGetHeight(self.scrollView.frame) < self.scrollView.contentSize.height)
    {
        self.scrollView.delaysContentTouches = YES;
        [self.scrollView flashScrollIndicators];
    } else
    {
        self.scrollView.delaysContentTouches = NO;
    }
}

@end
