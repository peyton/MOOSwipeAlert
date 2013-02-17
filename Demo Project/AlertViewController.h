//
//  ViewController.h
//  Demo Project
//
//  Created by Peyton Randolph on 7/10/12.
//


@class MOOMessageSwipeAlert;

@interface AlertViewController : UIViewController
{
    MOOMessageSwipeAlert *_alertView;
    MOOMessageSwipeAlert *_noDisappearAlertView;
    UIButton *_dismissButton;
}

@end
