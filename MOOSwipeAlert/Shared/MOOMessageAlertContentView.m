//
//  MOOMessageAlertContentView.m
//  MOOSwipeAlert
//
//  Created by Peyton Randolph on 6/13/12.
//

#import "MOOMessageAlertContentView.h"

@interface MOOMessageAlertContentView ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *messageLabel;

@end

@implementation MOOMessageAlertContentView
@synthesize titleLabel = _titleLabel;
@synthesize messageLabel = _messageLabel;
@synthesize contentInsets = _contentInsets;
@synthesize titleSpacing = _titleSpacing;

- (id)initWithFrame:(CGRect)frame
{
    if (!(self = [super initWithFrame:frame]))
        return nil;
    
    // Set property defaults
    self.contentInsets = UIEdgeInsetsMake(16.0f, 20.0f, 16.0f, 20.0f);
    self.titleSpacing = 12.0f;
    
    // Set view defaults
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.backgroundColor = [UIColor colorWithRed:115.f/255.f green:123.f/255.f blue:132.f/255.f alpha:1.0f];
    
    // Create title label
    self.titleLabel = [self _createLabelWithFont:[UIFont boldSystemFontOfSize:24.0f]];
    [self addSubview:self.titleLabel];
    
    // Create message label
    self.messageLabel = [self _createLabelWithFont:[UIFont systemFontOfSize:16.0f]];
    [self addSubview:self.messageLabel];
    
    return self;
}

- (id)initWithTitle:(NSString *)title message:(NSString *)message;
{
    if (!(self = [self initWithFrame:CGRectZero]))
        return nil;
    
    self.titleLabel.text = title;
    self.messageLabel.text = message;
    
    return self;
}

#pragma mark - Layout methods

- (void)layoutSubviews;
{
    [super layoutSubviews];
    
    // Size labels
    CGFloat labelWidth = CGRectGetWidth(self.bounds) - self.contentInsets.left - self.contentInsets.right;
    CGSize titleSize = [self.titleLabel.text sizeWithFont:self.titleLabel.font constrainedToSize:CGSizeMake(labelWidth, CGFLOAT_MAX) lineBreakMode:self.titleLabel.lineBreakMode];
    CGSize messageSize = [self.messageLabel.text sizeWithFont:self.messageLabel.font constrainedToSize:CGSizeMake(labelWidth, CGFLOAT_MAX) lineBreakMode:self.messageLabel.lineBreakMode];
    
    titleSize.width = messageSize.width = labelWidth;
    
    // Position labels
    CGRect titleFrame = CGRectMake(self.contentInsets.left, self.contentInsets.top, titleSize.width, titleSize.height);
    CGRect messageFrame = CGRectMake(self.contentInsets.left, CGRectGetMaxY(titleFrame) + ((titleSize.height) ? self.titleSpacing : 0), labelWidth, messageSize.height);
    self.titleLabel.frame = titleFrame;
    self.messageLabel.frame = messageFrame;
}

- (CGSize)sizeThatFits:(CGSize)size;
{
    CGFloat labelWidth = size.width - self.contentInsets.left - self.contentInsets.right;
    
    CGSize titleSize = [self.titleLabel.text sizeWithFont:self.titleLabel.font constrainedToSize:CGSizeMake(labelWidth, CGFLOAT_MAX) lineBreakMode:self.titleLabel.lineBreakMode];
    CGSize messageSize = [self.messageLabel.text sizeWithFont:self.messageLabel.font constrainedToSize:CGSizeMake(labelWidth, CGFLOAT_MAX) lineBreakMode:self.messageLabel.lineBreakMode];
    
    CGFloat height = self.contentInsets.top + titleSize.height + messageSize.height + self.contentInsets.bottom;
    if (titleSize.height && messageSize.height) height += self.titleSpacing;
    return CGSizeMake(size.width, height);
}

#pragma mark - View creation methods

- (UILabel *)_createLabelWithFont:(UIFont *)font;
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.backgroundColor = [UIColor clearColor];
    label.font = font;
    
// todo: iOS 6+ uses NSLineBreakMode
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    label.lineBreakMode = UILineBreakModeWordWrap;
#pragma clang diagnostic pop
    label.numberOfLines = 0;
    label.shadowColor = [UIColor colorWithWhite:0.2f alpha:1.0f];
    label.shadowOffset = CGSizeMake(0.0f, 1.0f);
    
// todo: iOS 6+ uses NSTextAlignment
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    label.textAlignment = UITextAlignmentCenter;
#pragma clang diagnostic pop
    label.textColor = [UIColor whiteColor];

    return label;
}

@end
