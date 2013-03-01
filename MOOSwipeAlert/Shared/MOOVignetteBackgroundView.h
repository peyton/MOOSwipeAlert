//
//  MOOVignetteBackgroundView.h
//  MOOSwipeAlert
//
//  Created by Peyton Randolph on 3/1/13.
//


@interface MOOVignetteBackgroundView : UIView

/*
 * The center of the gradient, where 0 <= x,y <= 1
 */
@property (nonatomic, assign) CGPoint gradientCenter;
@property (nonatomic, assign) CGFloat startRadius;
@property (nonatomic, assign) CGFloat endRadius;

@end
