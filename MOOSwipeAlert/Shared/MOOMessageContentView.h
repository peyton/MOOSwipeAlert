//
//  MOOMessageAlertContentView.h
//  MOOSwipeAlert
//
//  Created by Peyton Randolph on 6/13/12.
//


@interface MOOMessageContentView : UIView

@property (nonatomic, strong, readonly) UILabel *titleLabel;
@property (nonatomic, strong, readonly) UILabel *messageLabel;
@property (nonatomic, assign) UIEdgeInsets contentInsets;
@property (nonatomic, assign) CGFloat titleSpacing;

- (id)initWithTitle:(NSString *)title message:(NSString *)message;

@end
