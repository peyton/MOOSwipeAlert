//
//  MOOSwipeAlert.h
//  MOOSwipeAlert
//
//  Created by Peyton Randolph on 5/29/12.
//

#import "MOOAlertBox.h"

// Forward declarations
@class MOOAlertBox;
@class MOOSwipeAlert;
@protocol MOOSwipeAlertDelegate;

// Constants
typedef NS_ENUM(NSUInteger, MOOSwipeAlertState) {
    kMOOSwipeAlertStateHiddenBelow,
    kMOOSwipeAlertStateHiddenAbove,
    kMOOSwipeAlertStateDragging,
    kMOOSwipeAlertStateShowing
};

typedef NS_ENUM(NSUInteger, MOOSwipeAlertDirection) {
    kMOOSwipeAlertDirectionDown,
    kMOOSwipeAlertDirectionUp
};

// Block types
typedef void (^MOOSwipeAlertDismissBlock)(MOOSwipeAlert *alert, BOOL animated);
typedef BOOL (^MOOSwipeAlertShouldDismissBlock)(MOOSwipeAlert *alert);

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

@interface MOOSwipeAlert : UIView <MOOSwipeAlertOptions>
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

@property (nonatomic, copy) MOOSwipeAlertDismissBlock dismissBlock;
@property (nonatomic, copy) MOOSwipeAlertShouldDismissBlock shouldDismissBlock;
@property (nonatomic, unsafe_unretained) id<MOOSwipeAlertDelegate> delegate;

@property (nonatomic, assign, readonly) MOOSwipeAlertState state;
@property (nonatomic, assign, readonly, getter=isVisible) BOOL visible;

@property (nonatomic, strong, readonly) MOOAlertBox *alertBox;
@property (nonatomic, strong, readonly) UIView *backgroundView;

- (void)show;
- (void)dismissAnimated:(BOOL)animated;

- (void)configureWithOptions:(id<MOOSwipeAlertOptions>)options;
+ (id<MOOSwipeAlertOptions>)sharedDefaults;

@end

@protocol MOOSwipeAlertDelegate <NSObject>

@optional
- (void)alertViewWillPresent:(MOOSwipeAlert *)alertView animated:(BOOL)animated;
- (void)alertViewDidPresent:(MOOSwipeAlert *)alertView animated:(BOOL)animated;

- (BOOL)alertViewShouldDismiss:(MOOSwipeAlert *)alertView;
- (void)alertViewWillDismiss:(MOOSwipeAlert *)alertView animated:(BOOL)animated;
- (void)alertViewDidDismiss:(MOOSwipeAlert *)alertView animated:(BOOL)animated;

@end