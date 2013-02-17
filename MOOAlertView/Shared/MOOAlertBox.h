//
//  MOOAlertBox.h
//  MOOSwipeAlert
//
//  Created by Peyton Randolph on 6/13/12.
//


@interface MOOAlertBox : UIView
{
    @private
    CGFloat _oldCornerRadius;
}

@property (nonatomic, strong, readonly) UIButton *closeButton;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong, readonly) UIImageView *overlayView;

@property (nonatomic, strong) UIView *topAccessoryView;
@property (nonatomic, assign) CGFloat topAccessoryViewOffset;
@property (nonatomic, strong) UIView *bottomAccessoryView;
@property (nonatomic, assign) CGFloat bottomAccessoryViewOffset;
@property (nonatomic, strong, readonly) NSArray *accessoryViews;

- (CGRect)apparentBounds;

@end
