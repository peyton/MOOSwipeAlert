//
//  MOOButtonSwipeAlert.m
//  Demo Project
//
//  Created by Peyton Randolph on 3/3/13.
//  Copyright (c) 2013 Peyton Randolph. All rights reserved.
//

#import "MOOButtonSwipeAlert.h"

#import "MOOButtonContentView.h"

NSString * const kMOOSwipeAlertButtonStyleKey = @"kMOOSwipeAlertButtonStyleKey";
NSString * const kMOOSwipeAlertButtonTitleKey = @"kMOOSwipeAlertButtonTitleKey";

static NSString * const kMOOSwipeAlertButtonsKeyPath = @"buttons";

@interface MOOButtonSwipeAlert ()

@property (nonatomic, strong) NSMutableArray *buttons;

@end

@implementation MOOButtonSwipeAlert
@synthesize delegate = _delegate;

@synthesize buttons = _buttons;

- (id)initWithFrame:(CGRect)frame
{
    if (!(self = [super initWithFrame:frame]))
        return nil;
    
    // Create content view
    self.alertBox.contentView = [[MOOButtonContentView alloc] initWithFrame:CGRectZero];
    [(MOOButtonContentView *)self.alertBox.contentView setAlert:self];
    
    // Initialize defaults
    self.buttons = [NSMutableArray array];
    self.cancelButtonIndex = -1;
    
    // Watch for button changes
    [self addObserver:self forKeyPath:kMOOSwipeAlertButtonsKeyPath options:NSKeyValueObservingOptionNew context:(__bridge void *)kMOOSwipeAlertButtonsKeyPath];
    
    return self;
}

- (id)initWithTitle:(NSString *)title message:(NSString *)message delegate:(id<MOOSwipeAlertDelegate>)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ...;
{
    if (!(self = [self initWithTitle:title message:message delegate:delegate]))
        return nil;
    
    // Add buttons
    NSString *buttonTitle;
    va_list args;
    if (otherButtonTitles)
    {
        [self addButtonWithTitle:otherButtonTitles];
        va_start(args, otherButtonTitles);
        while ((buttonTitle = va_arg(args, NSString *)))
        {
            [self addButtonWithTitle:buttonTitle];
        }
    }
    
    if (cancelButtonTitle)
    {
        [self addButtonWithTitle:cancelButtonTitle style:kMOOSwipeAlertButtonStyleCancel];
        self.cancelButtonIndex = [self.buttons count] - 1;
    }
    
    return self;
}

- (void)dealloc;
{
    [self removeObserver:self forKeyPath:kMOOSwipeAlertButtonsKeyPath context:(__bridge void *)kMOOSwipeAlertButtonsKeyPath];
}

#pragma mark - Button management

- (void)addButtonWithTitle:(NSString *)title;
{
    [self addButtonWithTitle:title style:kMOOSwipeAlertButtonStyleDefault];
}

- (void)addButtonWithTitle:(NSString *)title style:(MOOSwipeAlertButtonStyle)style;
{
    if (title == nil)
        title = @"";

    NSMutableDictionary *buttonProperties = [NSMutableDictionary dictionaryWithObjectsAndKeys:title, kMOOSwipeAlertButtonTitleKey, [NSValue value:&style withObjCType:@encode(MOOSwipeAlertButtonStyle)], kMOOSwipeAlertButtonStyleKey, nil];
    
    [[self mutableArrayValueForKey:kMOOSwipeAlertButtonsKeyPath] addObject:buttonProperties];
}

#pragma mark - Appearance methods

- (void)dismissWithClickedButtonIndex:(NSInteger)buttonIndex animated:(BOOL)animated;
{
    if ([self.delegate respondsToSelector:@selector(alertView:willDismissWithButtonIndex:)])
        [self.delegate alertView:self willDismissWithButtonIndex:buttonIndex];
    
    [self dismissAnimated:animated];
    
    if ([self.delegate respondsToSelector:@selector(alertView:didDismissWithButtonIndex:)])
        [self.delegate alertView:self didDismissWithButtonIndex:buttonIndex];
}

#pragma mark - Getters and setters

- (void)setCancelButtonIndex:(NSInteger)cancelButtonIndex;
{
    if (cancelButtonIndex >= (NSInteger)[self.buttons count])
    {
        NSLog(@"(%@) Cancel button index %i is not less than %i, the number of buttons in %@", NSStringFromSelector(_cmd), cancelButtonIndex, [self.buttons count], self);
        return;
    }
    
    if (cancelButtonIndex == self.cancelButtonIndex)
        return;
    
    _cancelButtonIndex = cancelButtonIndex;
    if (self.cancelButtonIndex >= 0)
    {
        [self setButtonStyle:kMOOSwipeAlertButtonStyleCancel atIndex:self.cancelButtonIndex];
    }
}

- (MOOSwipeAlertButtonStyle)buttonStyleAtIndex:(NSInteger)index;
{
    if (!(0 <= index && index < (NSInteger)[self.buttons count]))
    {
        NSLog(@"(%@) Button index %i is negative or not less than %i, the number of buttons in %@", NSStringFromSelector(_cmd), index, [self.buttons count], self);
        
        return kMOOSwipeAlertButtonStyleDefault;
    }
    
    MOOSwipeAlertButtonStyle buttonStyle;
    [[(NSDictionary *)[self.buttons objectAtIndex:index] objectForKey:kMOOSwipeAlertButtonStyleKey] getValue:&buttonStyle];
    return buttonStyle;
}

- (void)setButtonStyle:(MOOSwipeAlertButtonStyle)style atIndex:(NSInteger)index;
{
    if (!(0 <= index && index < (NSInteger)[self.buttons count]))
    {
        NSLog(@"(%@) Button index %i is negative or not less than %i, the number of buttons in %@", NSStringFromSelector(_cmd), index, [self.buttons count], self);
        
        return;
    }

    [self willChange:NSKeyValueChangeReplacement valuesAtIndexes:[NSIndexSet indexSetWithIndex:index] forKey:kMOOSwipeAlertButtonsKeyPath];
    [(NSMutableDictionary *)[[self mutableArrayValueForKey:kMOOSwipeAlertButtonsKeyPath] objectAtIndex:index] setValue:[NSValue value:&style withObjCType:@encode(MOOSwipeAlertButtonStyle)] forKey:kMOOSwipeAlertButtonStyleKey];
    [self didChange:NSKeyValueChangeReplacement valuesAtIndexes:[NSIndexSet indexSetWithIndex:index] forKey:kMOOSwipeAlertButtonsKeyPath];
}

- (NSString *)buttonTitleAtIndex:(NSInteger)index;
{
    if (!(0 <= index && index < (NSInteger)[self.buttons count]))
    {
        NSLog(@"(%@) Button index %i is negative or not less than %i, the number of buttons in %@", NSStringFromSelector(_cmd), index, [self.buttons count], self);
        
        return nil;
    }
    
    return [(NSDictionary *)[self.buttons objectAtIndex:index] objectForKey:kMOOSwipeAlertButtonTitleKey];
}

- (void)setButtonTitle:(NSString *)title atIndex:(NSInteger)index;
{
    if (!(0 <= index && index < (NSInteger)[self.buttons count]))
    {
        NSLog(@"(%@) Button index %i is negative or not less than %i, the number of buttons in %@", NSStringFromSelector(_cmd), index, [self.buttons count], self);
        
        return;
    }
    
    [self willChange:NSKeyValueChangeReplacement valuesAtIndexes:[NSIndexSet indexSetWithIndex:index] forKey:kMOOSwipeAlertButtonsKeyPath];
    [(NSMutableDictionary *)[[self mutableArrayValueForKey:kMOOSwipeAlertButtonsKeyPath] objectAtIndex:index] setValue:title forKey:kMOOSwipeAlertButtonTitleKey];
    [self didChange:NSKeyValueChangeReplacement valuesAtIndexes:[NSIndexSet indexSetWithIndex:index] forKey:kMOOSwipeAlertButtonsKeyPath];
}

- (void)setSideBySideIndices:(NSIndexSet *)sideBySideIndices;
{
    if ([sideBySideIndices isEqualToIndexSet:self.sideBySideIndices])
        return;
    
    _sideBySideIndices = sideBySideIndices;
    [(MOOButtonContentView *)self.alertBox.contentView setSideBySideIndices:self.sideBySideIndices];
}

#pragma mark - KVO methods

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context;
{
    if (context == (__bridge void *)kMOOSwipeAlertButtonsKeyPath)
    {
        // update content after buttons change
        [(MOOButtonContentView *)self.alertBox.contentView setButtons:self.buttons];
    }
}

@end
