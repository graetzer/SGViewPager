//
//  SGAppDelegate.m
//  ViewPager
//
//  Created by Simon Grätzer on 30.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SGAppDelegate.h"

#import "SGExampleController.h"
#import "SGViewPagerController.h"
#import "SGAnnotatedPagerController.h"

@implementation SGAppDelegate

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    SGViewPagerController *pagerC = [[SGViewPagerController alloc] initWithNibName:@"SGViewPagerController" bundle:nil];
    pagerC.title = @"UIPageControl";
    
    for (int i = 0; i < 5; i++) {
        SGExampleController *ec = [[SGExampleController alloc] init];
        ec.title = [NSString stringWithFormat:@"Nr. %d", i+1];
        [pagerC addPage:ec];
    }
    
    SGAnnotatedPagerController *annotated = [[SGAnnotatedPagerController alloc] initWithNibName:@"SGAnnotatedPagerController" bundle:nil];
    annotated.title = @"TitleControl";
    
    for (int i = 0; i < 5; i++) {
        SGExampleController *ec = [[SGExampleController alloc] init];
        ec.title = [NSString stringWithFormat:@"Nr. %d", i+1];
        [annotated addPage:ec];
    }
    
    UITabBarController *tabC = [[UITabBarController alloc] init];
    //[tabC setViewControllers:[NSArray arrayWithObjects:pagerC, annotated, nil] animated:NO];
    [tabC setViewControllers:[NSArray arrayWithObjects:annotated, pagerC, nil] animated:NO];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = tabC;
    [self.window makeKeyAndVisible];
    return YES;
}

@end
