//
//  MOOAlertView.h
//  MOOAlertView
//
//  Created by Peyton Randolph on 5/29/12.
//

#import "MOOAlertBox.h"

@protocol MOOAlertViewDelegate;

#ifdef NS_ENUM
typedef NS_ENUM(NSUInteger, MOOAlertViewState) {
#else
typedef enum {
#endif
    kMOOAlertViewStateHiddenBelow,
    kMOOAlertViewStateHiddenAbove,
    kMOOAlertViewStateDragging,
    kMOOAlertViewStateShowing
#ifdef NS_ENUM
};
#else
} MOOAlertViewState;
#endif

#ifdef NS_ENUM
typedef NS_ENUM(NSUInteger, MOOAlertViewDirection) {
#else
    typedef enum {
#endif
    kMOOAlertViewDirectionDown,
    kMOOAlertViewDirectionUp
#ifdef NS_ENUM
    };
#else
} MOOAlertViewDirection;
#endif

@class MOOAlertBox;

@interface MOOAlertView : UIView
{
    @private
    CGPoint _dragStartPosition;
    CGRect _keyboardFrame;
    struct {
        BOOL dismissing: 1;
        BOOL preparedToShow: 1;
        BOOL preparedToDismiss: 1;
    } _alertViewFlags;
}

@property (nonatomic, unsafe_unretained) id<MOOAlertViewDelegate> delegate;

@property (nonatomic, assign, readonly) MOOAlertViewState state;
@property (nonatomic, assign, readonly, getter=isVisible) BOOL visible;

@property (nonatomic, strong, readonly) MOOAlertBox *alertBox;
@property (nonatomic, strong, readonly) UIView *backgroundView;

@property (nonatomic, assign) CGFloat backgroundViewAlpha;
@property (nonatomic, assign) NSTimeInterval showDuration;
@property (nonatomic, assign) NSTimeInterval dismissDuration;
@property (nonatomic, assign) NSTimeInterval accessoryViewFadeDuration;
@property (nonatomic, assign) CGFloat dismissDistanceThreshold;
@property (nonatomic, assign) CGFloat dismissVelocityThreshold;
@property (nonatomic, assign) CGFloat wobbleDistance;
@property (nonatomic, assign) BOOL dismissOnAlertBoxTouch;
@property (nonatomic, assign) BOOL dismissOnBackgroundTouch;
@property (nonatomic, assign) BOOL showsCloseButton;


- (void)show;
- (void)dismissAnimated:(BOOL)animated;

@end

@protocol MOOAlertViewDelegate <NSObject>

@optional
- (void)alertViewWillPresent:(MOOAlertView *)alertView animated:(BOOL)animated;
- (void)alertViewDidPresent:(MOOAlertView *)alertView animated:(BOOL)animated;

- (BOOL)alertViewShouldDismiss:(MOOAlertView *)alertView;
- (void)alertViewWillDismiss:(MOOAlertView *)alertView animated:(BOOL)animated;
- (void)alertViewDidDismiss:(MOOAlertView *)alertView animated:(BOOL)animated;

@end