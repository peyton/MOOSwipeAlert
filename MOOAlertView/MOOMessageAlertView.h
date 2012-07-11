//
//  MOOMessageAlertView.h
//  MOOAlertView
//
//  Created by Peyton Randolph on 6/13/12.
//

#import "MOOAlertView.h"

@interface MOOMessageAlertView : MOOAlertView

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *message;


- (id)initWithTitle:(NSString *)title message:(NSString *)message delegate:(id<MOOAlertViewDelegate>)delegate;

@end
