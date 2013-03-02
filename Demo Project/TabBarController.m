//
//  TabBarController.m
//  Demo Project
//
//  Created by Peyton Randolph on 3/1/13.
//

#import "TabBarController.h"

@interface TabBarController ()

@end

@implementation TabBarController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Customize appearance
    self.view.backgroundColor = [UIColor colorWithHue:0.f saturation:0.f brightness:0.94f alpha:1.f];
    
    // Customize tab bar
#if defined(__IPHONE_6_0)
    if ([self.tabBar respondsToSelector:@selector(setShadowImage:)])
        [self.tabBar setShadowImage:[UIImage imageNamed:@"Empty.png"]];
#endif
    [self.tabBar setBackgroundImage:[UIImage imageNamed:@"Tab-Bar-Background.png"]];
    [self.tabBar setSelectedImageTintColor:[UIColor colorWithWhite:0.2588f alpha:1.0f]];
    [self.tabBar setSelectionIndicatorImage:[UIImage imageNamed:@"Tab-Bar-Selection-Indicator-Image.png"]];     
    
    // Configure tab bar item text
    for (UITabBarItem *item in self.tabBar.items)
    {
        [item setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithWhite:0.73f alpha:1.0f], UITextAttributeTextColor, nil] forState:UIControlStateNormal];
        [item setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithWhite:0.26f alpha:1.0f], UITextAttributeTextColor, nil] forState:UIControlStateSelected];
        NSString *iconString = [NSString stringWithFormat:@"%@-Icon", item.title];
        NSString *iconSelectedString = [NSString stringWithFormat:@"%@-Selected", iconString];
        [item setFinishedSelectedImage:[UIImage imageNamed:[iconSelectedString stringByAppendingPathExtension:@"png"]] withFinishedUnselectedImage:[UIImage imageNamed:[iconString stringByAppendingPathExtension:@"png"]]];
    }
    
}

@end
