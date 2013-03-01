//
//  MOOVignetteBackgroundView.m
//  MOOSwipeAlert
//
//  Created by Peyton Randolph on 3/1/13.
//

#import "MOOVignetteBackgroundView.h"

@interface MOOVignetteBackgroundView ()

@property (nonatomic, assign) CGGradientRef gradientRef;

@end

@implementation MOOVignetteBackgroundView
@synthesize gradientRef = _gradientRef;
@synthesize gradientCenter = _gradientCenter;
@synthesize startRadius = _startRadius;
@synthesize endRadius = _endRadius;

- (id)initWithFrame:(CGRect)frame
{
    if (!(self = [super initWithFrame:frame]))
        return nil;
    
    // Remove background color
    self.backgroundColor = [UIColor clearColor];
    
    // Set defaults
    self.gradientCenter = CGPointMake(0.5f, 0.5f);
    self.startRadius = 0.f;
    self.endRadius = ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) ? 700.f : 300.f;
    
    return self;
}

- (void)dealloc;
{
    self.gradientRef = NULL;
}

#pragma mark - Drawing methods

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Convert self.center from [0,1] coordinates to the view's coordinates.
    CGRect leftQuadrant = CGRectApplyAffineTransform(self.bounds, CGAffineTransformMakeScale(self.gradientCenter.x, self.gradientCenter.y));
    CGPoint center = CGPointMake(leftQuadrant.size.width, leftQuadrant.size.height);
    
    CGContextDrawRadialGradient(context, self.gradientRef, center, self.startRadius, center, self.endRadius, kCGGradientDrawsAfterEndLocation);
}

#pragma mark - Getters and setters

- (CGGradientRef)gradientRef;
{
    if (_gradientRef == NULL)
    {
        // Create a new gradient
        CGFloat locations[2] = {0.0f, 1.0f};
        CGFloat colors[4] = {0.0f,0.3f,0.0f,1.0f}; // black, from 0.5f to 1.0f alpha
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
        _gradientRef = CGGradientCreateWithColorComponents(colorSpace, colors, locations, 2);
        CGColorSpaceRelease(colorSpace);
    }
    
    return _gradientRef;
}

- (void)setGradientRef:(CGGradientRef)gradientRef;
{
    CGGradientRelease(_gradientRef);
    _gradientRef = CGGradientRetain(gradientRef);
}

@end
