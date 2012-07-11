//
//  CAAnimation+MOOAlertView.h
//  MOOAlertView
//
//  Created by Peyton Randolph on 7/10/12.
//

#import <QuartzCore/QuartzCore.h>

@interface CAAnimation (MOOAlertView)

+ (CAAnimation *)rubberBandAnimationFromPosition:(CGPoint)fromPosition toPosition:(CGPoint)toPosition duration:(CFTimeInterval)duration;
+ (CAAnimation *)wobbleAnimationFromPosition:(CGPoint)fromPosition toPosition:(CGPoint)toPosition duration:(CFTimeInterval)duration;

@end
