//
//  MOOButtonContentView.m
//  Demo Project
//
//  Created by Peyton Randolph on 3/3/13.
//  Copyright (c) 2013 Peyton Randolph. All rights reserved.
//

#import "MOOButtonContentView.h"

#import "MOOSwipeAlertConstants.h"

#define BUTTON_BACKGROUND_INSETS (UIEdgeInsetsMake(0.f, 9.f, 0.f, 9.f))
#define BUTTON_SHADOW_INSETS (UIEdgeInsetsMake(3.f, 4.f, 6.f, 4.f))
#define BUTTON_PADDING 10.f
#define BUTTON_HEIGHT 44.f

@interface MOOButtonContentView ()

@property (nonatomic, strong) NSMutableArray *buttonViews;

@end

@implementation MOOButtonContentView
@synthesize buttons = _buttons;
@synthesize buttonViews = _buttonViews;

- (id)initWithFrame:(CGRect)frame
{
    if (!(self = [super initWithFrame:frame]))
        return nil;
    
    return self;
}

#pragma mark - Layout methods

- (void)layoutSubviews;
{
    [super layoutSubviews];
    
    [self _createButtonViewsIfNeeded];
    
    CGFloat buttonWidth = self.bounds.size.width - (BUTTON_PADDING - BUTTON_SHADOW_INSETS.left) - (BUTTON_PADDING - BUTTON_SHADOW_INSETS.right);
    CGAffineTransform shift = CGAffineTransformMakeTranslation(0.f, BUTTON_HEIGHT + BUTTON_PADDING);
    CGPoint buttonOrigin = CGPointMake(BUTTON_PADDING - BUTTON_SHADOW_INSETS.left, CGRectGetHeight(self.bounds) - [self _buttonsHeight]);
    for (UIButton *button in self.buttonViews)
    {        
        CGRect buttonFrame = CGRectMake(buttonOrigin.x, buttonOrigin.y, buttonWidth, BUTTON_HEIGHT + BUTTON_SHADOW_INSETS.top + BUTTON_SHADOW_INSETS.bottom);
        button.frame = buttonFrame;
        buttonOrigin = CGPointApplyAffineTransform(buttonOrigin, shift);
    }
}

- (CGSize)sizeThatFits:(CGSize)size;
{
    CGSize superSize = [super sizeThatFits:size];
    
    superSize.height += [self _buttonsHeight];
    
    return superSize;
}

- (CGFloat)_buttonsHeight;
{
    CGFloat height = 0.f;
    if (self.buttons)
    {
        height -= BUTTON_SHADOW_INSETS.top;
        height += [self.buttons count] * (BUTTON_HEIGHT + BUTTON_PADDING - BUTTON_SHADOW_INSETS.top + BUTTON_SHADOW_INSETS.bottom);
    }
    return height;
}

#pragma mark - View creation methods

- (void)_createButtonViewsIfNeeded;
{
    if (!_buttonContentViewFlags.needsButtonViews)
        return;
    
    _buttonContentViewFlags.needsButtonViews = NO;
    
    // Do nothing if there are no buttons to create
    if (!self.buttons || [self.buttons count] == 0)
        return;
    
    // Remove old button views
    for (UIButton *buttonView in self.buttonViews)
        [buttonView removeFromSuperview];
    
    // Create button views from buttons
    self.buttonViews = [NSMutableArray arrayWithCapacity:[self.buttons count]];
    for (NSDictionary *button in self.buttons)
    {
        MOOSwipeAlertButtonStyle style;
        [[button objectForKey:kMOOSwipeAlertButtonStyleKey] getValue:&style];
        UIButton *buttonView = [self _createButtonWithTitle:[button objectForKey:kMOOSwipeAlertButtonTitleKey] style:style];
        [self.buttonViews addObject:buttonView];
    }
    
    // Add new buttons to view
    for (UIButton *buttonView in self.buttonViews)
        [self addSubview:buttonView];
}

- (UIButton *)_createButtonWithTitle:(NSString *)title style:(MOOSwipeAlertButtonStyle)style;
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    button.contentEdgeInsets = BUTTON_SHADOW_INSETS;
    
    // Configure title label
    button.titleLabel.font = [UIFont boldSystemFontOfSize:16.0f];
    button.titleLabel.shadowOffset = CGSizeMake(0.f, -1.0f);
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setTitleShadowColor:[UIColor colorWithWhite:0.2f alpha:1.0f] forState:UIControlStateNormal];
    
    // Configure backgrounds
    NSString *bgPath = [[NSBundle bundleWithIdentifier:kMOOSwipeAlertBundleIdentifier] pathForResource:[self _buttonBackgroundFileNameForStyle:style] ofType:@"png"];
    NSString *highlightedBgPath = [[NSBundle bundleWithIdentifier:kMOOSwipeAlertBundleIdentifier] pathForResource:[self _highlightedButtonBackgroundFileNameForStyle:style] ofType:@"png"];
    
    [button setBackgroundImage:[[UIImage imageWithContentsOfFile:bgPath] resizableImageWithCapInsets:BUTTON_BACKGROUND_INSETS] forState:UIControlStateNormal];
    [button setBackgroundImage:[[UIImage imageWithContentsOfFile:highlightedBgPath] resizableImageWithCapInsets:BUTTON_BACKGROUND_INSETS] forState:UIControlStateHighlighted];
    
    // Configure events
    [button addTarget:self action:@selector(_buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    return button;
}

- (NSString *)_buttonBackgroundFileNameForStyle:(MOOSwipeAlertButtonStyle)style;
{
    NSString *buttonStem;
    switch (style)
    {
        case kMOOSwipeAlertButtonStyleCancel:
            buttonStem = @"Cancel-Button";
            break;
        case kMOOSwipeAlertButtonStyleDanger:
            buttonStem = @"Danger-Button";
            break;
        case kMOOSwipeAlertButtonStyleDefault:
            buttonStem = @"Default-Button";
            break;
        case kMOOSwipeAlertButtonStyleOK:
            buttonStem = @"OK-Button";
            break;
    }
    
    return buttonStem;
}

- (NSString *)_highlightedButtonBackgroundFileNameForStyle:(MOOSwipeAlertButtonStyle)style;
{
    NSString *buttonFileName = [self _buttonBackgroundFileNameForStyle:style];
    
    return [NSString stringWithFormat:@"%@-Highlighted", buttonFileName];
}

#pragma mark - Event handling

- (void)_buttonPressed:(id)sender;
{
    if (![self.buttonViews containsObject:sender])
    {
        NSLog(@"(%@) Untracked button %@ pressed, %@", NSStringFromSelector(_cmd), sender, self);
        return;
    }
    
    NSInteger index = [self.buttonViews indexOfObject:sender];
    
    if ([self.alert.delegate respondsToSelector:@selector(alertView:clickedButtonAtIndex:)])
        [self.alert.delegate alertView:self.alert clickedButtonAtIndex:index];
    
    [self.alert dismissWithClickedButtonIndex:index animated:YES];
}

#pragma mark - Getters and setters

- (void)_setNeedsButtonViews;
{
    _buttonContentViewFlags.needsButtonViews = YES;
    [self setNeedsLayout];
}

- (void)setSideBySideIndices:(NSIndexSet *)indices;
{
    _sideBySideIndices = indices;
    
    [self _setNeedsButtonViews];
}

- (void)setButtons:(NSArray *)buttons;
{
    _buttons = buttons;
    [self _setNeedsButtonViews];
}

@end
