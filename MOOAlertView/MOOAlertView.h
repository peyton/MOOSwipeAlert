//
//  MOOAlertView.h
//  MOOAlertView
//
//  Created by Peyton Randolph on 5/29/12.
//

#import "MOOAlertBox.h"

// Forward declarations
@class MOOAlertBox;
@protocol MOOAlertViewDelegate;

// Constants
typedef NS_ENUM(NSUInteger, MOOAlertViewState) {
    kMOOAlertViewStateHiddenBelow,
    kMOOAlertViewStateHiddenAbove,
    kMOOAlertViewStateDragging,
    kMOOAlertViewStateShowing
};

typedef NS_ENUM(NSUInteger, MOOAlertViewDirection) {
    kMOOAlertViewDirectionDown,
    kMOOAlertViewDirectionUp
};


// Protocol for storing options
@protocol MOOSwipeAlertOptions <NSObject>

@property (nonatomic, assign) CGFloat backgroundViewAlpha;
@property (nonatomic, assign) NSTimeInterval showDuration;
@property (nonatomic, assign) NSTimeInterval dismissDuration;
@property (nonatomic, assign) NSTimeInterval accessoryViewFadeDuration;
@property (nonatomic, assign) CGFloat dismissDistanceThreshold;
@property (nonatomic, assign) CGFloat dismissVelocityThreshold;
@property (nonatomic, assign) CGFloat wobbleDistance;
@property (nonatomic, assign) BOOL dismissOnAlertBoxTouch;
@property (nonatomic, assign) BOOL dismissOnBackgroundTouch;
@property (nonatomic, assign) BOOL vibrateOnFailedDismiss;
@property (nonatomic, assign) BOOL showsCloseButton;

@end
@interface MOOSwipeAlertOptions : NSObject <MOOSwipeAlertOptions>
@end

@interface MOOAlertView : UIView <MOOSwipeAlertOptions>
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

- (void)show;
- (void)dismissAnimated:(BOOL)animated;

- (void)configureWithOptions:(id<MOOSwipeAlertOptions>)options;
+ (id<MOOSwipeAlertOptions>)sharedDefaults;

@end

@protocol MOOAlertViewDelegate <NSObject>

@optional
- (void)alertViewWillPresent:(MOOAlertView *)alertView animated:(BOOL)animated;
- (void)alertViewDidPresent:(MOOAlertView *)alertView animated:(BOOL)animated;

- (BOOL)alertViewShouldDismiss:(MOOAlertView *)alertView;
- (void)alertViewWillDismiss:(MOOAlertView *)alertView animated:(BOOL)animated;
- (void)alertViewDidDismiss:(MOOAlertView *)alertView animated:(BOOL)animated;

@end