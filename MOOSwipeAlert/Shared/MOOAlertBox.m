//
//  MOOAlertBox.m
//  MOOSwipeAlert
//
//  Created by Peyton Randolph on 6/13/12.
//

#import "MOOAlertBox.h"

#import "MOOSwipeAlertConstants.h"

#define kMOOAlertBoxOverlayEdgeInsets UIEdgeInsetsMake(-3.0f, -5.0f, -7.0f, -5.0f)
#define kMOOAlertBoxMinContentHeight 73.0f
#define kMOOAlertBoxCornerRadius 4.0f

static NSString * const kMOOAlertBoxTopAccessoryViewKeyPath = @"topAccessoryView";
static NSString * const kMOOAlertBoxBottomAccessoryViewKeyPath = @"bottomAccessoryView";

@interface MOOAlertBox ()

@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UIImageView *overlayView;

@end

@implementation MOOAlertBox
@synthesize closeButton;
@synthesize contentView = _contentView;
@synthesize overlayView = _overlayView;

@synthesize topAccessoryView = _topAccessoryView;
@synthesize topAccessoryViewOffset = _topAccessoryViewOffset;
@synthesize bottomAccessoryView = _bottomAccessoryView;
@synthesize bottomAccessoryViewOffset = _bottomAccessoryViewOffset;

@dynamic accessoryViews;

- (id)initWithFrame:(CGRect)frame;
{
    if (!(self = [super initWithFrame:frame]))
        return nil;
    
    // Set view defaults
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    // Create overlay view
    NSString *overlayImagePath = [[NSBundle bundleWithIdentifier:kMOOSwipeAlertBundleIdentifier] pathForResource:@"Overlay" ofType:@"png"];
    UIImage *overlayImage = [UIImage imageWithContentsOfFile:overlayImagePath];
    UIImage *stretchableOverlayImage;
    if ([overlayImage respondsToSelector:@selector(resizableImageWithCapInsets:)])
        stretchableOverlayImage = [overlayImage resizableImageWithCapInsets:UIEdgeInsetsMake(38.0f, 35.0f, 42.0f, 35.0f)];
    else
        stretchableOverlayImage = [overlayImage stretchableImageWithLeftCapWidth:35.0f topCapHeight:38.0f];
    self.overlayView = [[UIImageView alloc] initWithImage:stretchableOverlayImage];
    [self addSubview:self.overlayView];
    
    // Create close button
    self.closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.closeButton.adjustsImageWhenDisabled = NO;
    self.closeButton.adjustsImageWhenHighlighted = NO;
    [self.closeButton setBackgroundImage:[UIImage imageWithContentsOfFile:[[NSBundle bundleWithIdentifier:kMOOSwipeAlertBundleIdentifier] pathForResource:@"Close-Button" ofType:@"png"]] forState:UIControlStateNormal];
    [self.closeButton setBackgroundImage:[UIImage imageWithContentsOfFile:[[NSBundle bundleWithIdentifier:kMOOSwipeAlertBundleIdentifier] pathForResource:@"Close-Button-Highlighted" ofType:@"png"]] forState:UIControlStateHighlighted];
    [self.closeButton setBackgroundImage:[UIImage imageWithContentsOfFile:[[NSBundle bundleWithIdentifier:kMOOSwipeAlertBundleIdentifier] pathForResource:@"Close-Button-Disabled" ofType:@"png"]] forState:UIControlStateDisabled];
    [self addSubview:self.closeButton];
    
    // Watch for accessory view changes
    [self addObserver:self forKeyPath:kMOOAlertBoxTopAccessoryViewKeyPath options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:(__bridge void *)kMOOAlertBoxTopAccessoryViewKeyPath];
    [self addObserver:self forKeyPath:kMOOAlertBoxBottomAccessoryViewKeyPath options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:(__bridge void *)kMOOAlertBoxBottomAccessoryViewKeyPath];
    
    return self;
}

- (void)dealloc;
{
    [self removeObserver:self forKeyPath:kMOOAlertBoxTopAccessoryViewKeyPath];
    [self removeObserver:self forKeyPath:kMOOAlertBoxBottomAccessoryViewKeyPath];
}

#pragma mark - Layout methods

- (void)layoutSubviews;
{
    [super layoutSubviews];
    
    // Size content view to fit
    [self.contentView sizeToFit];
    CGRect contentViewFrame = self.contentView.frame;
    if (contentViewFrame.size.height < kMOOAlertBoxMinContentHeight) contentViewFrame.size.height = kMOOAlertBoxMinContentHeight;
    self.contentView.frame = contentViewFrame;
    
    // Make overlay fill view
    CGRect overlayViewFrame = contentViewFrame;
    overlayViewFrame = UIEdgeInsetsInsetRect(overlayViewFrame, kMOOAlertBoxOverlayEdgeInsets);
    self.overlayView.frame = overlayViewFrame;
    
    // Position close button
    [self.closeButton sizeToFit];
    self.closeButton.center = CGPointMake(CGRectGetMidX(self.closeButton.bounds), CGRectGetMinY(self.contentView.frame));
    self.closeButton.frame = CGRectIntegral(self.closeButton.frame);
    
    // Position top accessory view
    CGPoint accessoryViewCenter = CGPointMake(CGRectGetMidX(self.bounds), 0.0f);
    if (self.topAccessoryView)
    {
        self.topAccessoryView.center = accessoryViewCenter;
        CGRect topAccessoryViewFrame = self.topAccessoryView.frame;
        topAccessoryViewFrame.origin.y = -(CGRectGetHeight(topAccessoryViewFrame) + self.topAccessoryViewOffset);
        self.topAccessoryView.frame = CGRectIntegral(topAccessoryViewFrame);
    }
    
    // Position bottom accessory view
    if (self.bottomAccessoryView)
    {
        self.bottomAccessoryView.center = accessoryViewCenter;
        CGRect bottomAccessoryViewFrame = self.bottomAccessoryView.frame;
        bottomAccessoryViewFrame.origin.y = CGRectGetHeight(self.bounds) + self.bottomAccessoryViewOffset;
        self.bottomAccessoryView.frame = CGRectIntegral(bottomAccessoryViewFrame);
    }
}

- (CGSize)sizeThatFits:(CGSize)size;
{
    // Determine the content view's size
    CGSize contentViewSize = [self.contentView sizeThatFits:size];
    return contentViewSize;
}

- (CGRect)apparentBounds;
{
    CGRect bounds = self.bounds;
    for (UIView *subview in self.subviews)
        bounds = CGRectUnion(subview.frame, bounds);
    
    return bounds;
}

- (CGFloat)topOverflowY;
{
    return -1.0f * [self apparentBounds].origin.y;
}

- (CGFloat)bottomOverflowY;
{
    return CGRectGetMaxY([self apparentBounds]) - CGRectGetHeight(self.bounds);
}

#pragma mark - Getters and setters

- (NSArray *)accessoryViews;
{
    // Add accessory view one-at-a-time in case one or the other is nil
    NSMutableArray *accessoryViews = [NSMutableArray arrayWithCapacity:2];
    if (self.topAccessoryView) [accessoryViews addObject:self.topAccessoryView];
    if (self.bottomAccessoryView) [accessoryViews addObject:self.bottomAccessoryView];
    
    return accessoryViews;
}

- (void)setContentView:(UIView *)contentView;
{
    if (contentView == self.contentView)
        return;
    
    // Remove old view
    self.contentView.layer.cornerRadius = _oldCornerRadius;
    [self.contentView removeFromSuperview];
    
    // Update ivar
    _contentView = contentView;
    
    // Add new view
    _oldCornerRadius = self.contentView.layer.cornerRadius;
    self.contentView.layer.cornerRadius = kMOOAlertBoxCornerRadius;
    [self insertSubview:self.contentView belowSubview:self.overlayView];
    
    [self setNeedsLayout];
    [self sizeToFit];
}

#pragma mark - Touch methods

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event;
{
    if ([self pointInside:point withEvent:event])
        return [super hitTest:point withEvent:event];
    
    // Make sure hits to buttons, text fields, etc are properly registered
    UIView *targetView;
    for (UIView *controlView in [self.accessoryViews arrayByAddingObject:self.closeButton])
    {
        targetView = [controlView hitTest:[controlView convertPoint:point fromView:self] withEvent:event];
        if ([targetView isKindOfClass:[UIControl class]] || [targetView isKindOfClass:[UITextField class]] || [targetView isKindOfClass:[UITextView class]])
            return targetView;
    }
    
    return nil;
}

#pragma mark - KVO methods

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context;
{
    id newVal = [change objectForKey:NSKeyValueChangeNewKey];
    id oldVal = [change objectForKey:NSKeyValueChangeOldKey];
    
    if (context == (__bridge void *)kMOOAlertBoxBottomAccessoryViewKeyPath || (__bridge void *)kMOOAlertBoxTopAccessoryViewKeyPath)
    {
        UIView *newView = (UIView *)newVal;
        UIView *oldView = (UIView *)oldVal;
        
        if (oldView != (id)[NSNull null] && [self.subviews containsObject:oldView])
            [oldView removeFromSuperview];
        
        if (newView != (id)[NSNull null])
            [self insertSubview:newView belowSubview:self.closeButton];
        
        [self setNeedsLayout];
    }
}

@end
