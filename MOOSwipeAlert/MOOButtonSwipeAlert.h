//
//  MOOButtonSwipeAlert.h
//  Demo Project
//
//  Created by Peyton Randolph on 3/3/13.
//  Copyright (c) 2013 Peyton Randolph. All rights reserved.
//

#import "MOOMessageSwipeAlert.h"

@class MOOButtonSwipeAlert;

typedef NS_ENUM(NSUInteger, MOOSwipeAlertButtonStyle) {
    kMOOSwipeAlertButtonStyleDefault,
    kMOOSwipeAlertButtonStyleCancel,
    kMOOSwipeAlertButtonStyleDanger,
    kMOOSwipeAlertButtonStyleOK
};

extern NSString * const kMOOSwipeAlertButtonStyleKey;
extern NSString * const kMOOSwipeAlertButtonTitleKey;

@protocol MOOButtonSwipeAlertDelegate <MOOSwipeAlertDelegate>

@optional
- (void)alertView:(MOOButtonSwipeAlert *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;

- (void)alertView:(MOOButtonSwipeAlert *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex;
- (void)alertView:(MOOButtonSwipeAlert *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex;

- (void)alertViewCancel:(MOOButtonSwipeAlert *)alertView;

@end

@interface MOOButtonSwipeAlert : MOOMessageSwipeAlert

@property (nonatomic, unsafe_unretained) id<MOOButtonSwipeAlertDelegate> delegate;

@property (nonatomic, assign, readonly) NSInteger numberOfButtons;
@property (nonatomic, assign) NSInteger cancelButtonIndex;
@property (nonatomic, assign, readonly) NSInteger firstOtherButtonIndex;
@property (nonatomic, strong) NSIndexSet *sideBySideIndices;

- (id)initWithTitle:(NSString *)title message:(NSString *)message delegate:(id<MOOSwipeAlertDelegate>)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION;


- (void)addButtonWithTitle:(NSString *)title;
- (void)addButtonWithTitle:(NSString *)title style:(MOOSwipeAlertButtonStyle)style;

- (MOOSwipeAlertButtonStyle)buttonStyleAtIndex:(NSInteger)index;
- (void)setButtonStyle:(MOOSwipeAlertButtonStyle)style atIndex:(NSInteger)index;
- (NSString *)buttonTitleAtIndex:(NSInteger)index;
- (void)setButtonTitle:(NSString *)title atIndex:(NSInteger)index;

- (void)dismissWithClickedButtonIndex:(NSInteger)buttonIndex animated:(BOOL)animated;

@end