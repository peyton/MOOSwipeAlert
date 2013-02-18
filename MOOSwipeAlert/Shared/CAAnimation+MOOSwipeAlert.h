//
//  CAAnimation+MOOSwipeAlertView.h
//  MOOSwipeAlert
//
//  Created by Peyton Randolph on 7/10/12.
//

#import <QuartzCore/QuartzCore.h>

@interface CAAnimation (MOOSwipeAlert)

+ (CAAnimation *)rubberBandAnimationFromPosition:(CGPoint)fromPosition toPosition:(CGPoint)toPosition duration:(CFTimeInterval)duration;
+ (CAAnimation *)wobbleAnimationFromPosition:(CGPoint)fromPosition toPosition:(CGPoint)toPosition duration:(CFTimeInterval)duration;

@end
