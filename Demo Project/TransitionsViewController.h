//
//  TransitionsViewController.h
//  Demo Project
//
//  Created by Peyton Randolph on 3/2/13.
//  Copyright (c) 2013 Peyton Randolph. All rights reserved.
//

#import "ViewController.h"

#import "MOOMessageSwipeAlert.h"

@interface TransitionsViewController : ViewController

@property (nonatomic, strong) MOOMessageSwipeAlert *alertView;
@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;

- (IBAction)showButtonPressed1:(id)sender;
- (IBAction)showButtonPressed2:(id)sender;
- (IBAction)showButtonPressed3:(id)sender;
- (IBAction)showButtonPressed4:(id)sender;
- (IBAction)showButtonPressed5:(id)sender;

@end
