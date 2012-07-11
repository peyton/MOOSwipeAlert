//
//  CAAnimation+MOOAlertView.m
//  MOOAlertView
//
//  Created by Peyton Randolph on 7/10/12.
//

#import "CAAnimation+MOOAlertView.h"

static CGPoint interpolatePointsScaled(CGPoint fromPoint, CGPoint toPoint, CGFloat scale);

@implementation CAAnimation (MOOAlertView)

+ (CAAnimation *)rubberBandAnimationFromPosition:(CGPoint)fromPosition toPosition:(CGPoint)toPosition duration:(CFTimeInterval)duration;
{
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    animation.autoreverses = NO;
    animation.calculationMode = kCAAnimationCubic;
    animation.duration = duration;
    animation.fillMode = kCAFillModeForwards;
    
    animation.keyTimes = [NSArray arrayWithObjects:
                          [NSNumber numberWithFloat:0.0f],
                          [NSNumber numberWithFloat:0.33f],
                          [NSNumber numberWithFloat:0.66f],
                          [NSNumber numberWithFloat:1.0f], nil];
    animation.removedOnCompletion = YES;
    animation.values = [NSArray arrayWithObjects:
                        [NSValue valueWithCGPoint:fromPosition],
                        [NSValue valueWithCGPoint:interpolatePointsScaled(fromPosition, toPosition, 1.1f)],
                        [NSValue valueWithCGPoint:interpolatePointsScaled(fromPosition, toPosition, 0.95f)],
                        [NSValue valueWithCGPoint:toPosition], nil];
    
    return animation;
}

+ (CAAnimation *)wobbleAnimationFromPosition:(CGPoint)fromPosition toPosition:(CGPoint)toPosition duration:(CFTimeInterval)duration;
{
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    animation.autoreverses = NO;
    animation.calculationMode = kCAAnimationCubic;
    animation.duration = duration;
    animation.fillMode = kCAFillModeForwards;
    
    animation.keyTimes = [NSArray arrayWithObjects:
                          [NSNumber numberWithFloat:0.0f],
                          [NSNumber numberWithFloat:0.33f],
                          [NSNumber numberWithFloat:0.66f],
                          [NSNumber numberWithFloat:1.0f], nil];
    animation.removedOnCompletion = YES;
    
    CAMediaTimingFunction *easeOut = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    CAMediaTimingFunction *defaultFunc = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault];
    animation.timingFunctions = [NSArray arrayWithObjects:easeOut, defaultFunc, defaultFunc, defaultFunc, defaultFunc, defaultFunc, nil];
    animation.values = [NSArray arrayWithObjects:
                        [NSValue valueWithCGPoint:fromPosition],
                        [NSValue valueWithCGPoint:interpolatePointsScaled(fromPosition, toPosition, 1.0f)],
                        [NSValue valueWithCGPoint:interpolatePointsScaled(fromPosition, toPosition, -0.5f)],
                        [NSValue valueWithCGPoint:interpolatePointsScaled(fromPosition, toPosition, 0.25f)],
                        [NSValue valueWithCGPoint:interpolatePointsScaled(fromPosition, toPosition, -0.1f)],
                        [NSValue valueWithCGPoint:fromPosition], nil];
    
    const NSUInteger numValues = [animation.values count];
    if (numValues > 3)
    {
        const CGFloat firstInterval = 0.15f;
        const CGFloat stepSize = (1.0f - firstInterval) / (numValues - 2);
        NSMutableArray *keyTimes = [NSMutableArray arrayWithCapacity:numValues];
        [keyTimes addObject:[NSNumber numberWithFloat:0.0f]];
        [keyTimes addObject:[NSNumber numberWithFloat:firstInterval]];
        for (NSUInteger index = 1; index < numValues - 1; ++index)
            [keyTimes addObject:[NSNumber numberWithFloat:index * stepSize + firstInterval]];
        animation.keyTimes = keyTimes;
    }
    
    return animation;
}

@end

static CGPoint interpolatePointsScaled(CGPoint fromPoint, CGPoint toPoint, CGFloat scale)
{
    return CGPointMake(fromPoint.x + scale * (toPoint.x - fromPoint.x), fromPoint.y + scale * (toPoint.y - fromPoint.y));
}
