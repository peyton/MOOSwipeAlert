//
//  MOOMessageSwipeAlert.h
//  MOOSwipeAlert
//
//  Created by Peyton Randolph on 6/13/12.
//

#import "MOOSwipeAlert.h"

@interface MOOMessageSwipeAlert : MOOSwipeAlert

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *message;


- (id)initWithTitle:(NSString *)title message:(NSString *)message delegate:(id<MOOSwipeAlertDelegate>)delegate;

@end
