//
//  MOOSwipeAlert.m
//  MOOSwipeAlert
//
//  Created by Peyton Randolph on 5/29/12.
//

#import "MOOSwipeAlert.h"

#if defined(ENABLE_VIBRATION)
    #import <AudioToolbox/AudioServices.h>
#endif
#import <objc/runtime.h>

#import "CAAnimation+MOOSwipeAlert.h"
#import "MOOAlertBox.h"

#define kMOOSwipeAlertiPadWidth 320.f

// Animation keys
static NSString * const kMOORubberBandAnimationKey = @"kMOORubberBandAnimationKey";
static NSString * const kMOOWobbleAnimationKey = @"kMOOWobbleAnimationKey";

// Helper functions
static CGFloat UIInterfaceOrientationAngle(UIInterfaceOrientation orientation);
static UIInterfaceOrientationMask UIInterfaceOrientationMaskFromOrientation(UIInterfaceOrientation orientation);


@implementation MOOSwipeAlertOptions
@synthesize swipeable, backgroundViewAlpha, fadeBackgroundOnDragCoefficient, showDuration, dismissDuration, accessoryViewFadeDuration, dismissDistanceThreshold, dismissVelocityThreshold, wobbleDistance, dismissOnAlertBoxTouch, dismissOnBackgroundTouch, vibrateOnFailedDismiss, showCloseButton;
@end

@interface MOOSwipeAlert ()

@property (nonatomic, assign) MOOSwipeAlertState state;

@property (nonatomic, strong) MOOAlertBox *alertBox;
@property (nonatomic, strong) UIView *backgroundView;

@end

@interface MOOSwipeAlert (UIGestureRecognizerDelegate) <UIGestureRecognizerDelegate>
@end

@implementation MOOSwipeAlert
@synthesize delegate = _delegate;

@synthesize state = _state;
@dynamic visible;

@synthesize backgroundView = _backgroundView;
@synthesize alertBox = _alertBox;

@synthesize swipeable = _swipeable;
@synthesize backgroundViewAlpha = _backgroundViewAlpha;
@synthesize fadeBackgroundOnDragCoefficient = _fadeBackgroundOnDragCoefficient;
@synthesize showDuration = _showDuration;
@synthesize dismissDuration = _dismissalDuration;
@synthesize accessoryViewFadeDuration = _accessoryViewFadeDuration;
@synthesize dismissDistanceThreshold = _dismissalDistanceThreshold;
@synthesize dismissVelocityThreshold = _dismissalVelocityThreshold;
@synthesize wobbleDistance = _wobbleDistance;
@synthesize dismissOnAlertBoxTouch = _dismissOnAlertBoxTouch;
@synthesize dismissOnBackgroundTouch = _dismissOnBackgroundTouch;
@synthesize vibrateOnFailedDismiss = _vibrateOnFailedDismiss;
@dynamic showCloseButton;

+ (void)initialize;
{
    if (self != [MOOSwipeAlert class])
        return;
    
    // Initialize shared defaults
    MOOSwipeAlertOptions *defaults = [self sharedDefaults];
    defaults.swipeable = YES;
    defaults.backgroundViewAlpha = 0.7f;
    defaults.fadeBackgroundOnDragCoefficient = 0.5f;
    defaults.showDuration = defaults.dismissDuration = defaults.accessoryViewFadeDuration = 0.3;
    defaults.dismissDistanceThreshold = 75.0f;
    defaults.dismissVelocityThreshold = 350.0f;
    defaults.wobbleDistance = 20.0f;
    defaults.dismissOnAlertBoxTouch = YES;
    defaults.dismissOnBackgroundTouch = YES;
    defaults.showCloseButton = NO;
    defaults.vibrateOnFailedDismiss = YES;
    
    // Load themes bundle
    [[NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"Default" ofType:@"MOOSwipeAlertTheme.bundle"]] load];
}

- (id)initWithFrame:(CGRect)frame
{
    if (!(self = [super initWithFrame:frame]))
        return nil;
    
    // Initialize options
    [self configureWithOptions:[[self class] sharedDefaults]];
    
    // Configure view
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.exclusiveTouch = YES;
    
    // Create background view
    self.backgroundView = [[UIView alloc] initWithFrame:frame];
    self.backgroundView.alpha = 0.0f;
    self.backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.backgroundView.backgroundColor = [UIColor blackColor];
    self.backgroundView.exclusiveTouch = YES;
    [self addSubview:self.backgroundView];
    
    // Create alert box
    self.alertBox = [[MOOAlertBox alloc] initWithFrame:CGRectZero];
    [self addSubview:self.alertBox];
    
    // Wire up alert box close button
    self.alertBox.closeButton.hidden = self.showCloseButton;
    [self.alertBox.closeButton addTarget:self action:@selector(_closeButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    // Create alert box drag gesture recognizer
    UIGestureRecognizer *gesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
    gesture.delegate = self;
    [self.alertBox addGestureRecognizer:gesture];
    
    // Create alert box tap gesture recognizer
    gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
    gesture.delegate = self;
    [self.alertBox addGestureRecognizer:gesture];
    
    // Create background tap gesture recognizer
    gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
    gesture.delegate = self;
    [self.backgroundView addGestureRecognizer:gesture];
    
    // Create swipe up and swipe down gesture recognizer
    UISwipeGestureRecognizerDirection directions[2] = {UISwipeGestureRecognizerDirectionUp, UISwipeGestureRecognizerDirectionDown};
    
    for (NSUInteger i = 0; i < 2; ++i)
    {
        gesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
        gesture.delegate = self;
        [(UISwipeGestureRecognizer *)gesture setDirection:directions[i]];
        [self addGestureRecognizer:gesture];
    }
    
    return self;
}

- (void)dealloc;
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Layout methods

- (void)layoutSubviews;
{
    [super layoutSubviews];
    
    // Size and position background view
    self.backgroundView.frame = self.bounds;
    
    // Size alert box
    [self.alertBox sizeToFit];
    CGSize alertBoxSizeConstraint = CGSizeZero;
    alertBoxSizeConstraint.height = CGRectGetHeight(self.bounds);
    alertBoxSizeConstraint.width = [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad ? kMOOSwipeAlertiPadWidth : CGRectGetWidth(self.window.bounds);
    CGSize alertBoxSize = [self.alertBox sizeThatFits:alertBoxSizeConstraint];
    CGRect alertBoxBounds = CGRectZero;
    alertBoxBounds.size = alertBoxSize;
    self.alertBox.bounds = alertBoxBounds;
    
    // Position alert box
    switch (self.state) {
        case kMOOSwipeAlertStateHiddenAbove:
            // Move alert box off the top of the screen
            self.alertBox.center = [self _aboveCenterForAlertBox:self.alertBox];
            break;
        case kMOOSwipeAlertStateHiddenBelow:
        {
            // Move alert box off the bottom of the screen
            self.alertBox.center = [self _belowCenterForAlertBox:self.alertBox];
            break;
        }
        case kMOOSwipeAlertStateShowing:
        {
            // Move alert box to the center of the screen
            self.alertBox.center = [self _centerForAlertBox:self.alertBox];
            self.alertBox.frame = CGRectIntegral(self.alertBox.frame);
            break;
        }
        case kMOOSwipeAlertStateDragging:
            break;
    }
}

- (CGPoint)_aboveCenterForAlertBox:(MOOAlertBox *)alertBox;
{
    return CGPointMake(CGRectGetMidX(alertBox.superview.bounds), -CGRectGetMidY(alertBox.bounds) - [alertBox bottomOverflowY]);
}

- (CGPoint)_belowCenterForAlertBox:(MOOAlertBox *)alertBox;
{
    return CGPointMake(CGRectGetMidX(alertBox.superview.bounds), CGRectGetHeight(alertBox.superview.bounds) + CGRectGetMidY(alertBox.bounds) + [alertBox topOverflowY]);
}

- (CGPoint)_centerForAlertBox:(MOOAlertBox *)alertBox;
{
    CGRect slice;
    CGRect remainder;
    CGRectDivide(self.bounds, &slice, &remainder, CGRectGetHeight(_keyboardFrame), CGRectMaxYEdge);
    return CGPointMake(CGRectGetMidX(remainder), CGRectGetMidY(remainder));
}

#pragma mark - Orientation handling

- (void)_handleWillChangeStatusBarOrientationNotification:(NSNotification *)notification;
{
    // Note: this notification should be sent in an animation block, so no need to explicitly animate.
    
    // Grab the new rotation transformation
    UIInterfaceOrientation newOrientation = [[notification.userInfo objectForKey:UIApplicationStatusBarOrientationUserInfoKey] unsignedIntegerValue];
    
    [self _configureWithOrientation:newOrientation];
}

- (void)_configureWithOrientation:(UIInterfaceOrientation)orientation;
{
    CGFloat angle = UIInterfaceOrientationAngle(orientation);
    CGAffineTransform rotation = CGAffineTransformMakeRotation(angle);
    
    // Do nothing if this new rotation is no different from the current rotation.
    if (CGAffineTransformEqualToTransform(rotation, self.transform))
        return;
    
    self.transform = rotation;
    self.frame = self.window.bounds; // set the frame to trigger transformation
    
    // Perform layout
    [self setNeedsLayout];
    [self layoutIfNeeded];
}


#pragma mark - Display methods

- (void)show;
{
    if (self.isVisible)
        return;
        
    // Add the alert view to the application's window
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    self.frame = keyWindow.bounds;
    [keyWindow addSubview:self];

    [self _showFromDirection:kMOOSwipeAlertDirectionDown animated:YES];
    
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    // Do show animation
    [UIView animateWithDuration:self.showDuration delay:0.0 options:0 animations:^{
        self.backgroundView.alpha = self.backgroundViewAlpha;
    } completion:^(BOOL finished) {
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    }];
}

- (void)dismissAnimated:(BOOL)animated;
{
    if (!self.isVisible)
        return;
    
    [self _dismissInDirection:kMOOSwipeAlertDirectionUp animated:YES];
}

- (BOOL)_shouldDismiss;
{
    // Use should dismiss block if available
    if (self.shouldDismissBlock)
        return self.shouldDismissBlock(self);
    
    // Else, use delegate if available
    if ([self.delegate respondsToSelector:@selector(alertViewShouldDismiss:)])
        return [self.delegate alertViewShouldDismiss:self];
    
    // Default to YES
    return YES;
}

- (void)_performDismissAnimated:(BOOL)animated;
{
    _alertViewFlags.dismissing = YES;

    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    
    void (^animations)(void) = ^{
        self.backgroundView.alpha = 0.0f;
    };
    void (^completion)(BOOL finished) = ^(BOOL finished){
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        [self removeFromSuperview];
        _alertViewFlags.dismissing = NO;
    };
    
    if (animated)
        [UIView animateWithDuration:self.dismissDuration delay:0.0 options:0 animations:animations completion:completion];
    else
    {
        animations();
        completion(YES);
    }
}

- (void)_dismissIfAbleAnimated:(BOOL)animated;
{
    if ([self _shouldDismiss])
        [self dismissAnimated:animated];
    else
    {
        if (self.vibrateOnFailedDismiss) [self _vibrate];
        [self _wobbleAlertBox:self.alertBox];
    }
}

- (void)_prepareToShowFromDirection:(MOOSwipeAlertDirection)direction;
{
    switch (direction)
    {
        case kMOOSwipeAlertDirectionDown:
            self.state = kMOOSwipeAlertStateHiddenBelow;
            break;
        case kMOOSwipeAlertDirectionUp:
            self.state = kMOOSwipeAlertStateHiddenAbove;
            break;
    }
    
    // Prevent alert box from accepting touches while animating
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    
    // Perform layout
    [self setNeedsLayout];
    [self layoutIfNeeded];
    
    _alertViewFlags.preparedToShow = YES;
}

- (void)_performShow;
{
    if (!_alertViewFlags.preparedToShow)
    {
        NSLog(@"Alert view %@ not prepared to show.", self);
        return;
    }
    _alertViewFlags.preparedToShow = NO;
    self.state = kMOOSwipeAlertStateShowing;
    
    // Perform layout
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (void)_showFromDirection:(MOOSwipeAlertDirection)direction animated:(BOOL)animated;
{
    if (self.isVisible)
        return;
    
    [self _willPresentAnimated:animated direction:direction];
    // Do show animation
    [self _prepareToShowFromDirection:direction];
    
    void (^completion)(BOOL finished) = ^(BOOL finished){
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        [self _didPresentAnimated:animated direction:direction];
    };
    
    if (animated)
        [UIView animateWithDuration:self.showDuration delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            [self _performShow];
        } completion:completion];
    else {
        [self _performShow];
        completion(YES);
    }
}

- (void)_prepareToDismiss;
{
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    
    _alertViewFlags.preparedToDismiss = YES;
}

- (void)_performDismissInDirection:(MOOSwipeAlertDirection)direction;
{
    switch (direction)
    {
        case kMOOSwipeAlertDirectionDown:
            self.state = kMOOSwipeAlertStateHiddenBelow;
            break;
        case kMOOSwipeAlertDirectionUp:
            self.state = kMOOSwipeAlertStateHiddenAbove;
            break;
    }
    
    [self setNeedsLayout];
    [self layoutIfNeeded];
    
    _alertViewFlags.preparedToDismiss = NO;
}

- (void)_dismissInDirection:(MOOSwipeAlertDirection)direction animated:(BOOL)animated;
{
    if (!self.isVisible)
        return;
    
    [self _willDismissAnimated:animated direction:direction];
    
    [self _performDismissAnimated:animated];
    
    if (animated)
    {
        CGPoint targetPoint;
        
        switch (direction)
        {
            case kMOOSwipeAlertDirectionDown:
                targetPoint = [self _belowCenterForAlertBox:self.alertBox];
                break;
            case kMOOSwipeAlertDirectionUp:
                targetPoint = [self _aboveCenterForAlertBox:self.alertBox];
                break;
        }
        
        [self _dismissWithVelocity:(targetPoint.y - self.alertBox.center.y) / self.dismissDuration];
    }
    else
    {
        [self _prepareToDismiss];
        [self _performDismissInDirection:direction];
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
        [self _didDismissAnimated:NO direction:direction];
    }
}

// Pass 0.0f velocity to dismiss with default duration
- (void)_dismissWithVelocity:(CGFloat)velocity;
{
    if (!self.isVisible)
        return;
    
    CGPoint targetPoint = [self _alertBox:self.alertBox targetPointForVelocity:velocity];
    MOOSwipeAlertDirection direction = (velocity < 0.0f) ? kMOOSwipeAlertDirectionUp : kMOOSwipeAlertDirectionDown;
    
    NSTimeInterval dismissalDuration = (fabsf(velocity) > FLT_EPSILON) ? fabs((self.alertBox.center.y - targetPoint.y) / velocity) : self.dismissDuration;
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    [UIView animateWithDuration:fmin(dismissalDuration, self.dismissDuration) delay:0.0 options:(velocity == 0.0f) ? UIViewAnimationOptionCurveEaseIn : 0 animations:^{
        [self _performDismissInDirection:direction];
    } completion:^(BOOL finished) {
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        
        [self _didDismissAnimated:YES direction:direction];
    }];
}

- (void)_dismissIfAbleInDirection:(MOOSwipeAlertDirection)direction animated:(BOOL)animated;
{
    if ([self _shouldDismiss])
        [self _dismissInDirection:direction animated:YES];
    else
    {
        if (self.vibrateOnFailedDismiss) [self _vibrate];
        [self _wobbleAlertBox:self.alertBox];
    }
}

- (CGPoint)_alertBox:(MOOAlertBox *)alertBox targetPointForVelocity:(CGFloat)velocity;
{
    if (velocity < 0.0f)
        return [self _aboveCenterForAlertBox:alertBox];
    else
        return [self _belowCenterForAlertBox:alertBox];
}

#pragma mark - Button handling

- (void)_closeButtonPressed:(id)sender;
{
    [self _dismissIfAbleAnimated:YES];
}

#pragma mark - Gesture handling

- (void)handleGesture:(UIGestureRecognizer *)gesture;
{
    if (gesture.view == self)
    {
        if ([gesture isKindOfClass:[UISwipeGestureRecognizer class]])
            [self _handleSwipe:(UISwipeGestureRecognizer *)gesture];
        else if ([gesture isKindOfClass:[UITapGestureRecognizer class]])
            [self _handleTap:(UITapGestureRecognizer *)gesture];
    }
    else if (gesture.view == self.alertBox)
    {
        if ([gesture isKindOfClass:[UIPanGestureRecognizer class]])
            [self _handleDrag:(UIPanGestureRecognizer *)gesture];
        else if ([gesture isKindOfClass:[UITapGestureRecognizer class]])
            [self _handleTap:(UITapGestureRecognizer *)gesture];
    }
    else if (gesture.view == self.backgroundView)
    {
        if ([gesture isKindOfClass:[UITapGestureRecognizer class]])
            [self _handleTap:(UITapGestureRecognizer *)gesture];
    }
}

- (void)_handleDrag:(UIPanGestureRecognizer *)gesture;
{
    // If swipeability is disabled, do nothing
    if (!self.swipeable)
        return;
    
    if (gesture.state == UIGestureRecognizerStateBegan)
    {
        self.state = kMOOSwipeAlertStateDragging;
        
        // Store layer position before adjusting anchor point
        gesture.view.layer.anchorPoint = CGPointMake(0.5f, 0.5f);
        _dragStartPosition = gesture.view.layer.position;
        [self _adjustAnchorPointForGestureRecognizer:gesture];
    }
    
    else if (gesture.state == UIGestureRecognizerStateChanged)
    {
        // Translate view by panned amount
        CGPoint translationPoint = [gesture translationInView:gesture.view];
        CGAffineTransform translationTransform = CGAffineTransformMakeTranslation(0.0f, translationPoint.y);
        gesture.view.center = CGPointApplyAffineTransform(gesture.view.center, translationTransform);
        
        // Set background alpha relative to the distance traveled from zero
        CGPoint naturalCenter = [self _centerForAlertBox:self.alertBox];
        CGPoint targetPoint = naturalCenter.y > gesture.view.center.y ? [self _aboveCenterForAlertBox:self.alertBox] : [self _belowCenterForAlertBox:self.alertBox];
        CGFloat curDistanceFromCenter = fabsf(naturalCenter.y - gesture.view.center.y);
        CGFloat totalDistanceFromCenter = fabsf(naturalCenter.y - targetPoint.y);
        CGFloat percentDragged = curDistanceFromCenter / totalDistanceFromCenter;
        
        self.backgroundView.alpha = self.backgroundViewAlpha * (1.0f - powf(percentDragged, 3.0f) * self.fadeBackgroundOnDragCoefficient);
        
        // Reset translation
        [gesture setTranslation:CGPointZero inView:gesture.view];
    }
    
    else if (gesture.state == UIGestureRecognizerStateEnded || gesture.state == UIGestureRecognizerStateCancelled)
    {
        self.state = kMOOSwipeAlertStateShowing;
        
        // Grab the y velocity
        CGFloat yVelocity = [gesture velocityInView:gesture.view].y;
        
        // Store the current position
        CGPoint midPoint = CGPointMake(CGRectGetMidX(gesture.view.bounds), CGRectGetMidY(gesture.view.bounds));
        CGPoint currentPosition = [gesture.view convertPoint:midPoint toView:gesture.view.superview];
        
        // Reset anchor point to default (since we'll be setting the position)
        gesture.view.layer.anchorPoint = CGPointMake(0.5f, 0.5f);
        gesture.view.layer.position = currentPosition;
        
        // Check whether thresholds reached
        BOOL velocityThresholdReached = fabsf(yVelocity) > self.dismissVelocityThreshold;
        CGFloat distanceFromStart = currentPosition.y - _dragStartPosition.y;
        BOOL distanceThresholdReached = fabsf(distanceFromStart) > self.dismissDistanceThreshold;
        if (!velocityThresholdReached)
            yVelocity = distanceFromStart / self.dismissDuration;
        
        MOOSwipeAlertDirection direction = (yVelocity < 0.0f) ? kMOOSwipeAlertDirectionUp : kMOOSwipeAlertDirectionDown;
        
        BOOL shouldDismiss = YES;
        if ((velocityThresholdReached || distanceThresholdReached) && (shouldDismiss = [self _shouldDismiss]))
        {
            // Dismiss alert view
            [self _willDismissAnimated:YES direction:direction];
            [self _performDismissAnimated:YES];
            [self _dismissWithVelocity:yVelocity];
        } else {
            // Snap back to beginning
            
            // First, vibrate if velocity or distance threshold reached, but delegate
            // prevented dismissal
            if (!shouldDismiss && self.vibrateOnFailedDismiss) [self _vibrate];
            
            // Set position to the start (otherwise the animation "pops back" to the current position)
            gesture.view.layer.position = _dragStartPosition;
            
            // Return-to-center animations

            // Rubber band animation
            CAAnimation *rubberBandAnimation = [CAAnimation rubberBandAnimationFromPosition:currentPosition toPosition:_dragStartPosition duration:self.dismissDuration * 2.0];
            rubberBandAnimation.delegate = self;
            rubberBandAnimation.removedOnCompletion = NO;
            [gesture.view.layer addAnimation:rubberBandAnimation forKey:kMOORubberBandAnimationKey];
            
            // Fade background back to original alpha
            [UIView animateWithDuration:self.dismissDuration delay:0.0 options:UIViewAnimationCurveEaseIn animations:^{
                self.backgroundView.alpha = self.backgroundViewAlpha;
            } completion:NULL];
            
            // Prevent user interaction while animation in progress
            [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
        }
    }
}

- (void)_handleTap:(UITapGestureRecognizer *)gesture;
{
    if (gesture.state != UIGestureRecognizerStateRecognized)
        return;
    
    if ((gesture.view == self.alertBox && !self.dismissOnAlertBoxTouch) || (gesture.view == self.backgroundView && !self.dismissOnBackgroundTouch))
        return;
    
    [self _dismissIfAbleInDirection:kMOOSwipeAlertDirectionUp animated:YES];
}

- (void)_handleSwipe:(UISwipeGestureRecognizer *)gesture;
{
    if (gesture.state != UIGestureRecognizerStateRecognized)
        return;
    
    switch (gesture.direction)
    {
        case UISwipeGestureRecognizerDirectionUp:
            [self _dismissIfAbleInDirection:kMOOSwipeAlertDirectionUp animated:YES];
            break;
        case UISwipeGestureRecognizerDirectionDown:
            [self _dismissIfAbleInDirection:kMOOSwipeAlertDirectionDown animated:YES];
            break;
        default:
            break;
    }
}

- (void)_adjustAnchorPointForGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer;
{
    // Adjust anchor point to fall under touch location
    UIView *view = gestureRecognizer.view;
    CGPoint locationInView = [gestureRecognizer locationInView:view];
    CGPoint locationInSuperview = [gestureRecognizer locationInView:view.superview];
    
    view.layer.anchorPoint = CGPointMake(locationInView.x / view.bounds.size.width, locationInView.y / view.bounds.size.height);
    view.center = locationInSuperview;
}

#pragma mark - Notification handling

- (void)_handleKeyboardWillShowNotification:(NSNotification *)notification;
{
    _keyboardFrame = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    UIViewAnimationCurve animationCurve = [[notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] unsignedIntegerValue];
    NSTimeInterval animationDuration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    [UIView animateWithDuration:animationDuration delay:0.0 options:animationCurve << 16 animations:^{
        self.alertBox.center = [self _centerForAlertBox:self.alertBox];
        self.alertBox.frame = CGRectIntegral(self.alertBox.frame);
    } completion:NULL];
}

- (void)_handleKeyboardWillHideNotification:(NSNotification *)notification;
{
    _keyboardFrame = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    UIViewAnimationCurve animationCurve = [[notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] unsignedIntegerValue];
    NSTimeInterval animationDuration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    [UIView animateWithDuration:animationDuration delay:0.0 options:animationCurve << 16 animations:^{
        self.alertBox.center = [self _centerForAlertBox:self.alertBox];
        self.alertBox.frame = CGRectIntegral(self.alertBox.frame);
    } completion:NULL];
}

#pragma mark - Delegate passing

- (void)_willPresentAnimated:(BOOL)animated direction:(MOOSwipeAlertDirection)direction;
{
    if ([self.delegate respondsToSelector:@selector(alertViewWillPresent:animated:)])
        [self.delegate alertViewWillPresent:self animated:animated];
    
    for (UIView *accessoryView in self.alertBox.accessoryViews)
    {
        accessoryView.alpha = 0.0f;
    }
    
    // Prepare rotation
    [self _configureWithOrientation:[UIApplication sharedApplication].statusBarOrientation];
    
    // Configure notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_handleWillChangeStatusBarOrientationNotification:) name:UIApplicationWillChangeStatusBarOrientationNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_handleKeyboardWillShowNotification:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_handleKeyboardWillHideNotification:) name:UIKeyboardWillShowNotification object:nil];
}

- (void)_didPresentAnimated:(BOOL)animated direction:(MOOSwipeAlertDirection)direction;
{
    if ([self.delegate respondsToSelector:@selector(alertViewDidPresent:animated:)])
        [self.delegate alertViewDidPresent:self animated:animated];
    
    [UIView animateWithDuration:self.accessoryViewFadeDuration delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        for (UIView *accessoryView in self.alertBox.accessoryViews)
        {
            accessoryView.alpha = 1.0f;
        }
    } completion:NULL];
}

- (void)_willDismissAnimated:(BOOL)animated direction:(MOOSwipeAlertDirection)direction;
{
    if ([self.delegate respondsToSelector:@selector(alertViewWillDismiss:animated:)])
        [self.delegate alertViewWillDismiss:self animated:animated];
    
    [UIView animateWithDuration:self.accessoryViewFadeDuration delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        for (UIView *accessoryView in self.alertBox.accessoryViews)
        {
            accessoryView.alpha = 0.0f;
        }
    } completion:NULL];
}

- (void)_didDismissAnimated:(BOOL)animated direction:(MOOSwipeAlertDirection)direction;
{
    if (self.dismissBlock)
        self.dismissBlock(self, animated);
    
    if ([self.delegate respondsToSelector:@selector(alertViewDidDismiss:animated:)])
        [self.delegate alertViewDidDismiss:self animated:animated];
    
    for (UIView *accessoryView in self.alertBox.accessoryViews)
    {
        accessoryView.alpha = 0.0f;
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    _keyboardFrame = CGRectZero;
}

#pragma mark - Failed dismiss methods

- (void)_wobbleAlertBox:(UIView *)alertBox;
{
    // Calculate wobble distance
    CGPoint fromPosition = alertBox.center;
    CGPoint toPosition = fromPosition;
    toPosition.y += self.wobbleDistance;
    
    // Disable user interaction during animation
    // If we were just to do self.userInteractionEnabled = NO, touch events would
    // fall through to views below. But disabling interaction on the entire window
    // *might* be a bit heavy-handed
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    
    CAAnimation *wobble = [CAAnimation wobbleAnimationFromPosition:fromPosition toPosition:toPosition duration:1.0f];
    wobble.delegate = self;
    wobble.removedOnCompletion = NO;
    [alertBox.layer addAnimation:wobble forKey:kMOOWobbleAnimationKey];
}

- (void)_vibrate;
{
#if defined(ENABLE_VIBRATION)
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
#endif
}

#pragma mark - CAAnimationDelegate methods

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag;
{
    NSString *animKey;
    if (anim == [self.alertBox.layer animationForKey:(animKey = kMOORubberBandAnimationKey)] || anim == [self.alertBox.layer animationForKey:(animKey = kMOOWobbleAnimationKey)])
    {
        [self.alertBox.layer removeAnimationForKey:animKey];
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    }
}

#pragma mark - UIGestureRecognizerDelegate methods

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch;
{
    UIView *target = [gestureRecognizer.view hitTest:[touch locationInView:gestureRecognizer.view] withEvent:nil];
    if ([target isKindOfClass:[UIControl class]] || [target isKindOfClass:[UITextField class]] || [target isKindOfClass:[UITextView class]])
        return NO;
    
    return YES;
}

#pragma mark - Configuration methods

- (void)configureWithOptions:(id<MOOSwipeAlertOptions>)options;
{
    // Grab the set of property names from the MOOSwipeAlertOptions protocol
    unsigned int outCount;
    objc_property_t *properties = protocol_copyPropertyList(@protocol(MOOSwipeAlertOptions), &outCount);
    NSMutableSet *propertyNames = [NSMutableSet setWithCapacity:outCount];
    for (unsigned int i = 0; i < outCount; i++)
    {
        objc_property_t property = properties[i];
        NSString *propertyName = [NSString stringWithCString:property_getName(property) encoding:NSASCIIStringEncoding];
        [propertyNames addObject:propertyName];
    }
    
    // Copy each property from the options object
    for (NSString *propertyName in propertyNames)
        [self setValue:[(NSObject *)options valueForKey:propertyName] forKey:propertyName];
}

#pragma mark - Getters and setters

- (BOOL)showCloseButton;
{
    return !self.alertBox.closeButton.hidden;
}

- (void)setShowCloseButton:(BOOL)showCloseButton;
{
    self.alertBox.closeButton.hidden = !showCloseButton;
}

+ (id<MOOSwipeAlertOptions>)sharedDefaults;
{
    static MOOSwipeAlertOptions *sharedDefaults = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedDefaults = [[MOOSwipeAlertOptions alloc] init];
    });
    return sharedDefaults;
}

- (BOOL)isVisible;
{
    return self.superview != nil && (self.state == kMOOSwipeAlertStateDragging || self.state == kMOOSwipeAlertStateShowing);
}

@end

// Orientation support
CGFloat UIInterfaceOrientationAngle(UIInterfaceOrientation orientation)
{
    CGFloat angle;
    
    switch (orientation)
    {
        case UIInterfaceOrientationPortraitUpsideDown:
            angle = M_PI;
            break;
        case UIInterfaceOrientationLandscapeLeft:
            angle = -M_PI_2;
            break;
        case UIInterfaceOrientationLandscapeRight:
            angle = M_PI_2;
            break;
        default:
            angle = 0.0f;
            break;
    }
    
    return angle;
}

UIInterfaceOrientationMask UIInterfaceOrientationMaskFromOrientation(UIInterfaceOrientation orientation)
{
    return 1 << orientation;
}
