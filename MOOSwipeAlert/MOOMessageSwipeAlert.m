//
//  MOOMessageSwipeAlert.m
//  MOOSwipeAlert
//
//  Created by Peyton Randolph on 6/13/12.
//

#import "MOOMessageSwipeAlert.h"

#import "MOOAlertBox.h"
#import "MOOMessageContentView.h"

@interface MOOMessageSwipeAlert ()

@end

@implementation MOOMessageSwipeAlert
@dynamic title;
@dynamic message;

- (id)initWithFrame:(CGRect)frame;
{
    if (!(self = [super initWithFrame:frame]))
        return nil;
    
    // Create alert message
    self.alertBox.contentView = [[MOOMessageContentView alloc] initWithFrame:CGRectZero];
    
    return self;
}

- (id)initWithTitle:(NSString *)title message:(NSString *)message delegate:(id<MOOSwipeAlertDelegate>)delegate;
{
    if (!(self = [self initWithFrame:CGRectZero]))
        return nil;
    
    // Set properties
    self.title = title;
    self.message = message;
    self.delegate = delegate;
    
    return self;
}

#pragma mark - Getters and setters

- (NSString *)title;
{
    if (![self.alertBox.contentView isKindOfClass:[MOOMessageContentView class]])
        return nil;
    
    return [((MOOMessageContentView *)self.alertBox.contentView).titleLabel.text copy];
}

- (void)setTitle:(NSString *)title;
{
    if (![self.alertBox.contentView isKindOfClass:[MOOMessageContentView class]])
        return;
    
    ((MOOMessageContentView *)self.alertBox.contentView).titleLabel.text = [title copy];
    
    [self setNeedsLayout];
}

- (NSString *)message;
{
    if (![self.alertBox.contentView isKindOfClass:[MOOMessageContentView class]])
        return nil;
    
    return [((MOOMessageContentView *)self.alertBox.contentView).messageLabel.text copy];
}

- (void)setMessage:(NSString *)message;
{
    if (![self.alertBox.contentView isKindOfClass:[MOOMessageContentView class]])
        return;
    
    ((MOOMessageContentView *)self.alertBox.contentView).messageLabel.text = [message copy];
    
    [self setNeedsLayout];
}

@end
