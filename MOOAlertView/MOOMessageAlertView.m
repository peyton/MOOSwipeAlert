//
//  MOOMessageAlertView.m
//  MOOAlertView
//
//  Created by Peyton Randolph on 6/13/12.
//

#import "MOOMessageAlertView.h"

#import "MOOAlertBox.h"
#import "MOOMessageAlertContentView.h"

@interface MOOMessageAlertView ()

@end

@implementation MOOMessageAlertView
@dynamic title;
@dynamic message;

- (id)initWithFrame:(CGRect)frame;
{
    if (!(self = [super initWithFrame:frame]))
        return nil;
    
    // Create alert message
    self.alertBox.contentView = [[MOOMessageAlertContentView alloc] initWithFrame:CGRectZero];
    
    return self;
}

- (id)initWithTitle:(NSString *)title message:(NSString *)message delegate:(id<MOOAlertViewDelegate>)delegate;
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
    if (![self.alertBox.contentView isKindOfClass:[MOOMessageAlertContentView class]])
        return nil;
    
    return [((MOOMessageAlertContentView *)self.alertBox.contentView).titleLabel.text copy];
}

- (void)setTitle:(NSString *)title;
{
    if (![self.alertBox.contentView isKindOfClass:[MOOMessageAlertContentView class]])
        return;
    
    ((MOOMessageAlertContentView *)self.alertBox.contentView).titleLabel.text = [title copy];
    
    [self setNeedsLayout];
}

- (NSString *)message;
{
    if (![self.alertBox.contentView isKindOfClass:[MOOMessageAlertContentView class]])
        return nil;
    
    return [((MOOMessageAlertContentView *)self.alertBox.contentView).messageLabel.text copy];
}

- (void)setMessage:(NSString *)message;
{
    if (![self.alertBox.contentView isKindOfClass:[MOOMessageAlertContentView class]])
        return;
    
    ((MOOMessageAlertContentView *)self.alertBox.contentView).messageLabel.text = [message copy];
    
    [self setNeedsLayout];
}

@end
