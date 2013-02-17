//
//  MOOAlertView.m
//  MOOAlertView
//
//  Created by Peyton Randolph on 5/29/12.
//

#import "MOOAlertView.h"

#if defined(ENABLE_VIBRATION)
    #import <AudioToolbox/AudioServices.h>
#endif
#import <objc/runtime.h>

#import "CAAnimation+MOOAlertView.h"
#import "MOOAlertBox.h"

static NSString * const kMOORubberBandAnimationKey = @"kMOORubberBandAnimationKey";
static NSString * const kMOOWobbleAnimationKey = @"kMOOWobbleAnimationKey";

@implementation MOOSwipeAlertOptions
@synthesize backgroundViewAlpha, showDuration, dismissDuration, accessoryViewFadeDuration, dismissDistanceThreshold, dismissVelocityThreshold, wobbleDistance, dismissOnAlertBoxTouch, dismissOnBackgroundTouch, vibrateOnFailedDismiss, showsCloseButton;
@end

@interface MOOAlertView ()

@property (nonatomic, assign) MOOAlertViewState state;

@property (nonatomic, strong) MOOAlertBox *alertBox;
@property (nonatomic, strong) UIView *backgroundView;

@end

@interface MOOAlertView (UIGestureRecognizerDelegate) <UIGestureRecognizerDelegate>
@end

@implementation MOOAlertView
@synthesize delegate = _delegate;

@synthesize state = _state;
@dynamic visible;

@synthesize backgroundView = _backgroundView;
@synthesize alertBox = _alertBox;

@synthesize backgroundViewAlpha = _backgroundViewAlpha;
@synthesize showDuration = _showDuration;
@synthesize dismissDuration = _dismissalDuration;
@synthesize accessoryViewFadeDuration = _accessoryViewFadeDuration;
@synthesize dismissDistanceThreshold = _dismissalDistanceThreshold;
@synthesize dismissVelocityThreshold = _dismissalVelocityThreshold;
@synthesize wobbleDistance = _wobbleDistance;
@synthesize dismissOnAlertBoxTouch = _dismissOnAlertBoxTouch;
@synthesize dismissOnBackgroundTouch = _dismissOnBackgroundTouch;
@synthesize vibrateOnFailedDismiss = _vibrateOnFailedDismiss;
@dynamic showsCloseButton;

+ (void)initialize;
{
    if (self != [MOOAlertView class])
        return;
    
    // Initialize shared defaults
    MOOSwipeAlertOptions *defaults = [self sharedDefaults];
    defaults.backgroundViewAlpha = 0.7f;
    defaults.showDuration = defaults.dismissDuration = defaults.accessoryViewFadeDuration = 0.3;
    defaults.dismissDistanceThreshold = 75.0f;
    defaults.dismissVelocityThreshold = 350.0f;
    defaults.wobbleDistance = 20.0f;
    defaults.dismissOnAlertBoxTouch = YES;
    defaults.dismissOnBackgroundTouch = YES;
    defaults.showsCloseButton = NO;
    defaults.vibrateOnFailedDismiss = YES;
    
    // Load MOOAlertView bundle
    [[NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"MOOAlertView" ofType:@"bundle"]] load];
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
    self.alertBox.closeButton.hidden = self.showsCloseButton;
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
    
    // Position alert box
    [self.alertBox sizeToFit];
    switch (self.state) {
        case kMOOAlertViewStateHiddenAbove:
            // Move alert box off the top of the screen
            self.alertBox.center = [self _aboveCenterForAlertBox:self.alertBox];
            break;
        case kMOOAlertViewStateHiddenBelow:
        {
            // Move alert box off the bottom of the screen
            self.alertBox.center = [self _belowCenterForAlertBox:self.alertBox];
            break;
        }
        case kMOOAlertViewStateShowing:
        {
            // Move alert box to the center of the screen
            self.alertBox.center = [self _centerForAlertBox:self.alertBox];
            self.alertBox.frame = CGRectIntegral(self.alertBox.frame);
            break;
        }
        case kMOOAlertViewStateDragging:
            break;
    }
}

- (CGPoint)_aboveCenterForAlertBox:(MOOAlertBox *)alertBox;
{
    return CGPointMake(CGRectGetMidX(alertBox.superview.bounds), -CGRectGetMidY([alertBox apparentBounds]));
}

- (CGPoint)_belowCenterForAlertBox:(MOOAlertBox *)alertBox;
{
    return CGPointMake(CGRectGetMidX(alertBox.superview.bounds), CGRectGetHeight(alertBox.superview.bounds) + CGRectGetMidY([alertBox apparentBounds]));
}

- (CGPoint)_centerForAlertBox:(MOOAlertBox *)alertBox;
{
    CGRect slice;
    CGRect remainder;
    CGRectDivide(self.bounds, &slice, &remainder, CGRectGetHeight(_keyboardFrame), CGRectMaxYEdge);
    return CGPointMake(CGRectGetMidX(remainder), CGRectGetMidY(remainder));
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

    [self _showFromDirection:kMOOAlertViewDirectionDown animated:YES];
    
    self.userInteractionEnabled = NO;
    // Do show animation
    [UIView animateWithDuration:self.showDuration delay:0.0 options:0 animations:^{
        self.backgroundView.alpha = self.backgroundViewAlpha;
    } completion:^(BOOL finished) {
        self.userInteractionEnabled = YES;
    }];
}

- (void)dismissAnimated:(BOOL)animated;
{
    if (!self.isVisible)
        return;
    
    [self _dismissInDirection:kMOOAlertViewDirectionUp animated:YES];
}

- (BOOL)_shouldDismiss;
{
    if ([self.delegate respondsToSelector:@selector(alertViewShouldDismiss:)])
        return [self.delegate alertViewShouldDismiss:self];
    
    return YES;
}

- (void)_performDismissAnimated:(BOOL)animated;
{
    _alertViewFlags.dismissing = YES;

    self.userInteractionEnabled = NO;    
    
    void (^animations)(void) = ^{
        self.backgroundView.alpha = 0.0f;
    };
    void (^completion)(BOOL finished) = ^(BOOL finished){
        self.userInteractionEnabled = YES;
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

- (void)_prepareToShowFromDirection:(MOOAlertViewDirection)direction;
{
    switch (direction)
    {
        case kMOOAlertViewDirectionDown:
            self.state = kMOOAlertViewStateHiddenBelow;
            break;
        case kMOOAlertViewDirectionUp:
            self.state = kMOOAlertViewStateHiddenAbove;
            break;
    }
    
    // Prevent alert box from accepting touches while animating
    self.userInteractionEnabled = NO;
    
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
    self.state = kMOOAlertViewStateShowing;
    
    // Perform layout
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (void)_showFromDirection:(MOOAlertViewDirection)direction animated:(BOOL)animated;
{
    if (self.isVisible)
        return;
    
    [self _willPresentAnimated:animated direction:direction];
    // Do show animation
    [self _prepareToShowFromDirection:direction];
    
    void (^completion)(BOOL finished) = ^(BOOL finished){
        self.userInteractionEnabled = YES;
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
    self.userInteractionEnabled = NO;
    
    _alertViewFlags.preparedToDismiss = YES;
}

- (void)_performDismissInDirection:(MOOAlertViewDirection)direction;
{
    switch (direction)
    {
        case kMOOAlertViewDirectionDown:
            self.state = kMOOAlertViewStateHiddenBelow;
            break;
        case kMOOAlertViewDirectionUp:
            self.state = kMOOAlertViewStateHiddenAbove;
            break;
    }
    
    [self setNeedsLayout];
    [self layoutIfNeeded];
    
    _alertViewFlags.preparedToDismiss = NO;
}

- (void)_dismissInDirection:(MOOAlertViewDirection)direction animated:(BOOL)animated;
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
            case kMOOAlertViewDirectionDown:
                targetPoint = [self _belowCenterForAlertBox:self.alertBox];
                break;
            case kMOOAlertViewDirectionUp:
                targetPoint = [self _aboveCenterForAlertBox:self.alertBox];
                break;
        }
        
        [self _dismissWithVelocity:(targetPoint.y - self.alertBox.center.y) / self.dismissDuration];
    }
    else
    {
        [self _prepareToDismiss];
        [self _performDismissInDirection:direction];
        self.userInteractionEnabled = YES;
        [self _didDismissAnimated:NO direction:direction];
    }
}

// Pass 0.0f velocity to dismiss with default duration
- (void)_dismissWithVelocity:(CGFloat)velocity;
{
    if (!self.isVisible)
        return;
    
    CGPoint targetPoint = [self _alertBox:self.alertBox targetPointForVelocity:velocity];
    MOOAlertViewDirection direction = (velocity < 0.0f) ? kMOOAlertViewDirectionUp : kMOOAlertViewDirectionDown;
    
    NSTimeInterval dismissalDuration = (fabsf(velocity) > FLT_EPSILON) ? fabs((self.alertBox.center.y - targetPoint.y) / velocity) : self.dismissDuration;
    [UIView animateWithDuration:fmin(dismissalDuration, self.dismissDuration) delay:0.0 options:(velocity == 0.0f) ? UIViewAnimationOptionCurveEaseIn : 0 animations:^{
        [self _performDismissInDirection:direction];
    } completion:^(BOOL finished) {
        self.userInteractionEnabled = YES;
        
        [self _didDismissAnimated:YES direction:direction];
    }];
}

- (void)_dismissIfAbleInDirection:(MOOAlertViewDirection)direction animated:(BOOL)animated;
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
    if (gesture.state == UIGestureRecognizerStateBegan)
    {
        self.state = kMOOAlertViewStateDragging;
        
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
        [gesture setTranslation:CGPointZero inView:gesture.view];
    }
    
    else if (gesture.state == UIGestureRecognizerStateEnded || gesture.state == UIGestureRecognizerStateCancelled)
    {
        self.state = kMOOAlertViewStateShowing;
        
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
        
        MOOAlertViewDirection direction = (yVelocity < 0.0f) ? kMOOAlertViewDirectionUp : kMOOAlertViewDirectionDown;
        
        BOOL shouldDismiss = NO;
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
            
            // Rubber band animation
            CAAnimation *rubberBandAnimation = [CAAnimation rubberBandAnimationFromPosition:currentPosition toPosition:_dragStartPosition duration:self.dismissDuration * 2.0];
            rubberBandAnimation.delegate = self;
            rubberBandAnimation.removedOnCompletion = NO;
            [gesture.view.layer addAnimation:rubberBandAnimation forKey:kMOORubberBandAnimationKey];
            
            // Prevent user interaction while animation in progress
            self.userInteractionEnabled = NO;
        }
    }
}

- (void)_handleTap:(UITapGestureRecognizer *)gesture;
{
    if (gesture.state != UIGestureRecognizerStateRecognized)
        return;
    
    if ((gesture.view == self.alertBox && !self.dismissOnAlertBoxTouch) || (gesture.view == self.backgroundView && !self.dismissOnBackgroundTouch))
        return;
    
    [self _dismissIfAbleInDirection:kMOOAlertViewDirectionUp animated:YES];
}

- (void)_handleSwipe:(UISwipeGestureRecognizer *)gesture;
{
    if (gesture.state != UIGestureRecognizerStateRecognized)
        return;
    
    switch (gesture.direction)
    {
        case UISwipeGestureRecognizerDirectionUp:
            [self _dismissIfAbleInDirection:kMOOAlertViewDirectionUp animated:YES];
            break;
        case UISwipeGestureRecognizerDirectionDown:
            [self _dismissIfAbleInDirection:kMOOAlertViewDirectionDown animated:YES];
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

- (void)_willPresentAnimated:(BOOL)animated direction:(MOOAlertViewDirection)direction;
{
    if ([self.delegate respondsToSelector:@selector(alertViewWillPresent:animated:)])
        [self.delegate alertViewWillPresent:self animated:animated];
    
    for (UIView *accessoryView in self.alertBox.accessoryViews)
    {
        accessoryView.alpha = 0.0f;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_handleKeyboardWillShowNotification:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_handleKeyboardWillHideNotification:) name:UIKeyboardWillShowNotification object:nil];
}

- (void)_didPresentAnimated:(BOOL)animated direction:(MOOAlertViewDirection)direction;
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

- (void)_willDismissAnimated:(BOOL)animated direction:(MOOAlertViewDirection)direction;
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

- (void)_didDismissAnimated:(BOOL)animated direction:(MOOAlertViewDirection)direction;
{
    if ([self.delegate respondsToSelector:@selector(alertViewDidDismiss:animated:)])
        [self.delegate alertViewDidDismiss:self animated:animated];
    
    for (UIView *accessoryView in self.alertBox.accessoryViews)
    {
        accessoryView.alpha = 0.0f;
    }
    
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
    self.window.userInteractionEnabled = NO;
    
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
        self.window.userInteractionEnabled = YES;
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

- (BOOL)showsCloseButton;
{
    return !self.alertBox.closeButton.hidden;
}

- (void)setShowsCloseButton:(BOOL)showCloseButton;
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
    return self.superview != nil && (self.state == kMOOAlertViewStateDragging || self.state == kMOOAlertViewStateShowing);
}

@end
