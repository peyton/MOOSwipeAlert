//
//  MOOAlertView.h
//  MOOAlertView
//
//  Created by Peyton Randolph on 5/29/12.
//

#import "MOOAlertBox.h"

@protocol MOOAlertViewDelegate;

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